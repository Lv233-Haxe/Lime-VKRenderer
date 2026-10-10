# SDL2 → SDL3 migration notes (Lime SDL3 fork)

This fork of Lime (based on upstream `lime` 8.4.0) upgrades the native backend
from SDL 2 to **SDL 3.4.14**. This document summarizes what changed and how to
build it.

## What was replaced

- `project/lib/sdl` previously held the SDL 2 source as a git submodule; it now
  contains the **SDL 3.4.14 source tree** (`include/` + `src/`).
- `project/lib/sdl-files.xml` was rewritten. The Windows section is the exact
  source list of an official SDL3 CMake build (`SDL3-static.vcxproj`); macOS /
  Linux sections are best-effort translations — regenerate them from a CMake
  build on the target platform if they drift:
  `cmake -S project/lib/sdl -B build -DSDL_STATIC=ON -DSDL_SHARED=OFF` and
  copy `build/include-config-<cfg>/build_config/SDL_build_config.h` into
  `project/lib/sdl/include/build_config/generated/<platform>/`.
- SDL3 needs a generated `SDL_build_config.h` (feature detection) and
  `SDL_revision.h`. The Windows x64 pair is committed under
  `include/build_config/generated/windows/` and `include/SDL3/SDL_revision.h`.
  Other platforms must generate their own (the hxcpp build passes
  `-DUSING_GENERATED_CONFIG_H` on Windows only).
- The vendored `sdl_sound` (SDL2-only API) is no longer compiled
  (`LIME_SDL_SOUND` removed, including the Haxe-side prim declarations in
  `NativeCFFI.hx`, which are only compiled when the define is explicitly
  restored). See "Audio decoding" below for what replaced it.
- `mojoal` (OpenAL-on-SDL2-audio) is disabled; `static_link` builds now use
  OpenAL Soft like normal builds.
- OpenAL Soft's SDL2 audio backend was removed from `openal-files.xml`; OpenAL
  Soft uses its native backends (WASAPI on Windows).
- ANGLE / `LIME_SDL_ANGLE` support was dropped — SDL3 no longer provides the
  EGL/ANGLE plumbing on Windows; WGL (`opengl`) and the software renderer are
  the supported contexts.
- Vulkan renderer (`VKRenderer.cpp`) is disabled by default in this fork
  (`-Dno-vulkan`) unless the Vulkan SDK headers are available via `VULKAN_SDK`.

## C++ backend port (project/src/backend/sdl)

Key API migrations:

