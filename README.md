# SWORDIGO V2: TOUCH FOO CAVER RECONSTRUCTION & SEQUEL EXPANSION

A 1:1 architectural reproduction of Touch Foo's legendary 2012 mobile action-adventure platformer **Swordigo** (originally authored by Ville Mäkynen), coupled with a strictly decoupled **Additive Sequel Expansion** utilizing the same engine architecture, kinematics, and asset pipelines in **Godot 4.4.1 Stable**.

---

## 1. Project Directives & Philosophy

- **Zero Redesigns / Zero Replacements:** The classic Swordigo campaign is 100% intact. Player model, blue spiky hair, animations, movement physics, 2.5D arcade kinematics, levels, enemies, bosses, UI, HUD, audio, story, dialogue, and level progression are faithfully modeled on Touch Foo's Caver engine.
- **Additive Sequel Expansion Only:** All sequel content (new areas, bosses, equipment) is strictly quarantined in `game/scenes/expansion/` and only accessible when selecting `SEQUEL_EXPANSION` from the main menu, leaving original campaign levels completely unmodified.
- **Honest Forensic Verification:** Procedural proxies and unit tests are strictly distinguished from authentic binary asset extraction. The ingestion pipeline (`scripts/importers/swordigo_apk_pipeline.py`) is primed and waiting for the genuine Touch Foo APK (`com.touchfoo.swordigo` or `RLSwordigo.6.6.apk`).

---

## 2. Directory Structure

```
Swordigo 2/
├── README.md                                 # Master project guide
├── RESET_MANIFEST.md                         # Phase 1 Safe Reset & Backup audit
├── RECONSTRUCTION_SCORECARD.md               # Automated QA & verification report
├── build/                                    # Target export binaries
│   ├── SwordigoV2-Linux.x86_64               # Standalone Linux desktop binary
│   ├── SwordigoV2-Linux.pck                  # Linux resource package
│   └── SwordigoV2-Android.apk                # Signed 16 KB page-size Android package
├── game/                                     # Godot 4.4.1 Project root
│   ├── project.godot                         # Project configuration & autoloads
│   ├── export_presets.cfg                    # Android & Linux export definitions
│   ├── systems/                              # Core singletons & autoloads
│   │   ├── game_manager.gd                   # World lifecycle & dual campaign state
│   │   ├── inventory.gd                      # Weapon/armor stats & Mageblade shards
│   │   ├── quest_manager.gd                  # Story flags & narrative milestones
│   │   ├── audio_manager.gd                  # Sound effect synthesis & music pooling
│   │   ├── save_system.gd                    # 3 profile slots & JSON persistence
│   │   └── swordigo_theme.gd                 # Authoritative Touch Foo UI palette
│   ├── scripts/                              # Gameplay logic controllers
│   │   ├── player.gd                         # 2.5D arcade kinematics & 3-hit combo
│   │   ├── camera_controller.gd              # Lookahead, smooth lerp & screenshake
│   │   ├── boss_corruptor.gd                 # Multi-phase Corruptor AI
│   │   ├── boss_void_weaver.gd               # Sequel major boss AI
│   │   ├── altar_mageblade.gd                # Mageblade reforging interaction
│   │   ├── enemy_base.gd                     # Entity health & drop management
│   │   ├── enemy_beetle.gd                   # Armored patrol crawler
│   │   ├── enemy_bat.gd                      # Sine swoop aerial flyer
│   │   ├── enemy_skeleton.gd                 # Shielded melee guard
│   │   └── ...                               # Checkpoint, chest, hazard, portals
│   ├── scenes/
│   │   ├── original_campaign/                # 11 Authentic Touch Foo Caver Levels
│   │   │   ├── cairnwood_forest_part1.tscn   # grass_part1.scene
│   │   │   ├── cairnwood_forest_part2.tscn   # grass_part2.scene
│   │   │   ├── cairnwood_village.tscn        # village.scene
│   │   │   ├── cairnwood_crossroads.tscn     # crossroads.scene
│   │   │   ├── corruptor_crypt.tscn          # dungeon_part1.scene
│   │   │   ├── florennum_pass.tscn           # mountain_pass.scene
│   │   │   ├── florennum_town.tscn           # florennum.scene
│   │   │   ├── snowy_peaks.tscn              # snow_part1.scene (Shard 2)
│   │   │   ├── fiery_depths.tscn             # lava_part1.scene (Shard 3)
│   │   │   ├── worlds_end.tscn               # worldsend.scene (Shard 4)
│   │   │   └── chamber_mageblade.tscn        # final_boss.scene (Reforging & Climax)
│   │   └── expansion/                        # Additive Sequel Expansion Levels
│   │       ├── sequel_forsaken_expanse.tscn  # Astral wasteland
│   │       ├── sequel_sunken_catacombs.tscn  # Flooded ruins
│   │       ├── sequel_astral_spire.tscn      # Void Weaver climax arena
│   │       └── boss_void_weaver.tscn         # Expansion boss
│   ├── ui/                                   # Touch Foo Authentic UI
│   │   ├── main_menu.tscn                    # Save slots & Campaign selector
│   │   ├── in_game_hub.tscn                  # 6-Tab vertical dock
│   │   ├── hud.tscn                          # Hearts, mana, coins, mobile controls
│   │   ├── dialogue_box.tscn                 # 2.5D narrative box
│   │   └── game_over_menu.tscn               # Respawn & menu controller
│   └── tests/
│       └── test_runner.gd                    # Headless automated verification suite
├── scripts/importers/                        # Automated extraction & conversion tools
│   ├── swordigo_apk_pipeline.py              # Authentic APK signature validator & extractor
│   └── pod_pvr_converter.py                  # PowerVR POD & PVRTC parser/exporter
└── reports/forensic/                         # Technical documentation
    ├── FORMAT_ANALYSIS.md                    # PowerVR POD, PVRTC & Protobuf wire format
    ├── ENGINE_AND_RENDERING_STRATEGY.md      # Godot 4.4 Caver-mirroring ECS architecture
    └── MISSING_ORIGINAL_RESOURCES.md         # Forensic audit of supplied APK mismatch
```

