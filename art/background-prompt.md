# Willowbrook image background

Built-in imagegen edit of `docs/art/willowbrook-concept.png`. Output used by the game: `assets/backgrounds/willowbrook-reference.png`.

Prompt: Preserve the approved stylized forest, timber village, ruined arch, banners, waterfall, bridge, castle, mountains, daylight and vegetation. Remove the HUD, title, touch controls, hero, enemy and collectible crystal. Replace the foreground walkable path with recessed riverbank/water/foliage so the image does not imply gameplay collision. Produce a clean wide background-only environment matte with no characters, text, controls or watermark.

The generated image is a flat camera-aligned backdrop for Willowbrook. Foreground platforms, NPCs, enemies and Kael remain live 3D objects; all collisions and interactions remain in the existing game scene. Other regions retain their themed backgrounds. The original approved concept is preserved as a reference.

`art/build_kael_v2.py` builds an original replacement 3D character with the existing animation pivot names, a slimmer blue tunic, linen sleeves, leather belt/bracers/boots, swept hair, two scarf tails and a broader luminous sword. It does not claim an exact reconstruction of the image's character.

## Foreground stage assets

Built-in imagegen generated two transparent assets using the approved concept as style guidance:

- `assets/stage/forest-platform.png`: one wide, isolated mossy limestone platform, slight top view, level walkable surface, rounded weathered stone, small grasses/daisies and hanging ivy. No scene, characters, HUD or text.
- `assets/stage/forest-foliage.png`: one low, wide woodland fern/broadleaf/moss/daisy cluster on transparency, warm upper-left daylight, no ground, pots, characters, text or UI.

`stage_art.gd` renders these assets as modular Sprite3D dressing over the original collision boxes. Texture regions remove unused transparent margins at render time without modifying the generated files. Floating ledges retain their original collision dimensions; decorative images have no collision. Foreground corner plants frame the view without intercepting touch input. This is an intentional hybrid 2.5D stage, not a claim that the image layers are volumetric geometry.
