# ORIGINAL VS SWORDIGO V2 ("IRONVALE") FEATURE MATRIX

**Date:** 2026-10-28  
**Project:** Swordigo V2 ("Ironvale")  
**Engine:** Godot 4.4 (GDScript, CharacterBody3D 2.5D Configuration)

---

## 1. Comprehensive System Comparison

| System / Dimension | Original Reference Baseline (Swordigo 2012) | Swordigo V2 / Ironvale Implementation | Status & Verification |
|---|---|---|---|
| **Engine & Platform** | Custom C++ engine, OpenGL ES 1.1, iOS/Android | Godot 4.4 Engine, Modern Forward+/Mobile renderer, Desktop & Android export | Implemented & Verified |
| **Graphics & Shading** | Flat vertex colors, unlit/baked low-poly meshes, static billboards | Modernized low-poly with PBR-lite materials, dynamic `WorldEnvironment`, toon rim-light, depth-of-field parallax | Implemented |
| **Particle VFX** | 2D billboard sprite bursts | `GPUParticles3D` (weapon trails, spell impacts, embers, ambient leaves) | Implemented |
| **Player Controller** | 2.5D kinematic box controller, jump, double jump, basic wall jump | `CharacterBody3D` 2.5D controller with coyote time, jump buffering, variable jump cut, wall slide/kick, attack combo | Implemented & Verified |
| **Combat Mechanics** | Single button melee attack, fixed damage multiplier | 3-stage sword combo, weapon types, critical hits, poise damage, hit-stop, directional knockback | Implemented & Verified |
| **Magic System** | 4 linear spells (Magic Bolt, Fireball, Ice, Dimensional Rift) | 6 spell categories: Magic Bolt, Nova Shockwave, Phase Dash, Flame Arc, etc., mana-gated with cooldowns | Implemented & Verified |
| **Enemy AI** | Hardcoded C++ state machines (walker, bat, charger) | Modular GDScript state machines: Ground Patroller, Flying Stalker, Charger, Leaper, Ranged Caster | Implemented & Verified |
| **Boss Encounters** | 6 single-phase or simple dual-phase encounters | 5 multi-phase bosses with telegraphed attacks, arena hazards, and phase transitions | Implemented & Verified |
| **Level Structure** | 11 zones connected via portals, basic terrain tiles | 14+ zones with modular Godot `.tscn` architecture, named spawn-point routing, screen-fade streaming | Implemented & Verified |
| **Inventory & Equipment** | 1 Weapon, 1 Armor, 1 Bauble slot | Dedicated slots: 1 Weapon, 1 Armor, 1 Amulet, 2 Rings, 1 Trinket, consumable pouch | Implemented & Verified |
| **Quests & Progression** | Simple integer story flags | Flag-based Quest Manager, branching dialogue bubble UI, objective tracker | Implemented & Verified |
| **Save / Persistence** | Binary proprietary format | Human-readable & robust JSON save slots (`user://saves/`) with auto-save at checkpoints | Implemented & Verified |
| **UI & Audio** | Low-res fixed texture atlas, stereo sound effects | High-res responsive HUD, floating damage numbers, boss health bars, procedural/custom audio streams | Implemented & Verified |
| **Testing & QA** | Manual device testing | Headless automated test suite (`godot4 --headless`) verifying physics, combat, inventory, save/load, and zone transitions | Implemented & Verified |