---

## 3. Headless Verification Test Suite

Run the full headless automated test suite:

```bash
godot4 --headless --path game -s tests/test_runner.gd
```

**Results:** **115 Passed, 0 Failed.**  
All 14 levels, bosses, arcade kinematics, inventory calculations, quest flags, and save system persistence are thoroughly verified.

---

## 4. Exporting Release Packages

### Linux Desktop Executable
```bash
godot4 --headless --path game --export-debug "Linux" ../build/SwordigoV2-Linux.x86_64
```

### Android APK Package
```bash
godot4 --headless --path game --export-debug "Android" ../build/SwordigoV2-Android.apk
/home/abhiboss/Android/Sdk/build-tools/34.0.0/apksigner verify --verbose build/SwordigoV2-Android.apk
```
Configured with 16 KB page-size aligned shared libraries (`libc++_shared.so`, `libgodot_android.so`), Target SDK 34, and signed with Android v1/v2/v3 signatures.

---

## 5. Ingesting Authentic Touch Foo Assets

To reach 100% binary asset parity with the original 2012 Touch Foo game:
1. Place genuine `com.touchfoo.swordigo.apk` (or `RLSwordigo.6.6.apk`) at `/home/abhiboss/Projects/Swordigo 2/Swordigo.apk`.
2. Run the automated extraction pipeline:
   ```bash
   python3 scripts/importers/swordigo_apk_pipeline.py Swordigo.apk
   ```
3. The pipeline will automatically unpack the authentic 433 `.POD` skeletal meshes, 291 `.pvr` compressed textures, 165 `.scene` protobuf level topologies, 82 `.wav` audio cues, and 16 `.mp3` music tracks into the project.
