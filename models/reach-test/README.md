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

## Second run: rings plus four first-layer squares

![Reach rings with four first-layer squares (centre and three around)](images/reach-test-2-squares.jpg)

- **The four squares look alike:** same line spacing at the centre and at all three outer positions, so the **bed is level** (confirms the first run).
- **Lines still visible with small gaps** in the squares and rings. The first layer is still slightly high everywhere. If this run already had a Z change, lower it about another 0.02–0.03. If not, the 0.05 suggestion above stands.
- **Broken arcs outside the 110 mm ring** (skirt/outer pass) are segmented and incomplete near the edge: beyond the reliable area (glass edge or reach limit). Keep parts within about 100 mm, as noted.
- Some stringing again across open areas (travel over empty bed).

## Third run

![Third run, top](images/reach-test-3-top.jpg)
![Third run, close-up of the squares](images/reach-test-3-close.jpg)
![Third run, overview with towers and clamps](images/reach-test-3-overview.jpg)

- **Better than run 2:** the squares are more solid (lines closer together, fewer gaps), and the rings and spokes are cleaner, with less stringing.
- **Still level:** all four squares look alike.
- Lines are still slightly visible in the squares. Close to right, with maybe 0.01–0.02 mm left; fine-tune live with `SET_GCODE_OFFSET Z_ADJUST=-0.01 MOVE=1` on the next print, then `Z_OFFSET_APPLY_PROBE` (ask Daniel before `SAVE_CONFIG`).
- The outer arcs past the 110 mm ring are still broken and segmented, beyond the reliable reach. That confirms the ~100 mm working circle.
- The clamps are clear of the printed area.

## Real-print 110 mm test: `bar_110.stl`

A flat bar 110 × 20 × 3 mm with quality features along its length, so you can see whether quality changes from the centre to the far end:
- **raised numbers 0–10** every 10 mm (cm from the gap end), and **GAP** / **TWR** labels at the ends;
- a **raised zigzag line** along one side: sharp corners all the way, which shows pressure advance and corner quality;
- **3 mm holes every 20 mm** along the other side: roundness (a hole going oval shows skew/backlash at that position).

**Geometry note:** on a delta, any straight line through the centre runs from a **gap** (30°, 150°, 270°) to a **tower** (the opposite direction). So a 110 mm part centred on the bed reaches 55 mm toward a tower, where the effector rubs. **Shift it toward the gap instead:** for example along Y, from Y = −60 (front gap, 270°) to Y = +50 (toward tower C).

1. Jog check first (probe clip off): `G28`, `G1 Z10 F3000`, `G1 X0 Y-60`, `G1 X0 Y50`. If nothing rubs, go ahead.
2. In Cura, rotate the bar so its long axis runs front to back, **GAP** end to the **front**, and set its position so it spans Y −60 … +50 (centre Y = −5 in printer coordinates). Check in the preview which way Cura's Y points.
3. Print with the normal profile (2 walls, 20 % infill, 4 top/bottom layers). It's a realistic print with solid layers, walls and infill.
4. Check: ends complete, equal thickness along the length (a ruler or calipers at both ends and the middle), and the numbers are spaced 10 mm, the zigzag corners look the same along the bar, and the holes stay round and equal (check one with a 3 mm drill bit).

### `bar_105.stl`

The same test bar at **105 mm**, a safer step before 110. Same features (numbers 0–10 from the gap end, zigzag, 3 mm holes, GAP/TWR labels). Place it **GAP end to the front, spanning Y −57.5 … +47.5** (centre Y = −5). Jog check first: `G1 Z10`, `G1 X0 Y-57.5`, `G1 X0 Y47.5`.

## Decision (bar tests)

- **The 110 mm bar printed cleanly** when shifted toward the front gap (Y −60 … +50).
- **105 mm is the new default** print diameter (centred parts).
- **110 mm only for parts shifted toward a gap** (30°, 150°, 270°), never centred.
- **Cura bed: 108 mm elliptic, origin at centre.** Cura keeps a small margin inside the edge, so centred parts end up about 105 mm. A part pushed to Cura's edge toward a tower can still reach about 54 mm from the centre, close to the ~55 mm belt rub, so keep big parts centred or toward a gap.

## First-layer squares, run 4

![Four first-layer squares](images/first-layer-squares-4a.jpg)
![Close-up](images/first-layer-squares-4b.jpg)

- **Three squares (centre, back, right) are good:** solid, lines fused, even. The first-layer height is now about right at these spots.
- **The front-left square is clearly different:** separate, rounded lines with gaps (too high there) and a blob with a curl at its corner. Front-left is toward **tower A**. Either the bed is slightly low on that side, or (more likely, since earlier runs were even) the **glass moved or is lifted near the front-left clamp** (the old foam tape sliding). Re-check after fitting the v2 clamps. If it persists, run `DELTA_CALIBRATE` again.
- Stringing on travel between squares: normal for a sparse test. Retraction can be tuned later.

## First-layer squares, run 5

![Four first-layer squares, run 5](images/first-layer-squares-5.jpg)

- **The front-left square is much better** than run 4: solid, with lines fused. The bed is even again on that side.
- **Back and right squares are good.** The centre square is good, with some strings and a curl on top (travel).
- Overall the first layer is close to right and consistent across the bed. The remaining issue is **stringing on travel moves**: try retraction 6.5 → 7 mm, or 5 °C cooler (200 °C), and enable "Retract at Layer Change".

## Corrections and later findings (2026-11-26)
- **Do not use the "Z offset review" steps above.** On this delta, `[probe] z_offset`, `PROBE_CALIBRATE` and `Z_OFFSET_APPLY_PROBE` do not change print height. Use `Z_OFFSET_APPLY_ENDSTOP` after a live adjustment, or edit all three `position_endstop` values (raise = nozzle closer). `SAVE_CONFIG` only after the print has ended.
- The first 110 mm test (Cura) had **two layers** and fatter first-layer lines; the later PrusaSlicer test had one layer, so they were not like for like. Broken outer arcs do not by themselves show a reach limit, because parts of the 80 mm ring also pulled loose.
- The 110 bar that printed was placed at **Y -58.5 to +51.5** with the two front corners trimmed to a 58.5 mm radius. At Y -60 the corners of the 20 mm wide bar would be 60.8 mm out, past a centred 120 mm glass.
- `bar_105.stl`: Y -56 to +49 keeps the front corners at 56.9 mm and the back corners at 50.0 mm.
- A 108 mm Cura bed lets parts reach 54 mm toward a tower, beyond the 52.5 mm (105 mm circle) default.
- **Squares run 4:** the v2 clamps were already fitted. The front-left failure was nozzle priming, not height (see [tower calibration](../../docs/tower-calibration.md)). "Retract at Layer Change" is a Cura setting; the squares were sliced with PrusaSlicer.
