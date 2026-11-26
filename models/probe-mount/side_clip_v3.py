"""Probe clip v3: slides onto the two effector tabs from the SIDE (horizontally),
switch body vertical with the lever/roller pointing down.
Coordinates (mm): X along the effector face, Y outward (Y=0 = clip face that touches the effector),
Z height above the nozzle tip. Run: python3 side_clip_v3.py
"""
import manifold3d as m, trimesh
def box(x0,x1,y0,y1,z0,z1): return m.Manifold.cube([x1-x0,y1-y0,z1-z0]).translate([x0,y0,z0])

# tabs (gauge 2 + test fits)
pocket_x, pocket_z = 6.0, 3.8   # pocket opening: 6.0 along the face, 3.8 tall
pocket_y = 6.5                  # how deep the tabs go in (gauge 2 slot was 7 and they went fully in)
gap      = 1.0                  # wall between the two pockets
tab_zc   = 27.0                 # tab centre above the nozzle tip (ESTIMATE from the Z50 ruler photo)
wall, margin = 2.0, 2.0
# switch, vertical, roller at the bottom
sw_len, sw_w, sw_t = 20, 10, 6.4
hole_from_roller_end = (5.25, 14.75)
hole_from_term_edge  = 2.4
roller_below = 5.0              # target: roller bottom this far below the nozzle tip
roller_drop  = 7.0              # roller bottom below the switch body's bottom end (estimate from photo)
pin_d, plate_t = 2.1, 4.0

cx = (gap + pocket_x) / 2
half = cx + pocket_x/2 + margin
zb, zt = tab_zc - pocket_z/2 - wall, tab_zc + pocket_z/2 + wall
yb = pocket_y + wall
block = box(-half, half, 0, yb, zb, zt)
for s in (-1, 1): block = block - box(s*cx - pocket_x/2, s*cx + pocket_x/2, -1, pocket_y, tab_zc - pocket_z/2, tab_zc + pocket_z/2)

body_bot = -roller_below + roller_drop
body_top = body_bot + sw_len
assert body_top < zb - 1, "switch runs into the clip block"
plate = box(-half, half, yb - plate_t, yb, body_bot - 1, zb + 0.01)
hx = sw_w/2 - hole_from_term_edge           # terminal edge on +X
pins = None
for h in hole_from_roller_end:
    p = m.Manifold.cylinder(sw_t + 0.8, pin_d/2, pin_d/2, 32).rotate([-90,0,0]).translate([hx, yb - 0.01, body_bot + h])
    pins = p if pins is None else pins + p
clip = block + plate + pins

def save(b, f):
    me = b.to_mesh(); t = trimesh.Trimesh(me.vert_properties[:,:3], me.tri_verts); t.export(f)
    print(f, t.extents.round(1), t.is_watertight)
save(clip, "probe_clip_v3.stl")
save(block, "probe_clip_v3_test.stl")
print("switch body z", body_bot, "to", body_top, "; block z", round(zb,1), "to", round(zt,1))
