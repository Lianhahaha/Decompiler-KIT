# Third-party notices

No reverse-engineering tool binaries are shipped in this repository. The installers
(`bootstrap.ps1` / `bootstrap.sh`) download each tool from its official upstream
release at install time. Each tool remains under its own license, listed below.

## Vendored source

- `dissectdat/` — **REA (Reverse Engineer Anything)**, https://github.com/morluto/rea,
  MIT License (Copyright © 2026 morluto). The full license text is at
  `dissectdat/LICENSE`. This vendored source is **not** covered by this repository's
  MIT license; it retains its own license and copyright.

| Tool | Upstream | License |
| --- | --- | --- |
| Ghidra | https://github.com/NationalSecurityAgency/ghidra | Apache-2.0 (some modules GPL-3.0) |
| GhidraMCP | https://github.com/LaurieWired/GhidraMCP | Apache-2.0 |
| Rizin | https://github.com/rizinorg/rizin | LGPL-3.0 |
| Cutter | https://github.com/rizinorg/cutter | GPL-3.0 |
| Detect It Easy | https://github.com/horsicq/Detect-It-Easy | MIT |
| PE-bear | https://github.com/hasherezade/pe-bear | GPL-3.0 |
| capa | https://github.com/mandiant/capa | Apache-2.0 |
| FLOSS | https://github.com/mandiant/flare-floss | Apache-2.0 |
| ImHex | https://github.com/WerWolv/ImHex | GPL-2.0 |
| x64dbg | https://github.com/x64dbg/x64dbg | GPL-3.0 |
| dnSpy | https://github.com/dnSpyEx/dnSpy | GPL-3.0 |
| RetDec | https://github.com/avast/retdec | MIT |
| jadx | https://github.com/skylot/jadx | Apache-2.0 |
| Apktool | https://github.com/iBotPeaches/Apktool | Apache-2.0 |
| dex2jar | https://github.com/pxb1988/dex2jar | Apache-2.0 |
| JPEXS FFDec | https://github.com/jindrapetrik/jpexs-decompiler | GPL-3.0 |
| ILSpy | https://github.com/icsharpcode/ILSpy | MIT |
| xboxrecomp | https://github.com/sp00nznet/xboxrecomp | MIT (APU/NV2A parts LGPL-2.1) |
| N64Recomp | https://github.com/N64Recomp/N64Recomp | MIT |
| XenonRecomp | https://github.com/hedge-dev/XenonRecomp | MIT |
| gba-matching-decomp-skill | https://github.com/FacundoMainere/gba-matching-decomp-skill | MIT |
| AssetRipper | https://github.com/AssetRipper/AssetRipper | GPL-3.0 |
| UABEA | https://github.com/nesrak1/UABEA | MIT |
| Il2CppDumper | https://github.com/Perfare/Il2CppDumper | MIT |
| BepInEx | https://github.com/BepInEx/BepInEx | LGPL-2.1 |
| MelonLoader | https://github.com/LavaGang/MelonLoader | Apache-2.0 |
| QuickBMS | https://aluigi.altervista.org/quickbms.htm (mirror https://github.com/LittleBigBug/QuickBMS) | GPL-2.0 |
| xdelta3 | https://github.com/jmacd/xdelta-gpl | GPL-2.0 |
| flips | https://github.com/Alcaro/flips | GPL-3.0 |
| xdvdfs | https://github.com/antangelo/xdvdfs | MIT |
| extract-xiso | https://github.com/XboxDev/extract-xiso | GPL-3.0 |
| ReClass.NET | https://github.com/ReClassNET/ReClass.NET | MIT |
| Frida | https://frida.re | wxWindows Library Licence |
| decomp2dbg | https://github.com/mahaloz/decomp2dbg | BSD-2-Clause |
| capstone | https://github.com/capstone-engine/capstone | BSD-3-Clause |
| pefile | https://github.com/erocarrera/pefile | MIT |
| LIEF | https://github.com/lief-project/LIEF | Apache-2.0 |
| Keystone | https://github.com/keystone-engine/keystone | GPL-2.0 |
| Unicorn | https://github.com/unicorn-engine/unicorn | GPL-2.0 |
| dnfile | https://github.com/malwarefrank/dnfile | Apache-2.0 |
| SystemInformer | https://github.com/winsiderss/systeminformer | MIT |
| Dependencies | https://github.com/lucasg/Dependencies | MIT |
| ScyllaHide | https://github.com/x64dbg/ScyllaHide | GPL-3.0 |
| Squalr | https://github.com/Squalr/Squalr | GPL-3.0 |
| Recaf | https://github.com/Col-E/Recaf | MIT |
| armips | https://github.com/Kingcom/armips | MIT |
| asar | https://github.com/RPGHacker/asar | MIT |
| CyberChef | https://github.com/gchq/CyberChef | Apache-2.0 |
| Crowbar | https://github.com/ZeqMacaw/Crowbar | MIT |
| rzpipe | https://github.com/rizinorg/rz-pipe | MIT |
| angr | https://github.com/angr/angr | BSD-2-Clause |
| androguard | https://github.com/androguard/androguard | Apache-2.0 |
| Miasm | https://github.com/cea-sec/miasm | GPL-2.0 |
| Diaphora | https://github.com/joxeankoret/diaphora | Apache-2.0 (plugin for IDA Pro / Ghidra) |
| Triton | https://github.com/JonathanSalwan/Triton | Apache-2.0 (build from source) |
| de4dot | https://github.com/0xd4d/de4dot | GPL-3.0 |
| Mitmproxy | https://github.com/mitmproxy/mitmproxy | MIT |
| Objection | https://github.com/sensepost/objection | MIT |

Tools in `scripts/install-extras.ps1` are not auto-bundled: Cheat Engine (freeware,
installer bundles third-party offers — decline them), IDA Free (proprietary, free tier),
Binary Ninja (proprietary, free tier requires account), Wireshark (GPL-2.0),
Caido (proprietary, "Basic" tier requires account).

(Licenses above are best-effort; confirm from each upstream repo's LICENSE before redistributing.)

Verbatim license texts are downloaded alongside each tool from its upstream release
archive. If you redistribute the installed `tools/` directory (not recommended), you
must retain each tool's LICENSE/COPYING/NOTICE files, and for GPL components provide a
written offer for the corresponding source.

## Legal note

These are analysis/development tools only. You must own the games you decompile or mod.
Do not redistribute ROMs, ISOs, XBEs, decrypted assets, or game code.
