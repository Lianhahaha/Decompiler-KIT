# Research notes — decompilation & game modding

Curated list of what is installed here, plus what else is worth pulling later.
Ordered by what you actually reach for.

## From the two screenshots

| Repo | What it is | Status |
| --- | --- | --- |
| `FacundoMainere/gba-matching-decomp-skill` | Claude skill for **matching** GBA decompilation with agbcc: ROM split, Ghidra headless setup, agent-driven function matching, permuter, header unification, decomp.dev progress. The suggestion in the thread was "start with a GBA game, not an Xbox game". | installed in `04_Static-Recompilation/` + as a skill |
| `sp00nznet/xboxrecomp` | Static recompilation toolkit for **original Xbox** XBE binaries → native C → Windows/Linux/macOS exe. Pipeline: xbe_parser → disasm → func_id → abi_analysis → recomp → runtime libs (kernel, D3D8→D3D11, DSound, APU, NV2A, input). Burnout 3 is the reference title; community is on Discord `discord.gg/CRpzGWZFcu`. | installed in `04_Static-Recompilation/xboxrecomp` |

Direct answer to the thread's "can I port Ninja Gaiden Black": that is `xboxrecomp`
plus **a lot** of runtime work (ICALLs, pushbuffer, threading). Start on something small
first — the GBA skill exists exactly for that.

## Installed here

### Disassembly / decompilation
- **Ghidra** — https://github.com/NationalSecurityAgency/ghidra — free, scriptable (Python/Java),
  best-in-class decompiler, FidDB for library functions, headless mode for automation.
- **Rizin** — https://github.com/rizinorg/rizin — radare2 fork, fast CLI, `-A` auto-analysis,
  great for scripting and quick xrefs.
- **Cutter** — https://github.com/rizinorg/cutter — GUI front end for rizin/radare2.
- **RetDec** — https://github.com/avast/retdec — one-command binary → C, supports PE/ELF/Mach-O.
- **Detect It Easy** — https://github.com/horsicq/Detect-It-Easy — packer/compiler detection;
  tells you if the binary is Themida/VMProtect/UPX before you waste time.
- **UPX** — https://github.com/upx/upx — unpacks UPX-compressed binaries (`upx -d`) before analysis.
- **ImHex** — https://github.com/WerWolv/ImHex — hex editor with a pattern language, good
  for reverse-engineering custom asset formats.

### Debuggers
- **x64dbg** — https://github.com/x64dbg/x64dbg — native Windows debugger, plugin ecosystem.
- **dnSpyEx** — https://github.com/dnSpyEx/dnSpy — .NET decompiler + debugger + assembly editor.
  Best tool for Mono/Unity `Assembly-CSharp.dll`.
- **ILSpy** — https://github.com/icsharpcode/ILSpy — cleaner C# output, good for reading.
- **jadx** — https://github.com/skylot/jadx — Android DEX → Java.
- **apktool** — https://github.com/iBotPeaches/Apktool — APK decode (manifest, resources, smali).
- **Frida** — https://frida.re — runtime instrumentation; hook functions, dump memory, bypass checks.
- **decomp2dbg** — https://github.com/mahaloz/decomp2dbg — sync Ghidra/IDA/Binja symbols into GDB.

### Static recompilation
- **xboxrecomp** — original Xbox (x86) → C.
- **N64Recomp** — https://github.com/N64Recomp/N64Recomp — N64 MIPS → C, mod tooling.
- **XenonRecomp** — https://github.com/hedge-dev/XenonRecomp — Xbox 360 (PowerPC) → C/C++.
- **ReXGlue SDK** — https://github.com/rexglue/rexglue-sdk — runtime for XenonRecomp output.
- **N64Recomp** projects to read: `N64Recomp/Zelda64Recomp`, `sonicretro/sm64port`.
- **ps3recomp** — sp00nznet's PS3 work (announced via the same Discord).

