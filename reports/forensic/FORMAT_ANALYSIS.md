# SWORDIGO BINARY FORMAT & CONVERSION ANALYSIS

**Date:** 2026-10-28  
**Project:** Swordigo V2: Extended Edition  
**Author:** Antigravity / Claude Code  
**Framework:** REA v6.8.0 / Native Binary Forensics  

---

## 1. Overview & Technical Foundation

The authentic Swordigo game (iOS/Android 2012–2014) runs on Touch Foo's proprietary **Caver** C++ game engine, authored by Ville Mäkynen. Rather than standard open-source game engines, Caver utilizes specialized binary formats chosen for mobile hardware constraints of OpenGL ES 1.1 / PowerVR SGX535 devices.

This document details the exact technical specifications of each authentic format, its decompression/decoding requirements, and the conversion path into Godot 4.4.

---

## 2. PowerVR 3D Model Format (`.POD`)

### 2.1 Format Identification & Specification
- **Format:** PowerVR Object Data (POD).
- **Source SDK:** Imagination Technologies PowerVR Tools & SDK (`CPVRTModelPOD`).
- **File Extension:** `.POD` (433 files in authentic game).
- **Binary Structure:**
  - **Header:** 32-bit format version identifier (`PVRObjectData`).
  - **Node Hierarchy:** Tree of scene nodes representing bones, mesh instances, lights, and cameras.
  - **Geometry Blocks:**
    - Vertex coordinates: 3-component float32 (`x, y, z`).
    - Vertex normals: 3-component float32.
    - Texture coordinates (UV): 2-component float32 (`u, v`).
    - Vertex colors: 4-component uint8 (`RGBA`).
    - Bone indices & weights: 4-component uint8/float32 for skeletal deformation.
    - Index buffer: uint16 triangle strip or triangle list.
  - **Animation Tracks:**
    - Keyframe matrices or decoupled Position (`Vector3`), Rotation (`Quaternion`), and Scale (`Vector3`) tracks sampled at 30/60 Hz.
  - **Materials & Textures:** String references pointing to corresponding `.pvr` texture files.

### 2.2 Conversion Pipeline to Godot 4.4
- **Target Format:** glTF 2.0 (`.glb`) or Godot native `MeshInstance3D` + `AnimationPlayer`.
- **Decoder Tooling:** Headless Imagination Technologies `PVRTexTool` / `PVRGeoPOD` or open-source Python POD parser.
- **Conversion Acceptance Criteria:**
  1. Vertex positions and UV mapping match original mesh coordinates.
  2. Bone vertex weights deform meshes without tearing.
  3. Animation clips (idle, run, jump, slash combo) match original frame timing and keyframe counts.

---

## 3. PowerVR Texture Format (`.pvr`)

### 3.1 Format Identification & Compression Types
- **Format:** PowerVR Texture Container.
- **File Extension:** `.pvr` (291 files in authentic game).
- **Header:** 52-byte PVR v2 header or 64-byte PVR v3 header (Magic: `0x03525650` / `"PVR\x03"`).
- **Internal Compression Codecs Used in Swordigo:**
  1. **PVRTC4:** 4 bits per pixel lossy compression for large terrain and background textures.
  2. **PVRTC2:** 2 bits per pixel lossy compression for distant geometry.
  3. **RGBA4444:** 16-bit uncompressed (4 bits per channel) for UI elements and sprite sheets requiring sharp transparency.
  4. **RGBA8888:** 32-bit uncompressed for characters and weapon glows.

### 3.2 Conversion Pipeline to Godot 4.4
- **Target Format:** Lossless PNG with pre-multiplied alpha handling.
- **Decoder Tooling:** Python `pillow` with PVR decoder plugin or `PVRTexToolCLI -i input.pvr -o output.png -f r8g8b8a8`.
- **Conversion Acceptance Criteria:**
  1. 100% color fidelity and accurate alpha channel preservation.
  2. No channel swapping (RGBA vs BGRA).
  3. Pixel dimensions equal to source texture dimensions (including retina `@2x` variants).

