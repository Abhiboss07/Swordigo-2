# PHASE 0 — ENVIRONMENT AND SAFETY AUDIT REPORT

**Date:** 2026-10-28  
**Project:** Swordigo V2 / Ironvale  
**Author:** Antigravity / Claude Code (Principal Reverse Engineering & Game Engine Reconstruction)

---

## 1. System Environment

| Metric / Component | Verified Value | Evidence Source |
|---|---|---|
| **Operating System** | Linux cachyos-x8664 7.3.0-4-cachyos | `uname -a` |
| **Architecture** | x86_64 (64-bit Little Endian) | `lscpu` |
| **CPU Model** | 13th Gen Intel(R) Core(TM) i5-13420H (12 vCPUs) | `/proc/cpuinfo`, `lscpu` |
| **Memory (RAM)** | 15 GiB Total, ~9.8 GiB Available | `free -h` |
| **Disk Storage** | NVMe `/dev/nvme0n1p2`, 231 GiB Available (51% used) | `df -h /home` |
| **Primary Shell** | `/bin/fish` | Environment query |
| **Node.js** | v26.12.1 (`/usr/bin/node`) | `node --version` |
| **npm** | 12.2.1 (`/usr/bin/npm`) | `npm --version` |
| **pnpm** | 12.8.1 (`/home/abhiboss/.npm-global/bin/pnpm`) | `pnpm --version` |
| **Python** | 3.14.8 (`/usr/bin/python3`) | `python3 --version` |
| **Java JDK** | OpenJDK 27.0.1.0.3 64-Bit Server VM | `java -version` |
| **Godot Engine** | Godot 4.4.1.stable.official.49a5bc7b6 | `godot4 --version` |
| **Android ADB** | `/usr/bin/adb` installed | `which adb` |
| **Binary Tools** | `unzip`, `7z`, `file`, `strings`, `nm`, `objdump`, `readelf`, `gdb` | System PATH inspection |

---

## 2. Project & Repository Verification

### 2.1 REA Framework
- **Path:** `/home/abhiboss/rea`
- **Git Branch:** `main` (clean working tree)
- **Status:** Package built and verified (`rea@6.8.0`).
- **Catalog:** 175 CLI commands, 229 MCP tools, 6 MCP prompts.
- **Node compatibility fix:** Adjusted TypeScript type stripping in `scripts/lib/verifier-source-loader.mjs` for Node.js 26 compatibility (`mode: "strip"`).

### 2.2 Swordigo V2 Project
- **Path:** `/home/abhiboss/Projects/Swordigo 2/`
- **Initial State:** Non-git directory containing only `swordigo.apk`.
- **Git Baseline:** Initialized local Git repository on branch `main` with `.gitignore` guarding intermediate build artifacts, temporary caches, and `.apk` files.
- **Directory Structure Established:**
  - `game/` — Godot 4.4 project root
  - `docs/` — Architecture and gameplay specifications
  - `reports/forensic/` — Audit and forensic reports
  - `reverse_engineering/` — Extraction and decompilation staging
  - `tests/` — Automated test suites

### 2.3 Original APK Verification
- **Path:** `/home/abhiboss/Projects/Swordigo 2/swordigo.apk`
- **Symlink:** `/home/abhiboss/Projects/Swordigo 2/Swordigo.apk` -> `swordigo.apk` (created to preserve case sensitivity compatibility)
- **Size:** 22,995,439 bytes (~21.93 MB)
- **SHA-256:** `86ce631bec342eaadbdef12904abe80f693af0925ae6f3edad1cecd6c9777f47`
- **MD5:** `43954d694b8b7a35df2b133fbbd60ff3`
- **File Format:** Android package (APK), with Gradle `app-metadata.properties`.
- **Signature Schemes (REA verified):** v1=false, v2=true (RSA-256 self-consistent digest `d7fc649d...`).

---

## 3. Safety Controls & Invariants

1. **Original APK Preservation:** The source APK file is read-only in our forensic workflow; no in-place modifications or deletions will be executed.
2. **Git Integrity:** All development work is tracked via incremental Git commits. No force-checkout or destructive Git commands.
3. **Staging Isolation:** Forensic asset dumps and decompiler intermediates are isolated in `reverse_engineering/intermediate/` and omitted from production version control.
4. **Legal & Clean-Room Compliance:**
   - As documented in the project brief (`swordigo2_antigravity_brief.md`), the sequel project ("Ironvale") is an **independent, original implementation**.
   - No proprietary binary assets (`.POD`, `.pvr`, `.scl`, audio) will be directly packaged into the shipping sequel.
   - Gameplay mechanics (2.5D side-scrolling platformer, combat, equipment, level streaming, boss state machines) are reconstructed cleanly in Godot 4.4 GDScript.
