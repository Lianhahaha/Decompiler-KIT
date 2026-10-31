# Native PC modding: patch or hook

The kit gives you analysis (Ghidra, rizin, x64dbg) and hook libraries (MinHook,
Detours, Frida). It does **not** ship a universal mod loader, because there is no such
thing for native PC games. Loaders are per engine:

| Engine | Loader |
| --- | --- |
| Unity Mono / IL2CPP | BepInEx, MelonLoader |
| Unreal Engine 4/5 | UE4SS |
| Source | SourceMod + Metamod:Source |
| GameMaker | UndertaleModTool scripts |
| Everything else | your own DLL plus an injector or proxy DLL |

## Pick the mechanism

- **Patch** a few bytes in the exe/dll. Permanent, no runtime dependency, no injection.
  Brittle across game updates, and you need a backup to revert.
- **Hook** a function at runtime. Survives surrounding code changes if you resolve the
  target by pattern rather than a fixed address. Needs code in the process.
- **Instrument** only (Frida). Fastest way to confirm a theory; not a shippable mod.

## Find the target

1. Ghidra or rizin: locate the function and note its RVA.
2. x64dbg: attach, compute `VA = module base + RVA`, breakpoint it, and reproduce the
   behaviour. A decompiled function that never executes is a guess.
3. Record the bytes around the instruction so you can pattern-scan later.

## MinHook (Windows x86/x64)

Installed to `06_Memory-and-Instrumentation/minhook`:

- `include/MinHook.h`
- `lib/libMinHook.x64.lib`
- `lib/libMinHook.x86.lib`

```cpp
#include <MinHook.h>

using Fn = int (*)(void* self, int amount);
static Fn orig = nullptr;

static int Hook(void* self, int amount) {
    // return orig(self, amount);   // call the original
    return 0;                       // or replace the behaviour
}

bool Install(std::uintptr_t target) {
    if (MH_Initialize() != MH_OK) return false;
    if (MH_CreateHook(reinterpret_cast<LPVOID>(target),
                      reinterpret_cast<LPVOID>(&Hook),
                      reinterpret_cast<LPVOID*>(&orig)) != MH_OK) return false;
    return MH_EnableHook(MH_ALL_HOOKS) == MH_OK;
}
```

Add `include` to the include path, `lib` to the library path, link
`libMinHook.x64.lib`, build x64, and load the DLL into the game.

## Detours (Windows)

Installed as source at `06_Memory-and-Instrumentation/detours`. Build it from a Visual
Studio developer prompt (`nmake`), then link `detours.lib`.

```cpp
#include <detours.h>

static int (WINAPI* Real)(void* self, int amount) = nullptr;
static int WINAPI Hook(void* self, int amount) { return 0; }

DetourTransactionBegin();
DetourUpdateThread(GetCurrentThread());
DetourAttach(&(PVOID&)Real, Hook);
DetourTransactionCommit();
```

## Frida (quick confirmation)

```powershell
frida -p <pid> -l hook.js
```

```js
const f = Module.getExportByName(null, "SomeExport");
Interceptor.attach(f, {
  onEnter(args) { console.log("hit", args[0]); },
  onLeave(ret) { ret.replace(0); }
});
```

Use it to prove the address and the effect before writing a DLL. It is not a delivery
mechanism for a mod users install.

## Getting the DLL into the process

The kit does not bundle an injector. Options:

- a proxy DLL that the game already loads (`d3d11.dll`, `version.dll`, ...),
- a small launcher that calls `CreateRemoteThread` + `LoadLibrary`,
- the engine's own loader (BepInEx/MelonLoader/UE4SS/SourceMod).

Whichever you choose, keep it offline: anti-cheat-protected games are out of scope, and
a hook that trips VAC is your problem, not the toolkit's.
