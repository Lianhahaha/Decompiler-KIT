# Left 4 Dead 2: unlimited ammo and a weapon dispenser (offline)

A worked example of a Source config mod. No binary is patched and no addon is used.
Tested on Left 4 Dead 2 build 7970 (The Last Stand), Windows.

## What it does

- Infinite ammo from the first second of every local map (`sv_infinite_ammo 1`).
- Cheats enabled automatically for the session (`sv_cheats 1`).
- `F8` loadout, `F9` supplies, `F11` laser + explosive ammo, `G` cycles all 18 guns,
  `F6` god, `F10` noclip, `P` refill, `F4` status.

## Install

Copy the three files into `<game>\left4dead2\cfg\`, keeping the names:

```
autoexec.cfg
l4d2_unlimited.cfg
listenserver.cfg
```

`listenserver.cfg` ships blank in a clean install, so nothing is overwritten that
mattered. Back it up if you have your own.

## How it works

`cfg/listenserver.cfg` is executed by the engine every time a local listen server is
created, including every campaign map:

```
sv_cheats 1
sv_infinite_ammo 1
```

`cfg/autoexec.cfg` runs at client start and execs `l4d2_unlimited.cfg`, which holds the
binds and aliases. `sv_infinite_ammo` is Valve's own convar; its description in
`left4dead2\bin\server.dll` is *"Player's active weapon will never run out of ammo"*.

## Verification (from the test run)

Console log, after loading `c1m1_hotel`:

```
L4D2 Unlimited: cheats ON, infinite ammo ON
"sv_infinite_ammo" = "1" ( def. "0" )
"sv_cheats" = "1" ( def. "0" )
```

Ammo A/B with a hunting rifle (15/150):

| State | 10 mouse clicks | Clip |
| --- | --- | --- |
| `sv_infinite_ammo 1` | fired | **15 / 150** |
| `sv_infinite_ammo 0` | fired | **8 / 150** |

The second row proves the clicks registered and that the convar is the thing keeping the
counter full. The weapon cycle was also checked: `G` printed `[1/18] M16 Assault Rifle`,
then `[2/18] AK-47`, and the AK was equipped (40/360).

## Where the kit fits

This job needed no decompiler. The useful parts were archive work and string analysis:

- `--file-tree` / `-e` on `pak01_dir.vpk` with VPKEdit to read the shipped weapon and
  config scripts.
- A string scan of `server.dll` to find `sv_infinite_ammo` and its description.
- In-game verification, which is the step that actually proves the mod.

If the game had not shipped the convar, the next step would have been Ghidra on
`server.dll` to find the ammo path, then a byte patch or a MinHook DLL. That is a
different job with different evidence.

## Limits

- Offline / local servers only. `sv_cheats` on a VAC-secured server is a bad idea.
- Achievements may not count while cheats are on.
- The binds are client-side. If you reset `config.cfg`, `autoexec.cfg` re-applies them on
  the next launch.

## Uninstall

Delete `autoexec.cfg` and `l4d2_unlimited.cfg`, then restore the original
`listenserver.cfg` (blank, or your backup).