### Matching decompilation (the "byte-identical rebuild" school)
- `FacundoMainere/gba-matching-decomp-skill` — GBA.
- **decomp.dev** — https://decomp.dev — progress dashboards for matching decomp projects.
- **decomp.me** — https://decomp.me — online scratchpad + permuter for matching a function.
- **simonlindholm/permuter** — https://github.com/simonlindholm/permuter — brute-force
  source permutations until the compiler emits identical asm.
- **encounter/objdiff** — https://github.com/encounter/objdiff — object-level diffing.
- Read any `decomp` org repo (e.g. `n64decomp/sm64`, `zeldaret/oot`) for project layout.

### Modding frameworks
- **BepInEx** — https://github.com/BepInEx/BepInEx — Unity Mono + IL2CPP mod loader.
- **MelonLoader** — https://github.com/LavaGang/MelonLoader — Unity mod loader, IL2CPP first.
- **Harmony** — https://github.com/pardeike/Harmony — runtime method patching for .NET (used by both).
- **Il2CppDumper** — https://github.com/Perfare/Il2CppDumper — recover types/methods from IL2CPP.
- **Cpp2IL** — https://github.com/SamboyCoding/Cpp2IL — actively maintained IL2CPP → C#/DLL recovery; better on newer Unity.
- **Il2CppInterop** — https://github.com/BepInEx/Il2CppInterop — managed bridge for IL2CPP.
- **UABEA** — https://github.com/nesrak1/UABEA — Unity asset bundle editor.
- **AssetRipper** — https://github.com/AssetRipper/AssetRipper — Unity assets → Unity project.
- **FModel** — https://github.com/4sval/FModel — Unreal Engine asset explorer/exporter.
- **UAssetGUI** — https://github.com/atenfyr/UAssetGUI — edit UE `.uasset` files.
- **UE4SS** — https://github.com/UE4SS-RE/RE-UE4SS — UE4/5 Lua/C++ scripting, blueprint dumps, live property editing.
- **repak** — https://github.com/trumank/repak — Unreal `.pak` packer/unpacker.
- **GDRE Tools** — https://github.com/GDRETools/gdsdecomp — Godot `.pck` extraction + project decompilation.
- **UndertaleModTool** — https://github.com/UnderminersTeam/UndertaleModTool — GameMaker `data.win` unpack, GML decompile, asset edit, repack.
- **vgmstream** — https://github.com/vgmstream/vgmstream — decodes most game audio formats (`.wem`, `.adx`, `.hca`, `.fsb`, …).
- **quickbms** — https://aluigi.altervista.org/quickbms.htm — archive extractor; scripts at
  https://aluigi.altervista.org/bms/ . Mirror: https://github.com/LittleBigBug/QuickBMS
- **Noesis** — https://richwhitehouse.com/index.php?content=inc_projects.php — model/texture converter.

### Xbox-specific (for the xboxrecomp path)
- **xdvdfs** — https://github.com/antangelo/xdvdfs — modern Xbox ISO tool (extract + build).
- **xemu** — https://github.com/xemu-project/xemu — Xbox emulator (use it to compare behavior
  against your recomp; xboxrecomp's APU/NV2A code is derived from it).
- **Cxbx-Reloaded** — https://github.com/Cxbx-Reloaded/Cxbx-Reloaded — HLE Xbox emulator.
- **XboxDev wiki** — https://xboxdevwiki.net — format docs (XBE, XISO, kernel exports).

### PE / binary utilities worth adding
- **PE-bear** — https://github.com/hasherezade/pe-bear — PE viewer/editor.
- **Scylla** — https://github.com/NtQuery/Scylla — import table reconstruction (after unpacking; now bundled).
- **CFF Explorer** — https://ntcore.com/?page_id=388 — PE editing.
- **HxD** — https://mh-nexus.de/en/hxd/ — fast hex editor.
- **Sysinternals Suite** — https://learn.microsoft.com/sysinternals/ — Process Explorer,
  Process Monitor, VMMap; indispensable for "what file is it reading".

