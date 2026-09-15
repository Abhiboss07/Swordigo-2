# LEVEL AND WORLD ANALYSIS SPECIFICATION

**Project:** Swordigo V2 / Ironvale  
**Target:** Godot 4.4 Modular World Topology

---

## 1. World Layout & Progression Flow

The world follows a Metroidvania-lite hub-and-spoke corridor architecture. The player journeys from peaceful beginnings through treacherous wilderness into ancient ruins and mechanical fortresses.

```
                  ┌──────────────────────┐
                  │    Overworld Hub     │
                  │   (Oakvale Village)  │
                  └──────────┬───────────┘
                             │
            ┌────────────────┴────────────────┐
            ▼                                 ▼
   ┌───────────────────┐             ┌───────────────────┐
   │  Emerald Valley   │             │   Sunken Ruins    │
   │    (Biome 01)     │             │    (Biome 02)     │
   └────────┬──────────┘             └────────┬──────────┘
            │                                 │
            ▼                                 ▼
   ┌───────────────────┐             ┌───────────────────┐
   │  Ancient Crypts   │             │ Boss: The Wickframe│
   │  (Dungeon Gate)   │             │  (Water/Rot Boss) │
   └────────┬──────────┘             └───────────────────┘
            │
            ▼
   ┌───────────────────┐
   │  Crystal Caverns  │
   │ Boss: Skarn       │
   └───────────────────┘
```

---

## 2. Zone Topology & Component Standards

Each Zone is an independent Godot `.tscn` scene that adheres to a standardized root hierarchy:

```
Zone_Root (Node3D)
├── Environment (WorldEnvironment, DirectionalLight3D, Sun/Moon)
├── TerrainGeometry (StaticBody3D / CSG / MeshInstances)
│   ├── Floors & Platforms (CollisionLayer 1: World)
│   ├── Walls & Slopes
│   └── BackgroundDecor (Non-colliding visual parallax layers)
├── Hazards (Spikes, Lava, Falling Stalactites - CollisionLayer 6: Hazard)
├── Portals (Area3D transitions to adjacent zones)
│   ├── Portal_To_Zone02 (target_scene, target_spawn_name)
│   └── Portal_To_Hub
├── SpawnPoints (Node3D markers)
│   ├── Spawn_Default
│   ├── Spawn_From_Zone02
│   └── Spawn_Checkpoint_01
├── Interactables
│   ├── Checkpoints (Monument with healing & auto-save)
│   ├── Chests (Treasure chests, mimics)
│   ├── BreakablePots (Coins, health pickups)
│   ├── Doors & CrystalSwitches (Gate mechanisms)
│   └── NPCs (Dialogue triggers, shopkeepers)
├── Enemies (Instanced enemy scenes)
└── CameraLimits (Marker3D bounds: min_x, max_x, min_y, max_y)
```

---

## 3. Transition & Streaming Protocol

1. **Trigger:** Player walks into an `Area3D` designated as a `Portal`.
2. **Transition Director:** The global `SceneTransition` autoload captures the event, pauses player inputs, and initiates a smooth screen-fade to black (0.3s cubic fade).
3. **Scene Change:** Calls `get_tree().change_scene_to_file(target_scene_path)`.
4. **Placement:** In the loaded zone, the player is positioned at the `Marker3D` matching `target_spawn_name`.
5. **Camera Snap:** The camera immediately centers on the player's new position before fading in to avoid visual panning glitches.
6. **Fade In:** Fade from black (0.3s) and restore input controls.
