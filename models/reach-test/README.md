# 110 mm reach test

`reach_test_110.stl`: three 2 mm wide rings (80, 100 and 110 mm diameter), 0.6 mm tall (3 layers at 0.2), tied together by three spokes pointing at the towers. About **1.4 g** of PLA, 10–15 minutes.

What it shows: whether the effector reaches 110 mm without the arms or carriages hitting anything, and whether the first layer is even all the way to the edge (a level check of the outer bed). A ring that is thin on one side, or missing, means the edge isn't level there, or the probe calibration didn't cover it.

**Before printing:** in `printer.cfg`, `[delta_calibrate] radius` and the kinematics `print_radius` (if set) limit how far out Klipper allows moves. For a 110 mm circle, `print_radius` must be at least 55. First jog to the edge by hand at a safe height (`G1 Z10`, then e.g. `G1 X0 Y55`, `G1 X47.6 Y-27.5`, `G1 X-47.6 Y-27.5`) and watch for collisions. Keep the glass clamps outside the 110 mm circle.
