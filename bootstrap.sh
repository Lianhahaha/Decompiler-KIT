#!/usr/bin/env bash
# bootstrap.sh - install the game RE / modding toolkit (macOS / Linux).
# Downloads each tool from its official upstream release (versions + sha256 pinned
# in manifest/tools.json) into ./tools/<category>/<id>.
#
# Usage:
#   ./bootstrap.sh                 # install all
#   ./bootstrap.sh --force         # reinstall
#   ONLY=ghidra,rizin ./bootstrap.sh
#   GAME_RE_ROOT=/opt/retools ./bootstrap.sh
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${GAME_RE_ROOT:-$REPO_ROOT/tools}"
DL="$ROOT/_downloads"
MAN="$REPO_ROOT/manifest/tools.json"
FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

mkdir -p "$ROOT" "$DL"

log(){ printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

command -v python3 >/dev/null 2>&1 || { log "python3 required"; exit 1; }

download(){
  local url="$1" out="$2"
  [ -f "$out" ] && [ "$FORCE" != 1 ] && return 0
  log "  download $url"
  if command -v curl >/dev/null 2>&1; then curl -fL --retry 3 --retry-delay 3 -o "$out" "$url"
  else wget -O "$out" "$url"; fi
}

sha256_ok(){
  local file="$1" sha="$2" got
  [ -z "$sha" ] && return 0
  got=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
  [ -z "$got" ] && got=$(shasum -a 256 "$file" 2>/dev/null | awk '{print $1}')
  if [ "$got" != "$sha" ]; then log "  sha256 MISMATCH for $file (got $got, want $sha)"; return 1; fi
  log "  sha256 ok"; return 0
}

extract(){
  local kind="$1" f="$2" dest="$3"
  mkdir -p "$dest"
  case "$kind" in
    zip) unzip -q -o "$f" -d "$dest" ;;
    7z)  if command -v 7z >/dev/null 2>&1; then 7z x -y -o"$dest" "$f" >/dev/null 2>&1
         else log "  WARN: 7z not found (brew install sevenzip) - skip $f"; return 1; fi ;;
    rar) if command -v unrar >/dev/null 2>&1; then unrar x -y "$f" "$dest" >/dev/null 2>&1
         elif command -v 7z >/dev/null 2>&1; then 7z x -y -o"$dest" "$f" >/dev/null 2>&1
         else log "  WARN: unrar/7z not found - skip $f"; return 1; fi ;;
    none) cp "$f" "$dest"/ ;;
  esac
}

python3 - "$MAN" <<'PY' |
import json, sys, platform
d = json.load(open(sys.argv[1]))
os_key = {"Windows": "win32", "Darwin": "darwin"}.get(platform.system(), "linux")
for t in d["tools"]:
    p = (t.get("platforms") or {}).get(os_key, {})
    row = [t.get("id",""), t.get("name",""), t.get("kind",""), t.get("category",""),
           t.get("repo",""), t.get("tag",""), t.get("asset",""),
           p.get("extract", t.get("extract","")), t.get("sha256",""),
           p.get("url", t.get("url","")), str(t.get("submodules","")),
           " ".join(t.get("packages", []))]
    print("\t".join(row))
PY
while IFS=$'\t' read -r id name kind category repo tag asset extract sha url sub pkgs; do
  [ -z "$id" ] && continue
  if [ -n "${ONLY:-}" ] && ! echo ",$ONLY," | grep -q ",$id,"; then continue; fi
  dest="$ROOT/$category/$id"
  if [ -d "$dest" ] && [ "$(find "$dest" -mindepth 1 -print -quit 2>/dev/null)" ] && [ "$FORCE" != 1 ]; then
    log "SKIP $id (already present)"; continue
  fi
  case "$kind" in
    release)
      log "== $id ($name)"
      url="https://github.com/$repo/releases/download/$tag/$asset"
      f="$DL/$asset"
      download "$url" "$f" || { log "FAIL $id: download"; continue; }
      sha256_ok "$f" "$sha" || { log "FAIL $id: sha256"; continue; }
      extract "$extract" "$f" "$dest" || { log "FAIL $id: extract"; continue; }
      log "  OK -> $dest"
      ;;
    direct)
      log "== $id ($name)"
      f="$DL/$(basename "$url")"
      download "$url" "$f" || { log "FAIL $id: download"; continue; }
      sha256_ok "$f" "$sha" || { log "FAIL $id: sha256"; continue; }
      extract "${extract:-none}" "$f" "$dest" || { log "FAIL $id: extract"; continue; }
      log "  OK -> $dest (run the installer/archive from there)"
      ;;
    git)
      log "== $id (clone)"
      args=(clone --depth 1)
      [ "$sub" = "true" ] && args+=(--recurse-submodules)
      git "${args[@]}" "$url" "$dest" || { log "FAIL $id: clone"; continue; }
      log "  OK -> $dest"
      ;;
    pip)
      log "== $id (pip)"
      # shellcheck disable=SC2086
      python3 -m pip install --disable-pip-version-check $pkgs || { log "FAIL $id: pip"; continue; }
      ;;
  esac
done

log "=== done. tools under $ROOT ==="
