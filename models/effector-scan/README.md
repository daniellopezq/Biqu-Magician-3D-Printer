# Effector photogrammetry scan (KIRI Engine)

The original KIRI export (OBJ + MTL + 2048 px texture, 250k triangles, 29 MB) froze the server when opened in a viewer. These are decimated, untextured copies:

| File | Triangles | Size |
|---|---|---|
| `effector-scan-20k.stl` | 20k | 1 MB (open this one first) |
| `effector-scan-50k.stl` | 50k | 2.5 MB |

**Scale is NOT real.** KIRI exports in arbitrary units (the model spans about 1.5 units). To use it for measurements, scale it using one known caliper dimension (for example, the fan's 30 mm or 40 mm frame, or the rod-end eye spacing).

Use it as a visual reference for the probe saddle clip (band + 2 lugs, rod-end clearance). Read precise numbers with calipers, not from the scan: photogrammetry is smoothed and has blobs around thin features like the lugs.

Headless tips (no viewer needed):

```
python3 -c "import trimesh;m=trimesh.load('effector-scan-20k.stl');print(m.extents,len(m.faces))"
```

Avoid opening the original 250k textured OBJ in a GUI on the server; if it's needed, use MeshLab with "Quadric Edge Collapse Decimation" first, or Blender's Decimate modifier.
