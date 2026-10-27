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
