# 110 mm reach test

`reach_test_110.stl`: three 2 mm wide rings (80, 100 and 110 mm diameter), 0.6 mm tall (3 layers at 0.2), tied together by three spokes pointing at the towers. About **1.4 g** of PLA, 10–15 minutes.

What it shows: whether the effector reaches 110 mm without the arms or carriages hitting anything, and whether the first layer is even all the way to the edge (a level check of the outer bed). A ring that is thin on one side, or missing, means the edge isn't level there, or the probe calibration didn't cover it.

**Before printing:** in `printer.cfg`, `[delta_calibrate] radius` and the kinematics `print_radius` (if set) limit how far out Klipper allows moves. For a 110 mm circle, `print_radius` must be at least 55. First jog to the edge by hand at a safe height (`G1 Z10`, then e.g. `G1 X0 Y55`, `G1 X47.6 Y-27.5`, `G1 X-47.6 Y-27.5`) and watch for collisions. Keep the glass clamps outside the 110 mm circle.

## Result (glass bed, Klipper)

![Reach test on the glass](images/reach-test-result.jpg)

- **Reach:** all rings and spokes complete. Note that at a 110 mm circle the effector lightly rubs a tower belt, so the safe circle is about 100 mm (see "Future: bigger glass" in docs/reviving-the-magician.md).
- **Bed level: good.** The look is the **same all the way around**, so there's no tilt.
- **First layer too high everywhere:** each 2 mm ring shows separate lines with gaps instead of one solid strip.
- **Messy outer ring at the bottom right, next to a clamp:** the glass may sit higher at that clamp, or the nozzle brushes the clamp's lip. Check the clamp height and its clearance from the 110 mm ring.
- **Stringing** across the open middle: travel over empty space (no infill to comb through). Check Enable Retraction and turn on Retract at Layer Change.

## For the server session: Z offset review

The first layer is uniformly about 0.05 mm too high. Suggested (**ask Daniel before `SAVE_CONFIG`**):

1. Check the current offset: `[probe] z_offset` in printer.cfg (and the `#*#` SAVE_CONFIG block).
2. Either:
   - **Paper test again:** `G28`, `PROBE_CALIBRATE`, `TESTZ Z=-0.05`, then the paper check with Daniel, `ACCEPT`, `SAVE_CONFIG`; or
   - **Live adjust during a first layer:** `SET_GCODE_OFFSET Z_ADJUST=-0.025 MOVE=1` (twice, or until the lines merge into a solid strip), then `Z_OFFSET_APPLY_PROBE`, then `SAVE_CONFIG`.
3. The net change should be about **+0.05 mm on `z_offset`** (a larger z_offset puts the nozzle closer to the bed). Don't go more than 0.1 mm without a test print in between.
4. Verify with `models/calibration-cube` or the reach test: the bottom should be one solid sheet with no lip.
