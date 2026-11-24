// Removable Z-probe bracket for the BIQU Magician (Steren SS0505A roller-lever microswitch).
//
// Two ways to mount it:
//   "clip": a saddle that pushes onto the raised band around the effector. Lips sit over and under
//           the band, and two windows drop over the two small square lugs on it (the OEM snap point
//           for a shroud), so it can't slide sideways. Nothing to drill, pulls straight off.
//   "fan":  a tab clamped under one existing M3 fan screw, with two lips hugging the corner of
//           the fan frame so it can't swing around the screw.
// Both carry the same plate: the switch is held by two M2 screws in vertical slots, so the roller
// height can be set 3-5 mm below the nozzle tip.
//
// Coordinates (all mm). Origin = nozzle tip.
//   +Y = straight out from the nozzle, through the middle of the effector face that carries the lugs
//   +Z = up
//   +X = along that face (clockwise seen from above)
//
// Every dimension marked GUESS was estimated from photos. Measure it (see README.md) and edit it here.
// Render one part: openscad -D 'part="clip"' -o probe_mount_clip.stl probe_mount.scad
//   part = "assembly" | "assembly_fan" | "clip" | "fan" | "test"

part = "assembly";

/* ---------- Switch: Steren SS0505A (subminiature roller lever) ---------- */
sw_l          = 20;    // body length (along X)
sw_h          = 10;    // body height, terminal face to lever face
sw_t          = 6.4;   // body thickness (along Y)
sw_hole_d     = 2.3;   // mounting hole diameter
sw_hole_pitch = 9.5;   // centre to centre of the two holes
sw_hole_end   = 5.25;  // roller-end of the body to the nearer hole centre ((20-9.5)/2 if centred)
sw_hole_act   = 7.1;   // lever face of the body to the hole centres (GUESS: typical is ~2.9 from the terminal face)
roller_drop   = 6.0;   // lever face to the bottom of the roller, lever at rest (GUESS)
roller_in     = 2.5;   // roller-end of the body to the roller centre, along X (GUESS)
roller_d      = 5.0;   // roller diameter
term_room     = 5.0;   // terminals + solder above the terminal face (wires bend toward the plate)

/* ---------- Where the roller should end up ---------- */
roller_below  = 4;     // roller bottom below the nozzle tip, mid-slot (target 3-5)
roller_x      = 0;     // roller centre along X (0 = straight out from the nozzle)
sw_dir        = -1;    // switch body runs from the roller toward +X (1) or -X (-1); -1 keeps it away from
                       // the hotend cable and rod end that sit on the +X side in the side photo
travel        = 8;     // slot travel, +-4 mm around roller_below
face_angle    = 90;    // direction the lug face points, in printer degrees (tower C/back = 90,
                       // A/front-left = 210, B/front-right = 330). Only used for the offset printout.

/* ---------- Hotend keep-out ---------- */
heater_reach  = 6;     // nozzle axis to the side of the heater block facing the probe (GUESS)
heater_zmin   = 2;     // heater block bottom above the nozzle tip (GUESS)
heater_zmax   = 12;    // heater block top above the nozzle tip (GUESS)
min_clear     = 8;     // required gap, heater block / nozzle to any part of the switch or bracket

/* ---------- The band and lugs on the effector (all GUESS until measured) ---------- */
band_h        = 5.0;   // band height, bottom edge to top edge
band_t        = 1.5;   // how far the band stands proud of the body just above / below it (0 = flush)
band_r        = 19;    // nozzle axis to the band's outer face (level, at the lugs)
band_z0       = 20;    // nozzle tip up to the band's bottom edge
lug_n         = 2;     // number of lugs
lug_w         = 3.5;   // lug width (along X)
lug_pitch     = 6.5;   // lug centre to centre (gap between lugs = pitch - width)
lug_h         = 3.5;   // lug height (along Z)
lug_t         = 1.2;   // how far a lug sticks out from the band face
lug_z0        = 20.75; // lug bottom edge above the nozzle tip (default: centred on the band)
lug_cx        = 0;     // centre of the lug pair along X

