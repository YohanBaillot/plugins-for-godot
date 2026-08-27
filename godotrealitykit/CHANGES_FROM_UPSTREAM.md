# Local modifications from upstream

This is a running log of every change made to get GodotRealityKit building and
running on this specific machine (Intel Mac, macOS 15.7.3, Xcode 26.3). None of
these are upstream Apple changes — if something breaks, this is the list to
check/revert against a clean `git clone`.

## System-level changes (outside the repo, not reversible via git)

- Removed stale MacPorts `gcc`/`g++`/`cpp`/`c++`/`gcj`/`gcov`/`gfortran` and
  their `-mp-4.7` binaries from `/opt/local/bin` — a 2017-era dead MacPorts
  install was shadowing Xcode's clang in `$PATH`.
- Removed stale MacPorts `ar`/`ranlib` from `/opt/local/bin` — same shadowing
  issue, was corrupting a build archive.
- Cleared `~/Library/Developer/Xcode/DerivedData` (~40GB) — disk had filled up
  (only ~850MB free on a 926GB drive) and crashed a mid-build link step.

## `SConstruct` (repo root)

1. **Added `HOST_ARCH = platform.machine()`** (top of file) and changed the
   hardcoded `bin/godot.macos.editor.dev.arm64` path in `build_godot()` to use
   `HOST_ARCH` instead. The script assumed Apple Silicon; this machine is
   Intel (x86_64), so the produced binary is named `...x86_64`, not `...arm64`.

2. **Added `arch=arm64`** to the visionOS `godot-cpp` build command in
   `build_godot_cpp()`. Without it, godot-cpp defaulted to the host's arch
   (x86_64) for the visionOS build, which fails outright — visionOS/XROS SDKs
   are arm64-only.

