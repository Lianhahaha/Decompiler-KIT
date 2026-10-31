# What "recompile" actually means

The word covers three different jobs. Knowing which one applies to your target is the
difference between a week of work and a dead end.

| Job | What it produces | Tooling |
| --- | --- | --- |
| Static recompilation | machine code lifted to C/C++, built as a native binary | xboxrecomp, N64Recomp, XenonRecomp |
| Matching decompilation | C that compiles to a byte-identical ROM | agbcc + GBA skill |
| Decompile, edit, rebuild | real source, recompiled by a normal compiler | dnSpy/ILSpy, apktool, javac |

## Per target

| Target | Decompile to | Rebuild? | Notes |
| --- | --- | --- | --- |
| Native PC (PE/ELF/Mach-O) | C pseudocode | **No** | Ghidra/RetDec output is for reading. Patch bytes or hook at runtime. |
| .NET (C#, VB) | C# | **Yes** | dnSpy/ILSpy, then rebuild the assembly. |
| Unity Mono | C# | **Yes** | `Assembly-CSharp.dll` -> edit -> rebuild; BepInEx for plugins. |
| Unity IL2CPP | C# signatures | **No** | Cpp2IL/Il2CppDumper recover types; mod with MelonLoader/BepInEx hooks. |
| Android APK | smali / Java | **Yes** | apktool decode, edit smali, apktool build, re-sign. |
| Unreal 4/5 | assets, blueprints | **No** | FModel/UAssetGUI for assets, UE4SS for Lua/C++ mods. |
| Source | C pseudocode | **No** | Patch/hook the engine DLLs, or write a SourceMod plugin. |
| Original Xbox | C | **Yes** | xboxrecomp generates a native project; expect to fix runtime stubs. |
| N64 | C | **Yes** | N64Recomp + RecompModTool. |
| Xbox 360 | C/C++ | **Yes** | XenonRecomp. |
| GBA | C (matching) | **Yes** | Byte-identical rebuild with agbcc; its own skill. |

## Why Ghidra output is not a build

A decompiler reconstructs expressions and control flow, not declarations, types, class
layouts, inline assembly, or the original build system. Feeding it to a compiler gives
thousands of errors and, even after cleaning, rarely the same behaviour. Use it to
understand the code, then make the smallest change that achieves the goal: a byte patch,
a hook, or a plugin written against the engine's own API.

## What each recompiler expects

- **xboxrecomp**: an extracted `.xbe` (`xdvdfs.exe extract`), then `tools.xbe_parser`,
  `tools.func_id`, `tools.recomp`. First build usually crashes; that is the documented
  loop (boot, stub, fix).
- **N64Recomp**: a ROM and a symbol/config file; outputs C plus a mod tool.
- **XenonRecomp**: `.xex` / extracted 360 image.
- **GBA**: follow `tools/04_Static-Recompilation/gba-matching-decomp-skill/SKILL.md`.

## Rules

- Own the game you are working on. Do not redistribute ROMs, ISOs, XBEs, or decrypted
  assets.
- A recompiled project still needs the original assets to run; the code alone is not a
  playable game.
- Report what you actually achieved: "lifted 812 functions, 43 unresolved ICALLs" beats
  "recompiled the game".
