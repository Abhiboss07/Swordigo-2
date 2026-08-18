# ORIGINAL GAMEPLAY REFERENCE SPECIFICATION

**Project:** Swordigo V2 / Ironvale  
**Target Engine:** Godot 4.4 (GDScript, CharacterBody3D in 2.5D configuration)  
**Reference Baseline:** Swordigo (Touch Foo 2012) 2.5D Action-Adventure Platformer

---

## 1. Engine & Architectural Paradigm

The reference title represents a definitive benchmark in mobile 2.5D action-adventure design. Its core architectural paradigm combines:
1. **2.5D Spatial Constraint:** The game world is rendered with 3D meshes and perspective projection, but physics simulation, character navigation, and entity interactions are strictly confined to a 2D plane (X: horizontal movement, Y: vertical elevation, Z: constrained constant plane).
2. **Kinematic Character Physics:** Jump arcs, running momentum, and gravity curves use custom-tuned kinematic equations rather than rigid-body simulation to provide snappy, responsive arcade controls.
3. **Portal-Based Seamless Streaming:** The world consists of interconnected zones linked via entry/exit portals with named target spawn points and fade-to-black transitions.
4. **Metroidvania-Lite Progression:** Zones are gated by abilities (e.g., Double Jump, Magic Bolt switch activation, Dimensional Rift) and keys, encouraging backtracking to discover hidden chests and lore.

---

## 2. Player Mechanics & Feel

### 2.1 Locomotion & Physics Constants
- **Horizontal Speed:** 8.0 m/s max run speed with high acceleration (`60.0 m/s²`) and immediate deceleration (`50.0 m/s²`) to avoid slippery inertia.
- **Jump Mechanics:**
  - Initial Jump Velocity: `13.5 m/s` (reaches ~2.8m height).
  - Variable Jump Cut: Releasing the jump button early dampens upward velocity by 50%, enabling precise short hops.
  - Gravity: `32.0 m/s²` normal falling gravity, with increased downward acceleration (`38.0 m/s²`) when descending to eliminate floatiness.
  - Coyote Time: 0.12 seconds window after leaving a ledge where jumping is still accepted.
  - Jump Buffering: 0.15 seconds input queue for jump presses just before touching ground.
  - Double Jump: Unlocked early in progression; resets vertical velocity to `12.5 m/s` mid-air.
  - Wall Slide & Wall Jump: Sliding down walls at reduced terminal velocity (`3.0 m/s`), allowing a kick-off jump (`11.0 m/s` vertical, `7.0 m/s` horizontal away from wall).

### 2.2 Combat & Animation Timing
- **Melee Combo:** 3-stage sword swing sequence:
  - Slash 1 (Down-forward): 0.25s duration, 1.0x weapon damage, minor knockback.
  - Slash 2 (Upward diagonal): 0.25s duration, 1.2x weapon damage, minor knockback.
  - Slash 3 (Finishing thrust): 0.35s duration, 1.8x weapon damage, heavy knockback (`12.0 m/s`).
- **Hit Detection:** Fast `Area3D` swept volume enabled during active attack frames (frame 4 to frame 12 at 60 FPS).
- **Invulnerability & Feedback:**
  - 1.0s invulnerability window on taking damage with rapid mesh flicker (10 Hz).
  - Hit-stop: 0.05s engine freeze on solid hit for impactful combat feel.
  - Directional knockback: Player is thrown backward and slightly upward (`6.0 m/s` X, `4.0 m/s` Y) upon receiving damage.

### 2.3 Magic System
- **Mana Economy:** Player has a recharging mana bar (or mana restored via soul shards / enemy defeats).
- **Magic Bolt:** Fast, straight-line energy projectile (`18.0 m/s`) that ignites enemies, activates ranged switches, and damages distant targets.
- **Dimensional Tear / Phase Shift:** Short-range horizontal teleport / blink (`8.0m`) that phases through enemy bodies, traps, and energy barriers.
- **Firestorm / Shockwave:** Radial AoE spell dealing heavy elemental burst damage around the player and clearing surrounding projectile swarms.

---

## 3. World & Level Topology

### 3.1 Zone Structure
Levels are designed as modular 2.5D corridors containing:
- Multi-tier platforms, slopes, and climbing surfaces.
- Moving platforms (linear back-and-forth, circular orbits).
- Environmental hazards: Spike pits, lava lakes, crumbling platforms, dart traps.
- Checkpoints: Stone monuments that activate when passed, restoring health and setting the active respawn coordinate.
- Portals: Archways or cave openings leading to adjacent zones, encoding destination scene and target spawn marker.
- Collectibles: Breakable pots (health gems, coins), hidden treasure chests (weapons, armor, baubles, quest items).

### 3.2 Camera System
- **Tracking:** 2.5D smoothed follow camera positioned at fixed Z distance (`Z = 9.0m`), slightly elevated above player eye line.
- **Lead Offset:** Camera looks ahead in the direction of player movement (+1.5m lead).
- **Vertical Deadzone:** Camera ignores small vertical hops (deadzone of 1.2m), tracking only sustained climbing or falling.
- **Room Bounds:** Min/Max X and Y clamps per level so the camera does not show void outside the level geometry.
- **Trauma-based Camera Shake:** Decay-driven screenshake on heavy impacts, boss slams, and explosions.

---

## 4. Entity & Progression Hierarchy

```
Entity (Node3D)
├── CharacterBody3D (Physics & Movement)
│   ├── CollisionShape3D
│   ├── VisualModel (MeshInstance3D / AnimationPlayer)
│   ├── Hitbox (Area3D - deals damage)
│   ├── Hurtbox (Area3D - receives damage)
│   └── StateMachine
│       ├── IdleState
│       ├── MoveState
│       ├── JumpState
│       ├── AttackState
│       └── HurtState
```

- **Player:** Central controller incorporating equipment stats (Attack, Defense, Magic Power), active baubles (Amulet, Rings, Trinket), and persistent inventory.
- **Enemies:** Behavior archetypes derived from base monster controller:
  - Ground Patroller: Patrols platforms, turns at edges, chases on player line-of-sight.
  - Leaping Beast: Crouches and springs toward player when in range.
  - Flying Stalker: Hovers and dives in sine-wave trajectories toward the player.
  - Ranged Caster: Keeps distance and casts homing energy bolts.
  - Boss: Multi-phase state machine with telegraphed attacks, invulnerability shields, minion summons, and arena stage transitions.
