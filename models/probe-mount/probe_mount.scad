// Removable Z-probe bracket for the BIQU Magician (Steren SS0505A roller-lever microswitch).
//
// Two ways to mount it:
//   "clip": a comb socket that slides up over the small molded teeth on the effector face
//           (the OEM accessory clip point). Nothing to drill, pulls straight off.
//   "fan":  a tab clamped under one existing M3 fan screw, with two lips hugging the corner of
//           the fan frame so it can't swing around the screw.
// Both carry the same plate: the switch is held by two M2 screws in vertical slots, so the roller
// height can be set 3-5 mm below the nozzle tip.
//
// Coordinates (all mm). Origin = nozzle tip.
//   +Y = straight out from the nozzle, through the middle of the effector face that carries the teeth
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
term_room     = 6.0;   // terminals + solder + wire bend above the terminal face

/* ---------- Where the roller should end up ---------- */
roller_below  = 4;     // roller bottom below the nozzle tip, mid-slot (target 3-5)
roller_x      = 0;     // roller centre along X (0 = straight out from the nozzle)
sw_dir        = 1;     // switch body runs from the roller toward +X (1) or -X (-1)
travel        = 8;     // slot travel, +-4 mm around roller_below
face_angle    = 90;    // direction the tooth face points, in printer degrees (tower C/back = 90,
                       // A/front-left = 210, B/front-right = 330). Only used for the offset printout.

/* ---------- Hotend keep-out ---------- */
heater_reach  = 6;     // nozzle axis to the side of the heater block facing the probe (GUESS)
heater_zmin   = 2;     // heater block bottom above the nozzle tip (GUESS)
heater_zmax   = 12;    // heater block top above the nozzle tip (GUESS)
min_clear     = 8;     // required gap, heater block / nozzle to any part of the switch or bracket

/* ---------- The molded teeth on the effector (all GUESS until measured) ---------- */
tooth_n       = 4;     // number of teeth
tooth_w       = 2.5;   // width of one tooth (along X)
tooth_pitch   = 4.5;   // centre to centre spacing (gap between teeth = pitch - width)
tooth_t       = 1.6;   // thickness, how far a tooth sticks out from the face (along Y)
tooth_h       = 3.0;   // height of a tooth (along Z)
tooth_gap     = 1.5;   // free gap BEHIND the teeth (between tooth and body). 0 = teeth sit on a flat face
teeth_r       = 19;    // nozzle axis to the OUTER face of the teeth
teeth_z       = 22;    // bottom tip of the teeth above the nozzle tip
teeth_cx      = 0;     // centre of the tooth row along X

/* ---------- Rod-end (arm joint) keep-out ---------- */
joint_x       = 20;    // X distance from the face centre to each rod-end eye centre (GUESS)
joint_z       = 26;    // height of the rod-end eye centres above the nozzle tip (GUESS)
joint_r       = 5;     // rod-end eye radius incl. the washer
joint_clear   = 2;

/* ---------- Clip ---------- */
fit           = 0.15;  // clearance per side in the tooth pockets (raise if too tight, lower if loose)
engage        = 2.5;   // how far the pockets go up over the teeth (< tooth_h)
wall          = 2.0;   // wall in front of the teeth
floor_t       = 2.0;   // floor under the teeth tips
clip_margin   = 2.5;   // solid end beyond the outer teeth
tongue_min    = 0.8;   // thinnest tongue worth printing into the gap behind the teeth

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
fan_screw     = [-8, 21, 17]; // [x, y, z] of the point where the screw head now sits on the fan frame
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
row_w    = (tooth_n - 1) * tooth_pitch + tooth_w;
has_tongue = tooth_gap >= tongue_min + 2 * fit;
clip_x0  = teeth_cx - row_w / 2 - fit - clip_margin;
clip_x1  = teeth_cx + row_w / 2 + fit + clip_margin;
clip_y0  = teeth_r - tooth_t - (has_tongue ? tooth_gap - fit : 0);
clip_y1  = teeth_r + fit + wall;
clip_z0  = teeth_z - floor_t;
clip_z1  = teeth_z + engage;

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
if (top_z + term_room > clip_z0 - 1 && sw_xb > clip_x0 && sw_xa < clip_x1 && sw_y1 > clip_y0)
    echo("WARNING: switch terminals run into the clip. Raise teeth_z, lower roller_below, or move roller_x");
