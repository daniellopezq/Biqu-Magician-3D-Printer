"""1:1 printable template for a truncated-triangle (irregular hexagon) glass bed.
Long sides face the towers (reach limited there), short sides at the gaps between towers.
Rt = centre to long sides, Rg = centre to short sides. Edit and rerun: python3 hex_glass.py
"""
import numpy as np, matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
Rt, Rg = 55.0, 65.0      # ESTIMATES: tower limit ~50 + 5 margin; gap limit unmeasured
towers = {"C (back)": 90, "A": 210, "B": 330}   # Klipper tower angles
def line(a, d): a=np.radians(a); return np.array([np.cos(a), np.sin(a)]), d
L = [line(a, Rt) for a in (90,210,330)] + [line(a, Rg) for a in (30,150,270)]
L.sort(key=lambda l: np.degrees(np.arctan2(l[0][1], l[0][0])) % 360)
V = []
for i in range(6):
    (n1,d1),(n2,d2) = L[i], L[(i+1)%6]
    V.append(np.linalg.solve(np.array([n1,n2]), np.array([d1,d2])))
V = np.array(V); side = [np.linalg.norm(V[i]-V[(i+1)%6]) for i in range(6)]
W, H = 215.9, 279.4   # US letter, mm
fig = plt.figure(figsize=(W/25.4, H/25.4)); ax = fig.add_axes([0,0,1,1])
ax.set_xlim(-W/2, W/2); ax.set_ylim(-H/2-20, H/2-20); ax.set_aspect("equal"); ax.axis("off")
P = np.vstack([V, V[:1]]); ax.plot(P[:,0], P[:,1], "k-", lw=1.2)
ax.plot([-4,4],[0,0],"k-",lw=.5); ax.plot([0,0],[-4,4],"k-",lw=.5)
for name,a in towers.items():
    r=np.radians(a); ax.annotate(f"tower {name}", (np.cos(r)*(Rt+22), np.sin(r)*(Rt+22)), ha="center", va="center", fontsize=9)
    ax.add_patch(plt.Rectangle((np.cos(r)*Rt-6*np.sin(r)*0-6, np.sin(r)*Rt-3), 12, 6, angle=0, fill=False, ls=":", lw=.6))
for i in range(6):
    m=(V[i]+V[(i+1)%6])/2; a=np.arctan2(m[1],m[0])
    ax.text(m[0]+np.cos(a)*6, m[1]+np.sin(a)*6, f"{side[i]:.1f}", fontsize=7, ha="center", va="center",
            rotation=np.degrees(a)-90 if abs(np.degrees(a)-90)<=90 else np.degrees(a)+90)
ax.text(0,-Rg-8,f"centre to long sides (tower sides) {Rt:.0f} mm, so across {2*Rt:.0f} mm\ncentre to short sides (between towers) {Rg:.0f} mm",fontsize=7,ha="center",va="top")
y0=H/2-38
ax.text(-W/2+12,y0,"BIQU Magician glass bed template, 1:1. Print at 100% / Actual size (no 'fit to page').",fontsize=9,weight="bold")
ax.text(-W/2+12,y0-7,"Check scale: the bar below must measure exactly 100 mm.",fontsize=8)
ax.plot([-W/2+12,-W/2+112],[y0-14,y0-14],"k-",lw=2)
for x in range(0,101,10): ax.plot([-W/2+12+x]*2,[y0-14,y0-11 if x%50 else y0-9],"k-",lw=.6)
ax.text(-W/2+62,y0-19,"100 mm",fontsize=7,ha="center")
ax.text(-W/2+12,-H/2-8,
 "Glass: 2-3 mm float glass, edges sanded/polished (\"canto pulido\"). Six straight cuts.\n"
 f"Side lengths (mm) are marked on each edge. Long sides face the towers, short sides point between towers.\n"
 "Dotted boxes: suggested clamp spots (tower sides: printing is limited there anyway).\n"
 f"PRELIMINARY: Rt={Rt:.0f}, Rg={Rg:.0f} are estimates. Measure the reach toward and between the towers first,\n"
 "then rerun hex_glass.py (Rt = tower limit + 5, Rg = gap limit + 5; must be Rt < Rg < 2*Rt).",fontsize=7,va="bottom")
fig.savefig("glass_bed_template.pdf"); fig.savefig("glass_bed_template.png", dpi=60)
print("sides", np.round(side,1), "max across", round(2*np.linalg.norm(V,axis=1).max(),1))