| SDL2 | SDL3 |
| --- | --- |
| `#include <SDL.h>` | `#include <SDL3/SDL.h>` |
| `SDL_Init` returns 0 on success | returns bool |
| `SDL_INIT_TIMER` / `SDL_INIT_GAMECONTROLLER` | removed / `SDL_INIT_GAMEPAD` |
| `SDL_WINDOWEVENT` + `window.event` codes | first-class `SDL_EVENT_WINDOW_*` events |
| `SDL_CreateWindow(title, x, y, w, h, flags)` | `SDL_CreateWindowWithProperties` (keeps `SDL_WINDOWPOS_UNDEFINED` placement) |
| `SDL_WINDOW_FULLSCREEN_DESKTOP` / `SDL_WINDOW_ALLOW_HIGHDPI` | `SDL_WINDOW_FULLSCREEN` / `SDL_WINDOW_HIGH_PIXEL_DENSITY` |
| `SDL_SetWindowFullscreen(win, flags)` | `SDL_SetWindowFullscreen(win, bool)` + `SDL_SetWindowFullscreenMode` |
| `SDL_GL_DeleteContext` | `SDL_GL_DestroyContext` |
| `SDL_RenderCopy` | `SDL_RenderTexture` (float rects) |
| `SDL_GetRendererOutputSize` | `SDL_GetCurrentRenderOutputSize` |
| `SDL_GetRendererInfo` | `SDL_GetRendererName` |
| `SDL_RenderReadPixels(..., fmt, ...)` | returns an `SDL_Surface*` (converted to ABGR8888 for Lime) |
| `SDL_GL_GetDrawableSize` / `SDL_Vulkan_GetDrawableSize` | `SDL_GetWindowSizeInPixels` / `SDL_GetWindowPixelDensity` |
| `SDL_SetRelativeMouseMode` (global) | `SDL_SetWindowRelativeMouseMode` (per window) |
| `SDL_SetTextInputRect` | `SDL_SetTextInputArea(window, rect, cursor)`; `SDL_StartTextInput(window)` |
| `SDL_IsTextInputActive` | `SDL_TextInputActive(window)` |
| `SDL_GetKeyFromScancode(sc)` | `SDL_GetKeyFromScancode(sc, mod, key_event)` |
| `event.key.keysym.sym/.mod` | `event.key.key` / `event.key.mod` |
| `KMOD_*` | `SDL_KMOD_*` |
| `SDL_CreateRGBSurfaceFrom` + masks | `SDL_CreateSurfaceFrom(w, h, SDL_PIXELFORMAT_RGBA8888, ...)` |
| `SDL_FreeSurface` | `SDL_DestroySurface` |
| `SDL_GetWindowDisplayMode` | `SDL_GetWindowFullscreenMode` (NULL when windowed) + `SDL_GetDesktopDisplayMode(displayID)` |
| `SDL_GetNumVideoDisplays` / display indexes | `SDL_GetDisplays` + opaque `SDL_DisplayID` (Lime keeps indexes internally) |
| `SDL_GetDisplayDPI` | `SDL_GetDisplayContentScale(displayID) * 96` |
| `SDL_GetDisplayOrientation` | `SDL_GetCurrentDisplayOrientation` |
| `SDL_GetNumDisplayModes` / `SDL_GetDisplayMode` | `SDL_GetFullscreenDisplayModes(displayID, &count)` (array freed with SDL_free) |
| `SDL_IsScreenSaverEnabled` | `SDL_ScreenSaverEnabled` |
| `SDL_LogSetPriority` | `SDL_SetLogPriority` |
| `SDL_EventState(SDL_DROPFILE, SDL_ENABLE)` | `SDL_SetEventEnabled(SDL_EVENT_DROP_FILE, true)` |
| `SDL_PeepEvents(..., SDL_FIRSTEVENT, SDL_LASTEVENT)` | `SDL_EVENT_FIRST` / `SDL_EVENT_LAST`; `SDL_WaitEventTimeout` returns bool |
| `SDL_atomic_t` / `SDL_AtomicSet/Get/Add/CAS` | `SDL_AtomicInt` / `SDL_SetAtomicInt` / `SDL_GetAtomicInt` / `SDL_AddAtomicInt` / `SDL_CompareAndSwapAtomicInt` |
| `SDL_ThreadID()` | `SDL_GetCurrentThreadID()` |
| `SDL_GetWindowWMInfo` (syswm) | `SDL_GetWindowProperties` + `SDL_PROP_WINDOW_WIN32_HWND_POINTER` |
| WndProc subclassing for live resize | `SDL_SetWindowsMessageHook` (WM_SIZING / WM_SIZE / WM_ENTERSIZEMOVE) |
| `SDL_GameController*` API | `SDL_Gamepad*` (`SDL_OpenGamepad`, `SDL_RumbleGamepad`, `SDL_AddGamepadMapping`, ...) |
| gamepad events `caxis/cbutton/cdevice` | `gaxis/gbutton/gdevice`; connect events carry the instance id directly |
| `SDL_JoystickOpen/InstanceID/...` | `SDL_OpenJoystick`, `SDL_GetJoystickID`, `SDL_GetJoystickAxis`, ... |
| `SDL_JoystickGetGUIDString` | `SDL_GUIDToString` |
| `SDL_SYSTEM_CURSOR_ARROW/HAND/SIZEALL/...` | `SDL_SYSTEM_CURSOR_DEFAULT/POINTER/MOVE/NESW_RESIZE/...` |
| `SDL_ShowCursor(true/false)` | `SDL_ShowCursor()` / `SDL_HideCursor()` |
| `SDL_RWops*` | `SDL_IOStream*` (`SDL_IOFromFile`, `SDL_ReadIO`, `SDL_SeekIO`, `SDL_GetIOSize`, ...); stdio `FILE*` recovered via `SDL_PROP_IOSTREAM_STDIO_FILE_POINTER` |
| `SDL_GetBasePath()` returns char* to free | returns `const char*` owned by SDL |
| `SDL_Vulkan_CreateSurface(win, inst, &surf)` | adds allocator param, returns bool |
| `SDL_Vulkan_GetInstanceExtensions(win, &n, names)` | `SDL_Vulkan_GetInstanceExtensions(&count)` returns an SDL-owned list |
| `SDL_iPhoneSetAnimationCallback` | `SDL_SetiOSAnimationCallback` |
| `SDL_EventFilter` returning int | returns bool |
| fake `RENDER_CONTEXT_RESTORED` after reset | `SDL_EVENT_RENDER_DEVICE_RESET` (recoverable) vs `SDL_EVENT_RENDER_DEVICE_LOST` |

## New SDL3 features exposed in Lime

