# Tower calibration by paper test (Klipper, 2026-11-26)

Done after the glass clamps were replaced (the printer was also laid on its side for that work). The bed read about 0.3 mm low at the centre, plus a tilt. What moved was not established.

## Method
- Probe clip **off** (its roller hangs below the nozzle), cold clean nozzle, one paper strip.
- Spots: centre (0, 0), A (-26, -15), B (26, -15), C (0, 30), then the centre again. If the two centre readings differ by more than about 0.05 mm, look for looseness before changing anything.
- The person only reports the feel (free / drag / tight). Whoever drives the printer picks the height: straight `G1 Z` moves, big steps first, fine steps near contact.
- Solve the three `position_endstop` values together with Klipper's delta geometry (all four spots, drag = Z 0). **Raising a tower's value brings the nozzle closer to the bed near that tower.** The radius was left alone.

## Result

| Spot | Round 1 | Round 2 |
|---|---|---|
| Centre | -0.30 (recheck -0.25) | 0.00 (recheck: very faint drag at 0.025) |
| A | -0.40 | 0.00 |
| B | -0.10 | 0.00 |
| C | -0.30 | about +0.05 (readings scattered 0 to +0.10) |

| `position_endstop` | Before | After |
|---|---|---|
| A (`stepper_a`) | 160.7355 | **161.2497** |
| B (`stepper_b`) | 161.6799 | **161.6376** |
| C (`stepper_c`) | 159.3585 | **159.6877** |

One round of changes was enough. `klipper/printer.cfg` has the new values.

## First-layer check
Four 12 mm squares on the calibration spots (0.3 mm first layer, 0.46 mm lines, PrusaSlicer, no skirt).

1. First run: A printed **first** after a 5 mm purge. Its outline was missing and the lines stayed separate. The other three were good.
2. Second run: A printed **last** after a 14 mm purge, with **no bed or Z change**. A came out good.

So the first-run failure was the nozzle starting partly empty, not bed height or a moved clamp. The PrusaSlicer files end with 6.5 mm of retraction plus 3 mm in the end G-code (**9.5 mm**), which the next start does not put back. A 5 mm purge never gets filament out; 14 mm leaves only about 4.5 mm. Files with a skirt are covered (the vise small-parts file uses 26.8 mm on two skirt loops). **To do:** for files without a skirt, purge at least 9.5 mm more than the priming needs. The slicer profile has not been changed yet.

After this, the SolderMate small-parts plate printed to completion (1 h 34 min). The base (4 h 12 min, inside the 105 mm circle), screw and repaired slider followed, and the vise is assembled. See [the SolderMate write-up](prints/soldermate-short-vise.md).
