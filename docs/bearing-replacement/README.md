# Replacing the Linear Bearings on a BIQU Magician Delta 3D Printer

*How to rescue a rusty BIQU Magician with seized carriages, step by step with photos.*

![Rusty carriage bearings](images/01-rusty-carriage-bearings.jpg)

## Why this guide exists

The BIQU Magician is a small delta 3D printer. I bought a used one with a carriage completely seized by rust, and searched for a disassembly or bearing-replacement guide. I found nothing: the official manual covers setup, leveling and first prints, and there were no forum threads, videos or teardowns for this model.

So this guide documents what actually worked, including the parts that weren't obvious:

- **The carriages use long LM8LUU bearings (8 × 15 × 45 mm), not standard LM8UU.** A single standard LM8UU per rod, centered in the bore, works as a stopgap.
- **The rods come out through the top, not the bottom.** The top housing is only press-fit onto the rods. The bottom ends of the rods are screwed down from under the base, and those screws can't be reached without breaking the feet. **Don't try to remove the feet.**
- **You don't need to remove the rods at all.** With the top housing off, the carriages slide off the top ends of the rods.

> **Note:** This is one person's repair of one printer. Your printer may differ, so check each step against your own machine and don't force anything.

---

## Parts and tools

**Parts**

| Item | Qty | Notes |
|---|---|---|
| LM8LUU linear bearings (8 × 15 × 45 mm) | 6 | The original part, best option |
| **or** LM8UU linear bearings (8 × 15 × 24 mm) | 6 | Stopgap: one per bore, centered (see Step 9) |
| 8 mm smooth rod | as needed | Only if a rod is badly pitted; measure the length first |

**Tools and supplies**

- Phillips screwdrivers and hex keys
- A socket of about 10–13 mm, plus a screwdriver or extension to push with
- Penetrating oil (WD-40 or similar)
- Steel wool, grade #000 or #0000
- 3000-grit wet/dry sandpaper
- Light machine oil (turbine or sewing-machine oil)
- White lithium grease, plus a cap and a small syringe for applying it
- Paper towels, a magnetic screw mat (or small cups), tape and marker
- A tape measure or calipers

---

## Step 1: Diagnose the problem

![Rust bleeding out of the carriage](images/01-rusty-carriage-bearings.jpg)
![Heavy rust on a rod](images/02-rust-on-rod.jpg)

Symptoms on my printer:

- One carriage wouldn't move at all, even by hand with the power off.
- **Orange stains around the bearing openings** on the carriage: rust bleeding out of the bearings.
- Rust spots and stains along the rods, worst where a carriage had sat parked for a long time.

To confirm it's the bearings, unclamp the belt from that carriage (Step 3). If the carriage still won't slide with the belt free, the problem is the bearings or the rod, not the motor or belt.

**First aid:** penetrating oil (WD-40) into both ends of each bearing, a 30–60 minute soak, then gentle taps with a screwdriver handle to break it loose. That freed my carriage, but it still needed tapping to move, so the bearings had to be replaced.

---

## Step 2: Power off and document

- Unplug the printer.
- **Photograph everything from several angles before taking anything apart**: carriages, belt clamps, arm joints and the top of each tower. These photos are your reassembly guide.
- Use a magnetic mat or cups to keep screws grouped by where they came from.

---

## Step 3: Detach the arms and free the belts

![Carriage with arms and belt clamps](images/03-carriage-belt-clamps-and-arms.jpg)
![Belt clamp plates](images/04-belt-clamp-rusty-rods.jpg)

**Arms:** each carriage has two arms attached with rod-end joints and a screw through each side lug. Remove the screws and let the arms hang from the print head. **Note the order of any washers or spacers.**

**Belts:** each belt end is held by a **small toothed plate with two screws**, and there are two plates per carriage. Loosen the screws a few turns and slide the belt ends out. Do this on all three carriages.

The belt stays looped around the **idler pulley inside the bottom foot**:

![Foot with idler and belt](images/06-foot-with-idler.jpg)
![Idler with the belt off](images/14-idler-belt-off.jpg)

While the belt is off, spin each idler. It should turn freely and smoothly.

---

## Step 4: Don't remove the feet

![Base underside](images/07-base-underside.jpg)
![Inside of a foot](images/08-foot-inside.jpg)

This is where I lost time. The underside of the base has a rubber foot with a hex screw under each tower, plus small screw heads. **The bottom ends of the rods are screwed down from below**, and those screws sit where you can't reach them without breaking the plastic foot.

The good news is you don't need to. **The rods come out of the top.**

---

## Step 5: Lift off the top housing

![Printer laid on its side](images/05-printer-on-its-side.jpg)
![Top housing before removal](images/09-top-housing-before.jpg)

The top housing (with the screen, electronics, motors and endstops) is **held on the rods only by friction**. Each rod end sits in a round cup.

