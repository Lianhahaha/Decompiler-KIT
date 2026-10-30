# env.ps1 - activate the toolkit in the current PowerShell session.
# Usage:  . .\env.ps1     (dot-source)
$RepoRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Root = if ($env:GAME_RE_ROOT) { $env:GAME_RE_ROOT } else { Join-Path $RepoRoot "tools" }
$Man  = Join-Path $RepoRoot "manifest\tools.json"

$paths = New-Object System.Collections.Generic.List[string]

if (Test-Path -LiteralPath $Man) {
  $data = Get-Content -LiteralPath $Man -Raw | ConvertFrom-Json
  foreach ($t in $data.tools) {
    if ($t.kind -eq "git") { continue }          # source repos: nothing runnable on PATH
    $d = Join-Path $Root "$($t.category)\$($t.id)"
    if (-not (Test-Path -LiteralPath $d)) { continue }
    $paths.Add($d)
    foreach ($sub in @("bin", "support", "x64", "x86", "artifacts")) {
      $s = Join-Path $d $sub
      if (Test-Path -LiteralPath $s) { $paths.Add($s) }
    }
    # versioned install dirs (ghidra_12.2_PUBLIC, rizin-.../ , Cutter-.../, dex-tools-v2.4, GhidraMCP-release-2-0)
    $hasExe = Get-ChildItem -LiteralPath $d -File -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -match '\.(exe|jar|bat|sh)$' } | Select-Object -First 1
    if (-not $hasExe) {
      Get-ChildItem -LiteralPath $d -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne ".git" } | ForEach-Object {
          $paths.Add($_.FullName)
          foreach ($sub in @("bin", "support", "x64", "x86")) {
            $s = Join-Path $_.FullName $sub
            if (Test-Path -LiteralPath $s) { $paths.Add($s) }
          }
        }
    }
  }
}

$gh = Get-ChildItem -LiteralPath (Join-Path $Root "01_Disassemblers\ghidra") -Directory -ErrorAction SilentlyContinue |
      Sort-Object Name -Descending | Select-Object -First 1
if ($gh) {
  $env:GHIDRA_HOME = $gh.FullName
  $env:GHIDRA_INSTALL_DIR = $gh.FullName
  $paths.Add((Join-Path $gh.FullName "support"))
}

foreach ($p in ($paths | Select-Object -Unique)) {
  if ($p -and (Test-Path -LiteralPath $p) -and ($env:PATH -notlike "*$p*")) {
    $env:PATH = "$p;$env:PATH"
  }
}

$env:GAME_RE_ROOT = $Root
Write-Host "Toolkit activated: $Root" -ForegroundColor Green
if ($gh) { Write-Host "  GHIDRA_HOME = $($gh.FullName)" }
