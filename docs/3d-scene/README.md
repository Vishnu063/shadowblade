# Willowbrook: first fully 3D art scene

[Watch the new engine video](https://chatgpt.com/library?file_id=libfile_9095ed3efcf8819185064b9d884f782a&account_id=personal)

Open the project in Godot 4.6.3, then choose **New 3D art preview** on the title screen. Alternatively, run `res://scenes/willowbrook_3d.tscn` directly. The short clearing supports the existing movement, jumping, sword, six powers, Warden fight and checkpoint respawn. It is an all-powers art sandbox that resets each run. Campaign save bytes are preserved; artificial preview progression is not written to the campaign slot.

## What changed

- Kael has a real 21-bone Skeleton3D with weighted torso, sleeves, scarf and articulated limbs. Runtime clips drive movement, landing, sword combos, casts and hit reactions. New clothing, contoured shoulder shells, bracers, boots, buckles and a steel sword with a sapphire inset replace the earlier visual model in this scene.
- The anatomical head is adapted from MakeHuman's CC0 graphical base mesh. Its cropped source, provenance and upstream license explanation are in [art/source/makehuman](../../art/source/makehuman/). Other modeling and implementation sources are authored in the project. No MakeHuman application code is bundled.
- The Warden uses interwoven root geometry, bark, an open heart, a single spirit eye, branching crown, fingers, moss and a runed stone hammer. Its wood joints blend between warning and strike poses. Its root power uses curved solid geometry; gameplay damage/warning timing is unchanged.
- The clearing is real 3D geometry: irregular cliffs, solid leaf canopies, pinnate ferns, flowers, an old arch, distant ridges, river and waterfall. There is no matte background, sprite platform or billboard plant layer. Perspective camera movement reveals depth and parallax. Leaf wind, water motion, directional shadows and mottled rock/moss shading run in the engine.
- The title menu exposes the optional scene. The existing six-world campaign keeps its previous artwork. This pass has not applied the new art to the other five villains/worlds or the final fortress.

[Clearing](clearing.png) · [Kael](kael.png) · [Warden](warden.png) · [Root attack](root-attack.png)

## Evidence and practical limits

The 16.375-second video is 393 actual Godot Compatibility frames at a fixed capture rate of 24 FPS, encoded as H.264. It stages close-ups, run/jump, sword/bolt combat, the Warden's power and Guardian Light. Actors and health are reset between sections for visibility; this is not a continuous human playthrough or an Android benchmark. [Render log](render.txt).

All 284 assertions pass: 272 existing checks and 12 for the new skeleton, physical movement, casting, hit detection, pause and save isolation. [Checks](checks.txt). Some headless runs retain an ObjectDB cleanup warning at exit; it is not represented as resolved. The large static environment is repacked into a glTF with five small external buffers, preserving the exact bytes of all 41 buffer views. It loads with the same scene geometry/material data as the recorded GLB. [Post-packaging checks](packaged-checks.txt).

This is a first 3D art pass, substantially below the detailed reference image. Final sculpt/texture painting, more expressive animation, more natural scenery, LODs and Android frame-time/memory testing remain. No new APK was built for this pass; the previously linked campaign APK predates this scene.

## Reproduce

Run Blender 4.2+ with `blender -b --python art/build_guardian_slice.py`, then import the project in Godot. The authoring script creates its own color, normal and roughness maps; they are procedural, not scanned or claimed to be finished hand-painted textures. `art/split_gltf_buffers.py` packages the static environment into smaller files for distribution.

`tests/slice_video.tscn` captures the sequence at fixed 24 FPS into the ignored `build/guardian-3d-frames` directory. Encode its first 393 frames with FFmpeg at 24 FPS. `tests/vertical_slice.tscn` checks the playable scene independently of the campaign.
