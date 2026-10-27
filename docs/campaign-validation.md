# Campaign validation — 27 October 2026

The restored source was imported and tested with official Godot 4.6.3 on Linux.

- Original suites: 37 gameplay, 15 journey, 4 exploration and 30 input-safety assertions (86 total).
- Campaign suite: 121 assertions, including physical route traversal, required-power puzzles, normal sword/bolt combat against all seven bosses, chapter exits, save round-trips and return travel. Boss health is not reduced and victories are not forced.
- Power suite: staged actors isolate fire, freeze, temporary ice recovery, dash/wall collision, lightning occlusion, shield limits, pause and respawn. This is separate from the natural campaign journey.

[Original checks](campaign-regression.txt) · [Campaign checks](campaign-journey.txt) · [Power checks](campaign-powers.txt)

The tests use separate save slots. Some headless runs retain an ObjectDB cleanup warning at exit; it has not been called resolved. Eleven current images were captured using Godot Compatibility and Mesa llvmpipe: [render log](campaign-render.txt). The capture script stages positions and progression; it is not a human playthrough. The log has no renderer errors; the unsupported V-Sync warning is retained. A signed ARM64 APK was exported and its signature/alignment verified: [export log](campaign-export.txt) and [SHA-256](campaign-apk-sha256.txt). No phone or emulator is available. These checks do not establish phone performance, human gameplay tuning or visual parity with the concept.
