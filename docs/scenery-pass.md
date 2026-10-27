# Willowbrook scenery refinement — 27 October 2026

This is an incremental presentation pass on top of `53a05ea`, not final art approval or a claim of matching the generated concept.

## Changes

- Added distant mountain silhouettes and two forest layers, with the conifers batched into two MultiMeshes.
- Added ground leaves and warm flower clusters in two more MultiMeshes. Decorative vegetation excludes the route's actual pit.
- Deepened the ground fascia, varied stone scale and placement, and filled gaps with a presentation-only bedrock backing. Existing terrain collision bodies are unchanged.
- Replaced repeated waterfall stone columns with unequal overlapping cliff masses using the existing original Blender stone asset.
- Added an original world-space rock shader with grain, strata and slope-based moss; adjusted sun, ambient color and fog.
- Kept the current Kael model, animations, three hearts, magic bar and phone controls. No new regions were added.

## Actual images

Before this pass:

Earlier captures are available in Git history.

Current engine capture:

![Current forest](screenshots/forest.png)

The capture script stages the player's position in the real playable scene. It is not a human playtest. The half-heart loss visible in the forest capture comes from the live encounter during capture; no artificial health or HUD changes were introduced.

## Validation and limits

See `scenery-pass-checks.txt` for this pass's headless gameplay checks, and `scenery-pass-render.txt` for the engine capture log. Captures use Godot 4.6.3 Compatibility with Mesa llvmpipe on Linux. These are software-renderer captures, not Android performance measurements. Previous rendered assertion reports belong to the previous revision unless explicitly rerun.

The APK was not rebuilt for this pass: Android SDK, templates and the prior test signing key are not restored in this checkout. The earlier APK therefore does not include these changes. No Android device or emulator test was performed.

## Still below the reference

Cliffs and waterfall remain simplified; the foliage is sparse compared with the concept, and the scene still needs stronger authored composition and painted material detail. Kael's proportions/animation and the legacy village NPCs, boss and castle need further work. A full environment/character art pass is still required. This pass does not solve those gaps or establish visual approval.
