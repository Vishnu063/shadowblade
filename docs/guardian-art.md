# Guardian and six-world villain art

The generated images are design targets, not screenshots, rigged models or extracted animation frames. They were created with the built-in image generation tool. Original Blender meshes approximate their silhouette and palette at much lower detail; visual parity has not been achieved.

[Hero concept](art/kael-guardian-concept.png) · [Movement poses](art/kael-movement-reference.png) · [Six power poses](art/kael-power-reference.png) · [Six villain/world concepts](art/six-villains-worlds-concept.png)

| World / village | Villain | Signature power | Dodge |
| --- | --- | --- | --- |
| Whispering Forest / Willowbrook | Hollow Warden | Thorn Snare | Leave the marked roots or jump; a hit briefly slows movement |
| Ember Depths / Emberhearth | Cinder Sentinel | Magma Eruption | Leave the marked ground or jump |
| Frozen Citadel / Frosthaven | Frostbound Keeper | Ice Prison | Leave the crystal marker or jump; a hit briefly slows movement |
| Shattered Skies / Windrest | Gale Harrier | Cyclone Dive | Jump over the moving low cyclone |
| Thunder Highlands / Stormwatch | Tempest Colossus | Thunder Strike | Move sideways out of the locked warning marker |
| Shadow Border / Duskveil | Void Herald | Shadow Rift | Leave the wider low rift or jump |

The existing Lord Vaelor encounter remains the finale beyond these six regional villains. The Dawn Gate at the final eastern exit opens after his defeat. Its ending-menu action teleports back to restored Willowbrook, retaining campaign progress. It is sealed before victory; no purchases or online service are involved.

All six regional powers warn for 0.8 seconds, lock their target before damage and hit at most once. They pause with gameplay, respect intervening walls and disappear on respawn, region travel or their caster's defeat. Slow effects clear on respawn. Frost affects ordinary foes and bosses as before; none of the new VFX modifies hero damage, magic costs or hitboxes.

Kael now has runtime rigid-pivot AnimationPlayer clips for idle, run, jump rise/fall, landing, three sword swings, six casts, hit recoil and defeat. The sword follows the elbow. A brief defeat echo preserves instant checkpoint respawn. Arcane trails, flame tongues, ice spikes, wind ribbons, lightning zigzags and Guardian rings use bounded mesh effects. The procedural clips are an initial animation pass, not motion capture or a fully skinned production rig.

## Actual engine images

[Kael](screenshots/hero-studio.png) · [Forest villain](screenshots/villain-1.png) · [Fire villain](screenshots/villain-2.png) · [Ice villain](screenshots/villain-3.png) · [Wind villain](screenshots/villain-4.png) · [Storm villain](screenshots/villain-5.png) · [Shadow villain](screenshots/villain-6.png) · [Dawn Gate](screenshots/dawn-gate.png)

The studio preview uses the actual engine models/clips and stages all powers on a neutral background. It is not a gameplay recording. `tests/animation_preview.tscn` records 313 frames at 15 FPS; encoding them yields a 20.87-second MP4. That capture rate is not a phone performance measurement.

## Villain image prompt

Use case: stylized-concept. A premium original fantasy RPG production board for Shadowblade: The Last Guardian, six illustrated cards in three columns and two rows. One distinct full-body villain per card with its own world backdrop and a cream footer showing its name and power. Cohesive painted stylized 3D art, detailed metal/leather/stone, readable silhouettes, no gore, no existing franchise characters, no HUD or watermark.

1. Hollow Warden / Thorn Snare: huge mossy wooden forest guardian, branch antlers, emerald eye, stone hammer, erupting thorn roots; lush waterfall ruins.
2. Cinder Sentinel / Magma Eruption: stocky basalt-armored furnace knight, orange molten seams, huge gauntlet; volcanic lava forges.
3. Frostbound Keeper / Ice Prison: elegant silver-white ice sorceress, crystal crown and floating ice orb; snowy cathedral.
4. Gale Harrier / Cyclone Dive: slender masked avian bronze duelist, twin curved swords and teal wind ribbons; floating islands and bridges.
5. Tempest Colossus / Thunder Strike: enormous stone/brass golem with violet storm core and pillar arms; stormy mountain ruins.
6. Void Herald / Shadow Rift: hovering hooded violet mage, star-filled faceless mask, crescent staff and purple rift; ruined twilight sanctuary. Behind it, a carved final teleport arch with six colored rune sockets and a gold-blue swirling interior.

The hero reference defines swept dark hair, navy split tunic, cream sleeves, silver/brass armor, cobalt scarf, blue chest gem and luminous sword on white. The movement and power sheets preserve that identity in twelve movement/combat poses and six spell poses respectively.

## Six villain power moves in the game

[Watch all six power moves](https://chatgpt.com/library?file_id=libfile_c80d612c68708191af7faa70e88c6f28&account_id=personal). The 18-second video records six staged encounters with the shipped boss AI and power logic. Each chapter shows approach, warning, active power and recovery; Kael is held still to make the effect and damage readable. No attack assets or gameplay behavior were changed for this capture. Current animation and non-forest environments remain basic.

Reproduce with Godot Compatibility at fixed 20 FPS using `tests/villain_preview.tscn`; encode the 360 PNG frames from `build/villain-power-frames` at 20 FPS. [Capture evidence](villain-power-render.txt) verifies warning, active effect and target damage for all six bosses, with zero frame-save errors. This is a renderer demonstration, not a phone performance test or human playthrough.
