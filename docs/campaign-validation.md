# Campaign validation — 27 October 2026

The restored source was imported and tested with official Godot 4.6.3 on Linux.

- Original suites: 37 gameplay, 15 journey, 4 exploration and 30 input-safety assertions (86 total).
- Campaign suite: 121 assertions, including physical route traversal, required-power puzzles, normal sword/bolt combat against all seven bosses, chapter exits, save round-trips and return travel. Boss health is not reduced and victories are not forced.
- Power suite: staged actors isolate fire, freeze, temporary ice recovery, dash/wall collision, lightning occlusion, shield limits, pause and respawn. This is separate from the natural campaign journey.

[Original checks](campaign-regression.txt) · [Campaign checks](campaign-journey.txt) · [Power checks](campaign-powers.txt)

The tests use separate save slots. Some headless runs retain an ObjectDB cleanup warning at exit; it has not been called resolved. Renderer capture and Android export evidence will be added after verification. No phone or emulator is available. These checks do not establish phone performance, human gameplay tuning or visual parity with the concept.
