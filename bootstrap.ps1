<#
  bootstrap.ps1 - install the game RE / modding toolkit.
  Downloads each tool from its official upstream release (versions + sha256 pinned
  in manifest\tools.json) into ./tools/<category>/<id>.

  Usage:
    powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1            # install all
    powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1 -Force     # reinstall
    powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1 -Only ghidra,rizin
    $env:GAME_RE_ROOT="C:\tools"; powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
#>
[CmdletBinding()]
param([switch]$Force, [string[]]$Only)

$ErrorActionPreference = "Continue"
$RepoRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Root  = if ($env:GAME_RE_ROOT) { $env:GAME_RE_ROOT } else { Join-Path $RepoRoot "tools" }
$Dl    = Join-Path $Root "_downloads"
$Man   = Join-Path $RepoRoot "manifest\tools.json"
$Log   = Join-Path $Root "install.log"

New-Item -ItemType Directory -Force -Path $Root, $Dl | Out-Null
function Log([string]$m){ $l="[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"),$m; Write-Host $l; Add-Content $Log $l -Encoding UTF8 }

if (-not (Test-Path $Man)) { throw "manifest not found: $Man" }
$data = Get-Content $Man -Raw | ConvertFrom-Json

function Wanted([string]$id){ if(-not $Only -or $Only.Count -eq 0){ return $true }; return ($Only -contains $id) }

function Download([string]$url,[string]$out){
  if((Test-Path $out) -and -not $Force){ return }
  Log "  download $url"
  & curl.exe -L --fail --retry 3 --retry-delay 3 --connect-timeout 30 -o $out $url
  if($LASTEXITCODE -ne 0){ throw "curl failed for $url" }
}
function Verify([string]$file,[string]$sha){
  if(-not $sha){ return }
  $h=(Get-FileHash $file -Algorithm SHA256).Hash.ToLower()
  if($h -ne $sha.ToLower()){ throw "sha256 mismatch for $file (got $h, want $sha)" }
  Log "  sha256 ok"
}
function Ensure7zr([string]$kind){
  $7zr = Join-Path $Dl "7zr.exe"
  if($kind -eq "7z" -and -not (Test-Path $7zr)){ Download "https://www.7-zip.org/a/7zr.exe" $7zr }
  return $7zr
}

foreach($t in $data.tools){
  if(-not (Wanted $t.id)){ continue }
  $dest = Join-Path $Root "$($t.category)\$($t.id)"
  if((Test-Path $dest) -and ((Get-ChildItem $dest -Force | Measure-Object).Count -gt 0) -and -not $Force){
    Log "SKIP $($t.id) (already present)"; continue
  }
  try {
    switch($t.kind){
      "release" {
        Log "== $($t.id) ($($t.name))"
        $url = "https://github.com/$($t.repo)/releases/download/$($t.tag)/$($t.asset)"
        $f = Join-Path $Dl $t.asset
        Download $url $f
        Verify $f $t.sha256
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        switch($t.extract){
          "zip" { & tar.exe -xf $f -C $dest; if($LASTEXITCODE -ne 0){ throw "tar failed" } }
          "7z"  { $7zr=Ensure7zr "7z"; & $7zr x -y "-o$dest" $f | Out-Null }
          "rar" {
            $7z = @("$env:ProgramFiles\7-Zip\7z.exe","$env:ProgramFiles(x86)\7-Zip\7z.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
            if($7z){ & $7z x -y "-o$dest" $f | Out-Null }
            else { Log "  WARN: 7-Zip not found; install it (winget install 7zip.7zip) and re-run, or extract $f manually to $dest" }
          }
          "none"{ Copy-Item $f $dest -Force }
        }
        Log "  OK -> $dest"
      }
      "direct" {
        Log "== $($t.id) ($($t.name))"
        $osKey = if($env:OS -eq "Windows_NT"){ "win32" }
                 elseif(Test-Path Variable:\IsMacOS){ if($IsMacOS){ "darwin" } else { "linux" } }
                 else { "linux" }
        $p = if($t.platforms){ $t.platforms.$osKey } else { $null }
        $dlUrl = if($p -and $p.url){ $p.url } else { $t.url }
        $ex = if($p -and $p.extract){ $p.extract } else { $t.extract }
        if(-not $dlUrl){ throw "no download url for platform '$osKey'" }
        $f = Join-Path $Dl (Split-Path $dlUrl -Leaf)
        Download $dlUrl $f
        Verify $f $t.sha256
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        switch($ex){
          "zip" { & tar.exe -xf $f -C $dest; if($LASTEXITCODE -ne 0){ throw "tar failed" } }
          "7z"  { $7zr=Ensure7zr "7z"; & $7zr x -y "-o$dest" $f | Out-Null }
          default { Copy-Item $f $dest -Force }
        }
        Log "  OK -> $dest (run the installer/archive from there)"
      }
      "git" {
        Log "== $($t.id) (clone)"
        $opts = @("clone","--depth","1")
        if($t.submodules){ $opts += "--recurse-submodules" }
        & git @opts $t.url $dest 2>&1 | ForEach-Object { Log "  $_" }
        if($LASTEXITCODE -ne 0){ throw "git clone failed" }
        Log "  OK -> $dest"
      }
      "pip" {
        Log "== $($t.id) (pip)"
        & python -m pip install --disable-pip-version-check @($t.packages) 2>&1 | ForEach-Object { Log "  $_" }
      }
    }
  } catch { Log "FAIL $($t.id) : $($_.Exception.Message)" }
}
Log "=== done. tools under $Root ==="
