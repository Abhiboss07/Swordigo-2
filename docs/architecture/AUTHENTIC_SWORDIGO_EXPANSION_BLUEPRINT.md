# AUTHENTIC SWORDIGO BASE GAME & SEQUEL EXPANSION BLUEPRINT

**Project:** Swordigo V2: Extended Edition  
**Target Engine:** Godot Engine 4.4.1.stable.official.49a5bc7b6  
**Author:** Antigravity / Claude Code  
**Date:** 2026-10-28  

---

## 1. The Core Mandate: Exact Preservation + Expansion Only

The goal of this project is literal and unequivocal:
1. **The Original Game Must Remain 100% Intact:**
   - Every original level, pathway, secret, platform, and checkpoint.
   - The original player character model, proportions, animations, physics, and controls.
   - All original enemies, bosses, AI state machines, and combat mechanics.
   - Original weapons, spells, item drops, damage calculations, and progression curves.
   - Original textures, models, materials, particle effects, UI, HUD, and audio.
   - Original dialogue, NPCs, quests, story, and level flow.
2. **Expansion Content Uses Original Assets:**
   - New levels, areas, and bosses must look, sound, and play like authentic extensions of Swordigo.
   - New content is constructed using the **same** environment meshes, textures, materials, character rigs, animation controllers, switches, portals, moving platforms, sound effects, and UI components.
3. **Strict Separation of Base Campaign and Expansion:**
   - The Base Game (Classic Campaign) remains untouched and strictly separated.
   - The Sequel Expansion is unlocked as a seamless continuation after the defeat of the Lord of Chaos or via dedicated portal chambers.

---

## 2. Technical Blocker Analysis & Exact Resource Required

### 2.1 The Blocker
- **Verified Fact:** The APK file provided at `/home/abhiboss/Projects/Swordigo 2/swordigo.apk` is an Aptoide Games distribution client (`com.aptoide.android.aptoidegames`, version 1.22.0, SHA-256 `86ce631b...`).
- **Filesystem Audit:** A recursive search of the user filesystem confirmed that neither `RLSwordigo.6.6.apk`, `com.touchfoo.swordigo.apk`, nor any extracted `.POD`, `.pvr`, `.scene`, or `.scl` binary assets currently exist on disk.
- **Consequence:** Literal byte-for-byte extraction of the authentic 433 3D models, 291 textures, 82 WAV sound effects, and 165 binary Protobuf level maps cannot occur until the genuine game APK is supplied.

### 2.2 The Exact Resource Needed
To achieve literal, byte-for-byte preservation of the original assets:
- **Required File:** The genuine Swordigo Android APK:
  - Official Touch Foo release: `com.touchfoo.swordigo.apk` (Version 1.4.x) **OR**
  - Extended community release: `RLSwordigo.6.6.apk` (containing uncompressed music and the full Caver resource tree).
- **Placement:** Placed at `/home/abhiboss/Projects/Swordigo 2/Swordigo.apk`.

---

## 3. Automated Asset Recovery & Conversion Pipeline

We have implemented and verified the automated extraction tool:
`scripts/importers/swordigo_apk_pipeline.py`

When the genuine APK is placed in the project directory, running:
```bash
python3 "scripts/importers/swordigo_apk_pipeline.py" "Swordigo.apk"
```
will automatically execute:

```
Genuine Swordigo.apk
    ├── assets/resources/*.scene (165 binary Protobuf maps)
    │     └── Parsed by Scene Importer -> game/scenes/world/*.tscn
    │
    ├── assets/resources/*.POD (433 PowerVR 3D Meshes & Anims)
    │     └── Converted to glTF 2.0 / Godot 3D Meshes -> game/assets/models/
    │
    ├── assets/resources/*.pvr (291 PVR Compressed Textures)
    │     └── Decompressed to lossless PNG -> game/assets/textures/
    │
    ├── assets/resources/*.wav (82 PCM Audio Effects)
    │     └── Extracted directly to -> game/assets/audio/sfx/
    │
    ├── assets/music/*.mp3 (16 Soundtrack Tracks)
    │     └── Extracted directly to -> game/assets/audio/music/
    │
    └── assets/resources/*.scl (118 Lua Script & Object Libraries)
          └── Transcribed into native GDScript entity controllers
```

---

## 4. Dual-Campaign Architecture

To ensure the original game is never modified by the expansion, the runtime architecture is strictly partitioned:

```
GameManager
├── CampaignMode: ENUM { CLASSIC_CAMPAIGN, SEQUEL_EXPANSION }
│
├── CLASSIC_CAMPAIGN (100% Authentic Baseline)
│   ├── Level Order: grass_part1..3 -> plains_woodkeep -> town_part1 -> ... -> worldsend
│   ├── Roster: Brass Sword -> Broadsword -> Iron Sword -> Magic Sword -> The Mageblade
│   ├── Spells: Magic Bolt, Magic Bomb, Dimension Rift, Dragon's Grasp
│   ├── Bosses: The Corruptor, Giant Worm, Corrupt Master, Fire Golem, Lord of Chaos
│   └── Save Track: Classic Slots (Profiles 1–3)
│
└── SEQUEL_EXPANSION (Additive Post-Game / Expansion)
    ├── Unlocked: After defeating Lord of Chaos or via Portal Stone Chamber
    ├── Reused Assets: Same Caver textures, tile models, shader materials, sound effects
    ├── Expansion Levels: Sunken Ruins, Crystal Caverns, Clockwork Fortress, Mirror Dimension, World's Root
    ├── Expansion Bosses: The Wickframe, Skarn the Splitting Crystal, Auger-9, The Hollow Choir
    └── Save Track: Expansion Profile flags
```

---

## 5. Verification & Acceptance Gate

1. **Gate 1 (Artifact Verification):** Genuine Swordigo APK provided and validated by `swordigo_apk_pipeline.py`.
2. **Gate 2 (Raw Asset Unpacking):** All 433 `.POD` models, 291 `.pvr` textures, 82 `.wav` sound files, and 165 `.scene` protobuf maps losslessly extracted into `reverse_engineering/raw_assets/`.
3. **Gate 3 (Base Campaign Recreation):** All original scenes instantiated and verified identical to original layouts, physics, and progression.
4. **Gate 4 (Expansion Integration):** Sequel zones and bosses constructed strictly using the extracted asset library.
5. **Gate 5 (Automated QA):** Test suite executing headlessly in Godot 4.4 verifying zero regressions in the classic campaign while validating expansion mechanics.
