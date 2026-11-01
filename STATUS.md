# Status & roadmap

`decompiler-kit` is a self-installing toolkit for decompiling, reverse-engineering,
recompiling, and modding games. No binaries live in this repo — `bootstrap.ps1` /
`bootstrap.sh` download each tool from its official upstream release (versions + sha256
pinned in `manifest/tools.json`) into `tools/` at install time.

## Included tools

| Category | Tools |
| --- | --- |
| `01_Disassemblers` | Ghidra, GhidraMCP, Binary Ninja (Free), rizin, Cutter, Detect It Easy, PE-bear, capa, floss, ImHex, UPX, Dependencies, CyberChef, angr, Diaphora, Triton |
| `02_Debuggers` | x64dbg, dnSpy, ScyllaHide, decomp2dbg |
| `03_Source-Decompilers` | RetDec, jadx, apktool, JPEXS FFDec, ILSpy, Recaf, de4dot |
| `04_Static-Recompilation` | xboxrecomp, N64Recomp (+RecompModTool), XenonRecomp, gba-matching-decomp-skill |
| `05_Game-Mods-and-Assets` | AssetRipper, UABEA, UnityPy, Il2CppDumper, Cpp2IL, BepInEx, MelonLoader, FModel, UAssetGUI, UE4SS, repak, retoc, GDRE Tools, UndertaleModTool, vgmstream, quickbms, xdelta3, flips, armips, asar, xdvdfs, Crowbar |
| `06_Memory-and-Instrumentation` | Frida, Scylla, ReClass.NET, SystemInformer, Squalr |
| `07_Network-and-APIs` | Mitmproxy, Objection |

Python libs (via pip): capstone, pefile, lief, keystone, unicorn, dnfile, frida,
decomp2dbg, rzpipe, angr, androguard, mitmproxy, objection, UnityPy.

`kind` is one of `release` (pinned GitHub asset), `git` (clone), `pip`, or `direct`
(official upstream installer URL, resolved per OS). `git`/`pip` tools like Diaphora,
Triton, and de4dot are fetched as source and may need a build step (see
`docs/research.md`). `direct` tools such as Binary Ninja Free ship an installer, so the
bootstrap downloads it but the user runs the installer (the free tier has no API/plugins;
it is downloaded from `cdn.binary.ninja`, so no sha256 is pinned).

## Not auto-bundled (account-gated / adware / big)

`scripts/install-extras.ps1` covers: Cheat Engine (adware installer — decline all
extras), IDA Free, RenderDoc, Ninja Ripper, console emulators, Sysinternals,
WinDbg (+TTD), API Monitor, PEStudio, Reko (needs .NET 8), pyinstxtractor-ng
(venv), Wireshark, Caido (Basic).

## Roadmap

- [ ] CI job that runs the bootstrap against a clean checkout to catch dead links /
      version bumps (keeps the pinned sha256/tag list honest).
- [ ] More Linux/macOS release assets where upstream provides them (many pins are
      Windows-only today).
- [ ] Optional telemetry-hardening step (`scripts/harden.ps1`) is provided; verify the
      Ghidra/AssetRipper/ImHex/Cutter/Squalr toggles after a GUI update.

## How to run

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
. .\env.ps1

# macOS / Linux
./bootstrap.sh && source ./env.sh
```

Install only a subset: `ONLY=ghidra,rizin ./bootstrap.sh` (or `-Only ghidra,rizin` on
Windows). Install elsewhere: set `GAME_RE_ROOT`.

## Key facts

- Ghidra needs JDK 21+.
- RetDec needs `libcrypto-1_1-x64.dll` (bundled in `RetDec\bin`).
- 7-Zip is required for `.7z`/`.rar` archives (e.g. ReClass.NET ships as `.rar`).
- Every download's sha256 is in `manifest/tools.json`; verification is skipped only if
  the field is omitted.
