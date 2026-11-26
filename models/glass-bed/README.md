# Glass bed: shaped for delta reach (future)

`glass_bed_template.pdf`: a 1:1 printable template (US letter, print at 100 %, check the 100 mm bar). `hex_glass.py` regenerates it.

**Shape:** a truncated triangle (irregular hexagon), not a regular hexagon. A regular hexagon has flats facing both the towers and the gaps, so it can't match the delta's reach. Here the **long sides (86.6 mm) face the towers**, where reach is limited by the belts, and the **short sides (52 mm) sit between the towers**, where the effector reaches farther. That's six straight cuts, which a glass shop does cheaply.

**Preliminary numbers:** Rt = 55 (centre to tower sides: the measured ~50 limit + 5) and Rg = 65 (centre to gap sides: an estimate). It's 140 mm corner to corner. **Measure the reach between the towers, check that the base plate supports the corners, then rerun the script** before ordering. Clamps go on the tower sides. See "Future: bigger glass" in docs/reviving-the-magician.md.