### Paid / account-gated (not bundled)
- **IDA Free** — https://hex-rays.com/ida-free — free for non-commercial; the best decompiler UI.
- **IDA Pro** — commercial.
- **Binary Ninja** — https://binary.ninja — commercial, great API. The **Free** tier
  (x86/x86_64/ARMv7/AArch64, non-commercial, no API/plugins) is now downloaded by the
  bootstrap as a per-OS installer (`kind: direct`).
- **Cheat Engine** — https://cheatengine.org — memory scanner; installer bundles adware,
  use the custom install and decline extras.
- **Hopper** — macOS only.

## Newly added (layer 2 — game-hacking kit)

- **capa** — https://github.com/mandiant/capa — detect capabilities in a binary (crypto, injection, VM checks). `capa game.exe`.
- **floss** — https://github.com/mandiant/flare-floss — extract de-obfuscated/stack strings.
- **PE-bear** — https://github.com/hasherezade/pe-bear — PE viewer/editor, section/directories analysis.
- **ReClass.NET** — https://github.com/ReClassNET/ReClass.NET — live memory scanner + C++ structure builder; pair with x64dbg/Cheat Engine.
- **JPEXS FFDec** — https://github.com/jindrapetrik/jpexs-decompiler — Flash/SWF decompiler + editor.
- **Il2CppDumper** — https://github.com/Perfare/Il2CppDumper — IL2CPP `GameAssembly.dll` + `global-metadata.dat` → types/methods/structs.
- **UABEA** — https://github.com/nesrak1/UABEA — Unity asset/bundle editor (standalone mod installers).
- **xdelta3** — https://github.com/jmacd/xdelta-gpl — binary diff/patch (the standard for romhack patches).
- **flips** — https://github.com/Alcaro/flips — IPS/BPS patcher.
- **GhidraMCP** — https://github.com/LaurieWired/GhidraMCP — MCP bridge so an AI agent drives Ghidra (headless + GUI).
- Python: **pefile, lief, keystone, unicorn, dnfile** (pip) — parsing, assembly, emulation.
- 7-Zip (winget) — needed for `.rar`/`.7z` archives (ReClass.NET ships as rar).

## Newly added (layer 3 — network, binary diffing, deobfuscation)

- **Diaphora** — https://github.com/joxeankoret/diaphora — binary diffing (patch analysis, diffing between versions). Plugin for IDA Pro / Ghidra; cloned into `01_Disassemblers/diaphora`.
- **Triton** — https://github.com/JonathanSalwan/Triton — DBA + dynamic symbolic execution / taint. Cloned as source; build with CMake (note: the PyPI `triton` package is OpenAI's GPU compiler, not this).
- **de4dot** — https://github.com/0xd4d/de4dot — .NET deobfuscator (un-ConfuserEx, un-rename, string decrypt). Cloned as source; build with msbuild/dotnet.
- **Mitmproxy** — https://github.com/mitmproxy/mitmproxy — interactive HTTPS proxy for API interception (`pip install mitmproxy`).
- **Objection** — https://github.com/sensepost/objection — Frida-based mobile runtime inspection (`pip install objection`).
- **Wireshark** — https://www.wireshark.org — packet capture (install via `scripts/install-extras.ps1` or your package manager).
- **Caido** — https://caido.io — web/API security toolkit; "Basic" tier is free but requires an account (install manually).

## Newly added (layer 4 — engine-specific modding)

- **FModel** — UE `.pak`/`.uasset`/`.umap` browsing and export; the tool modders reach for first on Unreal games.
- **UAssetGUI** — GUI editor for UE `.uasset` fields; pair with FModel for read → edit.
- **UE4SS** — runtime framework for UE4/5: Lua/C++ mods, blueprint mod loading, live property editor, SDK dumping.
- **repak** — Rust CLI to unpack/repack UE `.pak` files (ideal for distributing mods).
- **GDRE Tools** — Godot RE: unpack `.pck`, recover project files, decompile GDScript/C#.
- **UndertaleModTool** — GameMaker RE: unpack `data.win`, decompile GML, edit assets, repack.
- **Cpp2IL** — IL2CPP metadata/code recovery; output can be opened in dnSpy/ILSpy when Il2CppDumper's dummy DLLs are not enough.
- **vgmstream** — reference decoder for game audio; `vgmstream-cli` converts `.wem`, `.adx`, `.hca`, `.fsb`, etc. to WAV.
- **UPX** — unpack UPX-packed binaries before Ghidra/rizin sees them.