if (!has_tongue) echo("NOTE: tooth_gap too small for a tongue: the clip only keys between the teeth");
if (engage >= tooth_h) echo("WARNING: engage must be smaller than tooth_h");
px0 = min(clip_x0, sw_xa - plate_margin);
px1 = max(clip_x1, sw_xb + plate_margin);
j_in = joint_x - joint_r - joint_clear;          // rod-end eyes start this far out along X
j_lo = joint_z - joint_r - joint_clear;          // ... and this high
if (max(abs(clip_x0), abs(clip_x1)) > j_in && clip_z1 > j_lo)
    echo("WARNING: the clip block reaches a rod-end eye. Check joint_x/joint_z, or reduce clip_margin");
if (max(abs(px0), abs(px1)) > j_in && clip_z0 - gusset_h > j_lo)
    echo("WARNING: the plate reaches a rod-end eye. Check joint_x/joint_z, or move roller_x / sw_dir");

/* ---------- Parts ---------- */
module rounded_slot(len, w, h) {   // slot along Z, cut through Y
    hull() for (s = [-1, 1]) translate([0, 0, s * (len - w) / 2]) rotate([-90, 0, 0]) cylinder(d = w, h = h);
}

module plate_body(top) {
    translate([px0, pl_y0, pl_z0]) cube([px1 - px0, plate_t, top - pl_z0]);
}

module plate_cuts() {
    slot_len = travel + slot_w;
    for (x = hole_x) translate([x, pl_y0 - 1, hole_z]) {
        rounded_slot(slot_len, slot_w, plate_t + 30);                        // M2 slot (also cuts the gusset)
        // nut groove on the outer face, so the nuts can't spin
        translate([-(nut_af + 0.3) / 2, plate_t + 1 - nut_depth, -(slot_len + nut_af) / 2])
            cube([nut_af + 0.3, nut_depth + 30, slot_len + nut_af]);
    }
    // zip-tie slots just above the terminals: tie the two wires flat against the plate
    zc = (sw_xa + sw_xb) / 2;
    for (s = [-1, 1]) translate([zc + s * zip_pitch / 2 - zip_t / 2, pl_y0 - 20, top_z + term_room - 1])
        cube([zip_t, plate_t + 40, zip_w]);
}

module clip_block() {
    translate([clip_x0, clip_y0, clip_z0]) cube([clip_x1 - clip_x0, clip_y1 - clip_y0, clip_z1 - clip_z0]);
}

module clip_cuts() {
    for (i = [0 : tooth_n - 1]) {
        x = teeth_cx - row_w / 2 + i * tooth_pitch;
        translate([x - fit, teeth_r - tooth_t - fit, teeth_z]) cube([tooth_w + 2 * fit, tooth_t + 2 * fit, engage + 1]);
    }
    // small lead-in chamfer at the pocket mouth would go here; kept square so the fit is easy to judge
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

// Test piece: just the clip block with a short stub, to check the tooth fit (prints in a few minutes)
module test_clip() {
    difference() {
        union() {
            clip_block();
            translate([clip_x0, clip_y1 - wall, clip_z0 - 6]) cube([clip_x1 - clip_x0, wall, 6 + eps]); // pull tab
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
            plate_body(fan_top);
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
    color("steelblue", 0.35) {
        rb = teeth_r - tooth_t - tooth_gap;
        translate([0, 0, teeth_z + tooth_h]) cylinder(r = rb, h = 10, $fn = 6);
        translate([0, 0, heater_zmax]) cylinder(r1 = heater_reach + 4, r2 = rb, h = teeth_z + tooth_h - heater_zmax, $fn = 6);
        for (i = [0 : tooth_n - 1]) translate([teeth_cx - row_w / 2 + i * tooth_pitch, teeth_r - tooth_t, teeth_z])
            cube([tooth_w, tooth_t, tooth_h + 0.5]);
    }
    color("gray", 0.5) for (s = [-1, 1]) translate([s * joint_x, teeth_r - 2, joint_z]) rotate([90, 0, 0])
        cylinder(r = joint_r, h = 4, center = true);
}

if (part == "clip")              probe_clip();
else if (part == "fan")          probe_fan();
else if (part == "test")         test_clip();
else if (part == "assembly")     { color("deepskyblue") probe_clip(); ghost_switch(); ghost_hotend(); ghost_body(); }
else if (part == "assembly_fan") { color("limegreen") probe_fan(); ghost_switch(); ghost_hotend();
                                   color("black", 0.4) translate(fan_screw) rotate([fan_tilt - 90, 0, 0])
                                       intersection() { fan_frame_keepout(); translate([-20, -20, -8]) cube(40); } }
