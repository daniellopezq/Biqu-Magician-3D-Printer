"""Talk to a Marlin or Smoothieware printer over USB serial without resetting it between commands.

Opening a serial port resets many printer boards (on the BIQU Magician one of the USB chip's
control lines drives the board's reset), which forgets homing. So one background process
("serve") keeps the port open, and short "send" calls pass G-code to it over a local socket.

    python printer_link.py probe COM3                # try 115200 and 250000, identify the firmware
    python printer_link.py serve COM3 --baud 115200  # keep running in the background
    python printer_link.py send M119 M114            # each argument is one G-code line
    python printer_link.py send G28 M400 --timeout 120

For moves, follow them with M400 so the reply only comes back when the move has finished.
Every line sent and received is appended to printer_log.txt next to this file.
"""

import argparse
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


def command(ser, gcode, timeout):
    """Send one line and collect replies until 'ok'. 'busy' messages extend the wait."""
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
    args = p.parse_args()
    sys.exit(args.fn(args) or 0)


if __name__ == "__main__":
    main()
