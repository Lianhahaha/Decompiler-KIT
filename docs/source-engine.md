# Source engine: VPK, BSP, models, config mods

Source games (Left 4 Dead 2, Team Fortress 2, CS:S, Portal 2, Half-Life 2) all use the
same container and map formats, so one set of tools covers them.

Signals in the game folder:

- `gameinfo.txt`
- `pak01_dir.vpk` plus `pak01_000.vpk` ... chunks
- `bin/engine.dll`
- `<game>/bin/server.dll` and `client.dll`
- `hl2.exe` or a per-game launcher

## Tools

| Task | Tool |
| --- | --- |
| VPK list / extract / pack / modify | **VPKEdit** (`05_Game-Mods-and-Assets/vpkedit/vpkeditcli.exe`) |
| BSP map -> VMF source | **BSPSource** (`05_Game-Mods-and-Assets/bspsrc/bspsrc.jar`) |
| MDL model decompile / compile | **Crowbar** (`05_Game-Mods-and-Assets/crowbar/Crowbar.exe`) |
| Engine and server code | Ghidra / rizin / x64dbg |
| Server plugins | SourceMod + Metamod:Source (manual, see below) |
| Convars, binds, cheats | the game's own `cfg/` files |

## VPK

`vpkeditcli` picks its mode from the arguments. `-o` for extraction must be an
**existing** directory.

```powershell
$vp = "$GAME_RE_ROOT\05_Game-Mods-and-Assets\vpkedit\vpkeditcli.exe"
$pak = "C:\Games\Left 4 Dead 2\left4dead2\pak01_dir.vpk"

# print the tree
& $vp --file-tree $pak

# extract everything
New-Item -ItemType Directory -Force C:\work\vpk | Out-Null
& $vp -e / -o C:\work\vpk $pak

# extract one directory
& $vp -e "scripts/" -o C:\work\vpk $pak

# pack a folder into an addon VPK (L4D2 addons are commonly VPK v1; default is v2)
& $vp -v 1 -o C:\Games\Left 4 Dead 2\left4dead2\addons\my_addon.vpk C:\work\my_addon

# add a file to an existing VPK (modify edits the file in place; keep a copy)
Copy-Item my_addon.vpk my_addon.bak.vpk
& $vp --add-file C:\work\weapon_rifle.txt "scripts/weapon_rifle.txt" my_addon.vpk

# verify checksums
& $vp --verify-checksums all my_addon.vpk
```

An addon VPK needs `addoninfo.txt` at its root and is mounted from
`left4dead2\addons\`. Files under `scripts/`, `materials/`, `models/`, `sound/` override
the base game when the addon is enabled.

## BSP maps

BSPSource ships as a jar in `bspsrc-jar-only.zip` (no bundled JRE). Java 8+ is required.

```powershell
$bspsrc = "$GAME_RE_ROOT\05_Game-Mods-and-Assets\bspsrc\bspsrc.jar"
java -jar $bspsrc -o C:\work\vmf "C:\Games\Left 4 Dead 2\left4dead2\maps\c1m1_hotel.bsp"
java -jar $bspsrc -r "C:\Games\Left 4 Dead 2\left4dead2\maps" -o C:\work\vmf
```

The output is a VMF you can open in Hammer. Entity options (`--no_point_ents`,
`--no_cubemaps`, `--no_details`, ...) are in `java -jar $bspsrc --help`.

## Models

Crowbar decompiles a `.mdl` into QC/SMD sources and compiles them back. Point it at the
game's `models` folder and keep the `materials` folder next to it, otherwise the model
compiles without skins.

## Config-level mods (no binary patch)

Source executes:

- `cfg/autoexec.cfg` on client start.
- `cfg/listenserver.cfg` every time a local listen server is created. This is the hook
  used by the L4D2 example.

Cheat convars are gated by `sv_cheats`. Set `sv_cheats 1` in `listenserver.cfg` before
any other cheat convar, then keep the keybinds and aliases in a separate cfg that
`autoexec.cfg` execs. This survives map changes because each map start re-runs
`listenserver.cfg`.

**L4D2 caveat:** starting a campaign from the main menu creates a lobby that resets
`sv_cheats` to 0 *after* `listenserver.cfg` runs, so the cheats silently turn off.
The game prints the reason itself: *"Can't use cheats now; please exit to main menu
and start your own listen server with 'map mapname' so that you could enable
cheats."* Tested on build 7970: `listenserver.cfg` printed its `sv_cheats 1` line,
then the map loaded with `sv_cheats = 0`. A direct `map <name>` start (or `+map
<name>` on the launch command line, which SmartSteamEmu/`launcher.exe` passes through)
skips the lobby and the same cfg sticks. Chapter transitions after a direct start are
fine: `changelevel` re-runs `listenserver.cfg` with no lobby, and `sv_cheats` stayed 1
across `c1m1_hotel` -> `c1m2_streets`. Use `map`/`+map` for a modded session; the
campaign menu is fine for unmodded play.

A worked example, including the exact keys and the verification log lines, is in
`examples/l4d2-infinite-ammo/`.

## SourceMod and Metamod:Source

They are not in the manifest on purpose: builds are tied to a game and a Source version,
and the download pages rotate build numbers. Pinning a snapshot URL would rot fast.

- Metamod:Source: https://www.sourcemm.net/downloads.php
- SourceMod: https://www.sourcemod.net/downloads.php

Install Metamod into `<game>/addons/metamod/`, point `gameinfo.txt` at it, then drop
SourceMod into `<game>/addons/sourcemod/`. Plugins compile with `spcomp` from the
SourceMod package. This is the right path for gameplay changes that a convar cannot do
(spawn control, custom items, per-player logic). Local/offline servers only; VAC is not
involved there.

## Source 2

Source 2 still uses VPK containers, and VPKEdit reads them, but compiled assets
(`.vmdl_c`, `.vtex_c`, ...) need ValveResourceFormat. That tool is not bundled; add it to
the manifest if Source 2 becomes a target.
