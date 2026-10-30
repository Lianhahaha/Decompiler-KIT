# Status & roadmap

`decompiler-kit` is a self-installing toolkit for decompiling, reverse-engineering,
recompiling, and modding games. No binaries live in this repo — `bootstrap.ps1` /
`bootstrap.sh` download each tool from its official upstream release (versions + sha256
pinned in `manifest/tools.json`) into `tools/` at install time.

## Included tools

| Category | Tools |
| --- | --- |
| `01_Disassemblers` | Ghidra, GhidraMCP, rizin, Cutter, Detect It Easy, PE-bear, capa, floss, ImHex, Dependencies, CyberChef, angr, Miasm, Diaphora, Triton |
| `02_Debuggers` | x64dbg, dnSpy, ScyllaHide, decomp2dbg |
| `03_Source-Decompilers` | RetDec, jadx, apktool, dex2jar, JPEXS FFDec, ILSpy, Recaf, de4dot |
| `04_Static-Recompilation` | xboxrecomp, N64Recomp (+RecompModTool), XenonRecomp, gba-matching-decomp-skill |
| `05_Game-Mods-and-Assets` | AssetRipper, UABEA, Il2CppDumper, BepInEx, MelonLoader, quickbms, xdelta3, flips, armips, asar, xdvdfs, extract-xiso, Crowbar |
| `06_Memory-and-Instrumentation` | Frida, ReClass.NET, SystemInformer, Squalr |
| `07_Network-and-APIs` | Mitmproxy, Objection |

Python libs (via pip): capstone, pefile, lief, keystone, unicorn, dnfile, frida,
decomp2dbg, rzpipe, angr, androguard, miasm, mitmproxy, objection.

`kind` is one of `release` (GitHub asset), `git` (clone), or `pip`. `git`/`pip` tools
like Diaphora, Triton, and de4dot are fetched as source and may need a build step (see
`docs/research.md`).

## Not auto-bundled (account-gated / adware / big)

`scripts/install-extras.ps1` covers: Cheat Engine (adware installer — decline all
extras), IDA Free, Binary Ninja, RenderDoc, Ninja Ripper, console emulators, FModel,
UAssetGUI, Sysinternals, Wireshark, Caido (Basic).

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