---

## 4. Protobuf Level Scene Format (`.scene`)

### 4.1 Format Identification & Serialization
- **Format:** Google Protocol Buffers (`MessageLite` serialization).
- **File Extension:** `.scene` (165 level files in authentic game).
- **Message Type:** `Caver.Proto.Scene`.
- **Internal Structure:**
  - Serialized binary wire format (varints, 64-bit fixed, length-delimited byte chunks).
  - Contains array of `SceneObject` definitions:
    * `identifier` (string token, e.g. `"portal_to_village"`, `"chest_01"`).
    * `transform` (Position `x,y,z`, Rotation `x,y,z,w`, Scale `x,y,z`).
    * Polymorphic `Component` list:
      - `GroundMeshComponent` / `GroundPolygonComponent`: Static terrain vertices and collision boundaries.
      - `CollisionShapeComponent`: Box, circle, or polygon physics colliders.
      - `PortalComponent`: Level transition triggers with destination level name and target spawn ID.
      - `SpawnPointComponent`: Named player spawn coordinates.
      - `HealthComponent` / `DamageComponent`: Entity stats.
      - `ItemDropComponent`: Loot tables and chest drops.
      - `ProgramComponent`: Embedded Lua scripts governing level logic and triggers.

### 4.2 Conversion Pipeline to Godot 4.4
- **Target Format:** Godot 4.4 text scenes (`.tscn`).
- **Decoder Tooling:** Dedicated Protobuf wire-format parser (`scripts/importers/protobuf_scene_importer.py`).
- **Conversion Acceptance Criteria:**
  1. Exact world coordinates `(x, y, z)` preserved without drift.
  2. Terrain geometry and collision boundaries instantiated on Godot Physics Layer 1 (World).
  3. Portals linked to corresponding target scenes and named spawn markers.

---

## 5. Script & Object Library Format (`.scl`)

### 5.1 Format Identification & Execution
- **Format:** Protocol Buffers container wrapping Lua 5.1 bytecode / source chunks.
- **File Extension:** `.scl` (118 script files in authentic game, e.g., `weapons.scl`, `baubles.scl`, `abilities.scl`).
- **Contents:**
  - Entity archetype definitions and parameters.
  - Lua scripts executing against the Caver engine table API (`Scene`, `Character`, `Game`, `Camera`, `Health`, `Portal`, `ItemDrop`, `Bauble`).

### 5.2 Conversion Pipeline to Godot 4.4
- **Target:** Native typed GDScript 2.0 controllers.
- **Mapping:**
  - `Character.AddItem(name)` -> `Inventory.add_item(name)`
  - `Game.EnterPortal(scene, spawn)` -> `SceneTransition.transition_to_scene(scene, spawn)`
  - `Health.CurrentHealth()` -> `player.current_health` / `enemy.current_health`
  - `Camera.Rumble(val)` -> `camera_controller.add_trauma(val)`

---

## 6. Audio Formats (`.wav` and `.mp3`)

### 6.1 Sound Effects (`.wav`)
- **Format:** Uncompressed Microsoft RIFF WAV PCM.
- **Sample Rates:** 22,050 Hz and 44,100 Hz, 16-bit mono/stereo.
- **Count:** 82 files.
- **Conversion:** Direct, lossless placement into `game/assets/audio/sfx/` as `AudioStreamWAV`.

### 6.2 Music Tracks (`.mp3`)
- **Format:** MPEG-1 Audio Layer 3 (MP3).
- **Bitrate:** 128–192 kbps stereo.
- **Count:** 16 tracks (`1_boss23.mp3`, `1_dung73.mp3`, `1_hero2.mp3`, `1_plaintest2.mp3`, `2cave2.mp3`, etc.).
- **Conversion:** Direct placement into `game/assets/audio/music/` as `AudioStreamMP3` with looping enabled.
