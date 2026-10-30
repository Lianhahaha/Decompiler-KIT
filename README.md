# decompiler-kit

A self-installing, agent-friendly toolkit for **decompiling, reverse-engineering, recompiling,
and modding games**. One command installs ~53 pinned tools (Ghidra, rizin, RetDec, x64dbg,
dnSpy, ILSpy, jadx, Frida, AssetRipper, BepInEx, xboxrecomp, N64Recomp, XenonRecomp, and more),
with per-tool sha256 verification and license attribution.

Designed to be used two ways:

1. **As an AI-agent skill** — the `SKILL.md` tells the agent where everything is and the exact
   workflow per target (Unity / Unreal / .NET / Android / Xbox / N64 / GBA / native).
2. **By hand** — `env.sh` / `env.ps1` put everything on `PATH`.

> No binaries are stored in this repo (GitHub has a 100 MB file limit and this is ~4.5 GB
> installed). Tools are downloaded at install time from their official releases.

> **Bundled tool:** `dissectdat/` is a vendored copy of
> [REA — Reverse Engineer Anything](https://github.com/morluto/rea) (MIT, © morluto).
> It ships as source so it is available immediately after cloning, while the other tools
> download. It is **not** covered by this repo's MIT license — see `dissectdat/LICENSE`.
> Run `cd dissectdat && npm install` to use it.

## Install

```bash
# macOS / Linux
./bootstrap.sh && source ./env.sh

# Windows (PowerShell)
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
. .\env.ps1
```

Tools land in `./tools/<category>/<id>`. Set `GAME_RE_ROOT` to install elsewhere.
`ONLY=ghidra,rizin ./bootstrap.sh` installs a subset.

## What you get

| Category | Tools |
| --- | --- |
| Disassemblers | Ghidra, GhidraMCP, rizin, Cutter, Detect It Easy, PE-bear, capa, floss, ImHex, Dependencies, CyberChef, angr, Miasm, Diaphora, Triton |
| Debuggers | x64dbg, dnSpy, ScyllaHide, decomp2dbg |
| Source decompilers | RetDec, jadx, apktool, dex2jar, JPEXS FFDec, ILSpy, Recaf, de4dot |
| Static recompilation | xboxrecomp, N64Recomp, XenonRecomp, gba-matching-decomp-skill |
| Mods & assets | AssetRipper, UABEA, Il2CppDumper, BepInEx, MelonLoader, quickbms, xdelta3, flips, armips, asar, xdvdfs, extract-xiso, Crowbar |
| Memory / instrumentation | Frida, ReClass.NET, SystemInformer, Squalr |
| Network & APIs | Mitmproxy, Objection (Wireshark, Caido in `scripts/install-extras.ps1`) |

Full per-tool usage, target triage, and the "what else to add" research list are in
`docs/research.md`. Licenses and upstream links are in `NOTICE.md`.

## As an agent skill

Copy `SKILL.md` into your agent's skills directory, or reference this repo. The skill assumes
`GAME_RE_ROOT` points at the installed `tools/` dir (the `env` scripts set it).

Companion skills worth installing:
- `ghidra` (headless recipes + GhidraMCP) — see the SKILL's Ghidra sections.
- `gba-matching-decomp` — https://github.com/FacundoMainere/gba-matching-decomp-skill

## Legal

Analysis/development tools only. You must own the games you decompile or mod. Do not
redistribute ROMs, ISOs, XBEs, decrypted assets, or game code.

## Updating / adding tools

Edit `manifest/tools.json`, re-run bootstrap. `kind` is `release` (GitHub asset), `git`, or
`pip`. Include `sha256` for reproducibility (or omit to skip verification).
