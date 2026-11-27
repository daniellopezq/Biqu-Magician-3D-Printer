# Klipper on the BIQU Magician

How this printer was moved from stock Smoothieware to Klipper (v0.14.0) on 2026-11-22/23, what was learned, and how to go back. The final config is [`klipper/printer.cfg`](../klipper/printer.cfg). Board details and photos are in [Reviving a BIQU Magician](reviving-the-magician.md); the stock settings are in [stock-firmware-dump.md](stock-firmware-dump.md).

> **Safety first: the heater heats by itself in ISP mode.** With the BOOT jumper fitted and the board powered, nothing drives the heater pin (P2.7) and the nozzle climbed from 27 to 115 °C in about a minute (and past 209 °C when left longer). **Disconnect one heater wire before any ISP step** (flash, backup read, chip detect), and keep a hand on the power switch.

## Setup

| Part | What |
|---|---|
| Host | Ubuntu 24.04 PC, USB to the printer (CP2102, `/dev/ttyUSB0`) |
| Software | Klipper v0.14.0, Moonraker, Mainsail (installed with KIAUH; Mainsail on port 8100 because 80 was taken) |
| MCU | LPC1768, 12 MHz crystal, 100 MHz core |
| Serial | UART0 P0.3/P0.2 through the CP2102, **250000 baud** |
| Touchscreen | unplugged: it shares the serial line |

`ModemManager` was masked (`sudo systemctl mask ModemManager`), since it probes serial ports. The user is in `dialout`.

## Build settings (`make menuconfig`)

Saved as [`klipper/klipper-menuconfig.txt`](../klipper/klipper-menuconfig.txt).

- Micro-controller: **LPC176x**, processor **LPC1768 (100 MHz)**
- Bootloader offset: **No bootloader** (application at 0x0)
- Communication: **Serial (on UART0 P0.3/P0.2)**, baud **250000**
- **GPIO pins to set at micro-controller startup: `!P2.7,P2.4`**

The last one matters. At reset the LPC pins float with pull-ups, which turns the heater on until the host connects. This line drives the heater low and the fans on from the first microseconds of boot, with no host involved. Without it, the printer could heat unattended whenever it is powered and Klipper is not running.

## Flashing

1. Stop Klipper (`sudo systemctl stop klipper`) so it does not hold the serial port.
2. **Disconnect a heater wire.**
3. Power off, fit the **J11 "BOOT"** jumper, power on. Check with a single `?` byte at 115200: the chip answers `Synchronized`.
4. `lpc21isp -bin -verify out/klipper.bin /dev/ttyUSB0 115200 12000`
5. **Sector 0 always ends with `COMPARE_ERROR`.** That is expected: the first 512 bytes cannot be read back over ISP (the boot ROM covers them). Read the flash back and compare from 0x200 on; it matches.
6. Power off, **remove the jumper**, power on. The fans run at once (startup pins).
7. Point `[mcu] serial:` at `/dev/serial/by-id/usb-Silicon_Labs_CP2102_...` with `baud: 250000`, restart Klipper, and it connects.

Opening the serial port resets this board (DTR drives reset), which is normal.

## Pin map and what was verified

