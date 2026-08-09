# ENGINE & RENDERING STRATEGY EVALUATION

**Date:** 2026-10-28  
**Project:** Swordigo V2: Extended Edition  
**Author:** Antigravity / Claude Code  
**Framework:** Technical Architectural Evaluation  

---

## 1. The Original Engine Architecture: "Caver" (Touch Foo)

Based on our static forensic analysis of the authentic game binaries and symbol tables (`swordigo_analysis.md`), the original Swordigo is built on **Caver**, a proprietary C++ engine authored by Ville Mäkynen for iOS (2012) and ported to Android (2013).

### 1.1 Core Caver Subsystems
- **Graphics Pipeline:** Fixed-function OpenGL ES 1.1 (`libGLESv1_CM.so`). Vertex lighting, unlit flat shading, and simple texture combiners.
- **Mesh & Skeletal Animation:** PowerVR SDK (`CPVRTModelPOD`). 3D models stored in binary `.POD` containers with keyframe animation matrices.
- **Textures:** PowerVR compressed textures (`.pvr`) using PVRTC4/PVRTC2 lossy compression and RGBA4444 uncompressed formats.
- **Scene Serialization:** Google Protocol Buffers (`google::protobuf::MessageLite`). Level maps stored in binary `.scene` files containing serialized `Caver.Proto.Scene` messages.
- **Scripting Layer:** Lua 5.1 runtime wrapped in `.scl` Protobuf containers, dispatched via `libmini.so`.
- **Physics:** Custom 2.5D kinematic physics engine integrated directly into the scene hierarchy (`PhysicsObjectComponent`, `GroundMeshComponent`, `PhysicsPlatformComponent`).
- **Audio:** OpenAL-Soft for spatial 3D effects (`.wav`) and Android `MediaPlayer` for background music tracks (`.mp3`).

### 1.2 Limitations of the Original Engine Today
- **Source Availability:** The C++ source code of Caver has never been published. `libswordigo.so` is a stripped native binary.
- **Modern Platform Deprecations:**
  - Modern Android 14+ devices (and Android 15 with 16 KB memory page sizes) enforce 64-bit ELF alignment and deprecate 32-bit `armeabi-v7a` legacy drivers.
  - Modern mobile and desktop GPUs no longer natively support fixed-function OpenGL ES 1.1 pipelines.

---

## 2. Evaluation of Reconstruction Approaches

| Evaluation Criteria | Approach A: Native C++ Re-implementation | Approach B: Godot Engine 4.4 (Selected) | Approach C: Custom Monolithic Engine |
|---|---|---|---|
| **2.5D Physical Fidelity** | Requires writing custom physics solver | Native `CharacterBody3D` with Z-lock provides exact arcade precision | Requires writing custom solver from scratch |
| **Asset Compatibility** | Can link PowerVR SDK directly | Converts `.POD` to glTF 2.0 and `.pvr` to PNG losslessly | Requires custom asset loader integration |
| **Android 16 KB Alignment** | Complex custom NDK build scripts | Built-in verified Android export with NDK r27 support | High maintenance burden |
| **Multi-Platform Support** | Linux, Windows, Android require separate toolchains | Unified cross-platform export (Linux x86_64, Android, Web) | Difficult to maintain across operating systems |
| **Sequel Extensibility** | Requires recompiling binary for every new level | Modular scene composition (`.tscn`) and data-driven level loading | Hardcoded scene files |
| **Automated Testing** | Requires writing custom test harness | Built-in headless execution (`godot4 --headless -s`) | Custom test framework required |

---

## 3. Selected Strategy: Godot 4.4 with Caver-Mirroring ECS Architecture

Godot 4.4 is the optimal target engine, provided it is configured to mirror the exact behavior of Caver rather than implementing a generic platformer.

### 3.1 Strict Fidelity Constraints Imposed on Godot:
1. **Exact 2.5D Physics Lock:** All gameplay entities lock `position.z = 0` and `velocity.z = 0`. No 3D drift or lateral sliding.
2. **Fixed Kinematic Constants:** Acceleration, jump arcs, and terminal velocities match Caver's documented values rather than default Godot physics constants.
3. **Caver Component Mapping:**
   - `GroundMeshComponent` -> `StaticBody3D` on Physics Layer 1 (World).
   - `PortalComponent` -> `Area3D` on Physics Layer 7 (Interactable) with destination scene and named spawn point routing.
   - `SpawnPointComponent` -> `Marker3D`.
   - `CollisionShapeComponent` -> `CollisionShape3D` (Box, Sphere, Capsule, Convex).
   - `HealthComponent` / `DamageComponent` -> Decoupled Hitbox/Hurtbox nodes.
4. **Rendering Style:**
   - Shading mode configured for unshaded / lightweight PBR-lite to preserve the iconic saturated low-poly aesthetic of original Swordigo without overexposed PBR blowout.
   - Fixed 55° FOV camera positioned at $Z = 8.5\text{ m}$ with 1.2 m vertical deadzone.