3. **`build_framework_action()`**: now rewrites `SDKROOT` in
   `GodotRealityKit/Configurations/build.gen.xcconfig` to `macosx` or `xros`
   depending on which platform is being built, before invoking `xcodebuild`.
   The file that's supposed to auto-regenerate this (per a comment in
   `Config.xcconfig` referencing a scheme PreAction / `scripts/build/generate-build-config.sh`)
   doesn't exist in this repo — it shipped with `SDKROOT` hardcoded to `macosx`,
   which silently broke the visionOS framework build (it looked like a macOS-only
   build from Xcode's perspective).

4. **`build_framework_action()`**: `xcodebuild` invocation is now
   platform-conditional — macOS uses `-destination generic/platform=macOS`,
   visionOS uses `-sdk xros`. Reasoning:
   - `-destination generic/platform=visionOS` gets stuck / only resolves macOS
     as an available destination for this project (destination-resolution bug,
     cause unclear — possibly related to the missing PreAction above). `-sdk xros`
     works around it.
   - But `-sdk` alone (no `-destination`) makes `xcodebuild` build only the
     host's native architecture, ignoring `ARCHS` — so using `-sdk macosx` for
     the macOS build silently produced a single-arch (x86_64-only) framework
     instead of universal. macOS's `-destination` resolution works fine, so it
     keeps using that to get a real arm64+x86_64 universal build.

5. **Removed `resolve_xcode_destination()`** (obsoleted by point 4) and
   **`resolve_xcode_products_subdir()`** (was adding a `-xros` suffix to the
   visionOS Products subdirectory that doesn't actually exist when building
   with `-sdk`; both platforms just use the plain `Debug`/`Release` subdir).

## `GodotRealityKit/Configurations/Config.xcconfig`

- **`ARCHS[sdk=macosx*] = arm64 x86_64`** added (base `ARCHS = arm64` kept for
  visionOS, which is arm64-only). Was hardcoded to `arm64` unconditionally for
  *all* platforms including macOS, so the macOS framework only ever linked for
  Apple Silicon and failed to `dlopen` on this Intel Mac
  (`incompatible architecture (have 'arm64', need 'x86_64')`).

## Fetched Godot engine source — `out/shared_workspace/deps/debug/godot/platform/macos/detect.py`

⚠️ **This file is NOT part of the GodotRealityKit repo** — it's inside the
separately-cloned Godot engine fork under `out/`, which `.gitignore` excludes
(`out/`, `deps`). **This edit will be silently lost if `out/` is ever deleted
and the deps re-cloned.** If that happens and Metal breaks again, reapply this:

- Removed this gate around line 308:
  ```python
  if env["metal"] and env["arch"] != "arm64":
      print_warning(...)
      env["metal"] = False
  ```
  It force-disabled the Metal rendering driver on any non-arm64 build,
  regardless of whether the actual GPU supports Metal (it does — this Mac has
  an AMD Radeon Pro 5500M, a real Metal-capable GPU). Without Metal, this
  editor build had *no* RenderingDevice backend at all (Vulkan was also
  disabled via a separate `vulkan=false` build flag), which crashed the editor
  at startup (`RenderingServerDefault::_init()`, signal 11) the moment it
  tried to load a project configured for the "Mobile" rendering method.

## macOS 15 compatibility (avoids requiring an OS upgrade)

This Mac runs macOS 15.7.3. The plugin's `Config.xcconfig` had
`MACOSX_DEPLOYMENT_TARGET = 26.0`, and two code paths genuinely called
macOS-26-only RealityKit/Spatial APIs unconditionally. Rather than requiring
an OS upgrade (this machine — a 2019 Intel MacBook Pro 16" — is the last
Intel model macOS Tahoe 26 supports at all, and running it there was ruled
out as too strenuous on the hardware), both call sites were guarded to
gracefully degrade below macOS 26, following the *exact same pattern already
used elsewhere in this codebase* for `LowLevelInstanceData`
(`RealityKitUtils.swift:654`, `@available(macOS 26.0, visionOS 26.0, *)` with
an optional/nil fallback) — this wasn't a novel workaround, just finishing
something the plugin was already most of the way toward.

- **`GodotRealityKit/Configurations/Config.xcconfig`**:
  `MACOSX_DEPLOYMENT_TARGET` lowered from `26.0` to `15.0`.

- **`GodotRealityKit/RealityKitUtils.swift`** — `HoverEffectGroupID` called
  `HoverEffectComponent.GroupID()` (macOS 26.0+ only) unconditionally in its
  initializer. Restructured to store the value as `Any?`, only constructed
  `if #available(macOS 26.0, *)`; the typed `value` accessor is itself marked
  `@available(macOS 26.0, *)`. `setHoverEffect()` now branches: grouped hover
  effect when available, falls back to the older ungrouped
  `.spotlight`/`.highlight` overloads (no `groupID:` param) otherwise. Below
  macOS 26, hover-effect *grouping* specifically is unavailable; the hover
  effect itself still works.

- **`GodotRealityKit/RealityKitBridge.swift`** — `calculateRay()`'s
  `PerspectiveCameraComponent` branch used `ProjectiveTransform3DFloat`,
  `Angle2DFloat`, and `.inverse` (all macOS 26.0+ only) to convert a 2D click
  location into a 3D ray for entity picking in the local macOS RealityKit
  preview. Added `guard #available(macOS 26.0, *) else { return nil }` at the
  top of that branch. Below macOS 26, mouse click/hover picking in the local
  macOS preview doesn't resolve a ray (silently no-ops) — the
  `OrthographicCameraComponent` branch right below it doesn't use any
  restricted API and is unaffected. **The visionOS/Vision Pro device target
  is completely unaffected by this change** — it already has its own
  separate, non-restricted ray-casting implementation via
  `EntityTargetValue<SpatialEventCollection>` a few lines down (`#else`
  branch), which was never touched.

Verified: full `scons framework platform=macos` build succeeds at
`MACOSX_DEPLOYMENT_TARGET=15.0` with no errors (only pre-existing, harmless
`-Wunguarded-availability-new` warnings in `multimesh_loader.h`/
`mesh_common.h`, which don't block the build — they reference the
already-`@available`-guarded `LowLevelInstanceData` type). The demo project
(`demo/godot-realitykit-demo`) opens, the GDExtension loads
(`Godot-RealityKit version 1: rendering a Godot scene with RealityKit.`), and
the editor completes full initialization with no crash.
