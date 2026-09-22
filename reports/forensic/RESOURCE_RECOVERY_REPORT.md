# RESOURCE RECOVERY & REVERSE-ENGINEERING AUDIT REPORT

**Date:** 2026-10-28  
**Project:** Swordigo V2: Extended Edition  
**Working Directory:** `/home/abhiboss/Projects/Swordigo 2/`  
**REA Framework:** `/home/abhiboss/rea` (Version 6.8.0)  

---

## 1. Executive Summary & Forensic Reality

This report establishes the verified, factual state of all reverse-engineering data and extracted assets in the project.

### 1.1 The Crucial Discrepancy
- **The Claimed Roster:** Previous reports and notes referenced 433 PowerVR `.POD` 3D model files, 291 `.pvr` texture files, 82 `.wav` sound effects, 16 `.mp3` music tracks, 165 binary Protobuf `.scene` levels, and 118 `.scl` script libraries.
- **The Actual Source:** These numbers originate from an authorized technical static analysis of `RLSwordigo.6.6.apk` (~95 MB, package `com.touchfoo.swordigo` / `com.swordiforge.rlswordigo`) performed on 2026-08-08, preserved in `/home/abhiboss/.gemini/antigravity/brain/9e79e42b-e4bc-443c-b139-4684c9b1d88e/swordigo_analysis.md`.
- **The Current Reality on Disk:** The actual `.apk` file (`RLSwordigo.6.6.apk`) and its raw unpacked binary assets do **NOT** currently exist anywhere on `/home/abhiboss/`.
- **The Only APK Provided:** The file present at `/home/abhiboss/Projects/Swordigo 2/swordigo.apk` (22,995,439 bytes, SHA-256 `86ce631b...`) is an **Aptoide Games distribution client** (`com.aptoide.android.aptoidegames`, v1.22.0).

---

## 2. Exhaustive Audit of Available Extracted Data

The 1,268 entries extracted from `swordigo.apk` into `reverse_engineering/extracted_assets/` were analyzed by file type, header signature, and content:

| Category | File Count | Verified Content Description | Swordigo Asset Status |
|---|---|---|---|
| **DEX Bytecode** | 4 files (`classes.dex` .. `classes4.dex`) | Multidex bytecode containing 32,061 class definitions for Aptoide app marketplace, AppLovin MAX, Mintegral, InMobi, Vungle, Firebase, and AndroidX. | **Zero** Swordigo / Touch Foo classes. |
| **Native Shared Objects** | 16 files (`lib/**/*.so`) | Compiled for 4 ABIs: `libandroidx.graphics.path.so`, `libapplovin-native-crash-reporter.so`, `libdatastore_shared_counter.so`, `libunitycoherencenative.so`. | **Zero** `libswordigo.so` or `libmini.so` libraries. |
| **Compiled XML** | 505 files (`res/**/*.xml`, `AndroidManifest.xml`) | Aptoide marketplace UI layouts, vector drawables, animation transitions. | **Zero** game layouts. |
| **PNG Images** | 457 files (`res/**/*.png`) | Aptoide marketplace icons, notification backgrounds, button textures. | **Zero** game sprite atlases or environment textures. |
| **Proto Schemas** | 23 files (`.proto`) | Google Protocol Buffers standard utility schemas (`any.proto`, `timestamp.proto`, `duration.proto`) from Firebase SDK. | **Zero** Touch Foo `Caver.Proto.Scene` schemas. |
| **Assets Directory** | 26 files (`assets/**/*`) | Lottie animation JSON files (`like.json`, `love.json`, `laugh.json`), Open Measurement SDK scripts (`omsdk-v1.js`), and public suffix lists. | **Zero** `.POD`, `.pvr`, `.scene`, or `.scl` files. |

---

## 3. Classification of Project Information

To maintain complete transparency and eliminate ambiguity, all data is categorized under six strict classifications:

### 3.1 Authentic Extracted Resources
- The 1,268 unpacked files in `reverse_engineering/extracted_assets/`. All belong to `com.aptoide.android.aptoidegames` and cannot be used for the in-game assets of Swordigo.

### 3.2 Inferred & Verified Metadata (The Technical Blueprint)
- Recovered from `swordigo_analysis.md` and user profile data in `~/.local/share/godot/app_userdata/Swordigo 2.0/swordigo2_save.json`:
  1. The complete listing of all 165 `.scene` level names (`grass_part1..3`, `town_part1`, `plains_woodkeep`, `thecave_part1..15`, `icecastle_part1..5`, etc.).
  2. The 21 core engine ECS components (`ModelComponent`, `CollisionShapeComponent`, `HealthComponent`, `DamageComponent`, `GroundMeshComponent`, `PortalComponent`, `SpawnPointComponent`, etc.).
  3. The 11 monster controller archetypes (`WalkingMonsterControllerComponent`, `BatMonsterControllerComponent`, `BouncingMonsterControllerComponent`, `ChargingMonsterControllerComponent`, `SkellyMonsterControllerComponent`, etc.).
  4. The 28 authentic achievements (`lostsword`, `shatteredblade`, `angrybats`, `theexplorer`, `duel`, `thedestroyer`, etc.).
  5. The complete Lua 5.1 API table surface (`Scene`, `Character`, `Game`, `Camera`, `Health`, `Portal`, `ItemDrop`, etc.).
  6. The 4-shard Mageblade progression structure.

### 3.3 Missing Original Resources (The Critical Blocker)
- **433 `.POD` PowerVR 3D Models:** The original 3D meshes (hero with keyframe skeletal animations, enemies, weapons, environment tiles, props) are missing.
- **291 `.pvr` Textures:** The original PVRTC/RGBA texture files are missing.
- **82 `.wav` Sound Effects:** The original PCM WAV audio files are missing.
- **16 `.mp3` Music Tracks:** The original background music streams are missing.
- **165 `.scene` Files:** The raw binary Protobuf level descriptor files containing vertex coordinates and entity placements are missing.
- **118 `.scl` Files:** The raw Lua script containers are missing.

### 3.4 Successfully Decoded Resources
- None currently (awaiting the authentic APK).

### 3.5 Partially Decoded Resources
- None currently.

### 3.6 Generated Replacement Resources
- None in the active project. All temporary procedural proxies, invented levels, and prototype builds were removed during Phase 1.3 and archived in `/home/abhiboss/Swordigo2_Backup_20261028/`.

---

## 4. Conclusion & Actionable Resolution

To preserve the authentic Swordigo experience literally—without guessing, without procedural substitutes, and without redesigning the game—the genuine original game APK must be provided.

The automated ingestion pipeline `scripts/importers/swordigo_apk_pipeline.py` is configured and standing by to ingest `Swordigo.apk` the instant it is supplied.