/* ---------- Hotend cable (runs down in front of the band on one side) ---------- */
cable_x       = 10;    // cable centre along X where it crosses the band (GUESS; 0 = none)
cable_w       = 5;     // cable width incl. the Kapton wrap

/* ---------- Rod-end (arm joint) keep-out ---------- */
joint_x       = 21;    // X distance from the face centre to each rod-end eye centre (GUESS)
joint_z       = 22.5;  // height of the rod-end eye centres above the nozzle tip (GUESS)
joint_r       = 5;     // rod-end eye radius incl. the washer
joint_clear   = 2;

/* ---------- Saddle (clip) ---------- */
fit           = 0.15;  // clearance per side: lug windows and band height (lower = tighter grip)
front_t       = 2.4;   // front wall over the band face (the lug windows go through it)
lip_t         = 1.6;   // thickness of the lips over and under the band
margin_l      = 3;     // saddle end beyond the lugs on the -X side
margin_r      = 1.5;   // ... and on the +X side (toward the cable / rod end in the photo)

/* ---------- Switch plate ---------- */
plate_t       = 4.0;
plate_margin  = 1.5;   // plate edge beyond the switch body (X)
slot_w        = 2.4;   // M2 clearance slot
nut_af        = 4.0;   // M2 nut across flats (DIN 934 = 4.0)
nut_depth     = 1.8;   // nut groove depth on the outer face (M2 nut is 1.6 thick)
gusset_h      = 5;     // height of the sloped joint between clip and plate (>= overhang keeps it <= 45 deg)
zip_w         = 3.6;   // zip-tie slot length (fits ties up to ~3.5 mm wide)
zip_t         = 2.0;   // zip-tie slot width
zip_pitch     = 7;     // the two zip-tie slots, centre to centre

/* ---------- Fan-screw variant (all GUESS until measured) ---------- */
fan_screw     = [8, 21, 17];  // [x, y, z] of the point where the screw head now sits on the fan frame
fan_tilt      = 30;    // fan face angle from vertical, top leaning toward the nozzle (+)
fan_corner    = 1;     // which side the fan frame's outer corner edge is on, along X (+1 / -1)
fan_edge      = 3.2;   // screw centre to the frame's bottom edge and to its side edge
tab_t         = 2.5;   // tab thickness under the screw head (use a screw ~3 mm longer)
tab_d         = 7.5;   // tab width
m3_slot       = 3.4;   // M3 clearance
m3_slot_len   = 3;     // slot travel along the fan face
lip_h         = 2.0;   // lip depth over the frame edges
lip_w         = 1.6;   // lip thickness
fan_drop      = 4;     // plate top sits this far below the frame's bottom edge

$fn = 40;
eps = 0.01;

/* ---------- Derived ---------- */
row_w    = (lug_n - 1) * lug_pitch + lug_w;
band_z1  = band_z0 + band_h;
clip_x0  = lug_cx - row_w / 2 - fit - margin_l;
clip_x1  = lug_cx + row_w / 2 + fit + margin_r;
clip_y0  = band_r - band_t + fit;            // lip tips (just short of the body above / below the band)
clip_y1  = band_r + fit + front_t;
clip_z0  = band_z0 - fit - lip_t;
clip_z1  = band_z1 + fit + lip_t;
floor_t  = lip_t;

sw_y0    = heater_reach + min_clear;          // switch inner face (toward nozzle)
sw_y1    = sw_y0 + sw_t;
pl_y0    = sw_y1;                             // plate inner face; switch screws onto it
pl_y1    = pl_y0 + plate_t;

roller_z = -roller_below;                     // roller bottom
act_z    = roller_z + roller_drop;            // lever face of the body (facing down)
top_z    = act_z + sw_h;                      // terminal face (facing up)
hole_z   = act_z + sw_hole_act;
x_end    = roller_x - sw_dir * roller_in;     // roller-end of the body
sw_xa    = min(x_end, x_end + sw_dir * sw_l);
sw_xb    = max(x_end, x_end + sw_dir * sw_l);
hole_x   = [x_end + sw_dir * sw_hole_end, x_end + sw_dir * (sw_hole_end + sw_hole_pitch)];

