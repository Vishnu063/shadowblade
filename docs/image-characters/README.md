# Image-based character animation

[Watch or download the combined 33-second video](https://chatgpt.com/library?file_id=libfile_7b004cac82308191a4803b851a5578e8&account_id=personal)

The active art direction is painted image characters. No new 3D character models were created for this revision. Kael and all six regional villains now use separately animated image parts based on the approved designs. The previous 3D art experiment is retained as historical source and removed from the active title menu and Android export.

Select **Image character preview** on the title screen, then **Choose a villain** to try any of the six in the forest clearing. Move with A/D, jump with Space, strike with J and cast with K; touch controls remain available. Hold magic to select powers. The sandbox resets each run and preserves campaign save bytes.

Kael's image rig is also used throughout the normal campaign. The six regional bosses use distinct painted rigs and distinct image-based power effects: Thorn Snare, Magma Eruption, Ice Prison, Cyclone Dive, Thunder Strike and Shadow Rift. Lord Vaelor currently reuses the Void Herald image rig as a temporary finale appearance. NPCs, minor enemies and the regional environments retain their prior art; this is not a claim that every game asset has been converted.

## Actual engine images

[Hero and Warden](hero-and-warden.png) · [Kael close-up](hero.png) · [Warden close-up](warden.png)

The source PNGs contain 16 Kael parts and 12 parts per regional villain. They were created with built-in image generation using the original hero and villain concept references. [Exact prompts](../../art/image-character-prompts.json) · [Source image sheets](../../assets/image_characters/).

`art/prepare_cutout_regions.py` reads the generated alpha sheets and writes extraction metadata; it never overwrites the source PNGs. The game isolates the parts from their original pixels at load time. Head, torso, limbs, scarf, coat and weapon pivots are animated independently. In this existing engine architecture those images are displayed on flat Sprite3D planes while the old physics/combat code is retained. There are no hero or villain character meshes in the active image rigs. This is cutout animation, not a promise of hand-drawn frame-by-frame animation or 3D movement around the characters.

The hero's magic uses painted orb, fire, ice, wind and lightning art; Guardian Light tints the painted aura gold. The six regional enemy powers likewise use the painted effect slot in each villain sheet. Attack timing, damage, costs, collision and progression remain governed by the existing game code.

## Verification

All **285 automated assertions pass**: the existing 272 plus 13 image-character checks. Tests verify isolated saves, absence of character meshes, separate image parts, physical running/jumping, facing flips, sword damage, casting, pause and checkpoint recovery. The full campaign suite still traverses and defeats all seven encounters through ordinary combat. [Full log](checks.txt).

The videos are actual engine captures with staged positions and reset actors, not AI-generated motion or a continuous human playthrough. The six-villain showcase uses the same forest stage for comparison. It does not claim six new background paintings. Some headless runs retain an ObjectDB cleanup warning at exit; this has not been called resolved. Android performance, physical multitouch and human gameplay tuning remain unverified. No new APK was exported for this revision; the previous APK predates these image characters.

## Reproduce

Use Godot 4.6.3. `tests/image_video.tscn` captures 360 frames at fixed 24 FPS (15 seconds) into `build/image-character-frames`. `tests/painted_villains_video.tscn` captures 432 frames at 24 FPS (18 seconds) into `build/painted-villain-frames`. Encode the PNGs as H.264 and concatenate the two clips for the combined 33-second video. Capturing at 24 FPS does not measure phone performance.

The new scene is `scenes/image_preview.tscn`; the reusable rig is `scripts/image_puppet.gd`. Alpha metadata is cached into reusable part textures, and animations pause with gameplay. The original image files remain available for future animation refinement.

The data-only Android preset export was also loaded headlessly from its PCK without resource errors. All seven image metadata JSON files are explicitly included; archived 3D preview assets are excluded. This verifies packaging of resources, not installation or performance on Android. [Packaging log](pack-export.txt) · [Pack startup](pack-startup.txt).

Rebuild alpha metadata only if replacing a part sheet: install Python packages Pillow, NumPy and SciPy, then run `python3 art/prepare_cutout_regions.py`. They are authoring dependencies only; the game itself uses the committed PNG/JSON files offline.

## Six painted villain attacks

| Villain | Actual engine frame |
| --- | --- |
| Hollow Warden | [Thorn Snare](warden-power.png) |
| Cinder Sentinel | [Magma Eruption](cinder-power.png) |
| Frostbound Keeper | [Ice Prison](frost-power.png) |
| Gale Harrier | [Cyclone Dive](gale-power.png) |
| Tempest Colossus | [Thunder Strike](tempest-power.png) |
| Void Herald | [Shadow Rift](void-power.png) |
