# ASSET PIPELINE SPECIFICATION

**Project:** Swordigo V2 / Ironvale  
**Target Engine:** Godot 4.4  
**Pipeline Standard:** Clean-room, low-poly 3D assets with PBR-lite materials

---

## 1. Pipeline Principles & Provenance

In accordance with Phase 0 safety requirements and the project brief (`swordigo2_antigravity_brief.md`), this project enforces a 100% clean-room asset pipeline:
1. **Zero Proprietary Re-use:** No proprietary binary meshes (`.POD`), compressed texture formats (`.pvr`), or audio files from historical mobile packages are used.
2. **Modernized Low-Poly Aesthetic:** Assets are authored in clean, readable low-poly silhouettes with saturated color palettes, PBR-lite roughness/metallic values, and subtle toon rim lighting.
3. **Procedural & Vector Generation:** Textures, UI iconography, and materials are generated using high-fidelity vector / procedural generators or standard open-source formats.
4. **VFX Standard:** All particle effects (slashes, magic bolts, sparks, smoke, blood bursts, ambient dust) are authored in Godot's native `GPUParticles3D` for optimal performance on mobile and desktop.
5. **Audio Pipeline:** Sound effects (sword swings, impacts, footsteps, jumps, magic spells, coin pickups) and ambient themes are generated via high-sample-rate procedural synthesis and OGG/WAV encoding.

---

## 2. Directory Structure & Naming Conventions

```
game/assets/
├── models/
│   ├── player/
│   │   ├── hero_mesh.tscn (Low-poly hero model, sword, shield)
│   ├── enemies/
│   │   ├── goblin_mesh.tscn
│   │   ├── bat_mesh.tscn
│   │   └── boar_mesh.tscn
│   ├── bosses/
│   │   └── wickframe_mesh.tscn
│   ├── environment/
│   │   ├── platforms_grass.tscn
│   │   ├── platforms_stone.tscn
│   │   ├── pillars.tscn
│   │   └── trees_lowpoly.tscn
│   └── props/
│       ├── chest.tscn
│       ├── pot_breakable.tscn
│       └── checkpoint_monument.tscn
├── materials/
│   ├── mat_hero.tres
│   ├── mat_enemy_goblin.tres
│   ├── mat_terrain_grass.tres
│   ├── mat_terrain_stone.tres
│   ├── mat_magic_glow.tres
│   └── mat_water.tres
├── textures/
│   ├── ui/ (HUD icons, health hearts, mana crystals, coin icon)
│   └── particles/ (sparks, smoke, magic rings)
└── audio/
    ├── sfx/ (wav/ogg sound effects)
    └── music/
```

---

## 3. Automated Integrity Verification

The pipeline provides an automated asset audit script (`scripts/audit_assets.py` or within the Godot test suite) that validates:
- Every `.tscn` model and `.tres` material parses without missing dependencies.
- Texture compression and mipmap settings are optimal for 2.5D orthographic/perspective rendering.
- All audio streams exist and are correctly bound to `AudioManager`.
- All resource paths (`res://...`) referenced by items, quests, and levels resolve successfully.