1. Lay the printer on its side on a towel.
2. Optional: mark each rod with tape where it enters its cup, so you can check it seats back to the same depth.
3. **Watch the wires and the white filament tube.** Lift only as far as they have slack.
4. Pull the top housing **straight up, evenly**, off all six rods.

![Rods standing with top removed](images/13-rods-standing-top-removed.jpg)

With the top off, slide each carriage off the top ends of its rods.

---

## Step 6: Inspect the top housing

![Rod cups](images/10-top-housing-rod-cups.jpg)
![Pulley and endstop](images/11-top-housing-pulley-endstop.jpg)
![Check the cups for cracks](images/12-top-housing-cups-check-cracks.jpg)

While it's off, check:

- **The rod cups.** Look for cracks around the rims. A cracked cup won't grip its rod. Fix it with a drop of CA (super) glue in the crack or a zip tie tightened around the cup.
- **The endstop switches** (roller-lever microswitches). Press each lever and listen for a clean click. Mine had surface rust but still worked.
- **The motor pulleys.** Tighten the set screws so they grip the flat side of each motor shaft. A loose pulley causes shifted layers.

---

## Step 7: Clean and polish the rods (in place)

![Polished rods](images/15-polished-rods.jpg)
![A pitted rod](images/16-pitted-rod.jpg)

The rods stay screwed into the base, so polish them where they stand:

1. **#000/#0000 steel wool with oil.** Rub **along the length** of the rod, not around it, to remove rust.
2. **3000-grit wet/dry sandpaper with oil.** Wrap a strip around the rod and slide it the full length several times to polish it.
3. **Wipe clean** until the towel comes away with no orange or gray residue. Remove all steel-wool fibers, because they'll scratch the new bearings.
4. **Fingernail test:** run a nail along the rod. If it catches in pits, that rod is pitted.

**About pitted rods:** one of my rods had pitting in its upper section. A new bearing caught slightly on it, but after greasing it slid fine. I'm using it to test the printer and will replace it if it causes problems (clicking at one spot, or bands on prints at the same height). Pits near the top of a rod matter less, because the carriages only go up there for homing and tall prints.

Don't use coarse sandpaper or a grinder on the rods.

---

## Step 8: Remove the old bearings

![Carriage end view](images/17-carriage-end-view.jpg)
![Carriage belt-clamp side](images/18-carriage-belt-clamps-endstop-boss.jpg)
![The slot shows the long old bearing](images/19-carriage-slot-old-bearing.jpg)

**Carriage anatomy:** each carriage has two bores, one per rod. Each bore has a **slit along its length** that lets the plastic grip the bearing, so **the bearing is press-fit**. There's one long bearing per bore, and they sit flush with both ends of the carriage.

> **Don't touch the screw in the small round boss** on the carriage face. It appears to be what presses the endstop lever when homing, so changing it changes that tower's height (see Step 12).

To remove a bearing:

1. **Soak** both ends with penetrating oil for 10–15 minutes.
2. Put a socket (about 10–13 mm) against the bearing's metal edge. Use one small enough to fit inside the bore but big enough not to enter the bearing's hole.
3. **Push it out lengthwise** with steady pressure, using a screwdriver or extension through the socket. A vise also works: a small socket on one side, and a large socket (17–19 mm) on the other to catch the bearing.
4. **Never pry the slit open.** The plastic will crack.

![Pushing the old bearing out](images/21-pushing-out-old-bearing.jpg)
![Old bearing, about 45 mm](images/22-old-bearing-45mm.jpg)

**Measure it.** Mine was **about 45 mm long: an LM8LUU.**

---

## Step 9: Install the new bearings

![Old long bearing vs new LM8UU](images/20-old-vs-new-bearing.jpg)

**Best option:** six new **LM8LUU** (8 × 15 × 45 mm), a direct replacement.

**What I did:** I had already bought standard **LM8UU** (24 mm), so my printer ended up with a mix:

- **Two carriages: one LM8UU per rod, centered in the bore.**
- **One carriage: its original long bearings**, which still rolled smoothly after cleaning and packing with grease.

I first tried **two LM8UU end to end** per bore. That's 48 mm, about 3 mm longer than the original, so they **stuck out of the carriage**, and the longer carriage felt draggier. One centered bearing per rod glided better.

1. Clean rust flakes out of the bore.
2. **Slide the new bearing onto a rod first**, to keep it aligned.
3. Press it into the bore with the rod still inside, and **center it** along the bore's length.
4. Slide the carriage along a rod. It should glide with even resistance.

![A trial fit with two LM8UU end to end, which stuck out of the carriage](images/26-two-lm8uu-installed.jpg)

**Things I noticed:**

