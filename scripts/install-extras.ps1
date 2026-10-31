# install-extras.ps1 - Tier D tools (not auto-bundled: account-gated / adware / big / off-GitHub).
# Usage:  powershell -ExecutionPolicy Bypass -File .\scripts\install-extras.ps1 [ -Only name1,name2 ]
[CmdletBinding()]
param([string[]]$Only)
function W($n){ if(-not $Only -or $Only.Count -eq 0){ $true } else { $Only -contains $n } }
function Winget($id){ winget install --id $id --accept-package-agreements --accept-source-agreements --silent 2>&1 | Select-Object -Last 1 }

# Memory scanner (open-source CE alternative already bundled as Squalr; CE itself = adware installer)
if(W "cheatengine"){ Write-Host "Cheat Engine: https://cheatengine.org/downloads.php  (decline ALL bundled extras during install)" }

# IDA Free / Binary Ninja (account/paid)
# Binary Ninja Free is downloaded by bootstrap.ps1 into 01_Disassemblers\binaryninja
# (no account needed); only the paid tiers are manual.
if(W "ida"){ Write-Host "IDA Free: https://hex-rays.com/ida-free  |  Binary Ninja paid: https://binary.ninja/purchase/" }

# Graphics / asset ripping
if(W "renderdoc"){ Winget "BaldurKarlsson.RenderDoc" }
if(W "ninjaripper"){ Write-Host "Ninja Ripper: https://gamebanana.com/tools/5638" }

# Emulators with RAM search / Lua (console modding)
if(W "emulators"){ Winget "DolphinEmu.Dolphin"; Winget "PCSX2Team.PCSX2"; Winget "Ryujinx.Ryujinx"; Winget "PPSSPP.PPSSPP"; Winget "melonDS.melonDS"; Winget "BizHawk.BizHawk" }

# Unreal Engine asset tools (FModel, UAssetGUI, UE4SS, repak) are now auto-bundled.

# API / process monitoring
if(W "monitor"){ Winget "Microsoft.Sysinternals.ProcessExplorer"; Winget "Microsoft.Sysinternals.ProcessMonitor"; Write-Host "API Monitor: http://www.rohitab.com/apimonitor" }

# Network / API interception (Mitmproxy + Objection are auto-bundled via pip)
if(W "wireshark"){ Winget "WiresharkFoundation.Wireshark" }
if(W "caido"){ Write-Host "Caido Basic (free tier, account required): https://caido.io" }

Write-Host "done"