- `lime.ui.WindowProgressState` + `Window.progressState` / `Window.progressValue`
  — taskbar/dock progress indicator (`SDL_SetWindowProgressState`,
  SDL 3.2.8+), implemented in `project/src/SDL3Extensions.cpp`.
- `Window.safeArea` — `SDL_GetWindowSafeArea` (display cutouts / rounded
  corners).
- `Gamepad.rumbleTriggers(left, right, duration)` — `SDL_RumbleGamepadTriggers`.
- `Gamepad.setLED(r, g, b)` — `SDL_SetGamepadLED`.
- Per-window relative mouse mode (`Window.mouseLock` now uses
  `SDL_SetWindowRelativeMouseMode`).
- `SDL_WINDOW_TRANSPARENT` used for transparent windows, `SDL_WINDOW_HIGH_PIXEL_DENSITY`
  for `allowHighDPI`, and `Window.scale` is derived from
  `SDL_GetWindowPixelDensity`.
- `SDL_SetWindowsMessageHook` replaces the WndProc subclass hack for live
  resize events on Windows.

## SDL3 new features exposed in Lime

Beyond the API migration, this fork exposes SDL3-only capabilities through
new Lime APIs (all verified on Windows x64):

| Lime API | SDL3 backend | Since |
| --- | --- | --- |
| `System.theme: SystemTheme` (`UNKNOWN`/`LIGHT`/`DARK`) | `SDL_GetSystemTheme` | 3.2.0 |
| `System.isTablet: Bool` | `SDL_IsTablet` | 3.2.0 |
| `Display.usableBounds: Rectangle` (desktop work area) | `SDL_GetDisplayUsableBounds` | 3.2.0 |
| `Window.progressState` / `Window.progressValue` + `lime.ui.WindowProgressState` | `SDL_SetWindowProgressState` / `SDL_SetWindowProgressValue` | 3.2.8 |
| `Window.safeArea: Rectangle` | `SDL_GetWindowSafeArea` | 3.2.0 |
| `Window.mouseRect: Null<Rectangle>` (cursor confinement) | `SDL_SetWindowMouseRect` | 3.2.0 |
| `Window.setCursorImage(image)` (full-color, alpha cursor) | `SDL_CreateColorCursor` | 3.2.0 |
| `Window.onOccluded` event (render skip hint) | `SDL_EVENT_WINDOW_OCCLUDED` | 3.2.0 |
| `Window.blurMode` / `Window.blurTint` + `lime.ui.WindowBlurMode` (Windows 10+) | `SetWindowCompositionAttribute` (`ACCENT_ENABLE_BLURBEHIND` / `ACCENT_ENABLE_ACRYLICBLURBEHIND`) + `DwmExtendFrameIntoClientArea` | Windows-only |
| Per-window relative mouse mode (`Window.mouseLock`) | `SDL_SetWindowRelativeMouseMode` | 3.2.0 |
| `Gamepad.rumbleTriggers(left, right, duration)` | `SDL_RumbleGamepadTriggers` | 3.2.0 |
| `Gamepad.setLED(r, g, b)` | `SDL_SetGamepadLED` | 3.2.0 |
| `SDL_EVENT_RENDER_DEVICE_LOST` (unrecoverable) vs `..._RESET` (recoverable) | separate render context events | 3.2.0 |
| Native file dialogs (default; `-Dlime-tinyfiledialogs` restores the old backend) | `SDL_ShowOpenFileDialog` / `SDL_ShowSaveFileDialog` / `SDL_ShowOpenFolderDialog` via `SDL_RunOnMainThread` | 3.2.0 |
| `SDL_WINDOW_TRANSPARENT` used for transparent windows | window flag | 3.2.0 |
| `SDL_WINDOW_HIGH_PIXEL_DENSITY` + `Window.scale` via `SDL_GetWindowPixelDensity` | window flag / density | 3.2.0 |
| Live resize via `SDL_SetWindowsMessageHook` (replaces WndProc subclassing) | windows message hook | 3.2.0 |

Deliberately not exposed (with reasons):

- **SDL_GPU** — would compete with Lime's GL/Vulkan renderers; revisit as a
  separate render context type if there is demand.
- **SDL_AsyncIO** — Lime's IO is synchronous with worker threads already.
- **Clipboard MIME data** (`SDL_SetClipboardData`) — Lime's clipboard is
  text-only today; the API needs explicit buffer lifetime management.
- **Gamepad sensors/touchpads** — niche; straightforward to add on top of
  `SDL3Extensions.cpp` if needed.

