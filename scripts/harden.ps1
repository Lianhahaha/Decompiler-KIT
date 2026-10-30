# harden.ps1 - reduce telemetry / analytics in the installed tools.
# These tools are offline by nature; only a few have opt-in metrics. This disables them.
[CmdletBinding()]
param([string]$Root)

if(-not $Root){
  $RepoRoot = Split-Path -Parent $PSScriptRoot
  $Root = if($env:GAME_RE_ROOT){ $env:GAME_RE_ROOT } else { Join-Path $RepoRoot "tools" }
}

# 1) Ghidra usage metrics OFF (headless + GUI) — adds a JVM flag; ignored if unknown.
$ghidra = Get-ChildItem "$Root\01_Disassemblers\ghidra" -Directory | Sort-Object Name -Descending | Select-Object -First 1
if($ghidra){
  $lp = Join-Path $ghidra.FullName "support\launch.properties"
  if(Test-Path $lp){
    $flag = "VMARGS=-Dghidra.usage.metrics=OFF"
    if(-not (Select-String -Path $lp -SimpleMatch $flag -Quiet)){ Add-Content $lp $flag }
    "Ghidra: usage metrics flag set ($flag)"
  }
}

# 2) Report-only toggles (GUI, not scriptable headlessly)
Write-Host "Manual toggles (GUI):"
Write-Host "  - Ghidra: Edit > Tool Options > Tool > Usage Stats > OFF"
Write-Host "  - AssetRipper: Settings > disable 'anonymous usage statistics'"
Write-Host "  - ImHex: Help > Settings > disable update checks / anonymous usage"
Write-Host "  - Cutter: Help > Preferences > disable analytics"
Write-Host "  - Squalr: Settings > disable telemetry (if present)"

# 3) Optional hosts blocklist (add to your firewall/hosts if you want zero outbound)
Write-Host "Optional: block 'usage-stats.ghidra-sre.org' and any sentry/analytics hosts via hosts file."
Write-Host "done"