## Newly added (layer 5 — decompilers + modern modding)

- **Hyperion** — https://github.com/Sidenai/hyperion-disassembler — multi-arch disassembler + x86/x64/ARM64 decompiler (GUI, MIT): PE/ELF/Mach-O/.NET, RTTI recovery, FLIRT, packer detection.
- **Vineflower** — https://github.com/Vineflower/vineflower — modern Fernflower fork; best-in-class JVM bytecode → Java (Java 21+ features), standalone jar.
- **Kaitai Struct** — https://github.com/kaitai-io/kaitai_struct_compiler — `.ksy` specs → parsers in Python/C++/Java/etc.; ideal for custom asset formats.
- **retoc** — https://github.com/trumank/retoc — Unreal Engine IoStore (`.utoc`/`.ucas`) pack/unpack + Zen↔legacy conversion; complements `repak` for UE5.
- **UnityPy** — https://github.com/K0lb3/UnityPy — Python Unity asset/bundle reader/editor for scripted bulk extraction.
- **pyinstxtractor-ng** — https://github.com/pyinstxtractor/pyinstxtractor-ng — unpacks PyInstaller executables (Python games) to `.pyc`; not bundled (it pins an old `pycryptodome`) — install in a venv.
- **ret-sync** — https://github.com/bootleg/ret-sync — sync symbols/comments/breakpoints between Ghidra/IDA/Binja and x64dbg/GDB.

Removed as redundant: **dex2jar** (jadx handles APK → Java), **Miasm** (angr covers
symbolic execution), **extract-xiso** (xdvdfs extracts and builds XISOs).

## Community indexes to mine for more

These are the best "add more later" sources:

- **dsasmblr/game-hacking** — https://github.com/dsasmblr/game-hacking — the definitive curated game-hacking tool/tutorial list (the table above came partly from it).
- **wtsxDev/reverse-engineering** — https://github.com/wtsxDev/reverse-engineering — awesome reversing list.
- **onethawt/idaplugins-list** — https://github.com/onethawt/idaplugins-list — IDA plugin index.
- **r/REGames** — https://www.reddit.com/r/REGames/ — game-specific RE; search "tools", "how do I".
- **r/ReverseEngineering** — https://www.reddit.com/r/ReverseEngineering/ — general RE, tool release threads.
- **UnKnoWnCheaTs** — https://unknowncheats.me — largest game-hacking forum (tools/source releases).
- **Guided Hacking** — https://guidedhacking.com — tutorials + tooling.
- **Fearless Revolution** — https://fearlessrevolution.com — Cheat Engine tables.
- **decomp.dev / decomp.me** — matching-decomp dashboards + online permuter.
- **XboxDev wiki** — https://xboxdevwiki.net — Xbox format references.
- **tuts4you** — https://tuts4you.com — unpacking/tutorial archives.

## Suggested order of attack for a new game

1. Detect It Easy → what engine/packer?
2. If Unity: `AssetRipper` + `dnSpy`/IL2CPP path. If UE: `FModel` + `UAssetGUI`/`UE4SS`.
   If Godot: `GDRE Tools`. If GameMaker: `UndertaleModTool`. If native: check for `UPX` first.
3. If native: `Ghidra` for structure, `RetDec` for bulk C, `x64dbg` to confirm at runtime.
4. If you want a **port**, not a patch: matching decomp (GBA/N64/GC) or static recomp
   (Xbox/360) — use the repos above, they are different disciplines.
5. Only then start writing runtime shims. The xboxrecomp README is blunt about this:
   first boot crashes, then you stub, then you fix ICALLs, then it renders.
