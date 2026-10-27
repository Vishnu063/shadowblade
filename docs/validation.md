# Validation evidence — Willowbrook prototype

Validated on 27 October 2026 using Godot **4.6.3.stable.official.7d41c59c4**, Linux x86_64. This records automated correctness checks and rendered captures, not human playtesting or a phone benchmark.

| Operation | Result |
| --- | --- |
| Headless editor import | Completed without script/import errors |
| `./tools/check.sh` | Exit 0; **56/56 checks passed** across three sequential suites |
| Gameplay regression | **37/37**, including three simultaneous synthetic screen touches, slide-off, hold/tap magic, depletion/regen, half-heart damage, hit immunity, actual sword/bolt collision, crystal seal, lethal damage, pit recovery, mini-boss death, single reward, save/load/backup, invalid saves, focus pause/resume, journal, wall obstruction, coyote/buffer jumps and settings persistence |
| Continuous journey | **15/15**: start at Lyra, walk and jump the authored route, attune both checkpoints, cast from the actual crystal ledge, pass the seal, defeat the Warden with normal combat, reach completion and reconstruct the scene from disk; no forced respawn |
| Optional exploration | **4/4**: jump both upper ledges, collect the shard through player proximity and claim merchant restoration |
| Rendered gameplay regression | **37/37**, exit 0 with OpenGL Compatibility on Mesa llvmpipe, Xvfb 1280×720 |
| Actual rendered captures | Title, village, forest and power wheel PNGs produced successfully and visually inspected |
| Android export / install | **Unrun**: SDK, export templates, adb and device/emulator unavailable |
| Physical phone touch / background-resume / performance | **Unverified**: no named Android device available |

The headless result log is [test-results.txt](test-results.txt); the rendered gameplay log is [rendered-test-results.txt](rendered-test-results.txt). Reproduce the headless checks with `./tools/check.sh` from the repository root. Test saves are isolated from the player slot. Do not run multiple instances of the same suite simultaneously because they use the same isolated slot name.

The rendered run reports that Xvfb cannot change V-Sync mode. This is a virtual display limitation, not a measured phone result. Mesa llvmpipe is a CPU renderer; no Android FPS, device compatibility, power or thermal claims follow from these checks. Fixed simulation timing is used for test repeatability and must not be used to infer real-time performance.

The first integrated route run found and led to a correction of a low platform that blocked walking. Save tests found and led to JSON number validation/type normalization fixes. The final checks above run against the corrected implementation.

## Limits of this milestone

- All 3D art, animation and sounds are temporary primitives/procedural cues. A production visual pass and human gameplay tuning remain required.
- The approved sample image was not attached, so visual matching is not verified.
- Touch events and focus interruptions were simulated in Godot on Linux; actual Android dispatch, cutouts, multitouch hardware and OS lifecycle behavior need a device pass.
- Restart coverage reconstructs the entire scene from disk in a running test process. Actual app termination, power loss and Android filesystem durability need platform tests. The save uses temporary-file replacement and a backup, not a claim of proven crash-proof storage.
- The ordinary route, boss fight and optional route are short and deterministic; these checks do not replace extended exploratory playtesting.
- Only Willowbrook and Arcane Bolt are implemented. The five locked powers and their regions, final fortress and Lord Vaelor are pending. Menus and returning to Willowbrook work; multi-region transitions cannot be tested yet.
- No APK or export preset has been generated, signed or installed. The Android guide contains unexecuted instructions for a machine with the appropriate SDK/tooling.
