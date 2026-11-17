#!/usr/bin/env python3
"""Validate manifest/tools.json and keep the docs honest about it.

Schema checks run offline, and so does the doc audit: every tool must be named in
`NOTICE.md`, every category must appear in `STATUS.md`/`SKILL.md`/`README.md`, and
the tool counts quoted in prose must match the manifest. `--urls` additionally
probes every download URL with a HEAD request (falling back to a one-byte GET),
which is what the weekly CI job does.

Exit code 1 if any error is found, 0 otherwise.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "manifest" / "tools.json"

ID_RE = re.compile(r"^[a-z0-9][a-z0-9-]*$")
CATEGORY_RE = re.compile(r"^\d{2}_[A-Za-z0-9-]+$")
REPO_RE = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")
SHA_RE = re.compile(r"^[0-9a-f]{64}$")

KINDS = {"release", "git", "pip", "direct"}
EXTRACTS = {"zip", "7z", "rar", "none"}
PLATFORMS = {"win32", "darwin", "linux"}
GOOD_STATUS = {200, 206, 301, 302, 303, 307, 308}

errors: list[str] = []
warnings: list[str] = []
urls: list[tuple[str, str]] = []


def err(msg: str) -> None:
    errors.append(msg)


def warn(msg: str) -> None:
    warnings.append(msg)


def check_sha(value: object, where: str) -> None:
    if value is None:
        return
    if not isinstance(value, str) or not SHA_RE.match(value.lower()):
        err(f"{where}: sha256 must be 64 hex characters")


def check_common(tool: dict, seen: set[str]) -> None:
    tid = tool.get("id", "?")
    for key in ("id", "name", "kind", "category", "license"):
        value = tool.get(key)
        if not isinstance(value, str) or not value.strip():
            err(f"{tid}: missing or empty '{key}'")

    if isinstance(tool.get("id"), str):
        if not ID_RE.match(tool["id"]):
            err(f"{tid}: id must be lowercase letters, digits and hyphens")
        if tool["id"] in seen:
            err(f"{tid}: duplicate id")
        seen.add(tool["id"])

    if not CATEGORY_RE.match(str(tool.get("category", ""))):
        err(f"{tid}: category must look like '05_Game-Mods-and-Assets'")

    kind = tool.get("kind")
    if kind not in KINDS:
        err(f"{tid}: kind must be one of {sorted(KINDS)}")
    return None


def check_release(tid: str, tool: dict) -> None:
    repo = tool.get("repo")
    if not isinstance(repo, str) or not REPO_RE.match(repo):
        err(f"{tid}: repo must be 'owner/name'")
    for key in ("tag", "asset"):
        if not isinstance(tool.get(key), str) or not tool[key].strip():
            err(f"{tid}: release needs '{key}'")
    if tool.get("extract") not in EXTRACTS:
        err(f"{tid}: extract must be one of {sorted(EXTRACTS)}")
    check_sha(tool.get("sha256"), tid)
    if not tool.get("sha256"):
        warn(f"{tid}: no sha256 pinned")
    if repo and tool.get("tag") and tool.get("asset"):
        urls.append(
            (
                tid,
                f"https://github.com/{repo}/releases/download/"
                f"{tool['tag']}/{tool['asset']}",
            )
        )


def check_direct(tid: str, tool: dict) -> None:
    platforms = tool.get("platforms")
    if not platforms:
        url = tool.get("url")
        if not isinstance(url, str) or not url.startswith(("http://", "https://")):
            err(f"{tid}: direct tool needs platforms or an http(s) url")
            return
        urls.append((tid, url))
        check_sha(tool.get("sha256"), tid)
        return

    if not isinstance(platforms, dict) or not platforms:
        err(f"{tid}: platforms must be a non-empty object")
        return
    unknown = set(platforms) - PLATFORMS
    if unknown:
        warn(f"{tid}: unknown platform keys {sorted(unknown)}")
    for os_name, spec in platforms.items():
        where = f"{tid}[{os_name}]"
        if not isinstance(spec, dict):
            err(f"{where}: must be an object")
            continue
        url = spec.get("url")
        if not isinstance(url, str) or not url.startswith(("http://", "https://")):
            err(f"{where}: missing http(s) url")
        else:
            urls.append((tid, url))
        if spec.get("extract", "none") not in EXTRACTS:
            err(f"{where}: bad extract")
        check_sha(spec.get("sha256"), where)


def check_git(tid: str, tool: dict) -> None:
    url = tool.get("url")
    if not isinstance(url, str) or not url.startswith(("http://", "https://")):
        err(f"{tid}: git tool needs an http(s) url")
    elif not url.endswith(".git"):
        warn(f"{tid}: git url does not end with .git")
    if "submodules" in tool and not isinstance(tool["submodules"], bool):
        err(f"{tid}: submodules must be true/false")


def check_pip(tid: str, tool: dict) -> None:
    packages = tool.get("packages")
    if not isinstance(packages, list) or not packages:
        err(f"{tid}: pip tool needs a non-empty packages array")
        return
    for package in packages:
        if not isinstance(package, str) or not package.strip():
            err(f"{tid}: packages contains an empty value")


DOCS = ("README.md", "STATUS.md", "SKILL.md", "NOTICE.md")
COUNT_RE = re.compile(r"\b(\d+)(\+?)\s+tools\b")


def labels_for(tool: dict) -> list[str]:
    """Strings that count as naming this tool in prose."""
    name = str(tool.get("name", ""))
    labels = {str(tool.get("id", "")), name, re.sub(r"\s*\(.*?\)", "", name)}
    for key in ("repo", "url"):
        value = tool.get(key)
        if isinstance(value, str) and value:
            labels.add(value.rstrip("/").split("/")[-1])
    for package in tool.get("packages") or []:
        labels.add(str(package))
    return sorted(label for label in labels if len(label) > 2)


def check_docs(tools: list[dict], root: Path) -> None:
    """Fail when the prose stops matching the manifest."""
    docs: dict[str, str] = {}
    for name in DOCS:
        try:
            docs[name] = (root / name).read_text(encoding="utf-8")
        except OSError:
            err(f"{name}: missing or unreadable")

    notice = docs.get("NOTICE.md", "").lower()
    if notice:
        for tool in tools:
            tid = str(tool.get("id", "?"))
            labels = labels_for(tool)
            if not any(label.lower() in notice for label in labels):
                err(f"{tid}: not attributed in NOTICE.md (looked for: {', '.join(labels)})")

    total = len(tools)
    for name in ("README.md", "STATUS.md", "SKILL.md"):
        text = docs.get(name, "")
        for stated, plus in COUNT_RE.findall(text):
            claimed = int(stated)
            if plus:
                if claimed > total:
                    err(f"{name}: claims {stated}+ tools but the manifest has {total}")
                elif claimed != total:
                    warn(f"{name}: claims {stated}+ tools; manifest has {total} (state {total})")
            elif claimed != total:
                err(f"{name}: claims {stated} tools but the manifest has {total}")

    for category in sorted({str(tool.get("category", "")) for tool in tools}):
        for name in ("README.md", "STATUS.md", "SKILL.md"):
            text = docs.get(name, "")
            if text and category not in text:
                err(f"{name}: category {category} is installed but not documented")


def probe(url: str, attempts: int = 3) -> str:
    last: object = "no attempt"
    for attempt in range(1, attempts + 1):
        try:
            request = Request(url, method="HEAD", headers={"User-Agent": "decompiler-kit/check"})
            with urlopen(request, timeout=30) as response:  # noqa: S310 - fixed URLs
                return str(response.status)
        except HTTPError as exc:
            if exc.code in (403, 405, 429):
                try:
                    request = Request(
                        url,
                        headers={"User-Agent": "decompiler-kit/check", "Range": "bytes=0-0"},
                    )
                    with urlopen(request, timeout=30) as response:  # noqa: S310
                        return str(response.status)
                except (HTTPError, URLError, TimeoutError) as exc2:
                    last = exc2
            else:
                last = exc
        except (URLError, TimeoutError) as exc:
            last = exc
        if attempt < attempts:
            time.sleep(attempt * 1.5)
    return f"ERR {last}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--urls", action="store_true", help="probe every download URL")
    parser.add_argument("--no-docs", action="store_true", help="skip the doc consistency audit")
    parser.add_argument("--manifest", type=Path, default=MANIFEST)
    args = parser.parse_args()

    try:
        data = json.loads(args.manifest.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"FAIL  cannot read {args.manifest}: {exc}")
        return 1

    if not isinstance(data, dict) or not isinstance(data.get("tools"), list):
        print("FAIL  manifest must be an object with a 'tools' array")
        return 1

    seen: set[str] = set()
    tools = data["tools"]
    for tool in tools:
        if not isinstance(tool, dict):
            err("tools[] contains a non-object")
            continue
        check_common(tool, seen)
        kind = tool.get("kind")
        tid = str(tool.get("id", "?"))
        if kind == "release":
            check_release(tid, tool)
        elif kind == "direct":
            check_direct(tid, tool)
        elif kind == "git":
            check_git(tid, tool)
        elif kind == "pip":
            check_pip(tid, tool)

    if not args.no_docs:
        check_docs(tools, args.manifest.resolve().parent.parent)

    for message in warnings:
        print(f"WARN  {message}")

    if args.urls:
        print(f"\nProbing {len(urls)} URLs...")
        for tid, url in urls:
            status = probe(url)
            ok = status.isdigit() and int(status) in GOOD_STATUS
            print(f"{'OK  ' if ok else 'FAIL'}  {tid:20} {status:>4}  {url}")
            if not ok:
                err(f"{tid}: unreachable ({status}) {url}")

    print(f"\n{len(tools)} tools, {len(seen)} unique ids, {len(errors)} error(s), {len(warnings)} warning(s)")
    for message in errors:
        print(f"ERROR {message}")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
