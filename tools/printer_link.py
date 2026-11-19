"""Talk to a Marlin or Smoothieware printer over USB serial without resetting it between commands.

Opening a serial port resets many printer boards (on the BIQU Magician one of the USB chip's
control lines drives the board's reset), which forgets homing. So one background process
("serve") keeps the port open, and short "send" calls pass G-code to it over a local socket.

    python printer_link.py probe COM3                # try 115200 and 250000, identify the firmware
    python printer_link.py serve COM3 --baud 115200  # keep running in the background
    python printer_link.py send M119 M114            # each argument is one G-code line
    python printer_link.py send G28 M400 --timeout 120
    python printer_link.py print COM3 cube.gcode     # stream a sliced file (stop "serve" first)
    python printer_link.py print COM3 cube.gcode --telemetry temps.csv   # also log hotend temperature
    # while printing: create a file named "stop_print" next to this script to stop cleanly,
    # or "fan_full" to force the fans to 100% (later slicer fan commands below 100% are ignored)

For moves, follow them with M400 so the reply only comes back when the move has finished.
Every line sent and received is appended to printer_log.txt next to this file.
"""

import argparse
import re
import socket
import sys
import time
from datetime import datetime
from pathlib import Path

HOST, PORT = "127.0.0.1", 8765
BAUDS = (115200, 250000)
LOG = Path(__file__).with_name("printer_log.txt")
END = "\x04"  # end-of-reply marker on the local socket


def log(direction, text):
    with LOG.open("a", encoding="utf-8") as f:
        f.write(f"{datetime.now():%Y-%m-%d %H:%M:%S} {direction} {text}\n")


def open_port(port, baud):
    import serial  # pyserial

    ser = serial.Serial(port, baud, timeout=0.2)
    time.sleep(2.5)  # the board may reset on open; let it boot
    banner = drain(ser)
    return ser, banner


def drain(ser, quiet=0.5):
    """Read until the line has been silent for `quiet` seconds."""
    lines, last = [], time.time()
    while time.time() - last < quiet:
        raw = ser.readline()
        if raw:
            line = raw.decode("utf-8", "replace").rstrip()
            lines.append(line)
            log("<", line)
            last = time.time()
    return lines


def is_unsolicited_temp(line, gcode):
    """Temperature reports answering someone else's M105 (e.g. a touchscreen sharing the line)."""
    return line.startswith("ok T:") and not gcode.upper().startswith("M105")


def command(ser, gcode, timeout, on_line=None):
    """Send one line and collect replies until 'ok'. 'busy' messages extend the wait.

    `on_line`, if given, is called with every received line (used for temperature logging)."""
    ser.reset_input_buffer()
    ser.write((gcode.strip() + "\n").encode())
    log(">", gcode)
    lines, deadline = [], time.time() + timeout
    while time.time() < deadline:
        raw = ser.readline()
        if not raw:
            continue
        line = raw.decode("utf-8", "replace").rstrip()
        log("<", line)
        if on_line:
            on_line(line)
        if is_unsolicited_temp(line, gcode):
            continue
        lines.append(line)
        if "busy" in line.lower():
            deadline = time.time() + timeout
        if line.startswith("ok"):
            return lines, True
        low = line.lower()
        if low.startswith("!!") or (low.startswith("error") and "kill" in low):
            return lines, True
    lines.append(f"[no 'ok' within {timeout}s]")
    return lines, False


def probe(args):
    for baud in BAUDS:
        print(f"--- {args.port} at {baud} baud")
        try:
            ser, banner = open_port(args.port, baud)
        except Exception as e:  # port busy, missing driver, etc.
            print(f"cannot open: {e}")
            return 1
        try:
            reply, _ = command(ser, "M115", 5)
            reply += command(ser, "version", 5)[0]  # Smoothieware answers this, not M115
        finally:
            ser.close()
        text = banner + reply
        print("\n".join(text))
        if any("FIRMWARE_NAME" in l or "Smoothie" in l or "Build version" in l for l in text):
            print(f"=== firmware answered at {baud} baud")
            return 0
    print("=== no firmware reply at any baud rate")
    return 1


