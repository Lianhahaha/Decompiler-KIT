# Left 4 Dead 2: unlimited ammo and a weapon dispenser (offline)

A worked example of a Source config mod. No binary is patched and no addon is used.
Tested on Left 4 Dead 2 build 7970 (The Last Stand), Windows.

## What it does

- Infinite ammo from the first second of the map (`sv_infinite_ammo 1`).
- Cheats enabled automatically (`sv_cheats 1`).
- `F8` loadout, `F9` supplies, `F11` laser + explosive ammo, `G` cycles all 18 guns,
  `F6` god, `F10` noclip, `P` refill, `F4` status.

## Install

Copy the three files into `<game>\left4dead2\cfg\`:

```
autoexec.cfg
l4d2_unlimited.cfg
listenserver.cfg
```

Then launch with a direct map start, not through the campaign menu:

```
launcher.exe +map c1m1_hotel
```

A shortcut with the argument `+map c1m1_hotel` is the friendliest form. Replace
`c1m1_hotel` with `c2m1_highway`, `c3m1_plankcountry`, `c4m1_milltown_a` or
`c5m1_waterfront` for the other campaigns, or make one shortcut per campaign. The
console (`~`) `map <name>` command works too.

Once a campaign is running, chapter transitions are fine: `changelevel` runs
`listenserver.cfg` again and there is no lobby to reset it. Verified
`c1m1_hotel` -> `c1m2_streets` with `sv_cheats = 1` on both maps.

## Why the launch argument matters

`cfg/listenserver.cfg` runs when the local server spawns, and it does set
`sv_cheats 1`. But the **campaign lobby resets `sv_cheats` to 0 afterwards**. Starting
a campaign from the main menu therefore ends with cheats off:

```
L4D2 Unlimited: cheats ON, infinite ammo ON   <- cfg ran
Map: c1m1_hotel
"sv_cheats" = "0"                             <- lobby reset it
```

A direct `map` start skips the lobby, so the same cfg sticks:

```
L4D2 Unlimited: cheats ON, infinite ammo ON
Map: c1m1_hotel
"sv_cheats" = "1"
"sv_infinite_ammo" = "1"
```

## Verification (from the test runs)

Same machine, same cfg, two launch paths, `F4` status bind:

| Launch | `sv_cheats` | `sv_infinite_ammo` | `give` works |
| --- | --- | --- | --- |
| `+map c1m1_hotel` | 1 | 1 | yes |
| `+map c2m1_highway` | 1 | 1 | not re-tested |
| `changelevel` c1m1 -> c1m2 | 1 | 1 | not re-tested |
| Campaign via main menu | 0 | 0 | no (`Can't use cheat command give...`) |

Ammo A/B with a hunting rifle (15/150):

| State | 10 mouse clicks | Clip |
| --- | --- | --- |
| `sv_infinite_ammo 1` | fired | **15 / 150** |
| `sv_infinite_ammo 0` | fired | **8 / 150** |

The second row proves the clicks registered and that the convar is what keeps the
counter full. The weapon cycle was checked too: `G` printed `[1/18] M16 Assault Rifle`,
then `[2/18] AK-47`, with the AK equipped (40/360).

## Where the kit fits

This job needed no decompiler. The useful parts were archive work and string analysis:

- `--file-tree` / `-e` on `pak01_dir.vpk` with VPKEdit to read the shipped scripts.
- A string scan of `server.dll` to find `sv_infinite_ammo` and its description.
- In-game verification, which is the step that proves the mod.

If the game had not shipped the convar, the next step would have been Ghidra on
`server.dll` to find the ammo path, then a byte patch or a MinHook DLL. That is a
different job with different evidence.

## Limits

- Offline / local servers only. `sv_cheats` on a VAC-secured server is a bad idea.
- Achievements may not count while cheats are on.
- The campaign menu path will always reset cheats; use `map`/`+map`.
- The binds are client-side. If you reset `config.cfg`, `autoexec.cfg` re-applies them
  on the next launch.

## Uninstall

Delete `autoexec.cfg` and `l4d2_unlimited.cfg`, restore the original
`listenserver.cfg` (blank, or your backup), and drop the `+map` argument.
