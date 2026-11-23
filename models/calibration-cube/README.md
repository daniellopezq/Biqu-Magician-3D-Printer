# 10 mm XYZ calibration cube: the reference print

The same small cube is printed on each firmware or hardware change, so results can be compared like for like: first on the stock Smoothieware firmware, later on Klipper. Everything needed to repeat it is below.

## The file

The STL is **not included here**: it is a third-party download and we could not confirm its author or license (the pages we tried to read refused automated access). Fetch it yourself and check that it matches:

| | |
|---|---|
| File name | `xyz-10mm-calibration-cube.stl` |
| Size | 6,884 bytes, binary STL, 136 triangles |
| SHA-256 | `812e9f3b896ad2331693c232fa4fbbf234231ff06ca133e15247e3cadcad849f` |
| Bounding box | 10.0 × 10.0 × 10.0 mm (the model's origin is not at its center; the slicer recenters it) |
| Faces | X, Y and Z embossed on three faces |

It was probably downloaded from one of the Printables "XYZ-10mm Calibration Cube" models ([32539](https://www.printables.com/model/32539-xyz-10mm-calibration-cube) or [279946](https://www.printables.com/model/279946-xyz-10mm-calibration-cube)), but that is unverified. Any 10 mm cube works for a rough comparison; for a strict one, match the hash. If you confirm the license is CC BY or CC0, add the file here with its attribution.

Do not reuse G-code from another printer: slice the STL with your own settings (see the warning in [Reviving a BIQU Magician](../../docs/reviving-the-magician.md#first-print)).

## Settings used (stock Smoothieware, Cura 5.14)

| Setting | Value |
|---|---|
| Printer | Custom FFF, 100 mm round bed, origin at center, G-code flavor Marlin |
| Layer height | 0.2 mm (first layer 0.3 mm) |
| Temperature | 200 °C, bed unheated |
| Speed | 30 mm/s, first layer and walls 15 mm/s |
| Fan | 100% from the first layer |
| Adhesion | skirt, 2 loops |
| Infill | 20% |
| Retraction | Cura default (6.5 mm) |
| Surface | one thin coat of glue stick on the bare acrylic bed |
| Material | grey PLA, 1.75 mm |

The print takes about 7 minutes and uses about 1 g of filament.

## Results

Both cubes from the same STL and slicer profile, in the same grey PLA. **Left: stock Smoothieware. Right: Klipper v0.14.0** (after `DELTA_CALIBRATE` with the temporary probe and a paper-test Z height, see [Klipper on the BIQU Magician](../../docs/klipper.md)).

| | Stock Smoothieware | Klipper |
|---|---|---|
| X × Y × Z measured | about 10 mm on each face (ruler and photos, ±0.3 mm) | looks the same size by eye; not measured yet |
| Top face (Z) | messy: the embossed Z is blobbed and the top lines are rough | **clearly better**: clean Z, even top lines |
| Letters X and Y | crisp | slightly crisper edges |
| Bottom edge | square | **elephant's foot**: the bottom layers flare out, with a small blob at one corner of the Y face |
| Side walls | smooth, even layers | a little more textured: possibly slight over-extrusion or no pressure advance yet |
| Calipers (X, Y, Z) | not measured yet | not measured yet |

**What this says:**
- **Klipper's motion is better.** The top surface improvement is the clearest difference: smoother moves and steadier extrusion where the nozzle changes direction a lot.
- **The first layer is too close on Klipper.** The elephant's foot means the nozzle starts a little low, so the first layers are squished out. The Z height came from a paper test with the probe removed, which is easy to get slightly low.
- **The extrusion isn't tuned yet** on Klipper (no extruder calibration or pressure advance), which fits the textured walls.

**Next tuning steps on Klipper:**
1. **First layer:** raise the nozzle 0.05–0.1 mm. On the next print, baby-step Z up in Mainsail during the first layer until the lines are flat but not squished. Then save it (`Z_OFFSET_APPLY_ENDSTOP` for endstop-based Z, or `Z_OFFSET_APPLY_PROBE` when probing, then `SAVE_CONFIG`). In Cura, "Initial Layer Horizontal Expansion" at −0.1 to −0.2 mm also hides a small elephant's foot.
2. **Extruder:** mark the filament 120 mm above the extruder, extrude 100 mm slowly with the hotend hot, measure what's left, and correct `rotation_distance` for the extruder.
3. **Pressure advance:** run Klipper's tower test (`TUNING_TOWER COMMAND=SET_PRESSURE_ADVANCE PARAMETER=ADVANCE START=0 FACTOR=.005`) and pick the cleanest height.
4. **Recalibrate on glass:** this cube was printed on the acrylic bed. With the 120 mm glass plate fitted, redo the Z height (and ideally `DELTA_CALIBRATE`).
5. **Calipers:** measure both cubes on X, Y and Z, and fill in the table.

![Top face: stock left, Klipper right](../../docs/images/compare-cube-top-z.jpg)
![X face: stock left, Klipper right](../../docs/images/compare-cube-x-face.jpg)
![Y face: Klipper (right) shows the flared bottom and a corner blob](../../docs/images/compare-cube-y-face.jpg)
![Plain face: elephant's foot on the Klipper cube (right)](../../docs/images/compare-cube-blank-face.jpg)
![Back face: walls on both](../../docs/images/compare-cube-back-face.jpg)

Photos of the Smoothieware cube are in [`docs/images/`](../../docs/images/) (`first-print-cube-*.jpg`).
