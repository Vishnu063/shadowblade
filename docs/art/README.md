# Willowbrook visual reference

![Willowbrook concept](willowbrook-concept.png)

AI-generated concept art for **Shadowblade: The Last Guardian**. This is visual guidance, not a gameplay screenshot or a production-ready 3D asset.

## Codex handoff

Use `docs/art/willowbrook-concept.png` as the visual reference for the Willowbrook polish pass. Preserve existing gameplay and test coverage. Build real stylized 3D geometry, animation, collision, and interactive objects; do not substitute this image for a playable level.

- Preserve Kael's readable silhouette, blue scarf, practical outfit, and luminous blue sword.
- Match the clear mossy foreground platforms, ruined archway, village houses, layered forest, waterfall, distant castle, and restrained blue magic.
- Keep three red hearts and the slim blue magic bar at top left; pause at top right.
- Keep movement arrows at bottom left and sword, jump, and selected magic at bottom right, using responsive multitouch and phone safe areas.
- Treat layout and scenery as art direction: adapt platform heights and spacing to tested movement capabilities. The image does not validate jump distances.
- Keep background detail softer than the playable foreground. Prioritize Android performance and legibility over matching every decorative detail.
- Record licenses for any externally sourced implementation assets.
- Verify on Android before claiming touch behavior or device performance.

## Existing prototype

The user reported a local prototype commit `6031a4c` with 56 passing automated checks. That code was not present in this remote repository when this reference was added. Preserve that local work and reconcile histories when bringing these files into the prototype; do not force-push over either history.

## Scope

Six planned villages: Willowbrook, Emberhearth, Frosthaven, Windrest, Stormwatch, Duskveil. Six powers: Arcane Bolt, Flame Burst, Frost Bind, Wind Dash, Lightning Chain, Guardian Light. Polish and validate Willowbrook before expanding.
