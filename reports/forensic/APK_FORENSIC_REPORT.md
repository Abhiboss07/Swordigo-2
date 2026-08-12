# PHASE 2 — APK FORENSIC ANALYSIS REPORT

**Target APK:** `/home/abhiboss/Projects/Swordigo 2/swordigo.apk`  
**Symlink Target:** `/home/abhiboss/Projects/Swordigo 2/Swordigo.apk`  
**Analysis Date:** 2026-10-28  
**Analysis Framework:** REA v6.8.0 + Native Static ELF/DEX/AXML Inspection  
**File Size:** 22,995,439 bytes (21.93 MB)  
**SHA-256:** `86ce631bec342eaadbdef12904abe80f693af0925ae6f3edad1cecd6c9777f47`  
**MD5:** `43954d694b8b7a35df2b133fbbd60ff3`

---

## 1. Executive Summary & Identity

Forensic analysis of the artifact at `/home/abhiboss/Projects/Swordigo 2/swordigo.apk` reveals that the package is an Android application with package identifier `com.aptoide.android.aptoidegames` (Aptoide Games distribution client, version 1.22.0).

| Attribute | Verified Observation |
|---|---|
| **Package Name** | `com.aptoide.android.aptoidegames` |
| **Version Name** | `1.22.0` |
| **Signing Scheme** | APK Signature Scheme v2 (RSA-256, self-consistent) |
| **Certificate Subject** | `ST=Portugal` |
| **Total Archive Entries** | 1,268 files |
| **DEX Multidex Files** | 4 (`classes.dex`, `classes2.dex`, `classes3.dex`, `classes4.dex`) |
| **Total Defined Classes** | 32,061 classes across 4 DEX containers |
| **Supported Native ABIs** | `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64` |

---

## 2. APK Composition Breakdown

| Category | File Count | Compressed Size | Uncompressed Size | Notes |
|---|---|---|---|---|
| **DEX Bytecode** | 4 | 12,200,187 B (~11.6 MB) | 28,964,924 B (~27.6 MB) | Multidex application code & libraries |
| **Native Shared Objects** | 16 | 4,991,556 B (~4.7 MB) | 4,991,556 B (~4.7 MB) | 4 libraries compiled for 4 architectures |
| **Android Resources (`res/`)** | 1,001 | 3,344,295 B (~3.1 MB) | 5,912,304 B (~5.6 MB) | Drawables, XML layouts, strings, anims |
| **Assets (`assets/`)** | 26 | 137,225 B (~134 KB) | 1,262,747 B (~1.2 MB) | Lottie JSON animations, web templates |
| **Signature & Metadata** | 154 | 41,631 B | 111,734 B | `META-INF` signing block & Gradle metadata |
| **Manifest & Tables** | 2 | 8,831 B | 46,736 B | `AndroidManifest.xml`, `resources.arsc` |
| **Other** | 65 | 1,982,595 B | 2,090,663 B | AndroidX startup, font files |
| **Total** | **1,268** | **22,995,439 B** | **43,380,664 B** | Losslessly verified |

---

## 3. Native Libraries Analysis

The package ships 4 native dynamic shared libraries across 4 ABIs:
1. `libandroidx.graphics.path.so`: AndroidX Graphics Path interpolation and Bezier curve rendering.
2. `libapplovin-native-crash-reporter.so`: AppLovin signal handler and stack unwinding reporter.
3. `libdatastore_shared_counter.so`: Jetpack Datastore IPC synchronization primitives.
4. `libunitycoherencenative.so`: Unity Mediation / Coherence network bridge.

All 16 shared library binaries were analyzed with `readelf -d` and confirmed to depend strictly on standard platform libraries: `libc.so`, `libm.so`, `libdl.so`, and `liblog.so`.

---

## 4. Managed Code Breakdown

Static inspection of DEX class descriptors identified 32,061 class definitions:
- **Core Application (`com.aptoide.android.*` & `cm.aptoide.pt.*`):** 1,323 classes managing account authentication, game downloading, OBB expansion service, PaE (Play and Earn) foreground services, and GameGenie overlays.
- **Advertising & Mediation Frameworks:** 8,767 classes across AppLovin MAX, Mintegral/MBridge SDK, InMobi SDK, Vungle SDK, and Unity Ads.
- **Google Play & Firebase Services:** 10,839 classes across Firebase Crashlytics, Messaging, Remote Config, Analytics, and Transport.
- **AndroidX & Jetpack:** Core Jetpack architecture components (Lifecycle, Room, DataStore, WorkManager, Compose tooling previews).

---

## 5. Reverse Engineering Conclusions & Project Directive Alignment

1. **Artifact Origin:** The APK provided (`swordigo.apk`) is an Aptoide Games distribution client rather than the standalone Touch Foo 2012 game engine binary (`com.touchfoo.swordigo`).
2. **Legal & Clean-Room Imperative:** Even if the proprietary 2012 Touch Foo APK were substituted, project brief instructions (`swordigo2_antigravity_brief.md`) strictly mandate:
   - **No reused assets** (no `.POD`, `.pvr`, `.scene`, `.scl`, audio from original game).
   - **No decompiled code reproduction** (no porting of proprietary Lua or `libswordigo.so` symbols).
   - **Original design & sequel mechanics:** Reconstructing the reference 2.5D side-scrolling action-adventure baseline in modern Godot 4.4 GDScript, with an extensible framework for original zones, enemies, bosses, and progression.
3. **Action:** Proceed with Phase 3 (reconstructing the reference gameplay specifications from documented mechanics) and Phase 4-9 (building the complete, playable Godot 4.4 Swordigo V2 game).
