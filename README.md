# decompiler-kit

A self-installing, reproducible toolkit for **decompiling, reverse-engineering, and
statically recompiling binaries**, with an accompanying asset-pipeline and runtime tooling
set. One command installs ~60 tools (Ghidra, Binary Ninja Free, rizin/Cutter, RetDec, x64dbg,
dnSpy, ILSpy, jadx, Frida, angr, xboxrecomp, N64Recomp, XenonRecomp, and more) from their
official upstream releases, with per-tool SHA-256 verification where upstream pins allow it,
plus license attribution.

The repo itself is small (this is a bootstrap + manifest, no tool binaries). Everything is
declared in a single machine-readable manifest and materialised locally on demand, so the
installed layout is deterministic and reproducible across machines.

> No tool binaries are stored in this repository. `bootstrap.ps1` / `bootstrap.sh` download
> each tool from its official upstream release at install time (the full install is ~5 GB).
> Versions and hashes are pinned in `manifest/tools.json`.
>
> **AI agents:** if the user asks you to fetch/set up this repo, read `AGENTS.md` and run the
> bootstrapper automatically — do not ask the user to download tools by hand.

---

## Table of contents

- [Overview](#overview)
- [How it works](#how-it-works)
- [Bundled tool: `dissectdat` (REA)](#bundled-tool-dissectdat-rea)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Installing a subset / custom location](#installing-a-subset--custom-location)
- [Activating the environment](#activating-the-environment)
- [Repository layout](#repository-layout)
- [Tool catalog](#tool-catalog)
- [Python libraries](#python-libraries)
- [Triage in 30 seconds](#triage-in-30-seconds)
- [Workflows](#workflows)
- [Extras and hardening](#extras-and-hardening)
- [Managing the manifest](#managing-the-manifest)
- [Reproducibility and verification](#reproducibility-and-verification)
- [As an AI-agent skill](#as-an-ai-agent-skill)
- [Troubleshooting](#troubleshooting)
- [Legal](#legal)
- [License](#license)

---

## Overview

`decompiler-kit` is designed for two kinds of consumers:

1. **Humans at a terminal** — `bootstrap` installs, `env` puts everything on `PATH`, and each
   tool runs exactly as it would from its own release.
2. **AI agents** — `SKILL.md` is a self-contained skill that tells the agent where every tool
   lives and the exact command sequence per target, so an agent can drive the toolkit without
   guessing paths.

It is not a wrapper or an emulator: it is a **pin-and-fetch layer** over the real tools. You
get the same `ghidraRun`, `rizin`, `retdec-decompiler`, `x64dbg`, `ILSpy`, `jadx`, etc. that
you would get from upstream — just resolved into one predictable directory tree.

The design goals, in order:

- **Reproducible** — every release download is pinned to an exact tag + asset and (usually) a
  SHA-256. A given manifest produces the same install on any machine.
- **Transparent** — no magic wrappers. Tools are extracted verbatim; you invoke upstream
  binaries directly.
- **Attributable** — every tool's license and upstream URL is recorded in `NOTICE.md`.
- **Relocatable** — the install root is a single variable (`GAME_RE_ROOT`); nothing assumes a
  fixed path.

## How it works

```
manifest/tools.json   ──►  bootstrap.{ps1,sh}  ──►  tools/<category>/<id>/…
        │                       │
        │ pins tag/asset/sha    │ kind: release → download + verify + extract
        │                       │ kind: git     → shallow clone (optionally --recurse-submodules)
        │                       │ kind: pip     → python -m pip install <packages>
        │                       │ kind: direct  → per-OS vendor URL (e.g. Binary Ninja Free installer)
        │
        └──►  env.{ps1,sh}  ──►  resolves install dirs + adds them to PATH (+ GHIDRA_HOME)
```

Both bootstrappers read the **same** `manifest/tools.json`, so Windows and Unix produce an
equivalent layout. The env scripts are also manifest-driven: they walk the manifest, add each
tool's install directory (plus common `bin/`, `support/`, `x64/`, `x86/`, `artifacts/`
subdirectories and versioned inner folders), and set `GHIDRA_HOME` / `GHIDRA_INSTALL_DIR`.

This means **adding a tool is a data change, not a code change** (see
[Managing the manifest](#managing-the-manifest)).

## Bundled tool: `dissectdat` (REA)

Unlike the downloadable tools, `dissectdat/` is a **vendored source copy** of
[REA — Reverse Engineer Anything](https://github.com/morluto/rea) (MIT, © morluto). It is
committed directly so it is available **immediately after cloning**, before the larger tools
finish downloading.

- Full source, ~85 MB (`src/`, `bridge/`, `native/`, `scripts/`, `docs/`, tests, website).
- Its own git history is **not** included (only source files).
- **Not** covered by this repo's MIT license — it keeps its own license at
  `dissectdat/LICENSE`.
- To use it: `cd dissectdat && npm install` (Node version pinned in `dissectdat/.nvmrc`).

## Requirements

| Component | Needed for | Notes |
| --- | --- | --- |
| Windows PowerShell 5.1+ / bash | bootstrap + env | Both are provided; pick your platform. |
| `curl` | downloads | Bundled with Windows 10+; standard on macOS/Linux. |
| `tar` | `.zip` extraction | Windows 10+ ships `tar.exe`. |
| `git` | `kind: git` tools | Any recent git. |
| Python 3 + `pip` | `kind: pip` tools, GhidraMCP | `python3` on Unix, `python` on Windows. |
| JDK 21+ | Ghidra | Any JDK 21+ (e.g. Liberica/Temurin). Set `JAVA_HOME`. |
| 7-Zip | `.7z` / `.rar` archives | `.7z` via bundled `7zr.exe`; `.rar` (ReClass.NET) needs installed 7-Zip. |
| Node.js (24.x) | `dissectdat` | See `dissectdat/.nvmrc`. |

Disk: ~5 GB for the full tool install (Binary Ninja Free alone is a ~440 MB installer), plus
~85 MB for the vendored `dissectdat` source.

## Quick start

**Windows (PowerShell):**

```powershell
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
. .\env.ps1          # dot-source to modify the current session
```

**macOS / Linux:**

```bash
./bootstrap.sh
source ./env.sh
```

Installs land in `./tools/<category>/<id>/`. The bootstrap is **idempotent**: it skips any tool
whose directory is already populated. Use `-Force` (PowerShell) or `--force` (bash) to
reinstall/repair.

Most tools are extracted ready to run. One exception: **Binary Ninja Free** is an installer
(`kind: direct`), so the bootstrap downloads it to
`tools/01_Disassemblers/binaryninja/` — run that `.exe`/`.dmg` once (on Linux the zip is
extracted), and keep using the installed app. It is the free non-commercial tier (no
API/plugins); paid editions are not bundled.

## Installing a subset / custom location

```bash
# Only some tools (faster first run, smaller disk)
ONLY=ghidra,rizin,retdec ./bootstrap.sh

# PowerShell equivalent
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1 -Only ghidra,rizin,retdec
```

```bash
# Install somewhere other than ./tools (must use the same root when activating)
export GAME_RE_ROOT=/opt/retools        # bash
$env:GAME_RE_ROOT = "D:\retools"        # PowerShell
./bootstrap.sh
```

The env scripts read `GAME_RE_ROOT` first, then fall back to `./tools` next to the repo.

## Activating the environment

Sourcing the env script for the session is all that's required:

```powershell
. .\env.ps1        # sets PATH, GAME_RE_ROOT, GHIDRA_HOME / GHIDRA_INSTALL_DIR
```

```bash
source ./env.sh
```

What it does:

- Adds each installed tool directory to `PATH` (skips `kind: git` source repos, which contain
  nothing runnable).
- Adds `bin/`, `support/`, `x64/`, `x86/`, `artifacts/` subdirectories where present.
- Resolves **versioned** install dirs (Ghidra ships inside `ghidra_12.2_PUBLIC/`, rizin inside
  `rizin-win-installer-*/`, Cutter under `Cutter-v2.5.0-*/`).
- Exports `GHIDRA_HOME` and `GHIDRA_INSTALL_DIR` for Ghidra/GhidraMCP.
- Exports `GAME_RE_ROOT` so scripts and the agent skill agree on the root.

Pip-installed tools (Frida, angr, …) are not on `PATH`; they live in your Python
environment — invoke them via `python -m` or their entry-point scripts.

## Repository layout

```
decompiler-kit/
├─ manifest/tools.json      # source of truth: 60 tools, 7 categories
├─ bootstrap.ps1 | .sh      # installers (release / git / pip / direct kinds)
├─ env.ps1 | .sh            # session activation (PATH, GHIDRA_HOME, GAME_RE_ROOT)
├─ AGENTS.md                # AI-agent setup instructions (auto-install this kit)
├─ SKILL.md                 # AI-agent skill (per-target workflows)
├─ NOTICE.md                # per-tool licenses + upstream URLs
├─ docs/research.md         # deep notes: what each tool is for, what to add later
├─ scripts/
│  ├─ install-extras.ps1    # Tier-D: adware/account-gated/big tools (winget + links)
│  └─ harden.ps1            # disable Ghidra usage metrics + GUI telemetry toggles
├─ dissectdat/              # vendored REA source (MIT, © morluto) — see above
└─ tools/                   # created by bootstrap; NOT committed (gitignored)
```

## Tool catalog

Tools land at `tools/<category>/<id>/`. Versioned inner folders are resolved by `env`; the
paths below show the category and tool id.

### `01_Disassemblers` — static analysis & decoding

| Tool | What it's for |
| --- | --- |
| **Ghidra** | NSA's decompiler suite; headless mode (`analyzeHeadless`) for automation, scriptable in Python/Java. |
| **GhidraMCP** | MCP bridge so an agent can drive Ghidra (GUI or headless). |
| **Binary Ninja (Free)** | Vector 35's decompiler UI with an integrated debugger and built-in MCP server. Free tier covers x86/x86_64/ARMv7/AArch64, non-commercial, no API/plugins. Installer is downloaded per OS; run it once. |
| **rizin** | Fast CLI reverse-engineering framework (radare2 lineage); `-A` auto-analysis, xrefs, scripting. |
| **Cutter** | GUI front-end for rizin. |
| **Detect It Easy** | Compiler/packer detection (`diec.exe`) — identify UPX/Themida/VMProtect before wasting time. |
| **PE-bear** | PE viewer/editor: headers, sections, imports/exports, resources. |
| **capa** | Detects capabilities (crypto, injection, anti-VM) from disassembly. |
| **FLOSS** | Extracts obfuscated/stack strings from binaries. |
| **ImHex** | Hex editor with a pattern language — ideal for reversing custom asset formats. |
| **UPX** | Unpack UPX-compressed binaries (`upx -d`) before analysis. |
| **Dependencies** | Recursive DLL import/dependency walker (GUI + CLI). |
| **CyberChef** | Data transforms (decode/decrypt/parse) in a single offline HTML app. |
| **angr + androguard** | Symbolic execution / binary analysis; Android APK analysis. |
| **Diaphora** | Binary diffing (patch analysis / version diffing). Plugin for IDA Pro / Ghidra. |
| **Triton** | Dynamic binary analysis + symbolic execution / taint tracking (built from source). |

### `02_Debuggers` — runtime truth

| Tool | What it's for |
| --- | --- |
| **x64dbg** | Native Windows debugger with a plugin ecosystem. |
| **dnSpy (dnSpyEx)** | .NET decompiler + debugger + assembly editor. |
| **ScyllaHide** | Anti-anti-debug plugin for x64dbg (hides debugger from checks). |
| **decomp2dbg** | Syncs Ghidra/IDA/Binja symbols into GDB. |

### `03_Source-Decompilers` — binary → source

| Tool | What it's for |
| --- | --- |
| **RetDec** | One-command binary → C for PE/ELF/Mach-O. |
| **jadx** | Android DEX → Java (GUI + CLI). |
| **Apktool** | APK decode/rebuild (manifest, resources, smali). |
| **JPEXS FFDec** | Flash/SWF decompiler + editor. |
| **ILSpy** | Clean .NET C# decompiler (readable output). |
| **Recaf** | Java bytecode editor/analyzer. |
| **de4dot** | .NET deobfuscator (un-rename, string decrypt, un-ConfuserEx). |

### `04_Static-Recompilation` — binary → native source

| Tool | Target |
| --- | --- |
| **xboxrecomp** | Original Xbox (x86 / `.xbe`) → C with runtime libs. |
| **N64Recomp** (+ RecompModTool) | N64 (MIPS) → C + mod tooling. |
| **XenonRecomp** | Xbox 360 (PowerPC / `.xex`) → C/C++. |
| **gba-matching-decomp-skill** | Matching (byte-identical) GBA decompilation with agbcc. |

### `05_Game-Mods-and-Assets` — assets & content pipelines

| Tool | What it's for |
| --- | --- |
| **AssetRipper** | Unity assets → Unity project. |
| **UABEA** | Unity asset/bundle editor. |
| **Il2CppDumper** | Recover types/methods/structs from IL2CPP `GameAssembly.dll` + `global-metadata.dat`. |
| **Cpp2IL** | Modern IL2CPP → C#/DLL recovery; fallback when Il2CppDumper struggles with newer Unity. |
| **BepInEx** | Unity Mono + IL2CPP mod loader. |
| **MelonLoader** | Unity mod loader (IL2CPP-first). |
| **FModel** | Unreal Engine asset browser/exporter (`.pak`, `.uasset`, `.umap`). |
| **UAssetGUI** | Edit Unreal `.uasset` files with a GUI. |
| **UE4SS** | Unreal Engine 4/5 scripting system: Lua/C++ mods, blueprint dumps, live property editing. |
| **repak** | Unreal `.pak` packer/unpacker (CLI). |
| **GDRE Tools** | Godot `.pck` extractor + project decompiler (GDScript/C#). |
| **UndertaleModTool** | GameMaker (`data.win`) unpacker/decompiler/repacker: code, assets, and mods. |
| **quickbms** | Generic archive extractor (thousands of community scripts). |
| **xdelta3** | Binary diff/patch (the standard for ROM-hack patches). |
| **flips** | IPS/BPS patcher. |
| **armips** | Assembler for patching console binaries. |
| **asar** | SNES ROM assembler/patch tool. |
| **xdvdfs** | Modern Xbox ISO tool (extract/build). |
| **Crowbar** | Source-engine asset (VPK/MDL) extractor/compiler. |
| **vgmstream** | Game audio decoder/player (`.wem`, `.adx`, `.hca`, `.fsb`, many more). |

### `06_Memory-and-Instrumentation` — live process work

| Tool | What it's for |
| --- | --- |
| **Frida** | Dynamic instrumentation: hook functions, dump memory, bypass checks (pip). |
| **ReClass.NET** | Live memory scanner + C++ structure builder (pairs with x64dbg). |
| **SystemInformer** | Process/memory/handle inspector (Sysinternals-style). |
| **Squalr** | Open-source memory scanner (Cheat Engine alternative). |

### `07_Network-and-APIs` — traffic & API analysis

| Tool | What it's for |
| --- | --- |
| **Mitmproxy** | Interactive HTTPS proxy for API interception (pip). |
| **Objection** | Frida-based mobile runtime inspection (pip). |

`Wireshark` and `Caido (Basic)` are account/adware-sensitive and live in
`scripts/install-extras.ps1` instead.

Full per-tool notes, target triage, and a "what else to add" research list: `docs/research.md`.
Licenses and upstream links: `NOTICE.md`.

## Python libraries

Installed via `pip` by the `py-libs` manifest entry (and a few standalone entries):

- `capstone` — disassembly engine
- `pefile` — PE parsing
- `lief` — binary parsing/patching (PE/ELF/Mach-O)
- `keystone-engine` — assembler
- `unicorn` — CPU emulator
- `dnfile` — .NET metadata parsing
- plus `frida`, `decomp2dbg`, `rzpipe`, `angr`, `androguard`, `mitmproxy`, `objection`

## Triage in 30 seconds

Before choosing a workflow, identify the target:

```powershell
# What is it? (compiler / packer / arch)
& "$GAME_RE_ROOT\01_Disassemblers\detect-it-easy\diec.exe" target.exe

# Headers, imports, sections (fast CLI)
rizin -q -c "iI; ii; iS" target.exe

# Capabilities (crypto / injection / anti-analysis)
& "$GAME_RE_ROOT\01_Disassemblers\capa\capa.exe" target.exe -q

# De-obfuscated strings
& "$GAME_RE_ROOT\01_Disassemblers\floss\floss.exe" target.exe
```

| Signal | Path forward |
| --- | --- |
| `UnityPlayer.dll`, `GameAssembly.dll`, `*_Data/` | Unity (Mono or IL2CPP) |
| `Managed/Assembly-CSharp.dll` | Unity Mono → dnSpy / BepInEx |
| `global-metadata.dat` + `GameAssembly.dll` | Unity IL2CPP → Cpp2IL / Il2CppDumper + MelonLoader |
| `.pak` + `Engine/` | Unreal → FModel / UAssetGUI / UE4SS |
| `.pck` + `project.godot` | Godot → GDRE Tools |
| `data.win` / `game.win` | GameMaker → UndertaleModTool |
| `default.xbe` | Original Xbox → xboxrecomp + xdvdfs |
| `default.xex` | Xbox 360 → XenonRecomp |
| `.gba` | GBA → gba-matching-decomp skill |
| `.apk` | jadx + apktool |
| `UPX0`/`UPX1` sections | UPX → `upx -d` first |

## Workflows

> This is where the asset- and content-side (game modding) tooling comes in — the top of this
> README is deliberately scoped to decompilation and reverse engineering.

### Native binary — structure and decompilation

```powershell
# Ghidra GUI (version dir resolved dynamically)
$g = (Get-ChildItem "$GAME_RE_ROOT\01_Disassemblers\ghidra" -Directory | Sort Name -Descending | Select -First 1).FullName
& "$g\ghidraRun.bat"

# Ghidra headless
& "$g\support\analyzeHeadless.bat" C:\work\proj p1 -import target.exe

# Binary → C in one step
& "$GAME_RE_ROOT\03_Source-Decompilers\retdec\bin\retdec-decompiler.exe" --cleanup -o target.c target.exe

# Unpack a UPX-packed binary first
& "$GAME_RE_ROOT\01_Disassemblers\upx\upx-5.3.0-win64\upx.exe" -d target.exe
```

### Native binary — runtime confirmation

```powershell
& "$GAME_RE_ROOT\02_Debuggers\x64dbg\release\x64\x64dbg.exe" target.exe
```

### AI-agent-driven Ghidra (MCP)

```powershell
python -m ghidra_mcp --headless --binary target.exe --save
```

### .NET and Unity

```powershell
& "$GAME_RE_ROOT\02_Debuggers\dnspy\dnSpy.exe" "Game\Managed\Assembly-CSharp.dll"
& "$GAME_RE_ROOT\03_Source-Decompilers\ilspy\ILSpy.exe"   # alternative, cleaner C#
# IL2CPP (try Cpp2IL first on recent Unity; Il2CppDumper is the classic fallback)
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\cpp2il\Cpp2IL-2022.0.7-Windows.exe" --game-path "Game" --output "cpp2il-out"
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\il2cppdumper\Il2CppDumper.exe" "Game\GameAssembly.dll" "Game\global-metadata.dat" "dump-out"
```

### Unreal Engine

```powershell
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\fmodel\FModel.exe"          # browse/export .pak + .uasset
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\uassetgui\UAssetGUI.exe"     # edit a .uasset
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\repak\repak.exe" --help      # pack/unpack .pak
# Install UE4SS into the game's Binaries\Win64 folder (Lua/C++ mods, live object dumps)
```

### Godot

```powershell
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\gdre-tools\gdre_tools.exe"   # recover .pck + decompile GDScript
```

### GameMaker

```powershell
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\undertalemodtool\UndertaleModTool.exe"   # open data.win
```

### Android

```powershell
java -jar "$GAME_RE_ROOT\03_Source-Decompilers\apktool\apktool_3.0.3.jar" d app.apk -o out
& "$GAME_RE_ROOT\03_Source-Decompilers\jadx\jadx-gui-1.5.6.exe" app.apk
```

### Console static recompilation

```powershell
# Original Xbox
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\xdvdfs\xdvdfs.exe" extract --input game.iso --output gf
cd "$GAME_RE_ROOT\04_Static-Recompilation\xboxrecomp"
py -3 -m tools.xbe_parser gf\default.xbe --json gf\default_analysis.json
py -3 -m tools.recomp      gf\default.xbe --all --split 250 --gen-dir ..\mygame\src\recomp\gen

# GBA matching decompilation: follow dissectdat/ or the gba-matching-decomp skill.
```

### Assets, patch formats, and content pipelines

```powershell
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\assetripper\AssetRipper.GUI.Free.exe"
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\vgmstream\vgmstream-cli.exe" -o out.wav "sound.wem"
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\xdelta3\xdelta3-3.1.0-x86_64.exe" -d -s base.rom patch.xdelta out.rom
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\flips\flips.exe"
```

### Runtime hooking / memory

```powershell
frida-trace -p <pid> -i "CreateFile*"
& "$GAME_RE_ROOT\06_Memory-and-Instrumentation\reclass\x64\ReClass.NET.exe"
```

## Extras and hardening

**Extras (Tier D)** — tools that are account-gated, adware-bundled, or very large, so they are
not auto-installed:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-extras.ps1            # all
powershell -ExecutionPolicy Bypass -File .\scripts\install-extras.ps1 -Only wireshark
```

Covers: Cheat Engine (decline bundled extras), IDA Free, RenderDoc, Ninja Ripper,
Dolphin/PCSX2/Ryujinx/PPSSPP/melonDS/BizHawk, Sysinternals, Wireshark, Caido.
Binary Ninja Free is handled by the bootstrap (see [Quick start](#quick-start)); only paid
Binary Ninja editions are manual.

**Telemetry hardening** — reduce outbound analytics from the installed tools:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\harden.ps1
```

Sets Ghidra's usage-metrics flag and prints the GUI toggles for AssetRipper / ImHex / Cutter /
Squalr.

## Managing the manifest

Adding a tool is a data change. Edit `manifest/tools.json`, re-run the bootstrap, and update
`NOTICE.md`.

| Field | Applies to | Required | Meaning |
| --- | --- | --- | --- |
| `id` | all | yes | Directory name under `category/`. |
| `name` | all | yes | Display name. |
| `kind` | all | yes | `release` \| `git` \| `pip` \| `direct`. |
| `category` | all | yes | Top-level folder (e.g. `01_Disassemblers`). |
| `license` | all | yes | License string (see `NOTICE.md`). |
| `repo` | release | yes | `owner/name` on GitHub. |
| `tag` | release | yes | Exact GitHub release tag. |
| `asset` | release | yes | Exact release asset filename. |
| `extract` | release | yes | `zip` \| `7z` \| `rar` \| `none`. |
| `sha256` | release | optional | Expected hash; omit to skip verification. |
| `url` | git | yes | Clone URL. |
| `submodules` | git | optional | `true` to recurse submodules. |
| `packages` | pip | yes | Array of pip package names. |
| `url` | direct | yes* | Vendor download URL (*unless per-OS `platforms` given). |
| `platforms` | direct | optional | `{ "win32": {url, extract}, "darwin": …, "linux": … }`. |
| `extract` | direct | optional | Same values as `release`, per platform (default `none`). |

**Release** (pinned GitHub asset):

```json
{
  "id": "rizin",
  "name": "Rizin",
  "kind": "release",
  "category": "01_Disassemblers",
  "repo": "rizinorg/rizin",
  "tag": "v0.9.1",
  "asset": "rizin-windows-static-v0.9.1.zip",
  "extract": "zip",
  "sha256": "<64 hex chars>",
  "license": "LGPL-3.0"
}
```

**Git** (source clone):

```json
{ "id": "diaphora", "name": "Diaphora", "kind": "git",
  "category": "01_Disassemblers",
  "url": "https://github.com/joxeankoret/diaphora.git", "license": "Apache-2.0" }
```

**Pip**:

```json
{ "id": "mitmproxy", "name": "Mitmproxy", "kind": "pip",
  "category": "07_Network-and-APIs",
  "packages": ["mitmproxy"], "license": "MIT" }
```

**Direct** (vendor installer, per OS):

```json
{ "id": "binaryninja", "name": "Binary Ninja (Free)", "kind": "direct",
  "category": "01_Disassemblers",
  "platforms": {
    "win32": { "url": "https://cdn.binary.ninja/installers/binaryninja_free_win64.exe", "extract": "none" },
    "darwin": { "url": "https://cdn.binary.ninja/installers/binaryninja_free_macosx.dmg", "extract": "none" },
    "linux": { "url": "https://cdn.binary.ninja/installers/binaryninja_free_linux.zip", "extract": "zip" }
  },
  "license": "Proprietary (free non-commercial tier; no API/plugins)" }
```

## Reproducibility and verification

- Downloads are pinned by exact `tag` + `asset`.
- When `sha256` is present, the bootstrapper aborts that tool on mismatch.
- The bootstrap skips populated directories, so re-runs are cheap and repair-focused.
- Install logs are written to `<root>/install.log` (gitignored).
- `kind: git` tools are shallow clones; `kind: pip` resolves the latest matching wheel (pin via
  your own constraints if you need bit-for-bit reproducibility for those).
- `kind: direct` uses the vendor's official unversioned installer URL (Binary Ninja Free), so
  neither the version nor a sha256 is pinned — re-running fetches the current free build.

## As an AI-agent skill

`SKILL.md` is written so an agent can operate the toolkit end-to-end: it assumes `GAME_RE_ROOT`
is set (the env scripts do this), then uses the per-target command sequences above.

- `AGENTS.md` (repo root) is the setup contract: an agent asked to "fetch this repo" installs
  everything by running the bootstrapper, verifies `tools/install.log`, activates `env`, and
  reports `GAME_RE_ROOT` — no manual downloads, no prompts.
- After install, usage is prompt-driven: give the agent the target path and the goal, e.g.
  "decompile `C:\games\foo\foo.exe` with the kit" or "this is Unity IL2CPP — dump the classes
  and hook `Player.Health`". The agent reads `SKILL.md` and picks Ghidra, RetDec, Il2CppDumper,
  dnSpy/ILSpy, jadx, etc.
- Copy/reference `SKILL.md` in your agent's skills directory so it loads automatically.
- Companion skills worth installing:
  - `ghidra` (headless recipes + GhidraMCP) — see the SKILL's Ghidra sections.
  - `gba-matching-decomp` — https://github.com/FacundoMainere/gba-matching-decomp-skill

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Ghidra won't launch | Install JDK **21+** and set `JAVA_HOME`; verify with `java -version`. |
| RetDec fails to start | Needs `libcrypto-1_1-x64.dll` (bundled in `RetDec\bin`). |
| `.rar` (ReClass.NET) not extracted | Install 7-Zip (`winget install 7zip.7zip`), then re-run bootstrap. |
| `angr`/`androguard` pip fails | Often the newest Python (e.g. 3.14); use a 3.11–3.12 venv. Best-effort entry — a failure here doesn't block the rest. |
| Tool "not found" after install | Re-run env activation (`. .\env.ps1` / `source ./env.sh`); make sure `GAME_RE_ROOT` matches the install root. |
| Path seems wrong | Versioned tools (Ghidra/rizin/Cutter) resolve the inner folder automatically — don't hardcode the version dir. |
| Windows path case | On case-sensitive systems, use the manifest `id` verbatim (e.g. `detect-it-easy`, not `DetectItEasy`). |
| Reinstall one tool | `-Force -Only <id>` (PowerShell) or `--force` with `ONLY=<id>` (bash). |

## Legal

Analysis and development tools only. **You must own the software you decompile or modify.**
Do not redistribute ROMs, ISOs, XBEs, decrypted assets, or proprietary code. The vendored
`dissectdat/` retains its own MIT license and copyright.

## License

This repository (manifest, bootstrappers, env scripts, docs) is **MIT** — see `LICENSE`.
The reverse-engineering tools are **not** part of this repository: they are downloaded at
install time and remain under their own licenses (see `NOTICE.md`). The vendored
`dissectdat/` source is separately licensed (see `dissectdat/LICENSE`).
