# Calibration task for the server session: new clip-on probe (drop10)

**Context:** the zip-tied SS0505A switch has been replaced with a printed clip (`models/probe-mount/probe_clip_drop10.stl`). The same switch is on the same wiring and pin (`^!P1.28`, C/NC). Measured from photos, the roller is **about 4 mm below the nozzle tip**. Every probe offset in `printer.cfg` is now stale.

Daniel does the physical steps (paper, dots, pressing the roller). The server session edits `printer.cfg` and runs the commands. **Ask Daniel before `SAVE_CONFIG`.** No firmware flashing.

## 1. Config edits before probing
```
[probe]
z_offset: 4.0          # placeholder until PROBE_CALIBRATE (was 13.15)
x_offset: 0            # placeholder until the dot method
y_offset: 0
speed: 5
samples: 2
sample_retract_dist: 3

[delta_calibrate]
radius: 45
horizontal_move_z: 10  # was 25; the roller only hangs about 4 mm below the nozzle
speed: 40
```
`RESTART`, then `G28`.

## 2. Switch check
`QUERY_PROBE` with the roller free should give "open", and with Daniel pressing it, "TRIGGERED". If it's inverted, flip the `!` on the pin.

## 3. Trigger margin (safety)
1. Nozzle paper test at the bed centre: note Z (Za).
2. Raise to Z10, move so the roller is over the centre, step down with `G1 Z.. F120` in 0.5 mm steps, checking `QUERY_PROBE`. Note the Z where it triggers (Zt).
3. Zt − Za is the real margin. **It needs to be ≥ 2 mm.** If it's less, stop and tell Daniel (bend the lever slightly or reprint).

## 4. X/Y offsets (dot method, see docs/reviving-the-magician.md)
Mark a dot near the centre. Nozzle over the dot gives X1/Y1, roller over the dot gives X2/Y2. `x_offset = X1 − X2`, `y_offset = Y1 − Y2`. Enter them in `[probe]`, `RESTART`.

## 5. Z offset
`G28`, `PROBE_CALIBRATE`, paper test with `TESTZ`, `ACCEPT`, then (with Daniel's OK) `SAVE_CONFIG`. Expect z_offset around 4 (±1).

## 6. Delta calibration
`G28`, `DELTA_CALIBRATE`, then `SAVE_CONFIG` (with Daniel's OK). Repeat once if the heights spread by more than 0.05 mm.

## 7. Verify
`G28`, `G1 Z0.2` at the centre and at the three tower points about 40 mm out: the paper drag should feel the same everywhere. Print `models/reach-test/reach_test_110.stl` or the calibration cube.

## 8. Unclip before printing
The probe hangs about 4 mm below the nozzle and will hit prints. Remove the clip after calibrating.

After that: pressure advance (`models/pressure-advance/README.md`).