- **With the top housing off, the carriages bound near the free top ends of the rods.** Without the top, the rod ends aren't held parallel. Test the glide again with the top housing installed.
- **Salvage the old bearings.** Clean them, soak them with penetrating oil and grease them. If one rolls smoothly on a rod, it's still usable. Pair a reused bearing with a smooth rod, not a pitted one.
- **A single short bearing is a stopgap.** It holds the rod over 24 mm instead of 45 mm, so the carriage can rock very slightly, and towers with different bearings don't behave quite the same. My printer still printed true to size this way, but **six LM8LUU** are the proper fix for better print quality.

---

## Step 10: Grease the bearings

![White lithium grease and a cap](images/23-grease-and-cap.jpg)
![Loading a syringe](images/24-loading-syringe.jpg)
![Greasing a bearing](images/25-greasing-bearing.jpg)

I used **white lithium grease** from an aerosol can:

1. Spray it into a bottle cap and **let it sit a few minutes** so the solvent evaporates and it thickens.
2. Load it into a small syringe.
3. Put a **bead of grease inside each bearing**. Don't pack it full.
4. Slide each bearing back and forth on a rod to spread the grease, and wipe off the excess.
5. Leave only a **thin film on the rods**, because thick grease collects dust.

Use the same lubricant on all three towers so they all move with the same resistance. Watch for grit in the grease. If it picked up steel-wool fibers or dirt, use fresh grease.

---

## Step 11: Reassemble

1. **Carriages on:** slide each one onto its rods from the top, with the **round endstop boss pointing up** toward the top housing.
2. **Belts:** each belt loops around its bottom idler, with both ends up. Leave them loose for now.
3. **Top housing on:** line up all six cups with the rod ends, then press **straight down, evenly**, a little at a time on each side, until every rod bottoms out in its cup. Don't pinch any wires.
4. **Glide test:** slide each carriage the full length by hand. With the top on, the binding near the ends should be gone. **Push each carriage all the way up and confirm the endstop clicks before the bearing ends touch the top housing.**
5. **Route the belts:** feed one end of each belt up over its motor pulley and back down to the carriage. Clamp one end under its toothed plate with the teeth meshed. Pull the other end snug and clamp it. It should twang a little when plucked, not flop. Aim for similar tension on all three belts.
6. **Arms on:** washers and spacers in their original order. Snug, but the joints must still swivel freely.
7. **Hand test** (power off): move the print head around gently. It should be smooth everywhere, with nothing catching.

---

## Step 12: Test and calibrate

**Power-on tests, before buying filament:**

1. **Auto Home:** all three carriages rise and click their endstops.
2. **Jog** each axis from the menu: the motion should be smooth, with no clicking or skipped steps.
3. **Heat** the hotend to 200 °C, but **turn the fans on first** (`M106 S255`, or the fan control in the menu). On the Magician the heatsink fan above the nozzle is on the switched fan output, so it doesn't start by itself when the hotend heats. The temperature should climb steadily and hold.
4. **Extrude** 10–20 mm with the hotend hot: the extruder gear should turn smoothly.
5. **"Air print":** slice a small test cube with the Z offset raised about 10 mm, so it prints in the air, and watch the whole run.

**Calibration:**

After my reassembly, homing worked, but one tower stopped **1–2 mm higher** than the others, and the head drifted to one side when moving down. That's expected after a teardown.

The stock firmware turned out to be **Smoothieware**, with **no probe** and **no SD card on the mainboard**. So there's no automatic leveling, and `M500` can't save settings. What worked:

- **Optional, mechanical:** measure from each carriage to the top housing right after homing. If one carriage stops higher, turn its endstop-trigger screw (in the round boss) **out** slightly so it triggers sooner.
- **Paper test over USB:** unplug the touchscreen's serial cable (otherwise USB commands are ignored), home, and find the light-drag height at the bed center and near each tower. Correct the towers with endstop trims (`M666`, values of 0 or below), then the delta radius (`M665 R`) if the center still differs, then the max height (`M665 Z`). Three rounds got all towers within 0.05 mm.
- **Keep the values in your slicer's start G-code**, since they can't be saved on the printer. Put `M106 S255` first, then your `M665` and `M666` values, then `G28`.

The full walkthrough, with test points, the order of corrections and a start G-code template, is in **[Reviving a BIQU Magician](../reviving-the-magician.md)**. The [calibration notes](../calibration.md) also cover the Klipper route.

---

## Lessons learned

- **Rust is the enemy.** This printer had clearly been stored somewhere damp. Store printers dry, and re-grease the rods every few weeks.
- **Check bearing length before ordering.** The Magician uses LM8LUU (45 mm), not LM8UU (24 mm).
- **Don't fight the base.** Everything comes apart from the top.
- **Test glide with the top housing on**, not off.
- **A pitted rod can be used temporarily** to find out whether the printer is worth further investment.

## License

Text and photos: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) (see [docs/LICENSE](../LICENSE)). Share and adapt with attribution.

A printable PDF of this guide is in [biqu-magician-bearing-replacement.pdf](biqu-magician-bearing-replacement.pdf).