| Function | Klipper | Status |
|---|---|---|
| Steppers A / B / C step | `P2.0` / `P2.1` / `P2.2` | works |
| Direction | `P0.5`, `P0.11`, `P0.20` (**not** inverted: Smoothie's `!` was wrong here) | verified with `FORCE_MOVE` |
| Enable | `!P0.4`, `!P0.10`, `!P0.19` | verified |
| Endstops (max, homing up) | `^P1.25`, `^P1.27`, `^P1.29` | verified with `QUERY_ENDSTOPS` |
| Probe (SS0505A, C+NC) | `^P1.28` | verified: open at rest, TRIGGERED when pressed |
| Heater / thermistor | `P2.7` / `P0.24`, EPCOS 100K | reads room temperature, holds 200 °C |
| Heatsink + part fans (one output) | `P2.4` as a `[heater_fan]` | verified at 50 and 200 °C |
| Extruder step / dir / enable | `P2.3`, `!P0.22`, `!P0.21` | **direction not tested yet** |

Not yet verified: that 16 microsteps with `rotation_distance: 32` gives exact distances (a ruler check of a 10 mm move is still to do; the probe and paper results agree roughly), and the extruder direction.

## The fan

All three fans, including the heatsink fan above the nozzle, share the switched output P2.4. In Klipper that fan is a `[heater_fan]` with `fan_speed: 1.0` and `shutdown_speed: 1.0`. It turns on as soon as the heater is switched on (not only at 50 °C) and stays on until the nozzle has cooled. `M106`/`M107` are overridden by do-nothing macros so a slicer cannot switch it off. There is no adjustable part cooling: every fan runs at 100% while the hotend is active.

## Calibration (acrylic bed)

1. `QUERY_ENDSTOPS` and `QUERY_PROBE` pressed by hand, then `FORCE_MOVE` per tower, then `G28` at 20 mm/s.
2. `PROBE` from Z 10 found the bed about 33 mm below Klipper's Z 0: the real frame height is about 166 mm, far from the placeholder `position_endstop: 135` (which is deliberately low so the first moves stop above the bed).
3. `minimum_z_position` was set to -80 temporarily so the probe could reach the bed. **Set it back to -5.**
4. `DELTA_CALIBRATE` (7 points, radius 20 mm, `horizontal_move_z: 25` which must be at least the probe `z_offset`) gave the delta radius 63.13, tower angles 212.77 / 328.71 / 90 and endstops 165.89 / 167.29 / 164.68. Saved with `SAVE_CONFIG`.
5. The probe hangs about 14.9 mm under the nozzle, so a paper test (`MANUAL_PROBE`, `TESTZ`, `ACCEPT`) with the probe removed set the real height: light drag at Z 1.876 at the centre, so all endstops were lowered by 1.876 and the probe `z_offset` set to 14.88.
6. Paper checks at 20 mm from the centre: centre -0.01, front-left -0.17, front-right +0.02, back +0.02. Front-left's endstop was raised 0.3 mm; afterwards front-left was about +0.02 and the centre +0.08, so the bed is flat to about 0.06 mm.

The probe is a temporary SS0505A roller switch zip-tied to the nozzle block, roughly 10 mm toward the front (`y_offset: -10`) and 13-15 mm below the tip. **Remove it before printing**, and before heating for long periods (it sits against the heater block).

## Heater test

With the heatsink fan confirmed, `M104 S50` reached 50 °C in 21 s, and `M104 S200` reached 200 °C in about 100 s, settling at 200-201 °C with the stock PID values (P22.2 I1.08 D114). Run `PID_CALIBRATE HEATER=extruder TARGET=210` later if wanted.

## Glass bed and the remounted probe (2026-11-23)

The 120 mm glass plate now sits on the acrylic, held by three printed slotted clamps ([`models/glass-clamp/`](../models/glass-clamp/)). The probe was remounted along the way, and these numbers came out of it:

- **Probe offsets:** the roller is **10 mm toward tower C** (`x_offset: 0`, `y_offset: 10`) and hangs **13.15 mm below the nozzle** (`z_offset`). The ruler estimate of 9-10 mm was wrong; the paper test gave the real value. The roller faces A and B (the front), and the switch body points at C.
- **Towers:** A = front-left (210 deg), B = front-right (330 deg), C = back (90 deg). Checked by touching each endstop.
- **Method:** `G28`, `DELTA_CALIBRATE` (radius 45), `SAVE_CONFIG`, then a cold-nozzle paper test at the centre (`MANUAL_PROBE`, `TESTZ`, `ACCEPT`) to set the true Z, applied by hand to the three endstops. `Z_OFFSET_APPLY_ENDSTOP` stages nothing after a plain `MANUAL_PROBE`.
- **Edge check (paper, r = 40):** A -0.36, B +0.15, C +0.05, front -0.30 mm against the centre. The glass is not clamped down firmly, so part of that tilt may be the glass seating. All three endstops were trimmed (+0.54 / -0.18 / -0.17) and later lowered by 0.05 and 0.04 for the first layer.
- **Reach:** `print_radius` is now 66. The arms can reach about 83 mm (arm horizontal), so a 130 mm bed looks possible with a bigger glass.

First layer on the glass: 215 C for layer 1, then 205 C, 15 mm/s, thin glue stick. The bottom still shows slightly separate lines, so a little more Z may follow.

## Slicing with Cura (Windows) (2026-11-25)

PrusaSlicer CLI on the host still works ([`klipper/slicer/magician-pla-cube.ini`](../klipper/slicer/magician-pla-cube.ini)); Cura 5.x on a Windows laptop is the everyday slicer. First Cura prints (a tab gauge, ~28 min, then a larger v2) came out fine.

**Machine (Custom FFF printer):** 110 x 110 mm, height 140, **elliptic** plate, **origin at center**, no heated bed, G-code flavor Marlin, nozzle 0.4, filament 1.75.

Start G-code:

```
G21
G90
M82
G28
M104 S{material_print_temperature_layer_0}
M109 S{material_print_temperature_layer_0}
G92 E0
G1 Z5 F1500
```

End G-code: `M104 S0`, `G91`, `G1 E-3 F1800`, `G1 Z20 F1200`, `G90`, `G1 X0 Y0 F3000`, `M84`.

**Profile (same as the PrusaSlicer one):** layer 0.2, first layer 0.3, line width 0.4, 2 walls, 4 top/bottom, 20 % grid; 205 °C (first layer 215), plate 0; walls 15 mm/s, infill 30, first layer 15, travel 60 (100 made a messy first layer); retraction 6.5 mm at 25 mm/s (Bowden); fan 100 % (Cura's M106 is ignored by a macro anyway: the only fan output is the heatsink fan); skirt 2 lines.

**Sending files:** Cura Marketplace plugin *Moonraker Connection*, address `http://<host>:7125` (no API key from a `trusted_clients` subnet). Turn off "start print after upload" and start the print from Mainsail: starting through Moonraker has hung before. Saving the .gcode and dragging it into Mainsail works too.

## Webcam (2026-11-25)

Logitech C505 (720p, fixed focus, needs about 30 cm or more to be sharp), streamed with ustreamer as MJPEG on port 8080 ([`klipper/ustreamer.service`](../klipper/ustreamer.service)), added to Mainsail as webcam "Printer" (`/?action=stream`, snapshot `/?action=snapshot`). The webcam entry lives in Moonraker's database (added with `POST /server/webcams/item`), not in `moonraker.conf`.

**Position for print monitoring:** in front of the gap between towers A and B, about 10-15 cm above the bed, looking down at the glass. Bed level or beside a tower hides flat prints; too close cuts the nozzle off and goes out of focus; from above the effector hides the part. Light from the front avoids glare on the glass. The BIQU logo under the clear glass makes flat first layers hard to see. At this distance it is about 0.2 mm per pixel: good for catching failures (spaghetti, a part coming loose), not for judging surface quality. Failure detection: self-hosted Obico (2026-11-26), see below.

## Obico failure detection (2026-11-26)

- **Server:** [obico-server](https://github.com/TheSpaghettiDetective/obico-server) in Docker on the Klipper host (`sudo docker compose up -d --build`, web UI on port 3334). Built with no print running: the local image build pins all CPU threads and Klipper is timing-sensitive. Opening it by LAN IP gave a 500 until the address was added as a site: `docker compose exec web ./manage.py site --add <host>:3334`. The install creates an admin `root@example.com`; set its password with `./manage.py changepassword root@example.com`.
- **Printer side:** [moonraker-obico](https://github.com/TheSpaghettiDetective/moonraker-obico) `./install.sh`, server `http://<host>:3334`, linked with the 6-digit code ("Klipper generic - self-installed"). It adds `[include moonraker_obico_macros.cfg]` to `printer.cfg` and `[include moonraker-obico-update.cfg]` to `moonraker.conf`. In `moonraker-obico.cfg`, `[tunnel] dest_port = 8100` (Mainsail's port).
- The installer runs `apt-get update` and stops on any broken apt source (here an old Plex repo).
- Without Janus / a hardware H.264 encoder the Obico web view refreshes about every 10 s; detection uses those snapshots. Pausing uses Mainsail's PAUSE, which parks a delta at the back (y = max - 5) after a 2 mm lift.

## Pressure advance (2026-11-25)

**`pressure_advance: 0.50`** in `[extruder]`. Tuned with Klipper's `square_tower.stl` sliced by PrusaSlicer ([`klipper/slicer/magician-pa-tower.ini`](../klipper/slicer/magician-pa-tower.ini): 100 mm/s walls, 0.2 mm layers, 215 C; the start G-code runs `SET_VELOCITY_LIMIT SQUARE_CORNER_VELOCITY=1 ACCEL=500` and `TUNING_TOWER COMMAND=SET_PRESSURE_ADVANCE PARAMETER=ADVANCE START=0 FACTOR=.020`).

- Corners showed no bulging even at PA 0, so the tower only gave an upper limit: dotted gaps after the corner from about 33-35 mm on the worst corner (PA 0.66-0.70), 40 mm on the best (a delta drives each corner with a different motor mix, so go by the worst).
- 0.50 leaves a margin under that limit (photo-and-ruler readings are good to 1-2 mm) and still cuts ooze. Bulging corners: try 0.55-0.60; gaps after corners: 0.45.
- Photos and the first 40 mm attempt (too slow in Cura, effect invisible: the wall speeds themselves must be high) are in [`models/pressure-advance/`](../models/pressure-advance/README.md).
- After a tuning tower, `RESTART` before the next print: the test leaves PA near 1.0, accel 500 and square corner velocity 1.

## Tower calibration after the clamp change (2026-11-26)

Endstops are now A 161.2497, B 161.6376, C 159.6877, set by paper test: see [tower calibration](tower-calibration.md).

## What is still open

- Bigger glass (150 mm mirror, [tray adapter 2713277](https://www.thingiverse.com/thing:2713277)) and an accelerometer for input shaping.
- A printed probe bracket (the nozzle shroud has a rail that looks like the original mount), then re-measure the probe offsets with it fitted.
- Probe-based edge check with `bed_mesh`, once the glass is firmly seated.
- Obico: confirm "pause on failure" works on a real print.

## Restoring the stock firmware

`firmware/stock-backup.bin` is a 512 KB read of the stock flash over ISP. It is **not published in this repository** (it is the vendor's build); only its SHA-256 is, in [`firmware/stock-backup.bin.sha256`](../firmware/stock-backup.bin.sha256). Two reads were identical and Code Read Protection was off. It is Smoothieware `~11myvar2` (2018-04-11). Read your own printer's flash the same way before flashing Klipper.

**Limit of the backup:** the first 512 bytes (0x000-0x1FF) could not be read over ISP; they hold the vector table and the boot checksum, and the image has the boot ROM's own words there instead. To restore stock:

1. Replace bytes 0x00-0x1FF of the backup with a rebuilt vector table: initial stack pointer `0x10008000`, the reset vector pointing into the bootloader (0x200 and up), and the checksum word at 0x1C set so the first 8 words sum to zero. A reference is the public Smoothie bootloader at the same address range.
2. Flash with the heater disconnected: `lpc21isp -bin -wipe stock-fixed.bin /dev/ttyUSB0 115200 12000`.

A reconstruction like this is likely to work but is **untested**. For an exact copy, read the flash over the **SWD header** (RST, TCK, TMS; a Pico running debugprobe plus OpenOCD, `target/lpc17xx.cfg`) before any further erasing. Either way the board is hard to brick: the ISP bootloader is in ROM, and BOOT plus SWD always allow reflashing.

Stock values for reference: M665 L146.03 R61.7 Z150, M666 trims 0, M92 X/Y/Z 100, E 395, M301 P22.2 I1.08 D114.
