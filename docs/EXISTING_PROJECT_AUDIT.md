# PHASE 4 — EXISTING GODOT PROJECT AUDIT

**Date:** 2026-10-28  
**Project:** Swordigo V2 / Ironvale  
**Target Root:** `/home/abhiboss/Projects/Swordigo 2/`  
**Engine:** Godot Engine 4.4.1.stable.official.49a5bc7b6 (`/home/abhiboss/.local/bin/godot4`)

---

## 1. Initial Project Inspection

An exhaustive audit of `/home/abhiboss/Projects/Swordigo 2/` and adjacent directories was performed prior to any modifications:
1. **Existing Source Files:** No pre-existing `project.godot`, `.tscn` scenes, or GDScript `.gd` files were present in the directory.
2. **Pre-existing Artifacts:** Only `swordigo.apk` was located in the project directory.
3. **Engine Installation:** The system has Godot Engine 4.4.1 stable installed at `/home/abhiboss/.local/bin/godot4`.
4. **Conclusion:** The project is initiated as a clean, modern Godot 4.4 implementation adhering strictly to modern GDScript 2.0 conventions (static typing, signals, `@export`, modular scene composition).

---

## 2. Target Architecture Principles

The new Godot 4.4 project (`game/project.godot`) will be structured as follows:
- **Clean Folder Isolation:**
  - `game/scenes/`: Subdivided into `world/`, `entities/`, and `ui/`.
  - `game/scripts/`: Subdivided into `systems/`, `entities/`, and `ui/`.
  - `game/resources/`: `.tres` definitions for items, equipment, quests, and loot tables.
  - `game/assets/`: Models, textures, audio, fonts, and materials.
- **Autoload Singletons (Global Managers):**
  - `GameManager`: Centralized game state, active profile, player reference.
  - `Inventory`: Item collection, equipment slots, currency balance.
  - `QuestManager`: Story flags, objective tracking.
  - `SceneTransition`: Screen fade, portal navigation, spawn marker routing.
  - `AudioManager`: Global SFX pool, music cross-fading.
  - `SaveSystem`: Profile JSON serialization and auto-save checkpoints.
- **Strict 2.5D Constraint:** All 3D gameplay entities lock their Z position (`position.z = 0`) and physics velocity (`velocity.z = 0`) to enforce pure 2D platforming within a 3D perspective world.
