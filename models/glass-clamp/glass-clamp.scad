// Slotted glass clamp for the BIQU Magician bed.
// x runs radially: x=0 is the glass edge, glass is at x>0, the bed screw is near x=-15.
// z=0 is the top of the acrylic lobe.
glass   = 3.2;   // 1/8 inch glass
gap_z   = 0.3;   // clearance, glass top to lip underside
base_t  = 1.6;   // tab thickness under the screw head
lip_t   = 1.6;   // lip roof thickness
overhang= 3.0;   // lip reach over the glass edge
gap_x   = 0.4;   // clearance, riser to glass edge
riser_t = 2.0;
w       = 12;    // tab width
slot_c  = -15;   // slot centre = screw distance from the glass edge
slot_l  = 8;     // slot length (travel)
slot_w  = 3.6;   // M3 clearance
tail    = 7;     // tab length behind the slot centre

xe = -gap_x;
zl0 = glass + gap_z;
zl1 = zl0 + lip_t;
back = slot_c - tail;

module clamp() {
    difference() {
        union() {
            translate([back, -w/2, 0]) cube([xe - back, w, base_t]);                 // base
            translate([xe - riser_t, -w/2, 0]) cube([riser_t, w, zl1]);               // riser
            translate([xe - riser_t, -w/2, zl0]) cube([overhang - (xe - riser_t), w, lip_t]); // lip
        }
        // slotted M3 hole
        hull() for (s = [-1, 1])
            translate([slot_c + s * (slot_l - slot_w) / 2, 0, -1]) cylinder(d = slot_w, h = base_t + 2, $fn = 32);
    }
}

clamp();
