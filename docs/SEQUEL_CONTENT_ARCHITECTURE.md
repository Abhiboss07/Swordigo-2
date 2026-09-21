# SEQUEL CONTENT ARCHITECTURE SPECIFICATION

**Project:** Swordigo V2 / Ironvale  
**Target:** Godot 4.4 Modular Architecture

---

## 1. Content Architecture Principles

Swordigo V2 is designed as a data-driven, expandable action-adventure sequel. New regions, dungeons, enemies, equipment, and quest chains can be added without modifying the core player controller or physics engine.

### 1.1 Separation of Data and Behavior
- **Content Definitions:** Items, quests, enemy stats, and level parameters are defined as structured data (GDScript dictionaries, `.tres` resources, or JSON).
- **Core Systems:** Controllers (`Player`, `EnemyBase`, `BossBase`) consume these definitions polymorphically.
- **Scene Modularity:** Zones and levels are self-contained `.tscn` scenes that adhere to a standardized hierarchy, communicating with global managers through typed signals.

---

## 2. Level & Zone Schema

Every level is represented either as a Godot scene (`.tscn`) or an instantiated level data record:

```gdscript
{
    "id": "zone_04_sunken_ruins",
    "display_name": "Sunken Ruins",
    "biome": "aquatic_rot",
    "scene_path": "res://scenes/world/zone_04_sunken_ruins.tscn",
    "ambient_music": "music_sunken_temple",
    "bounds": {
        "min_x": -30.0,
        "max_x": 120.0,
        "min_y": -15.0,
        "max_y": 35.0
    },
    "entry_portals": [
        {
            "id": "portal_from_crypts",
            "position": Vector3(-25.0, 0.0, 0.0),
            "source_zone": "zone_02_crypts",
            "target_spawn": "Spawn_From_Crypts"
        }
    ],
    "spawn_points": [
        {"name": "Spawn_Default", "position": Vector3(0.0, 1.0, 0.0)},
        {"name": "Spawn_From_Crypts", "position": Vector3(-24.0, 1.0, 0.0)},
        {"name": "checkpoint_sunken_hall", "position": Vector3(45.0, 2.0, 0.0)}
    ],
    "required_flags": ["crypt_gate_unlocked"],
    "checkpoints": ["checkpoint_sunken_hall"],
    "boss_encounter": "The Wickframe"
}
```

---

## 3. Expandable Biomes & Content Roster

Beyond the 3 implemented core zones, the content framework provides specifications for 11 additional zones:

| Zone ID | Biome Theme | Unique Environmental Mechanic | Boss / Capstone Encounter |
|---|---|---|---|
| `zone_01_valley` | Emerald Valley | Introductory platforming, streams | Goblin Chieftain (Mini-boss) |
| `zone_02_crypts` | Ancient Crypts | Moving platforms, spike pits, crystal switches | Armored Charger pack |
| `zone_03_boss_arena` | Sunken Arena | Rising tide, detached limb minions | **The Wickframe** (Water/Rot Boss) |
| `zone_04_crystal_caverns` | Resonating Crystals | Light-refraction puzzles, prism redirection | **Skarn, the Splitting Crystal** |
| `zone_05_clockwork_fortress` | Mechanical Fortress | 90° rotating gear platforms, timed pressure plates | **Auger-9** (Clockwork Boss) |
| `zone_06_mirror_dimension` | Void / Horror | Palette-swapped inverse physics, shadow clones | **The Hollow Choir** (Tri-wraith Boss) |
| `zone_07_sky_isles` | Floating Islands | Wind-current updrafts, aerial platforming | Storm Drake (Mini-boss) |
| `zone_08_volcanic_core` | Magma / Obsidian | Rising lava hazards, cooling crust platforms | Molten Behemoth |
| `zone_09_frozen_citadel` | Glacial Ruins | Slippery ice physics, falling icicle stalactites | Frost Revenant |
| `zone_10_twilight_marsh` | Toxic Bog | Poison fog, sinking lilypads, submerged ruins | Hydra Swarm |
| `zone_11_astral_observatory` | Arcane Nebula | Low gravity zones, gravitational slingshots | Celestial Arbiter |
| `zone_12_underforge` | Blacksmith Sanctum | Piston crushers, molten metal troughs | Ancient Forgemaster |
| `zone_13_ashen_wastes` | Scorched Barrens | Dust storm vision occlusion, burrowing enemies | Ash Titan |
| `zone_14_worlds_root` | Primordial Core | Gauntlet of callback mechanics from prior biomes | **The Root-That-Remembers** (Final Boss) |

---

## 4. Equipment & Spell Expansion System

### 4.1 Weapon Types
- **Swords:** Balanced attack speed and damage, standard 3-hit combo.
- **Dual Daggers:** Fast 4-hit combo, lower damage, +15% critical hit chance.
- **Greatswords / Warhammers:** Slow 2-hit combo, heavy poise damage, built-in armor shred.
- **Spears:** Extended horizontal reach, forward lunging pierce attack.

### 4.2 Spells Roster
- `magic_bolt`: Basic directional projectile, triggers distant switches.
- `nova_burst`: Radial AoE shockwave, breaks shields and deflects enemy projectiles.
- `phase_dash`: Horizontal invulnerable blink through traps and enemies.
- `flame_arc`: Upward sweeping fire arc dealing high burning damage over time.
- `frost_shards`: Cone of ice projectiles that slow enemy movement speed by 40%.
- `spectral_shield`: Creates an orbiting aegis absorbing 3 incoming damage instances.

---

## 5. Content Validation Architecture

Validation is executed via `ContentValidator` before any production build:
1. Validates all item IDs referenced in loot tables, chests, and shops exist in `item_definitions`.
2. Validates all level scenes exist on disk and can be instantiated without errors.
3. Checks portal destination integrity to ensure no portals point to nonexistent scenes or spawn markers.
4. Validates quest chains for circular dependencies or unreachable stages.
