"""Probe clip v2 for the BIQU Magician effector tabs (manifold3d).
Coordinates (mm): Z = height above nozzle tip, X = along the effector face,
Y = outward, with Y=0 at the tabs' outer face. Prints upright exactly as exported.
Run: python3 saddle_clip.py  -> probe_clip_v2.stl, probe_clip_v2_test.stl
"""
import manifold3d as m, trimesh
B = m.Manifold.cube
def box(x0,x1,y0,y1,z0,z1): return B([x1-x0,y1-y0,z1-z0]).translate([x0,y0,z0])

# measured (gauges + ruler at G1 Z50)
pocket_w  = 3.8    # gauge 2 slot 1: snug, fully on
tab_gap   = 4.0    # edge to edge
band_z    = 29.5   # band underside above nozzle tip: ruler 76 mm + 3.5 mm unmarked ruler end = 79.5 mm at Z50
tab_h     = 3.5    # estimate, pockets made 1 mm deeper
# design
pocket_d  = tab_h + 1.0
wall_out  = 2.0    # wall outside the tabs
pocket_in = 6.0    # closed pocket, inward depth: same as gauge 2 (tab fit fully)
wall_in   = 1.0    # inner wall, same as gauge 2 (it fit behind the tab)
margin    = 2.5
floor_t   = 2.0
plate_t   = 4.0
sw_l, sw_h, sw_t = 20, 10, 6.4
roller_below, roller_drop, hole_act, travel = 4, 6, 7.1, 8
slot_w, nut_af, nut_d = 2.4, 4.3, 1.8

cx = [-(tab_gap+pocket_w)/2, (tab_gap+pocket_w)/2]          # tab centres
half = (tab_gap/2 + pocket_w + margin)
z_top, z_bot = band_z, band_z - pocket_d - floor_t
clip = box(-half, half, -pocket_in-wall_in, wall_out, z_bot, z_top)
pockets = [box(c-pocket_w/2, c+pocket_w/2, -pocket_in, 0, z_top-pocket_d, z_top+1) for c in cx]

# switch plate hangs from the outer wall, switch on its OUTER face (clear of the heater)
act_z  = -roller_below + roller_drop          # lever face of the switch body
hole_z = act_z + hole_act
pz0 = hole_z - travel/2 - slot_w/2 - 2.5
px = sw_l/2 + 1.5
py0, py1 = wall_out - plate_t, wall_out
plate = box(-px, px, py0, py1, pz0, z_bot + 0.01)
gusset = (box(-half, half, -pocket_in-wall_in, wall_out, z_bot, z_bot+0.01) + box(-px, px, py0, py1, z_bot-5, z_bot-4.99)).hull()
hole_x = [-sw_l/2 + 5.25, -sw_l/2 + 14.75]
cuts = []
for x in hole_x:
    L = travel + slot_w
    slot = (m.Manifold.cylinder(40, slot_w/2, slot_w/2, 32).rotate([90,0,0]).translate([x, 20, hole_z - (L-slot_w)/2]) +
            m.Manifold.cylinder(40, slot_w/2, slot_w/2, 32).rotate([90,0,0]).translate([x, 20, hole_z + (L-slot_w)/2])).hull()
    cuts += [slot, box(x-nut_af/2, x+nut_af/2, py0-1, py0+nut_d, hole_z-L/2-nut_af/2, hole_z+L/2+nut_af/2)]
body = clip + plate + gusset
for c in pockets + cuts: body = body - c
# screwless version: two pins through the switch holes instead of slots + screws
pin_d = 2.1                      # switch holes are 2.3 (standard SS-5 subminiature)
pin_len = sw_t + 0.8             # through the switch body, a little extra to melt into a rivet head
fz = -roller_below + roller_drop + hole_act   # fixed hole height (roller 4 mm below the tip)
fpz0 = fz - 6
plate_p = box(-px, px, py0, py1, fpz0, z_bot + 0.01)
pins = None
for x in hole_x:
    pin = m.Manifold.cylinder(pin_len, pin_d/2, pin_d/2, 32).rotate([-90,0,0]).translate([x, py1 - 0.01, fz])
    pins = pin if pins is None else pins + pin
body_pins = clip + plate_p + gusset + pins
for c in pockets: body_pins = body_pins - c

def save(b, f):
    me = b.to_mesh(); t = trimesh.Trimesh(me.vert_properties[:,:3], me.tri_verts)
    t.apply_translation([0,0,-t.bounds[0][2]]); t.export(f); print(f, t.extents.round(1), t.is_watertight)
save(body, "probe_clip_v2.stl")
save(body_pins, "probe_clip_v2_pins.stl")
test = clip + box(-half, half, wall_out-2, wall_out, z_bot-8, z_bot+0.01)
for c in pockets: test = test - c
save(test, "probe_clip_v2_test.stl")
print("roller ~", round(wall_out + sw_t/2, 1), "mm outside the tab face, x =", -sw_l/2 + 2.5, "; adjustable",
      -roller_below - travel/2, "to", -roller_below + travel/2)
