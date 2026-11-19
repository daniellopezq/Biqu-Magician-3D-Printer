# BIQU Magician 3D Printer

Notes, photos and a small tool for reviving a second-hand **BIQU Magician** delta 3D printer: stock Smoothieware on an LPC1768 board, a BIGTREETECH 2.8" touchscreen, and no probe.

## Guides

- **[Reviving a BIQU Magician](docs/reviving-the-magician.md)**: what's inside (with photos), why USB ignores commands and how to fix it, the missing SD card, calibrating the delta with a paper test over USB without a probe, a fan-wiring warning, and probe and Klipper notes.
- **[Replacing the linear bearings](docs/bearing-replacement/README.md)**: rescuing a rusty Magician with seized carriages, step by step with photos ([PDF version](docs/bearing-replacement/biqu-magician-bearing-replacement.pdf)). Key findings:
  - The carriages use **LM8LUU (8 × 15 × 45 mm)** bearings. Two LM8UU end to end work as a substitute.
  - The top housing is **press-fit** on the rods and lifts straight off. Don't remove the feet.
- **[Calibration notes](docs/calibration.md)**: recalibrating after reassembly, over USB with the stock firmware or with Klipper.

## Contents

- `docs/`: guides, setup, calibration and maintenance notes
  - [`docs/images/`](docs/images/): photos of the board, screen, extruder, bed and SD slot
- [`tools/printer_link.py`](tools/printer_link.py): keeps one USB serial connection open (so the board isn't reset between commands) and sends G-code from the command line. It can also print a sliced G-code file. Needs Python 3 and `pyserial`.
- Planned: `firmware/` (firmware builds and configuration), `slicer-profiles/` (slicer settings), `models/` (printable parts and upgrades)

## Quick start (USB)

```
pip install pyserial
python tools/printer_link.py probe COM3                # find the baud rate, identify the firmware
python tools/printer_link.py serve COM3 --baud 115200  # leave running
python tools/printer_link.py send M503                 # in another terminal
```

Unplug the touchscreen's serial cable first, or the printer will ignore USB commands.

## Status

The bearing replacement is done and the printer homes and moves. It has been calibrated over USB with the stock firmware (paper test), the extruder steps/mm checked, and a 10 mm calibration cube printed in PLA over USB (sliced in Cura, glue stick on the acrylic bed) came out true to size with sharp letters. Next: a glass or PEI bed surface, then possibly Klipper.

## License

Guides and photos in `docs/` are licensed [CC BY-SA 4.0](docs/LICENSE).
