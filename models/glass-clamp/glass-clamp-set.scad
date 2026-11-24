// Three glass clamps printed on their side: the L profile lies flat in every layer,
// so the lip has nothing to droop over, and the spacing gives each layer time to cool.
use <glass-clamp.scad>;
for (i = [-1, 0, 1])
    translate([0, i * 22, 0])
        rotate([90, 0, 0])            // old y (width) becomes the print height
            translate([0, 0, 6]) clamp();
