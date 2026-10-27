# Willowbrook evidence — 27 October 2026

Godot 4.6.3.stable.official.7d41c59c4, Linux x86_64. The approved reference was fetched and inspected at `1381f09`. These results validate a playable candidate, not full visual parity or Android readiness.

| Evidence | Result and actual scope |
| --- | --- |
| Baseline at 6031a4c | Original 56 checks rerun successfully: 37 regression, 15 journey, 4 exploration. See `baseline-6031a4c.txt`. |
| Current automated simulation | **86/86**: original 56 plus 30 safety assertions. Real Godot physics, synthetic events, injected notifications and direct method calls. |
| Rendered regression | **37/37** on OpenGL Compatibility, Mesa llvmpipe / LLVM 19.1.7, Xvfb 1280×720. |
| Rendered safety | **30/30** on the same desktop renderer. These repeat automated assertions, not new independent phone tests. |
| Visual captures | Title, village, forest and wheel captured from the current scene and inspected; positions are staged by the capture script. |
| Normal application interaction | Agent sent X11 mouse/keyboard events to the normal game, in a separate local-save profile; observed menu navigation and the hold-to-select power wheel. This was not a human playtest or complete interactive route/boss run. |
| Android export | Debug APK built; v2/v3 signatures and 16 KiB zip alignment verified. Manifest inspected: API minimum 24, target 36; arm64-v8a and x86_64. No app permissions requested. |
| Android runtime and performance | **Unverified**. ADB device list empty; no emulator installed and `/dev/kvm` absent. No Android version/device/renderer/frame-rate measurement exists. |

## What the checks do and do not establish

The original regression suite checks title state, initial health/magic, three simultaneous synthetic touches, slide-off/release, tap versus hold, locked wheel selection, empty magic and regeneration, damage/invulnerability, sword active windows, a real bolt hitting the crystal, death/checkpoint/pit recovery, a projectile killing the mini-boss (with reduced health for that assertion), idempotent rewards, saves/backups/corruption, schema rejection, focus cleanup, journal pause, wall occlusion, coyote/buffer jumps and settings persistence. Some assertions call methods directly: they are not proof of complete input-to-behavior coverage.

The scripted journey traverses the authored gap and ledge, opens the seal, fights the boss with normal sword/bolt actions, reaches completion and reconstructs the scene from saved progress. It uses bounded scripted controls and asserts no forced death. Exploration traverses both secret ledges and claims the merchant reward. Neither is hands-on gameplay.

The added 30 assertions exercise four concurrent touches; releases outside without drag; canceled/duplicate/reused gesture ownership; keyboard aliases and mixed key/touch ownership; focus/background/resume/back notifications; stable empty-magic puzzle recovery; safe resets and refusal on the wrong side; completed quest protection; contradictory save rejection; and safe pit recovery support. Injecting Android-like notifications in Linux does not verify Android OS delivery.

## Reproduce

`./tools/check.sh` runs all suites sequentially and preserves failure exit codes. Each uses a dedicated save slot, not `journey.json`. Do not run duplicate copies of a suite concurrently.

`DISPLAY=:99 ./tools/godot.sh --audio-driver Dummy res://tests/gameplay.tscn` and the corresponding `input_safety.tscn` command require an existing X server. Fixed simulation timing in the headless script is not a benchmark. `tests/capture.tscn` regenerates the staged gameplay PNGs.

Logs: `test-results.txt`, `rendered-test-results.txt`, `rendered-safety-results.txt`. Xvfb reports unsupported V-Sync mode. Some fast headless runs report an ObjectDB cleanup warning at shutdown; assertions pass, but this should be revisited if reproduced during real device use. No warnings were hidden to turn a failed test into a pass.

## Remaining validation

Install and play on a named Android phone: physical multitouch, release/cancel, app switching, safe areas, pause/back behavior, full route/boss, save/restart and thermal/frame-time profiling at both quality settings. Crash/power-loss durability and actual process termination are not proven by scene-reload tests. Human combat/camera/animation tuning and visual approval against the richer concept remain pending. The other five regions have not been added.

## Blender forest visual-review revision

The same 86 gameplay assertions pass after swapping the forest assets and adding limb posing; terrain colliders, AI, combat timings, quest/save rules and controls are preserved. Current rendered logs are replaced with the revision's actual runs. Visual review is documented separately in `forest-revision.md` and `visual-review.html`; assertions are not proof of artistic quality. Current captures include an explicitly labeled close-up in addition to the gameplay camera. No full human interactive playtest or Android measurement was performed for this art revision. A fresh `adb devices -l` returned an empty device list.

## Scenery refinement — 27 October 2026

Reran all four headless suites on the final scenery code: 37 regression, 15 journey, 4 exploration, and 30 input/safety assertions passed (86 total). See `scenery-pass-checks.txt`. Regenerated and visually inspected the gameplay captures with Godot 4.6.3 Compatibility / Mesa llvmpipe; see `scenery-pass-render.txt`. The 67 rendered assertions from the previous Blender revision were not rerun for this pass. A headless shutdown reported an ObjectDB cleanup warning; the full warning is retained in the log. The APK was not rebuilt and no Android or human playtest was performed.
