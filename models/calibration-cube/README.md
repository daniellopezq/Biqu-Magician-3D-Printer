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

| | Stock Smoothieware | Klipper |
|---|---|---|
| X × Y × Z measured | about 10 mm on each face (ruler and photos, ±0.3 mm) | not tested yet |
| Letters | X, Y and Z crisp and readable | |
| Corners and walls | square, no curling | |
| Top face | the Z on top is messy (typical for 10 mm cubes: each top layer takes seconds) | |
| Calipers (X, Y, Z) | not measured yet | |

For a finer comparison, measure the three sides with calipers and write them in the table. A minimum layer time of about 10 seconds in the slicer helps the top face of small parts.

Photos of the Smoothieware cube are in [`docs/images/`](../../docs/images/) (`first-print-cube-*.jpg`).
