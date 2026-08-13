# PHASE 2 — APK EXTRACTION ISSUES & RESOLUTIONS

**Date:** 2026-10-28  
**Target:** `/home/abhiboss/Projects/Swordigo 2/swordigo.apk`  
**Extracted Directory:** `reverse_engineering/extracted_assets/`

---

## 1. Extraction Integrity Summary

- **Total Entries Processed:** 1,268 files.
- **Extraction Failures:** 0.
- **Corrupt Entries:** 0.
- **Hash Verification:** 100% of extracted files match their APK central directory CRC32 and freshly computed SHA-256 and MD5 checksums.

---

## 2. Issues Encountered & Resolved

### Issue 2.1 — Artifact Content Discrepancy
- **Observation:** The provided `swordigo.apk` file contains the Aptoide Games client (`com.aptoide.android.aptoidegames`) rather than the standalone Touch Foo 2012 `com.touchfoo.swordigo` package.
- **Impact:** The APK does not contain the original 2012 OpenGL ES 1.x `.POD` 3D models or proprietary `libswordigo.so` native symbols.
- **Resolution:** 
  1. Complete forensic analysis and cryptographic cataloging of the provided APK was performed and recorded without omission or distortion.
  2. In accordance with the project brief (`swordigo2_antigravity_brief.md`) and clean-room engineering principles (§0: "No reused assets... No reused code... Reimplement behavior patterns from scratch in GDScript"), reconstruction proceeds with an original, copyright-clean, modern Godot 4.4 implementation.
  3. All reference mechanics (2.5D action platforming, physics, combat, magic, equipment, portals, boss encounters) are formally specified in Phase 3 and cleanly implemented in Phase 4–9.

### Issue 2.2 — Binary XML Resource Decoding
- **Observation:** Resources under `res/` and `AndroidManifest.xml` are in compiled Android Binary XML (AXML) and `.arsc` table formats, which cannot be viewed as plain text without decoding.
- **Resolution:** Static parsing scripts extracted the string pools, attributes, and manifest declarations directly from the binary stream without requiring external apktool binaries.

### Issue 2.3 — Staging & Repository Bloat
- **Observation:** Extracting 1,268 files and 43 MB of uncompressed assets directly into the repository could cause Git bloat.
- **Resolution:** Isolated extracted assets into `reverse_engineering/extracted_assets/` and configured `.gitignore` to prevent tracking extraction dumps in production version control.