The file dialogs run the modal on the main thread via
`SDL_RunOnMainThread`, while Lime's `FileDialog` worker thread blocks on a
semaphore until the SDL callback delivers the result — the existing Haxe
`FileDialog` API (`browse()`, `onSelect`/`onSelectMultiple`/`onCancel`) is
unchanged.

### Window blur / acrylic (磨砂) on Windows

`Window.blurMode` turns on the Windows backdrop blur behind the window,
implemented in `SDLWindow::SetBlurMode` (project/src/backend/sdl/SDLWindow.cpp)
by dynamically loading `SetWindowCompositionAttribute` from user32 — no
dwmapi.lib dependency for the accent policy itself:

| `WindowBlurMode` | Effect |
| --- | --- |
| `NONE` (0) | opaque window, no backdrop effect |
| `BLUR` (1) | `ACCENT_ENABLE_BLURBEHIND` — cheap Gaussian-ish blur |
| `ACRYLIC` (2) | `ACCENT_ENABLE_ACRYLICBLURBEHIND` — blur + saturation + noise, supports tint |

`Window.blurTint` (ARGB, e.g. `0x80101040`) is only used by `ACRYLIC`; the
low-opacity byte (alpha of the tint layer) controls how strongly the tint
covers the blurred backdrop.

Requirements for the effect to actually be visible:

1. The window must be created with `transparent="true"` (Project.xml
   `<window ... transparent="true" />` → `SDL_WINDOW_TRANSPARENT`). With an
   opaque window the composition effect is applied but fully covered by the
   frame.
2. The rendered frame must leave those pixels **transparent** (alpha < 255)
   where the backdrop should show through. A GL renderer that clears to an
   opaque color hides the blur entirely — clear with alpha 0 (e.g.
   `background="#00000000"` in Project.xml plus a matching GL clear alpha)
   and draw the UI with alpha on top.
3. `DwmExtendFrameIntoClientArea(-1,-1,-1,-1)` is applied automatically so
   the whole client area participates in composition.

Caveats:

- **Acrylic drag lag**: with `ACCENT_ENABLE_ACRYLICBLURBEHIND` Windows renders
  the backdrop with a visible latency while dragging the window on some
  Win10/11 + GPU combinations (a long-standing OS behavior, see Microsoft's
  devblogs). `BLUR` mode does not lag. Test on target machines before
  shipping acrylic.
- The API round trip (mode + tint get/set, accent state changes, live loop,
  clean exit) is verified headlessly on Windows x64; the visual result
  depends on the points above and needs a manual eyeball check per app.

## Audio decoding

