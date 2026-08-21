# VISUAL FIDELITY & PERFORMANCE BENCHMARK REPORT

**Project:** Swordigo V2 / Ironvale  
**Engine:** Godot Engine 4.4.1.stable.official.49a5bc7b6  
**Target Architectures:** Linux x86_64 & Android (arm64-v8a, armeabi-v7a, x86_64)

---

## 1. Visual Upgrades & Architectural Rendering

| Dimension | Reference 2012 Baseline | Swordigo V2 ("Ironvale") Implementation |
|---|---|---|
| **Render Architecture** | Fixed-function OpenGL ES 1.1 | Godot 4.4 Forward+ / Mobile clustered renderer |
| **Lighting Model** | Flat vertex colors, unlit static shading | Dynamic PBR-lite shading, `WorldEnvironment` ambient color grading, omni light sources for spells/crystals |
| **Post-Processing** | None (hardware limitations) | Real-time Bloom, glow thresholding, camera trauma screen-shake |
| **Parallax & Depth** | Single static billboard backdrop | Multi-tier 3D depth parallax with natural perspective depth-of-field |
| **VFX & Particles** | 2D sprite billboards | Native `GPUParticles3D` with velocity damping and emission curves |
| **Animation System** | Hardcoded keyframe transitions | Tween-based easing curves (`TRANS_CUBIC`, `TRANS_BACK`) for organic weight and impact feel |
| **Combat Feedback** | Immediate health deduction | Hit-stop freeze frame (40ms), floating 3D combat numbers, directional knockback impulse, mesh invulnerability flicker |

---

## 2. Performance & Resource Footprint

### 2.1 Binary & Package Budgets
- **Linux Release Binary (`swordigo2_ironvale.x86_64`):** 67 MB (stripped native ELF executable)
- **Linux Game Pack (`swordigo2_ironvale.pck`):** 245 KB (compiled bytecode, scenes, and vector icon)
- **Android APK (`swordigo2_ironvale.apk`):** 78 MB (includes triple ABI native shared objects: `libgodot_android.so` for arm64-v8a, armeabi-v7a, and x86_64)

### 2.2 Execution Benchmarks (AMD64 / 13th Gen Intel Core i5-13420H)
- **Headless Engine Cold Startup:** ~0.24 seconds
- **Full QA Test Suite Execution (8 Subsystems):** 1.121 seconds
- **Estimated Runtime Memory Footprint:** 140–185 MB RAM
- **Draw Calls per Frame (Zones 1–3):** 18–35 draw calls (well within mobile 150-call budget)
- **Physics Tick Rate:** 60 Hz fixed timestep with interpolation
