# RESET MANIFEST — SWORDIGO V2 CLEAN FOUNDATION RESET

**Date:** 2026-10-28  
**Project:** Swordigo V2: Extended Edition  
**Working Directory:** `/home/abhiboss/Projects/Swordigo 2/`  
**REA Framework Path:** `/home/abhiboss/rea`  
**Recoverable Backup Location:** `/home/abhiboss/Swordigo2_Backup_20261028` (359 MB, verified)

---

## 1. Reset Rationale

The previous Ironvale implementation and subsequent prototype reconstructions replaced authentic Swordigo content with invented elements (invented names, procedural proxy meshes, synthetic audio, and speculative levels). In accordance with the Master Reset Directive, all incorrect prototype code, scenes, builds, and assets have been purged from the active project to establish a clean, evidence-based foundation.

---

## 2. Preserved Artifacts & Verified Assets

| Artifact / Path | Status | SHA-256 Checksum | Description |
|---|---|---|---|
| `swordigo.apk` | **PRESERVED** | `86ce631bec342eaadbdef12904abe80f693af0925ae6f3edad1cecd6c9777f47` | Original supplied APK (22,995,439 bytes), identified as `com.aptoide.android.aptoidegames` v1.22.0. |
| `Swordigo.apk` | **PRESERVED** | Symlink to `swordigo.apk` | Preserves case-insensitive and case-sensitive path lookups. |
| `reverse_engineering/extracted_assets/` | **PRESERVED** | Verified (1,268 files) | Complete lossless extraction of `swordigo.apk` entries (DEX, native SOs, compiled Android resources). |
| `reports/forensic/` | **PRESERVED** | Verified (8 reports) | Forensic reports detailing APK metadata, code structure, resource inventory CSV, and REA capabilities. |
| `scripts/importers/swordigo_apk_pipeline.py` | **PRESERVED** | Verified | Automated ingestion, validation, and extraction script ready for the authentic game APK. |
| `docs/architecture/AUTHENTIC_SWORDIGO_EXPANSION_BLUEPRINT.md` | **PRESERVED** | Verified | Architectural blueprint enforcing dual-campaign separation between Base Game and Sequel Expansion. |
| `docs/SWORDIGO_FIDELITY_GAP_ANALYSIS.md` | **PRESERVED** | Verified | Gap analysis and status scorecard tracking authentic Swordigo components. |

---

## 3. Removed Prototype Components

The following components were removed from the active project and safely archived in the external backup:
1. `game/scenes/world/` (`zone_01_valley.tscn`, `zone_02_crypts.tscn`, `zone_03_boss_arena.tscn`, `cairnwood_forest.tscn`, `cairnwood_village.tscn`, `corruptor_crypt.tscn`).
2. `game/scenes/entities/` (procedural proxy meshes for player, patroller, flyer, charger, Wickframe boss, Corruptor proxy).
3. `game/scenes/ui/` (`hud.tscn`, `main_menu.tscn`, `in_game_hub.tscn`, `pause_menu.tscn`, `inventory_menu.tscn`, `game_over_menu.tscn`).
4. `game/scripts/` (prototype GDScript logic and systems).
5. `game/.godot/` (stale engine import caches and UID caches).
6. `builds/` (prototype Linux desktop binary `swordigo_v2.x86_64` and Android APK `swordigo_v2.apk`).
7. `game/tests/` (prototype test runner).

---

## 4. Recoverable Backup Verification

- **Backup Path:** `/home/abhiboss/Swordigo2_Backup_20261028/`
- **Total Size:** 359 MB
- **APK Verification in Backup:**
  `86ce631bec342eaadbdef12904abe80f693af0925ae6f3edad1cecd6c9777f47  /home/abhiboss/Swordigo2_Backup_20261028/swordigo.apk` (Exact Match)
- **Readability:** Confirmed readable via filesystem traversal.

---

## 5. Active Clean Project Structure (Phase 9 Compliant)

```
/home/abhiboss/Projects/Swordigo 2/
├── swordigo.apk                                 # Preserved supplied APK
├── Swordigo.apk -> swordigo.apk                 # Preserved symlink
├── RESET_MANIFEST.md                            # This audit record
├── reports/forensic/                            # Forensic audits & inventories
├── docs/                                        # Specifications, gap analysis, and blueprints
│   ├── architecture/
│   │   └── AUTHENTIC_SWORDIGO_EXPANSION_BLUEPRINT.md
│   └── SWORDIGO_FIDELITY_GAP_ANALYSIS.md
├── reverse_engineering/
│   ├── extracted_assets/                        # Unpacked entries from supplied APK
│   ├── raw_assets/                              # Target for genuine game POD/PVR/Scene assets
│   ├── decoded_assets/                          # Target for converted GLB meshes and PNG textures
│   └── asset_catalog/                           # Manifests and catalogs
├── scripts/
│   └── importers/
│       └── swordigo_apk_pipeline.py             # Automated ingestion & conversion pipeline
└── game/
    ├── assets/                                  # Verified production assets only
    ├── scenes/
    │   ├── original_campaign/                   # 100% authentic base game levels
    │   └── expansion/                           # Additive sequel levels
    ├── scripts/
    ├── systems/
    ├── ui/
    └── tests/
```
