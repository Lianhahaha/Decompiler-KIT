---
name: decompiler-kit
description: Decompile, reverse engineer, recompile, and mod games with a self-installing local toolkit. Use for native PC game binaries, Unity/Unreal/Godot/.NET/Android games, Xbox/Xbox 360/N64/GBA recompilation or matching decompilation, asset extraction, archive unpacking, audio extraction, memory scanning, and runtime hooking. First run bootstrap (./bootstrap.sh or bootstrap.ps1) then activate env (source env.sh or . .\env.ps1). Covers Ghidra (+ GhidraMCP), Binary Ninja Free, rizin/Cutter, RetDec, x64dbg, dnSpy, ILSpy, jadx, apktool, JPEXS FFDec, capa, floss, PE-bear, ImHex, Detect It Easy, UPX, Frida, AssetRipper, UABEA, Il2CppDumper, Cpp2IL, BepInEx, MelonLoader, FModel, UAssetGUI, UE4SS, repak, GDRE Tools, UndertaleModTool, vgmstream, quickbms, xdelta3, flips, ReClass.NET, xboxrecomp, N64Recomp, XenonRecomp.
metadata:
  version: "2"
---

# Game RE / Decompilation / Modding toolkit

A self-installing toolkit. It ships no binaries — run the bootstrap once to download
everything (versions + sha256 pinned in `manifest/tools.json`) into `./tools/`.

```
bootstrap.ps1          (Windows)     -> installs into .\tools\
bootstrap.sh           (macOS/Linux) -> installs into ./tools/
env.ps1 / env.sh       -> activate PATH + GHIDRA_HOME for a session
manifest/tools.json    -> pinned versions + sha256
NOTICE.md              -> per-tool licenses
```

## First use

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
. .\env.ps1

