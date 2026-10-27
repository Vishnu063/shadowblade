# Art sources and attribution

- **Original Shadowblade model set:** Kael with blue scarf and sword; Thornling, Veil Moth, Hollow Warden; three village characters; alder/fir trees; cottages, arches, waystones, castle and waterfall. Authored in `art/models.gd`, packed into editable Godot scenes by `art/build_models.gd` under `assets/models/`. No downloaded models or game artwork. Rebuild deliberately with `./tools/godot.sh --headless --script res://art/build_models.gd`; this overwrites the generated model scenes.
- **Original environment, effects and UI:** faceted terrain, vegetation, icons/hearts, application emblem, water shader and procedural poses authored in this project. Static geometry is merged into vertex-colored surfaces to reduce draw calls. No third-party implementation art or texture licenses are required.
- **Temporary original audio:** synthesized sine cues. Music, voice, and finished sound design remain pending. NPCs currently share the humanoid rig; animations and some environmental detail remain a first pass.
- **Approved concept:** user-supplied, AI-generated `docs/art/willowbrook-concept.png`, introduced at remote commit `1381f09`; instructions at `docs/art/README.md`. Used as art direction only, excluded from the APK, clearly separate from gameplay screenshots. No independent license or ownership claim is made for the supplied reference.
- **Godot 4.6.3:** MIT engine and bundled third-party components/default font. Retain the engine's [license and third-party notices](https://godotengine.org/license/) in distributions. No project-wide source-code distribution license has been selected by the owner.
- **Gameplay images:** real Godot renderer output from `tests/capture.gd`, with staged positions in the playable scene. They are not concept images.

## Representative forest revision

`art/forest_blender.py` is the original asset source for this revision; `art/source/forest.blend` contains editable Blender scenes. Authored and exported with **Blender 4.3.2** into `assets/forest/*.glb`: Kael, rounded stone, branching oak/individual leaves, fern, worn arch, timber cottage, and winged enemy. Embedded material grain is generated mathematically by the script, not copied from the concept or a texture library. No external models, photographs, stock textures, or additional third-party asset licenses were introduced. Blender is GPL software; the original exported artwork is not made GPL merely by use of Blender. Project asset distribution licensing remains the owner's decision.

Rebuild with `blender -b --python art/forest_blender.py`, then run Godot editor import. The native source folder has `.gdignore` so Godot does not also import the authoring file. `art/build_models.gd` remains the legacy generator; it does **not** replace the new GLB models. Legacy NPCs, boss and distant castle are still visibly different and are not represented as finished forest art. Water and mist are original engine effects; audio remains temporary.

## Scenery refinement source

`scripts/forest_detail.gd` builds deterministic mountain meshes, instanced conifers, ground leaves and flower clusters. `assets/shaders/forest_stone.gdshader` generates world-space grain, moss and strata mathematically. `scripts/scenery.gd` assembles the existing original Blender stones into terrain and unequal waterfall cliffs. No downloaded implementation assets or additional third-party licenses were introduced.

## Reference-background and Kael visual revision

`assets/backgrounds/willowbrook-reference.png` is an AI-generated environment matte edited from the approved concept using built-in imagegen; its prompt and role are documented in `art/background-prompt.md`. It contains no HUD or player/enemy sprites. `art/build_kael_v2.py` reuses this project's original modeling/material helpers to author `assets/forest/kael-v2.glb` and its generated material images in Blender 4.2.0. Existing collision shapes, animation pivots and gameplay rules are preserved. No external model or stock texture was added.

The Willowbrook stage also uses two transparent built-in imagegen assets, `assets/stage/forest-platform.png` and `assets/stage/forest-foliage.png`, as decorative Sprite3D layers. Their source prompts and rendering role are in `art/background-prompt.md`. Original physics boxes remain unchanged; these image assets do not establish collision or three-dimensional geometry.

## Guardian and regional boss revision

The built-in image generator created the guardian hero, movement/power reference sheets and six-villain/world board in `docs/art/`. Their role and prompts are documented in [guardian-art.md](guardian-art.md). They are concept references, excluded from the APK. `art/build_kael_v3.py` and `art/build_villains.py` author original Blender 4.2.0 geometry and material variation; the exported GLBs live in `assets/forest/`. No downloaded models or stock textures were introduced. Kael uses rigid hierarchical AnimationPlayer clips. Regional bosses now have their own meshes; legacy Lord Vaelor and NPC art remain. All new spell meshes and the Dawn Gate are authored in project code.

## First fully 3D Willowbrook scene

`art/build_guardian_slice.py` authors the 3D clearing, guardian clothing/armour, weighted skeleton, Warden, surface maps and exported assets under `assets/slice3d/`. Kael's head topology is adapted from MakeHuman's CC0 graphical base mesh; the cropped asset, source/hash and upstream license explanation are retained under `art/source/makehuman/`. This is an exception to older original-only asset notes: the new head foundation is third-party CC0 artwork. No MakeHuman application code is used. The environment glTF uses exact-buffer repackaging through `art/split_gltf_buffers.py`; the scene loads all five `.bin` files locally. No remote service is needed at runtime. [Scene scope and evidence](3d-scene/README.md).

## Active painted image-character revision

The built-in image generator created the transparent Kael and six regional villain part sheets under `assets/image_characters/`, guided by the approved concept references. Exact prompts are in `art/image-character-prompts.json`. The original PNGs are preserved. `art/prepare_cutout_regions.py` writes alpha-region metadata, and `scripts/image_puppet.gd` isolates/animates the original image parts at runtime. No new 3D character models were authored in this revision. The six villain effect images and the hero's painted magic/aura are used in gameplay; cutout movement is driven by project animation code. Previous 3D artwork and its licenses remain in source for history, with the separate 3D preview no longer active in the menu or Android export. [Current image-based scene](image-characters/README.md).
