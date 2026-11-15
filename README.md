# Breach Wave v4 (Godot 4)

2D reverse tower defense prototype. You send units down a winding path; towers try to stop them; reduce the enemy base's HP to 0 to win. You lose if you run out of waves with the base still alive.

## Open it
1. Install Godot 4.3 or newer (standard build, not .NET).
2. Project Manager -> Import -> select `project.godot`.
3. Press F5 to run.

## Controls
Click a unit tile (top-left) to queue it (cost shown under the icon), then press **Send Wave** (bottom-left). Clear refunds the queue.
After each cleared wave you earn souls and every tower levels up (+5% damage per level).

## What changed in v4
- Armor removed completely: units only have HP, and towers deal their full damage.
- Tower range is shown as a soft tinted area only; the outer rings are gone.
- Instruction text added at the top of the screen.

## v3
- Tower attack ranges are now drawn the same bright way for every tower (the red Gunner rings were nearly invisible before).
- Right Gunner moved up and right so its range reaches the downward road; right Flak moved right, closer to the road.
- Axes removed from towers.
- Hovering a tower shows its stats (damage, attack speed, DPS, range, targets), like the unit buttons.

## v2
- Scout -> Skeleton, Flyer -> Bat, Tank -> Slime; Healer removed. Slime HP 350, speed 80.
- Tower level-ups: +5% damage per level (`upgrade_multiplier` in `Tower.gd`).

## Layout
- `scripts/GameManager.gd` - autoload: currency, base HP, waves, win/lose
- `scripts/Unit.gd` - PathFollow2D unit; stats live in the `TYPES` dictionary
- `scripts/UnitArt.gd` - shared drawing for units and UI icons
- `scripts/Tower.gd` - distance-based targeting, furthest-along-the-path first
- `scripts/WaveSpawner.gd` - queue and spawning
- `scripts/Main.gd` - builds the map, towers, and UI in code, runs the wave loop
