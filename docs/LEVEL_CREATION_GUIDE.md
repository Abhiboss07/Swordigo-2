# LEVEL CREATION & EXPANSION GUIDE

**Project:** Swordigo V2 / Ironvale  
**Target Engine:** Godot 4.4  
**Workflow:** Modular 2.5D Zone Authoring

---

## 1. Overview

This guide explains how to construct and integrate a new playable zone into Swordigo V2. All zones are independent scenes located in `scenes/world/zone_XX_name.tscn` and adhere to standardized node hierarchies and naming conventions.

---

## 2. Standard Scene Hierarchy

Create a new scene with a `Node3D` root named after your zone (e.g., `Zone04SunkenRuins`).

```
ZoneName (Node3D)
├── WorldEnvironment
├── DirectionalLight3D
├── HUD (Instanced res://scenes/ui/hud.tscn)
├── Player (Instanced res://scenes/entities/player.tscn)
├── CameraController (Instanced res://scenes/entities/camera_controller.tscn)
├── Terrain (Node3D)
│   ├── Floors (StaticBody3D, Layer 1)
│   ├── Walls (StaticBody3D, Layer 1)
│   └── MovingPlatforms (Instanced res://scenes/entities/moving_platform.tscn)
├── Hazards (Node3D)
│   └── Spikes (Instanced res://scenes/entities/hazard_spikes.tscn)
├── Interactables (Node3D)
│   ├── Checkpoint (Instanced res://scenes/entities/checkpoint.tscn)
│   ├── Portals (Instanced res://scenes/entities/portal.tscn)
│   ├── Chests (Instanced res://scenes/entities/chest.tscn)
│   ├── BreakablePots (Instanced res://scenes/entities/pot_breakable.tscn)
│   ├── CrystalSwitches (Instanced res://scenes/entities/crystal_switch.tscn)
│   └── NPCs (Instanced res://scenes/entities/npc.tscn)
├── Enemies (Node3D)
│   ├── Patrollers (Instanced res://scenes/entities/enemy_patroller.tscn)
│   ├── Flyers (Instanced res://scenes/entities/enemy_flyer.tscn)
│   ├── Chargers (Instanced res://scenes/entities/enemy_charger.tscn)
│   └── Bosses (Instanced res://scenes/entities/boss_wickframe.tscn)
└── SpawnPoints (Node3D)
    ├── Spawn_Default (Marker3D)
    └── Spawn_From_AdjacentZone (Marker3D)
```

---

## 3. Step-by-Step Implementation

### Step 3.1: Environment & Camera Limits
1. Add a `WorldEnvironment` with ambient light, sky material, and subtle glow.
2. Add a `DirectionalLight3D` rotated to illuminate from the foreground.
3. Configure `CameraController`:
   - Set `limit_left` and `limit_right` to match your level horizontal boundaries.
   - Set `limit_bottom` and `limit_top` to constrain vertical camera motion.

### Step 3.2: Terrain & 2.5D Constraint
1. Build floors and platforms using `StaticBody3D` with `CollisionShape3D` and `MeshInstance3D`.
2. **Critical:** Always set the Z-center of your collision shapes to `z = 0.0` with adequate depth (e.g. `size.z = 4.0`).
3. Ensure terrain collision layer is set to `Layer 1: World`.

### Step 3.3: Portals & Spawn Routing
1. Instance a `portal.tscn`.
2. Configure export variables:
   - `target_scene_path`: path to destination `.tscn`
   - `target_spawn_name`: name of target `Marker3D` in destination scene
   - `requires_key`: optional item ID (e.g. `"old_dungeon_key"`) required to enter
3. Add a corresponding `Marker3D` inside `SpawnPoints` for returning players.

### Step 3.4: Checkpoints & Progression
1. Place a `checkpoint.tscn` at the entrance or midpoint of the level.
2. Give it a unique `checkpoint_id` (e.g. `"crypts_checkpoint_02"`).
3. Place interactive chests (`chest.tscn`) and assign loot parameters:
   - `chest_id`: unique string identifier
   - `reward_coins`: integer coin amount
   - `reward_item_id`: item ID from `Inventory.item_definitions`

---

## 4. Pre-Commit Validation

Before committing a newly authored level:
1. Open terminal and run the content validator:
   ```bash
   /home/abhiboss/.local/bin/godot4 --headless --path game -s res://tests/test_runner.gd
   ```
2. Confirm all 8 test suites pass without errors or broken node dependencies.