def serve(args):
    import serial  # pyserial

    ser, banner = open_port(args.port, args.baud)
    print("\n".join(banner))
    srv = socket.socket()
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((HOST, PORT))
    srv.listen(1)
    print(f"serving {args.port}@{args.baud} on {HOST}:{PORT}", flush=True)
    while True:
        conn, _ = srv.accept()
        with conn:
            data = b""
            while not data.endswith(END.encode()):
                chunk = conn.recv(4096)
                if not chunk:
                    break
                data += chunk
            text = data.decode().rstrip(END)
            timeout, _, body = text.partition("\n")
            for gcode in body.splitlines():
                if not gcode.strip():
                    continue
                try:
                    reply, _ = command(ser, gcode, float(timeout))
                except (serial.SerialException, OSError) as e:
                    # Printer switched off and on: reopen, report, and skip the rest of this batch.
                    log("!", f"serial error: {e}")
                    try:
                        ser.close()
                    except Exception:
                        pass
                    try:
                        ser, banner = open_port(args.port, args.baud)
                        note = "[connection lost and reopened: the printer rebooted, home again before moving]"
                    except Exception as e2:
                        note = f"[connection lost, reopen failed: {e2}]"
                    conn.sendall(f"> {gcode}\n{note}\n".encode())
                    break
                conn.sendall((f"> {gcode}\n" + "\n".join(reply) + "\n").encode())
            conn.sendall(END.encode())


def send(args):
    with socket.create_connection((HOST, PORT), timeout=args.timeout * len(args.gcode) + 10) as s:
        s.sendall((f"{args.timeout}\n" + "\n".join(args.gcode) + END).encode())
        buf = b""
        while not buf.endswith(END.encode()):
            chunk = s.recv(4096)
            if not chunk:
                break
            buf += chunk
    sys.stdout.write(buf.decode().rstrip(END))
    return 0


STOP_FILE = Path(__file__).with_name("stop_print")
FAN_FILE = Path(__file__).with_name("fan_full")


def gcode_commands(path):
    """Return [(command, layer)] for a G-code file: comments and blank lines removed, and the
    layer number taken from Cura-style ';LAYER:n' comments (-1 before the first layer)."""
    out, layer = [], -1
    for raw in Path(path).read_text(encoding="utf-8", errors="replace").splitlines():
        if raw.startswith(";LAYER:"):
            try:
                layer = int(raw[7:])
            except ValueError:
                pass
        line = raw.split(";", 1)[0].strip()
        if line:
            out.append((line, layer))
    return out


TEMP_RE = re.compile(r"T:\s*([\d.]+)\s*/\s*([\d.]+)\s*@\s*(\d+)")


class Telemetry:
    """Write hotend temperature, target and heater power to a CSV while printing.

    Smoothie reports 'T:200.1 /200.0 @131' once a second while M109 waits, and on every M105,
    so the heat-up is logged at 1 s resolution and the print itself every `interval` seconds."""

    def __init__(self, path, interval, total):
        self.f = open(path, "w", encoding="utf-8")
        self.f.write("elapsed_s,command,of,layer,temp_c,target_c,power\n")
        self.interval, self.total = interval, total
        self.start, self.last, self.n, self.layer = time.time(), 0.0, 0, -1

    def mark(self, n, layer):
        self.n, self.layer = n, layer

    def on_line(self, line):
        m = TEMP_RE.search(line)
        if m:
            t = time.time() - self.start
            self.f.write(f"{t:.1f},{self.n},{self.total},{self.layer},{m.group(1)},{m.group(2)},{m.group(3)}\n")
            self.f.flush()
            self.last = t

    def due(self):
        return time.time() - self.start - self.last >= self.interval

    def close(self):
        self.f.close()


def temperature(ser, on_line=None):
    reply, _ = command(ser, "M105", 10, on_line)
    for line in reply:
        if "T:" in line:
            try:
                return float(line.split("T:", 1)[1].split()[0])
            except ValueError:
                pass
    return None


