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

## What is still open

- Extruder direction (`!P0.22`) and steps check with filament loaded.
- Glass bed (3 mm, 120 mm): print clips, refit, run `DELTA_CALIBRATE` again, `SAVE_CONFIG`.
- Raise `print_radius` (now 45) in steps with no-filament dry runs.
- Set `minimum_z_position` back to -5.

## Restoring the stock firmware

`firmware/stock-backup.bin` is a 512 KB read of the stock flash over ISP. It is **not published in this repository** (it is the vendor's build); only its SHA-256 is, in [`firmware/stock-backup.bin.sha256`](../firmware/stock-backup.bin.sha256). Two reads were identical and Code Read Protection was off. It is Smoothieware `~11myvar2` (2018-04-11). Read your own printer's flash the same way before flashing Klipper.

**Limit of the backup:** the first 512 bytes (0x000-0x1FF) could not be read over ISP; they hold the vector table and the boot checksum, and the image has the boot ROM's own words there instead. To restore stock:

1. Replace bytes 0x00-0x1FF of the backup with a rebuilt vector table: initial stack pointer `0x10008000`, the reset vector pointing into the bootloader (0x200 and up), and the checksum word at 0x1C set so the first 8 words sum to zero. A reference is the public Smoothie bootloader at the same address range.
2. Flash with the heater disconnected: `lpc21isp -bin -wipe stock-fixed.bin /dev/ttyUSB0 115200 12000`.

A reconstruction like this is likely to work but is **untested**. For an exact copy, read the flash over the **SWD header** (RST, TCK, TMS; a Pico running debugprobe plus OpenOCD, `target/lpc17xx.cfg`) before any further erasing. Either way the board is hard to brick: the ISP bootloader is in ROM, and BOOT plus SWD always allow reflashing.

Stock values for reference: M665 L146.03 R61.7 Z150, M666 trims 0, M92 X/Y/Z 100, E 395, M301 P22.2 I1.08 D114.