# macOS / Linux
./bootstrap.sh && source ./env.sh
```

`$env:GAME_RE_ROOT` / `$GAME_RE_ROOT` is then the tools root. Prefer that variable over
hardcoded paths. Tools live at `<root>/<category>/<id>`, e.g. `<root>/01_Disassemblers/Ghidra`.

## Hard rules

1. Never claim a decompile/mod works without running it and quoting output.
2. Never commit or redistribute ROMs, ISOs, XBEs, decrypted assets, or game code.
3. Resolve versioned dirs dynamically (Ghidra/rizin/cutter ship inside a version folder).
4. Detect the engine first (Detect It Easy / PE-bear) before choosing a workflow.

## Categories (what's under tools/)

| Category | Tools |
| --- | --- |
| `01_Disassemblers` | Ghidra, GhidraMCP, Binary Ninja (Free installer), rizin, Cutter, Detect It Easy, PE-bear, capa, floss, ImHex, UPX, Dependencies, CyberChef, angr, Diaphora, Triton |
| `02_Debuggers` | x64dbg, dnSpy, ScyllaHide, decomp2dbg |
| `03_Source-Decompilers` | RetDec, jadx, apktool, JPEXS FFDec, ILSpy, Recaf, de4dot |
| `04_Static-Recompilation` | xboxrecomp, N64Recomp, XenonRecomp, gba-matching-decomp-skill |
| `05_Game-Mods-and-Assets` | AssetRipper, UABEA, Il2CppDumper, Cpp2IL, BepInEx, MelonLoader, FModel, UAssetGUI, UE4SS, repak, GDRE Tools, UndertaleModTool, vgmstream, quickbms, xdelta3, flips, armips, asar, xdvdfs, Crowbar |
| `06_Memory-and-Instrumentation` | Frida, ReClass.NET, SystemInformer, Squalr |
| `07_Network-and-APIs` | Mitmproxy, Objection |

## Triage (30 seconds)

```powershell
& "$GAME_RE_ROOT\01_Disassemblers\detect-it-easy\diec.exe" game.exe     # what is it?
rizin -q -c "iI; ii; iS" game.exe                                     # headers/imports/sections
& "$GAME_RE_ROOT\01_Disassemblers\capa\capa.exe" game.exe -q          # capabilities
& "$GAME_RE_ROOT\01_Disassemblers\floss\floss.exe" game.exe           # de-obfuscated strings
```

| Signal | Path |
| --- | --- |
| `UnityPlayer.dll` / `GameAssembly.dll` / `*_Data\` | Unity |
| `Assembly-CSharp.dll` in `Managed\` | Unity Mono → dnSpy / BepInEx |
| `global-metadata.dat` + `GameAssembly.dll` | Unity IL2CPP → Cpp2IL / Il2CppDumper + MelonLoader |
| `.pak` + `Engine` folder | Unreal → FModel / UAssetGUI / UE4SS / repak |
| `.pck` + `project.godot` | Godot → GDRE Tools |
| `data.win` / `game.win` | GameMaker → UndertaleModTool |
| `default.xbe` | Original Xbox → xboxrecomp + xdvdfs |
| `default.xex` | Xbox 360 → XenonRecomp |
| `.gba` | GBA → gba-matching-decomp skill |
| `.apk` | jadx + apktool |
| `UPX0`/`UPX1` sections | UPX → `upx -d` first |

## Workflows

### Native binary (structure + decompile)
```powershell
& "$GAME_RE_ROOT\01_Disassemblers\upx\upx-5.3.0-win64\upx.exe" -d game.exe   # if UPX-packed
$g = (Get-ChildItem "$GAME_RE_ROOT\01_Disassemblers\ghidra" -Directory | Sort Name -Descending | Select -First 1).FullName
& "$g\ghidraRun.bat"                                              # GUI
& "$g\support\analyzeHeadless.bat" C:\work\proj p1 -import game.exe   # headless
& "$GAME_RE_ROOT\03_Source-Decompilers\retdec\bin\retdec-decompiler.exe" --cleanup -o game.c game.exe
```

### Agent-driven Ghidra (MCP)
```powershell
python -m ghidra_mcp --headless --binary game.exe --save   # headless MCP stdio
```

### Native binary (runtime truth)
```powershell
& "$GAME_RE_ROOT\02_Debuggers\x64dbg\release\x64\x64dbg.exe" game.exe
```

### Unity (Mono / IL2CPP)
```powershell
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\assetripper\AssetRipper.GUI.Free.exe"
& "$GAME_RE_ROOT\02_Debuggers\dnspy\dnSpy.exe" "Game\Managed\Assembly-CSharp.dll"
# IL2CPP: Cpp2IL first on recent Unity, Il2CppDumper as fallback
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\cpp2il\Cpp2IL-2022.0.7-Windows.exe" --game-path "Game" --output "cpp2il-out"
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\il2cppdumper\Il2CppDumper.exe" "Game\GameAssembly.dll" "Game\global-metadata.dat" "dump-out"
```

### Unreal Engine (pak / uasset / runtime mods)
```powershell
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\fmodel\FModel.exe"          # browse/export assets
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\uassetgui\UAssetGUI.exe"     # edit .uasset
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\repak\repak.exe" --help      # pack/unpack .pak
# UE4SS: copy the extracted files into <Game>\Binaries\Win64
```

### Godot (.pck)
```powershell
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\gdre-tools\gdre_tools.exe"   # recover project + decompile scripts
```

### GameMaker (data.win)
```powershell
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\undertalemodtool\UndertaleModTool.exe"
```

### Game audio
```powershell
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\vgmstream\vgmstream-cli.exe" -o out.wav "sound.wem"
```

### Android
```powershell
java -jar "$GAME_RE_ROOT\03_Source-Decompilers\apktool\apktool_3.0.3.jar" d game.apk -o out
& "$GAME_RE_ROOT\03_Source-Decompilers\jadx\jadx-gui-1.5.6.exe" game.apk
```

### Original Xbox (recompilation)
```powershell
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\xdvdfs\xdvdfs.exe" extract --input game.iso --output gf
cd "$GAME_RE_ROOT\04_Static-Recompilation\xboxrecomp"
py -3 -m tools.xbe_parser gf\default.xbe --json gf\default_analysis.json
py -3 -m tools.disasm gf\default.xbe --text-only
py -3 -m tools.func_id gf\default.xbe -v
py -3 -m tools.abi_analysis gf\default.xbe -v
py -3 -m tools.recomp gf\default.xbe --all --split 250 --gen-dir ..\mygame\src\recomp\gen
```

### GBA matching decomp
Follow `tools/04_Static-Recompilation/gba-matching-decomp-skill/SKILL.md` (also installable
as its own agent skill). Needs agbcc + arm-none-eabi toolchain (see docs/research.md).

### Romhack patches
```powershell
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\xdelta3\xdelta3-3.1.0-x86_64.exe" -d -s base.rom patch.xdelta out.rom
& "$GAME_RE_ROOT\05_Game-Mods-and-Assets\flips\flips.exe"
```

### Runtime hooking / memory
```powershell
frida-trace -p <pid> -i "CreateFile*"
& "$GAME_RE_ROOT\06_Memory-and-Instrumentation\reclass\x64\ReClass.NET.exe"
```

## Reporting results

State the tool, exact command, and evidence: Ghidra address + decompiled signature; file
offset/RVA for a patch; before/after behavior from an actual run. Do not present pseudocode
as original source, or a static xref as proof of runtime execution.

## Adding / updating a tool

Edit `manifest/tools.json` (add `{id,name,kind,repo,tag,asset,extract,sha256,category,...}`),
re-run bootstrap. `kind` is one of `release` | `git` | `pip`. Get the sha256 from the
upstream release (or drop the field to skip verification).
