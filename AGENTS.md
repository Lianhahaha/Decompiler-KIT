# AGENTS.md

Instructions for AI agents working in this repository.

## If the user asks you to fetch / clone / set up this kit: install it automatically

Do **not** ask which tools to install, and do **not** download tools by hand. The repository is
a bootstrap + manifest; running the bootstrapper is the intended install path.

1. Clone (if not already cloned) and enter the repo:

   ```bash
   git clone https://github.com/Lianhahaha/Decompiler-KIT.git
   cd Decompiler-KIT
   ```

2. Run the bootstrapper for the current OS. It is non-interactive and idempotent, so it is safe
   to re-run. Expect it to take a long time and download several GB.

   ```powershell
   # Windows
   powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
   ```

   ```bash
   # macOS / Linux
   ./bootstrap.sh
   ```

3. Verify the install before reporting success:

   - `tools/install.log` ends with `=== done. tools under ... ===`
   - `tools/<category>/<id>/` exists for the tools you need
   - inspect the log for `FAIL` lines rather than assuming everything worked

4. Activate the environment (needed for PATH + `GAME_RE_ROOT` + `GHIDRA_HOME`):

   ```powershell
   . .\env.ps1
   ```

   ```bash
   source ./env.sh
   ```

5. Tell the user where the tools are (`$GAME_RE_ROOT` / `%GAME_RE_ROOT%`) and that they can run
   tools directly from `tools/<category>/<id>/`.

## Options

- Subset: `-Only ghidra,rizin,retdec` (PowerShell) or `ONLY=ghidra,rizin,retdec ./bootstrap.sh`.
- Custom root: set `GAME_RE_ROOT` before running the bootstrap and env scripts.
- Repair / reinstall: `-Force` (PowerShell) or `--force` (bash).
- Extras (account-gated / adware-bundled, opt-in only):
  `powershell -ExecutionPolicy Bypass -File .\scripts\install-extras.ps1`.

## Known manual steps

- **Binary Ninja Free** is downloaded as an installer to
  `tools/01_Disassemblers/binaryninja/`; run that `.exe`/`.dmg` once. On Linux the zip is
  already extracted.
- Do not commit anything under `tools/`; it is gitignored and machine-specific.

## Working on this repo itself

- Tool versions, assets, and hashes live in `manifest/tools.json`; the env scripts and both
  bootstrappers read the same manifest. Adding a tool is a data change.
- Keep Windows (`.ps1`) and Unix (`.sh`) paths in sync.
- `SKILL.md` documents per-target reverse-engineering workflows for agents; read it before
  choosing a decompilation path.