pl_z0    = hole_z - travel / 2 - slot_w / 2 - 2.5;
roller_y = sw_y0 + sw_t / 2;

/* ---------- Checks (printed in the console) ---------- */
function rot(v, a) = [v[0] * cos(a) - v[1] * sin(a), v[0] * sin(a) + v[1] * cos(a)];
// local (+X along the face, +Y out of it) -> printer XY, with the face pointing at face_angle
off = rot([roller_y, -roller_x], face_angle);

echo(str("ROLLER: ", roller_y, " mm out from the nozzle axis, ", roller_x, " mm along the face"));
echo(str("ESTIMATE [probe] x_offset: ", round(off[0] * 10) / 10, "  y_offset: ", round(off[1] * 10) / 10,
         "  (face_angle ", face_angle, "; confirm with the dot method)"));
echo(str("Roller bottom adjustable from ", roller_z - travel / 2, " to ", roller_z + travel / 2, " (nozzle tip = 0)"));
if (pl_z0 < roller_z + travel / 2 + 1)
    echo("WARNING: plate bottom is within 1 mm of the roller at the top of the slot travel");
if (top_z + 1 + zip_w > clip_z0 - 0.5) echo("WARNING: zip-tie slots reach the saddle lip; lower roller_below or raise band_z0");
if (top_z + term_room > clip_z0 - 1 && sw_xb > clip_x0 && sw_xa < clip_x1 && sw_y1 > clip_y0)
    echo("WARNING: switch terminals run into the saddle. Raise band_z0, lower roller_below, or move roller_x");
if (band_t < 0.8) echo("NOTE: band_t is small: the lips barely hook the band, so the lug windows do all the work");
if (lug_t > front_t - 0.4) echo("NOTE: lugs stick out past most of the front wall; consider a thicker front_t");
if (lug_z0 < band_z0 || lug_z0 + lug_h > band_z1) echo("WARNING: lugs are outside the band height; check lug_z0 / band_z0 / band_h");
px0 = min(clip_x0, sw_xa - plate_margin);
px1 = max(clip_x1, sw_xb + plate_margin);
if (cable_x != 0 && ((clip_x1 > cable_x - cable_w / 2 && clip_x0 < cable_x + cable_w / 2) ||
                     (px1 > cable_x - cable_w / 2 && px0 < cable_x + cable_w / 2)))
    echo("WARNING: bracket overlaps the hotend cable. Move it aside with a zip tie, or reduce margin_r / flip sw_dir");
j_in = joint_x - joint_r - joint_clear;          // rod-end eyes start this far out along X
j_lo = joint_z - joint_r - joint_clear;          // ... and this high
if (max(abs(clip_x0), abs(clip_x1)) > j_in && clip_z1 > j_lo)
    echo("WARNING: the clip block reaches a rod-end eye. Check joint_x/joint_z, or reduce margin_l / margin_r");
if (max(abs(px0), abs(px1)) > j_in && clip_z0 - gusset_h > j_lo)
    echo("WARNING: the plate reaches a rod-end eye. Check joint_x/joint_z, or move roller_x / sw_dir");

/* ---------- Parts ---------- */
module rounded_slot(len, w, h) {   // slot along Z, cut through Y
    hull() for (s = [-1, 1]) translate([0, 0, s * (len - w) / 2]) rotate([-90, 0, 0]) cylinder(d = w, h = h);
}

module plate_body(top, x0 = px0, x1 = px1) {
    translate([x0, pl_y0, pl_z0]) cube([x1 - x0, plate_t, top - pl_z0]);
}