def cool_down(ser, below, on_line=None):
    """Keep the fans on until the hotend is below `below` °C, then turn them off.

    On the Magician the heatsink fan shares the switched fan output, and closing the port
    may reset the board (fans off), so the port stays open until the nozzle is cool."""
    command(ser, "M106 S255", 10)
    while True:
        t = temperature(ser, on_line)
        print(f"cooling: {t} °C", flush=True)
        if t is not None and t < below:
            break
        time.sleep(15)
    command(ser, "M107", 10)
    print("fans off", flush=True)


def print_file(args):
    """Stream a G-code file line by line, waiting for 'ok' after each one."""
    cmds = gcode_commands(args.file)
    lines = [c for c, _ in cmds]
    STOP_FILE.unlink(missing_ok=True)
    ser, banner = open_port(args.port, args.baud)
    print("\n".join(banner))
    print(f"printing {args.file}: {len(lines)} commands. Create {STOP_FILE} to stop.", flush=True)
    tele = Telemetry(args.telemetry, args.interval, len(lines)) if args.telemetry else None
    on_line = tele.on_line if tele else None
    start, stopped, fans_locked = time.time(), False, False
    FAN_FILE.unlink(missing_ok=True)
    try:
        for n, (line, layer) in enumerate(cmds, 1):
            if tele:
                tele.mark(n, layer)
                if tele.due() and not line.upper().startswith("M109"):
                    command(ser, "M105", 10, on_line)  # periodic sample between commands
            if FAN_FILE.exists():
                # Live override: fans to 100% now, and ignore later slicer commands that lower them.
                FAN_FILE.unlink(missing_ok=True)
                fans_locked = True
                command(ser, "M106 S255", 10, on_line)
                print(f"fans forced to 100% at command {n} (fan_full file)", flush=True)
            if fans_locked:
                m = re.match(r"M106\s+S(\d+)", line.upper())
                if m and int(m.group(1)) < 255:
                    continue
            if STOP_FILE.exists():
                stopped = True
                print(f"stop requested at command {n}", flush=True)
                for g in ("M104 S0", "M106 S255", "G91", "G1 Z10 F1500", "G90", "M400"):
                    command(ser, g, 30)
                break
            reply, ok = command(ser, line, args.timeout, on_line)
            if not ok or any(r.lower().startswith(("!!", "error")) for r in reply):
                print(f"command {n} '{line}' failed: {reply}", flush=True)
                command(ser, "M104 S0", 10)
                stopped = True
                break
            if n % 200 == 0 or n == len(lines):
                mins = (time.time() - start) / 60
                print(f"{n}/{len(lines)} ({100 * n // len(lines)}%) {mins:.1f} min", flush=True)
        print("stopped" if stopped else "print finished", flush=True)
        cool_down(ser, args.cool_below, on_line)
    finally:
        STOP_FILE.unlink(missing_ok=True)
        if tele:
            tele.close()
        ser.close()
    return 1 if stopped else 0


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("probe")
    a.add_argument("port")
    a.set_defaults(fn=probe)
    a = sub.add_parser("serve")
    a.add_argument("port")
    a.add_argument("--baud", type=int, default=115200)
    a.set_defaults(fn=serve)
    a = sub.add_parser("send")
    a.add_argument("gcode", nargs="+")
    a.add_argument("--timeout", type=float, default=10)
    a.set_defaults(fn=send)
    a = sub.add_parser("print", help="stream a G-code file (opens the port itself: stop 'serve' first)")
    a.add_argument("port")
    a.add_argument("file")
    a.add_argument("--baud", type=int, default=115200)
    a.add_argument("--timeout", type=float, default=300, help="seconds to wait for each 'ok' (M109 heats slowly)")
    a.add_argument("--cool-below", type=float, default=50, help="keep fans on until the hotend is below this")
    a.add_argument("--telemetry", help="write hotend temperature, target and heater power to this CSV")
    a.add_argument("--interval", type=float, default=10, help="seconds between temperature samples while printing")
    a.set_defaults(fn=print_file)
    args = p.parse_args()
    sys.exit(args.fn(args) or 0)


if __name__ == "__main__":
    main()
