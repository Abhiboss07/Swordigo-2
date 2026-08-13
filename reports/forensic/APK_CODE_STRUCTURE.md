# PHASE 2 — APK CODE STRUCTURE AUDIT

**Target:** `/home/abhiboss/Projects/Swordigo 2/swordigo.apk`  
**Package:** `com.aptoide.android.aptoidegames`  
**DEX Count:** 4 Multidex files (total uncompressed bytecode: 28.96 MB)  
**Total Classes:** 32,061  

---

## 1. Multidex Partitioning

| DEX File | Size | Class Count | Primary Responsibilities |
|---|---|---|---|
| `classes.dex` | 10.24 MB | 10,812 | Primary application bootstrap, `AptoideApplication`, core activities (`MainActivity`, `SupportActivity`, `UrlActivity`), OBB service, AndroidX lifecycle & startup |
| `classes2.dex` | 8.01 MB | 8,944 | Advertising mediation adapters (AppLovin, InMobi, Mintegral, Vungle), RTB (real-time bidding) webview redirection |
| `classes3.dex` | 8.55 MB | 9,410 | Google Play Services, Firebase Cloud Messaging, Firebase Crashlytics, Protocol Buffers, DataStore preferences |
| `classes4.dex` | 2.16 MB | 2,895 | Unity Mediation / Coherence SDK, GameGenie overlay service, Play & Earn foreground tracking |

---

## 2. Activity & Service Architecture

### 2.1 Main Declared Activities
- `com.aptoide.android.aptoidegames.MainActivity`: Launcher activity (`android.intent.action.MAIN`, category `LAUNCHER`). Manages game discovery catalog and downloads.
- `com.aptoide.android.aptoidegames.SupportActivity`: Support & helpdesk web interface.
- `com.aptoide.android.aptoidegames.UrlActivity`: Deep-link routing handler for `*.aptoide.com` and custom URL schemes.
- `com.aptoide.android.aptoidegames.feature_rtb.presentation.AdRedirectWebViewActivity`: In-app browser for sponsor redirection.
- `com.aptoide.android.aptoidegames.play_and_earn.presentation.permissions.OverlayPermissionActivity`: Manages `SYSTEM_ALERT_WINDOW` permission requests.
- `com.aptoide.android.aptoidegames.play_and_earn.presentation.permissions.UsageStatsPermissionActivity`: Manages `PACKAGE_USAGE_STATS` telemetry consent.

### 2.2 Foreground & Background Services
- `cm.aptoide.pt.installer.obb.ObbService`: Handles unpacking and placement of game expansion `.obb` containers into `/Android/obb/`.
- `com.aptoide.android.aptoidegames.gamegenie.presentation.GameGenieOverlayService`: Floating overlay HUD displayed over active games.
- `com.aptoide.android.aptoidegames.play_and_earn.presentation.service.PaEForegroundService`: Tracks play time for reward accrual.
- `com.aptoide.android.aptoidegames.notifications.AptoideGamesNotificationsService`: Push notification receiver.

---

## 3. Native Bindings & JNI Methods

Inspection of native libraries identified JNI registration entry points:
- `Java_androidx_graphics_path_PathParser_nParseAndAssign`: Vector path parsing.
- `Java_com_applovin_impl_adview_activity_FullscreenAdService_nInit`: Crash reporter signal hooks (`SIGSEGV`, `SIGBUS`, `SIGFPE`).
- `Java_androidx_datastore_preferences_core_AtomicSharedCounter_nIncrement`: Inter-process shared counter mutex.
- `Java_com_unity3d_services_core_coherence_nSend`: Coherence telemetry socket dispatcher.

---

## 4. Assessment for Swordigo V2 Reconstruction

The investigated APK is confirmed to be an app store client rather than the standalone Touch Foo game engine. As established in Phase 0 and the project brief, clean-room reconstruction in Godot 4.4 GDScript must proceed based on the reference 2.5D action-adventure mechanics:
- 2.5D CharacterBody3D player mechanics (horizontal physics, variable jump, double jump, wall slide, sword slash combo, magical projectiles).
- Entity state machines for enemies and bosses.
- Modular zone/level hierarchy connected via portals.
- Comprehensive UI, equipment, inventory, quest, and save/load systems.