module plate_cuts() {
    slot_len = travel + slot_w;
    for (x = hole_x) translate([x, pl_y0 - 1, hole_z]) {
        rounded_slot(slot_len, slot_w, plate_t + 30);                        // M2 slot (also cuts the gusset)
        // nut groove on the outer face, so the nuts can't spin
        translate([-(nut_af + 0.3) / 2, plate_t + 1 - nut_depth, -(slot_len + nut_af) / 2])
            cube([nut_af + 0.3, nut_depth + 30, slot_len + nut_af]);
    }
    // zip-tie slots just above the switch body: tie the two wires flat against the plate
    // (kept below the saddle so they never weaken its lower lip)
    zc = (sw_xa + sw_xb) / 2;
    for (s = [-1, 1]) translate([zc + s * zip_pitch / 2 - zip_t / 2, pl_y0 - 20, top_z + 1])
        cube([zip_t, plate_t + 40, zip_w]);
}

module clip_block() {   // C-shaped saddle seen from the side: upper lip, front wall, lower lip
    translate([clip_x0, band_r + fit, clip_z0]) cube([clip_x1 - clip_x0, front_t, clip_z1 - clip_z0]);
    translate([clip_x0, clip_y0, band_z1 + fit]) cube([clip_x1 - clip_x0, clip_y1 - clip_y0, lip_t]);
    translate([clip_x0, clip_y0, clip_z0]) cube([clip_x1 - clip_x0, clip_y1 - clip_y0, lip_t]);
}

module clip_cuts() {   // a window through the front wall for each lug
    for (i = [0 : lug_n - 1]) {
        x = lug_cx - row_w / 2 + i * lug_pitch;
        translate([x - fit, band_r - 1, lug_z0 - fit]) cube([lug_w + 2 * fit, front_t + fit + 2, lug_h + 2 * fit]);
    }
}

module probe_clip() {
    difference() {
        union() {
            clip_block();
            plate_body(clip_z0 - gusset_h + eps);
            hull() {   // sloped gusset: clip floor down to the plate
                translate([clip_x0, clip_y0, clip_z0]) cube([clip_x1 - clip_x0, clip_y1 - clip_y0, floor_t]);
                translate([px0, pl_y0, clip_z0 - gusset_h]) cube([px1 - px0, plate_t, eps]);
            }
        }
        clip_cuts();
        plate_cuts();
    }
}

// Test piece: just the saddle with a short pull tab, to check the fit on the band and lugs (prints in a few minutes)
module test_clip() {
    difference() {
        union() {
            clip_block();
            translate([clip_x0, band_r + fit, clip_z0 - 6]) cube([clip_x1 - clip_x0, front_t, 6 + eps]); // pull tab
        }
        clip_cuts();
    }
}

// Fan-screw variant
module fan_frame_local() {   // tab in local coords: z = out of the fan face, y = down the face, origin = screw
    difference() {
        union() {
            hull() {
                cylinder(d = tab_d, h = tab_t);
                translate([0, fan_edge + fit + lip_w - tab_d / 2, 0]) cylinder(d = tab_d, h = tab_t);
                translate([fan_corner * (fan_edge + fit + lip_w - tab_d / 2), 0, 0]) cylinder(d = tab_d, h = tab_t);
            }
            // lip along the frame's bottom edge
            translate([-tab_d / 2 + min(0, fan_corner) * (fan_edge + fit + lip_w - tab_d / 2), fan_edge + fit, -lip_h])
                cube([tab_d + abs(fan_edge + fit + lip_w - tab_d / 2), lip_w, lip_h + eps]);
            // lip along the frame's outer side edge
            translate([fan_corner > 0 ? fan_edge + fit : -(fan_edge + fit) - lip_w, -tab_d / 2, -lip_h])
                cube([lip_w, tab_d + fan_edge + fit + lip_w - tab_d / 2, lip_h + eps]);
        }
        hull() for (s = [-1, 1]) translate([0, s * m3_slot_len / 2, -5]) cylinder(d = m3_slot, h = 20);
    }
}

module fan_frame_keepout() {   // the fan frame corner, local coords
    translate([fan_corner > 0 ? -40 : -fan_edge, -40, -40]) cube([40 + fan_edge, 40 + fan_edge, 40]);
}

