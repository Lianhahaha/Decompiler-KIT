#!/usr/bin/env python3
"""Check the documentation links.

Walks every Markdown file in the repo (except the vendored `dissectdat/` tree) and
verifies two things:

  * every relative link points at a file that exists
  * every `#anchor` link points at a heading in the same document

Exit code 1 if any link is broken, 0 otherwise. Runs in CI next to check_manifest.py.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKIP = {"dissectdat"}
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*)$", re.M)
SLUG_STRIP = re.compile(r"[`*_\[\]()]")
SLUG_DROP = re.compile(r"[^a-z0-9\s-]")


def slug(heading: str) -> str:
    """Approximate GitHub's heading anchor."""
    text = SLUG_STRIP.sub("", heading.strip().lower())
    return SLUG_DROP.sub("", text).replace(" ", "-")


def markdown_files(root: Path) -> list[Path]:
    return sorted(
        path
        for path in root.rglob("*.md")
        if not SKIP.intersection(path.relative_to(root).parts)
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    args = parser.parse_args()

    errors: list[str] = []
    checked = 0

    for doc in markdown_files(args.root):
        text = doc.read_text(encoding="utf-8", errors="replace")
        anchors = {slug(m.group(2)) for m in HEADING_RE.finditer(text)}
        for target in LINK_RE.findall(text):
            target = target.strip().split(" ")[0]
            if target.startswith(("http://", "https://", "mailto:")):
                continue
            checked += 1
            name = doc.relative_to(args.root)
            if target.startswith("#"):
                if target[1:] not in anchors:
                    errors.append(f"{name}: no heading for anchor {target}")
                continue
            path = (doc.parent / target.split("#")[0]).resolve()
            if not path.exists():
                errors.append(f"{name}: missing file {target}")

    for message in errors:
        print(f"ERROR {message}")
    print(f"{checked} links checked, {len(errors)} error(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
