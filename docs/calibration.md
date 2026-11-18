# Calibrating the BIQU Magician after reassembly

After replacing bearings, or anything else that changes the towers, a delta printer needs recalibrating. This page covers two routes: the **stock firmware over USB**, and **switching to Klipper**.

> **Safety:** stay at the printer with a hand near the power switch whenever it moves under computer control. Start with the nozzle well above the bed and lower it in small steps.

> **What we found on a stock unit** (details in [Reviving a BIQU Magician](reviving-the-magician.md)): the stock firmware is **Smoothieware, not Marlin**. The USB chip is a **CP2102** (Silicon Labs CP210x driver) at **115200** baud. **USB ignores commands until the touchscreen's serial cable is unplugged.** `G33` doesn't exist in Smoothie, and `G32` needs a probe the Magician doesn't have. **`M500` can't save** without an SD card on the mainboard. `M666` trims must be ≤ 0. The steps below still apply, with those differences.

## Connecting over USB

- Use a USB cable from the printer to a computer.
- If no serial port appears, install the **CH340 USB-serial driver**. Windows shows the printer as a COM port in Device Manager; Linux shows `/dev/ttyUSB0` and usually has the driver built in.
- Connect with a terminal program such as **Pronterface** (Printrun, free), or a short Python script using `pyserial`. Try **115200** baud first, then **250000**.

## Route 1: stock firmware (Marlin-style G-code)

Commands like these are standard in Marlin. Check what your firmware supports, since a vendor build may not include all of them.

| Step | Command | What it does |
|---|---|---|
| 1 | `M115` | Reports the firmware name and version |
| 2 | `M503` | Prints current settings. **Save this output as a backup first.** |
| 3 | `G28` | Homes all three towers |
| 4 | `G33` | Delta auto-calibration (only if the firmware supports it and a probe is set up) |
| 4 (alt) | `G29` | Bed leveling routine |
| 5 | `M666 X.. Y.. Z..` | Endstop offsets per tower (evens out tower heights) |
| 6 | `M665 R..` | Delta radius (fixes a dome or bowl-shaped nozzle path) |
| 7 | `M500` | Saves settings to EEPROM |

**Manual check (paper test):**

1. `G28` to home.
2. Move to the bed center at a safe height, then lower in small steps until a sheet of paper drags slightly under the nozzle. Set this as the Z offset.
3. Repeat the paper test near each of the three towers.
   - **One tower higher or lower:** adjust its endstop offset (`M666`), or its endstop-trigger screw (see Step 12 in the [bearing replacement guide](bearing-replacement/README.md#step-12-test-and-calibrate)).
   - **Center differs from the edges:** adjust the delta radius (`M665 R`).
4. Repeat until all four points give the same light drag, then save with `M500`.

## Route 2: Klipper

Klipper does most of the delta calibration automatically and is much easier to tune. It runs on a host computer (any old PC or laptop running Linux, or a Raspberry Pi) connected to the printer by USB.

1. Install Debian or Ubuntu Server on the host.
2. Install Klipper, Moonraker and a web interface (Mainsail or Fluidd) with [KIAUH](https://github.com/dw-0/kiauh).
3. Identify the printer's mainboard chip (open the electronics housing and photograph the board), build the Klipper firmware for it, and flash it.
4. Write `printer.cfg` for a delta: `kinematics: delta`, arm length, delta radius, endstops and steps.
5. Run `DELTA_CALIBRATE`, then `SAVE_CONFIG`.
6. Optional: input shaping with an ADXL345 accelerometer on an extra MCU (for example a Raspberry Pi Pico) for cleaner, faster prints.

Your config lives in one file (`printer.cfg`), so moving to a different host later is just reinstalling Klipper and copying the file.

## Using an AI coding assistant

An AI coding assistant running on the computer the printer is plugged into (for example Claude Code) can find the serial port, send the G-code above, and explain each setting. Have it **confirm before every downward move**, and do the paper tests yourself, because only a person can feel the drag.