module fan_tab_placed() {
    translate(fan_screw) rotate([fan_tilt - 90, 0, 0]) fan_frame_local();
}

fan_top = fan_screw[2] - fan_edge * cos(fan_tilt) - fan_drop;

module probe_fan() {
    difference() {
        union() {
            plate_body(fan_top, px0_fan, px1_fan);
            hull() {
                fan_tab_placed();
                translate([px0_fan, pl_y0, fan_top - eps]) cube([px1_fan - px0_fan, plate_t, eps]);
            }
            fan_tab_placed();
        }
        translate(fan_screw) rotate([fan_tilt - 90, 0, 0]) {
            hull() for (s = [-1, 1]) translate([0, s * m3_slot_len / 2, -1]) cylinder(d = m3_slot, h = 30);  // screw
            translate([0, 0, tab_t]) cylinder(d = 7, h = 30);                                               // head room
            fan_frame_keepout();                                                                            // the frame itself
        }
        plate_cuts();
    }
}
px0_fan = min(fan_screw[0] - tab_d, sw_xa - plate_margin);
px1_fan = max(fan_screw[0] + tab_d, sw_xb + plate_margin);

/* ---------- Ghosts for the assembly preview ---------- */
module ghost_switch() {
    color("dimgray") translate([sw_xa, sw_y0, act_z]) cube([sw_l, sw_t, sw_h]);
    color("silver") translate([roller_x, sw_y0 + sw_t / 2, roller_z + roller_d / 2]) rotate([90, 0, 0])
        cylinder(d = roller_d, h = 2.5, center = true);
    color("gold") for (i = [0 : 2]) translate([sw_xa + 2 + i * (sw_l - 4) / 2, sw_y0 + sw_t / 2 - 0.3, top_z]) cube([0.6, 0.6, 4]);
}
module ghost_hotend() {
    color("orange") cylinder(d1 = 1, d2 = 6, h = heater_zmin);                                  // nozzle
    color("orangered", 0.6) translate([0, 0, heater_zmin]) cylinder(r = heater_reach, h = heater_zmax - heater_zmin);
    %translate([0, 0, 0]) cylinder(r = heater_reach + min_clear, h = heater_zmax);              // keep-out
}
module ghost_body() {
    rb = band_r - band_t;
    color("steelblue", 0.35) {
        translate([0, 0, band_z1]) cylinder(r = rb / cos(30), h = 8, $fn = 6);
        translate([0, 0, band_z0]) cylinder(r = band_r / cos(30), h = band_h, $fn = 6);
        translate([0, 0, heater_zmax]) cylinder(r1 = heater_reach + 4, r2 = rb / cos(30), h = band_z0 - heater_zmax, $fn = 6);
        for (i = [0 : lug_n - 1]) translate([lug_cx - row_w / 2 + i * lug_pitch, band_r - 0.5, lug_z0])
            cube([lug_w, lug_t + 0.5, lug_h]);
    }
    color("gray", 0.5) for (s = [-1, 1]) translate([s * joint_x, band_r - 2, joint_z]) rotate([90, 0, 0])
        cylinder(r = joint_r, h = 4, center = true);
    if (cable_x != 0) color("goldenrod", 0.6) translate([cable_x, band_r + fit + front_t + cable_w / 2 + 0.5, heater_zmax])
        cylinder(d = cable_w, h = band_z1 + 8 - heater_zmax);
}

if (part == "clip")              probe_clip();
else if (part == "fan")          probe_fan();
else if (part == "test")         test_clip();
else if (part == "assembly")     { color("deepskyblue") probe_clip(); ghost_switch(); ghost_hotend(); ghost_body(); }
else if (part == "assembly_fan") { color("limegreen") probe_fan(); ghost_switch(); ghost_hotend();
                                   color("black", 0.4) translate(fan_screw) rotate([fan_tilt - 90, 0, 0])
                                       intersection() { fan_frame_keepout(); translate([-20, -20, -8]) cube(40); } }
