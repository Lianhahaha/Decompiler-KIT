# env.sh - activate the toolkit in the current shell (macOS / Linux).
# Usage:  source ./env.sh
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${GAME_RE_ROOT:-$REPO_ROOT/tools}"

add_path(){ case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH";; esac; }

if [ -d "$ROOT/01_Disassemblers/ghidra" ]; then
  GHIDRA_HOME="$(find "$ROOT/01_Disassemblers/ghidra" -maxdepth 1 -mindepth 1 -type d | sort -r | head -n1)"
  export GHIDRA_HOME GHIDRA_INSTALL_DIR="$GHIDRA_HOME"
  add_path "$GHIDRA_HOME/support"
fi

NEW_PATHS="$(python3 - "$ROOT" "$REPO_ROOT" <<'PY'
import json, os, sys
root, repo = sys.argv[1], sys.argv[2]
out = []
for t in json.load(open(os.path.join(repo, "manifest", "tools.json")))["tools"]:
    if t.get("kind") == "git":
        continue
    d = os.path.join(root, t["category"], t["id"])
    if not os.path.isdir(d):
        continue
    out.append(d)
    for sub in ("bin", "support", "x64", "x86", "artifacts"):
        s = os.path.join(d, sub)
        if os.path.isdir(s):
            out.append(s)
    has_exe = any(e.endswith((".exe", ".jar", ".bat", ".sh"))
                  for e in os.listdir(d) if os.path.isfile(os.path.join(d, e)))
    if not has_exe:
        for e in os.listdir(d):
            full = os.path.join(d, e)
            if e == ".git" or not os.path.isdir(full):
                continue
            out.append(full)
            for sub in ("bin", "support", "x64", "x86"):
                s = os.path.join(full, sub)
                if os.path.isdir(s):
                    out.append(s)
print("\n".join(out))
PY
)"

while IFS= read -r p; do [ -n "$p" ] && [ -d "$p" ] && add_path "$p"; done <<< "$NEW_PATHS"

export GAME_RE_ROOT="$ROOT"
echo "Toolkit activated: $ROOT"
[ -n "${GHIDRA_HOME:-}" ] && echo "  GHIDRA_HOME = $GHIDRA_HOME"