SDL3 core only ships a WAV loader (`SDL_LoadWAV_IO`); compressed formats are
intentionally left to the app (SDL's own docs point at SDL_mixer). The SDL3
fork therefore keeps Lime's own decode chain (`lime_audio_load_file/bytes`)
and restores what SDL_sound used to provide with header-only decoders:

| Format | Decoder | Notes |
| --- | --- | --- |
| WAV | `WAV::Decode` | unchanged, pure C++ |
| OGG | `OGG::Decode` + `VorbisFile` streaming | vendored libvorbis, SDL-independent |
| MP3 | `MP3::Decode` (**new**) | `dr_mp3.h` (public domain), replaces SDL_sound |
| FLAC | `FLAC::Decode` (**new**) | `dr_flac.h` (public domain), replaces SDL_sound |

The dr_libs headers live in `project/lib/custom/dr/` and are enabled by
default (`LIME_MP3` / `LIME_FLAC` sets in `Build.xml`, pass
`-Dno-mp3` / `-Dno-flac` to disable after adding matching unset rules).

Implementation notes:

- Both decoders read the whole file/bytes into PCM in memory (no streaming),
  converted to 16-bit PCM in the source's channel/sample-rate layout.
- hxcpp has a moving GC: the decoders keep a pointer to GC-managed source
  bytes while decoding, so all output is written to a `malloc` buffer first
  and copied into the `AudioBuffer` only after the decoder is closed — a GC
  allocation between those points could move the source and crash.

## IME policy ("stuck IME" fix)

SDL3 already implements the right lifecycle — it detaches the OS IME when a
window is created ("Ensure that the IME isn't active on the new window until
explicitly requested") and re-attaches the window's original IME context in
`SDL_StartTextInput`. However its `IME_Enable`/`IME_Disable` are skipped for
any window that is not the first "main" window (`ime_hwnd_current !=
ime_hwnd_main`) and until the first IME messages arrive, so the detach is not
always enforced and the user's Chinese/Japanese/Korean IME can swallow game
keys into a composition window.

Lime enforces the missing side itself (Windows desktop, `SDLWindow`):

- **Text input disabled (game mode, the default):** the IME is detached from
  the window via `ImmAssociateContext(hwnd, NULL)` — keys always reach SDL as
  raw (English) key events, no composition window, no stuck IME. This is also
  re-asserted when the window regains focus (`UpdateIMEState`), covering
  native window re-creation (DPI/display changes) and system re-attachment.
- **Text input enabled (focused text field):** attaching is left to SDL3,
  which captured the window's original IME context at creation time — Lime
  must NOT call `ImmAssociateContext` here (its own handle would be NULL,
  since SDL3 has already detached the window by then) and must not detach
  after `SDL_StartTextInput`.

The policy is transparent to Haxe code: it follows `Window.textInputEnabled`
(`lime_window_set_text_input_enabled`), which OpenFL's TextField sets on
focus. imm32.dll is loaded dynamically, the implementation is skipped on
WinRT, and setting the environment variable `LIME_DEBUG_IME=1` prints the
attach/detach decisions to stdout for diagnostics.

### HaxeFlixel note

Flixel's `FlxInputText` (as vendored by Psych Engine and similar projects)
manages its own `hasFocus` flag and never sets `FlxG.stage.focus`, so OpenFL's
`TextField.__enableInput()` never runs and `Window.textInputEnabled` stays
`false` — with the SDL3 IME policy the field then only receives raw English
key events and the IME never engages.

The project's vendored `source/flixel/addons/ui/FlxInputText.hx` was patched
to bridge the two layers:

- `set_hasFocus` now enables/disables `FlxG.stage.window.textInputEnabled`
  and subscribes to `window.onTextInput` (`__updateTextInputMode`);
- committed text (IME results and plain keystrokes) is inserted at the caret
  by `__onWindowTextInput`, honoring `filter`/`maxLength`/`onChange`;
- `onKeyDown` skips printable-character insertion while the window's
  text-input mode is on, so keystrokes are not double-inserted and raw
  pinyin/moshi composition keys never leak into the field.

Unfocused fields keep the window in game mode (IME detached); focusing any
`FlxInputText`/`FlxUIInputText` restores the user's IME until it loses focus.

## Building (Windows x64)

```bash
haxelib dev lime D:/Lime-8.4.0-preview
haxelib run lime rebuild windows -64 -Dno-vulkan
# (optional) with the Vulkan SDK installed, drop -Dno-vulkan
```

The result is `ndll/Windows/lime.ndll`, statically linking SDL 3.4.14.

Note the two variants: `lime rebuild` builds only the **debug** ndll
(`lime-debug.ndll`, `-DHXCPP_DEBUG`); the **release** `lime.ndll` is rebuilt
automatically by the next `lime build windows` of an app that uses this dev
lime whenever project sources are newer than its cached objects.

## Faster Haxe → C++ builds (low-end CPUs)

Most of an `lime build windows` wall-clock is hxcpp compiling the generated
C++ (hundreds of files). Three levers, in order of impact:

1. **hxcpp compile cache** — caches object files across builds keyed by
   compiler command line, so unchanged modules (haxe std, lime, openfl,
   flixel sources) are not recompiled at all when they don't change:

   ```bat
   set HXCPP_COMPILE_CACHE=D:\hxcpp-cache
   set HXCPP_CACHE_MB=8192
   ```

   Set these once (system environment or a wrapper .bat). First build after
   enabling is *slower* (fills the cache); from the second build on,
   haxe-only iterations drop from minutes to well under a minute on a
   4-core CPU. `D:\Psych-Online-CNVE-NEO\build-fast.bat` wraps all of this.

2. **-debug iteration builds** — build the `-debug` variant while iterating
   (`lime build windows -debug`): hxcpp compiles the generated C++ with
   `-Od` (no optimization) instead of `-O2 -Os`, which is dramatically
   faster per file on weak CPUs. Ship with a final non-debug build. Do not
   mix: debug and release variants keep separate object trees, so one does
   not invalidate the other.

3. **Trim the backend** — already done in this fork: `-Dno-vulkan` (skips
   the Vulkan backend entirely unless the SDK is wanted), no
   lime-openalsoft-with-SDL2, no SDL_sound, no ANGLE. The dr_mp3/dr_flac
   headers are the only additions.

What does *not* help: haxe-side flags like `-Dmacro-times` only diagnose;
`--hxml` tweaks don't touch the C++ stage which dominates. For genuinely
faster C++ compiles the cache (1) is the effective lever, since hxcpp skips
recompiling anything whose generated source and flags are unchanged.
