# Glass clamps

`glass-clamp.scad` / `.stl`: the first version, with a lip 0.3 mm above a 3.2 mm glass. On the ~2 mm glass it left a gap, which was filled with double-sided tape pads. **The tape slides**, so the glass can move.

## v2: no tape, the clamps grip the glass themselves

`glass-clamp-v2-lip18.stl`, `-lip20.stl`, `-lip22.stl`: the same footprint (12 mm wide tab, slotted M3 hole about 15 mm from the glass edge), but:
- **The riser face touches the glass edge.** Slide each clamp inward until it pushes the edge, then tighten. Three clamps pushing inward at 120° lock the glass sideways, so it can't slide.
- **Light downward preload:** the lip underside sits at 1.8 / 2.0 / 2.2 mm above the acrylic. Pick the one just **below** your glass thickness (for ~2.0 mm glass use lip18), so the lip flexes slightly and presses down. A small ridge under the lip tip presses on a line.
- Thicker (2.4 mm) tab, riser and lip for stiffness.
- **Print on its side, exactly as exported** (the profile lies flat, no overhangs, no supports). PLA or PETG, 3 walls, 100 % infill (small part). Print all three at once so each layer has time to cool.

Fit: measure the glass with calipers, print one of the matching size, and test. It should slide over the edge with a light push and hold the glass without rocking. If it's too tight to fit, go up one size.

### Foam-tape versions: `glass-clamp-v2-foam-lip28.stl`, `-foam-lip32.stl`

For the BAZIC 981 double-sided foam mounting tape (thickness not printed on the pack, typically about 1–1.6 mm). The lip sits 2.8 / 3.2 mm above the acrylic, which over ~2.0 mm glass leaves room for the foam squeezed about 20 %. No ridge under the lip; the foam is the contact. The slot is 1 mm longer, so the riser can reach the glass edge. Measure the tape (calipers, or stack 5 layers on a ruler and divide by 5): about 1.0 mm → lip28, about 1.4–1.6 mm → lip32. The riser must still touch the glass edge. That's what stops sliding; the foam only holds down.
