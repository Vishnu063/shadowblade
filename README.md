# Shadowblade: The Last Guardian

An original offline Android action adventure, built with Godot 4.6.3 / GDScript. Kael explores six villages, learns six powers and confronts Lord Vaelor in the final fortress. Gameplay follows a fixed side-scrolling plane inside real 3D scenes.

**Status:** complete playable campaign candidate. Graphics remain below the approved concept. Phone performance, physical multitouch and a full human playtest remain unverified. This is not a store-ready release.

## Current gameplay images

![Current Willowbrook](docs/screenshots/willowbrook.png)
![Current forest](docs/screenshots/forest.png)

[Kael close-up](docs/screenshots/kael-detail.png) · [Power wheel](docs/screenshots/powers.png) · [Visual comparison](docs/visual-review.html)

These are actual engine captures with staged positions, not concept art or proof of a human playthrough. Obsolete comparison images were removed from this branch; the approved [concept](docs/art/willowbrook-concept.png) remains separate. The current regional gallery is linked below.

## Regional screenshots

| Region | Current engine image |
| --- | --- |
| Emberhearth | [View](docs/screenshots/emberhearth.png) |
| Frosthaven | [View](docs/screenshots/frosthaven.png) |
| Windrest | [View](docs/screenshots/windrest.png) |
| Stormwatch | [View](docs/screenshots/stormwatch.png) |
| Duskveil | [View](docs/screenshots/duskveil.png) |
| Final fortress | [View](docs/screenshots/fortress.png) |

## Campaign

| Village / area | Power | Main mechanism |
| --- | --- | --- |
| Willowbrook | Arcane Bolt | Crystal switch |
| Emberhearth | Flame Burst | Vine seal and lava hazard |
| Frosthaven | Frost Bind | Frost rune and temporary ice bridge |
| Windrest | Wind Dash | Wide gap and wind vane |
| Stormwatch | Lightning Chain | Conductor |
| Duskveil | Guardian Light | Void seal and hidden high relic |
| Shadow Fortress | All unlocked powers | Four seals, Lord Vaelor and ending |

Each region has a guide quest, rest point, merchant service, optional relic, checkpoints, puzzle and boss. New powers unlock before the regional boss. Defeat the boss and follow the eastern trail to continue. The final monument requires Flame, Frost, Lightning and Light. Return travel preserves each region’s progress.

The regions reuse a common route/3D kit and encounter framework, with different backdrops, landmarks, lighting, required mechanics and later boss variations. They are not seven wholly bespoke art sets.

## Controls

| Action | Phone | Desktop development |
| --- | --- | --- |
| Move | Left/right buttons | A/D or arrows |
| Jump | Hold Jump | Hold Space |
| Sword combo | Sword | J or X |
| Cast | Tap selected magic | Tap K or C |
| Power selection | Hold magic, slide, release | Hold K or use 1–6 |
| Talk/rest/use | Talk / Use | E |
| Pause/map/journal | Pause menu | Escape / Tab |

Three red hearts and the shared blue magic bar are preserved. Sword attacks are free. Magic regenerates after a delay. Arcane Bolt costs 10, Flame 20, Frost 25, Wind 15, Lightning 30 and Guardian Light 40. Shield absorbs two hits but cannot prevent pit damage. Dash resets on landing and cannot cross walls. Temporary ice warns before disappearing and cannot become a permanent recovery point.

## Play and build

Import `project.godot` in the standard Godot 4.6.3 editor and press F5. No .NET edition, account, backend or paid service is required. With a Godot executable on PATH, `./tools/godot.sh` runs the project. Set `GODOT_BIN` for a different executable path.

`python3 tools/export_android.py` exports `build/Shadowblade-Campaign-debug.apk` for ARM64 Android using matching templates, JDK 17 and Android SDK build-tools 36.0.0. See [Android instructions](docs/android.md). Keys remain outside Git. A successful export does not prove phone runtime behavior.

## Saves and verification

One validated offline slot stores separate chapter checkpoints, quests, relics, seals, discovered villages, selected power and settings. Original Willowbrook version-one saves migrate without discarding progress. Corrupt primary saves can recover from a previous valid backup. Uninstalling may remove local progress; no cloud save is used.

`./tools/check.sh` runs the original regression, journey, exploration and input-safety suites plus full-campaign and power-mechanics suites. [Current evidence](docs/campaign-validation.md). **228 assertions pass:** 86 original, 121 campaign and 21 power checks. Eleven renderer captures and a signed/alignment-verified ARM64 APK were produced. Synthetic input and headless simulation do not establish Android hardware behavior or artistic quality.

## Remaining release work

Character animation, painted materials, rich vegetation, cliff/waterfall composition, legacy NPC/boss art and sound need more polish to approach the concept. Music and voice are absent. Android app switching, physical multitouch, safe areas, frame-time, memory/thermal behavior and human tuning need a real phone. No 60 FPS claim is made.

[Asset sources](docs/ATTRIBUTION.md) · [Environment](docs/environment.md) · [Original brief](docs/design-brief.md)
