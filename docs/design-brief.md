We’ll keep **three red hearts and the blue magic bar exactly like the sample**, with six unlockable powers and six villages.

Copy this into Codex and **attach the sample image**:

Build my original Android game: **Shadowblade: The Last Guardian**.

₹ / $ Working rules:
Work step by step. Inspect the existing repository first and reuse working code. Keep changes focused. Make routine decisions yourself; ask only when essential. Test actual gameplay failures and never claim success without evidence. Minimize unnecessary credit usage. Explain what every terminal command does and why we need it. Clearly distinguish implemented, tested, and pending work.

VISION
Create a phone-only, landscape, 2.5D side-scrolling action-adventure with sword combat, magic, exploration, secrets, village quests, and bosses. Use Godot 4 with GDScript unless the repository already has a working suitable implementation.

The attached image is the approved visual direction. Match its clear foreground platforms, readable hero, forest ruins, waterfall, blue magic, layered scenery, and simple touch controls. Treat the image as an art target; build actual playable scenes rather than using the image as the game background.

Use original characters and assets. Swordigo is a reference for accessible controls and adventure pacing. Preserve our own identity, environments, story, and interface artwork.

HERO AND STORY
The hero is Kael, a young adult blacksmith apprentice in Aetheria. The Void is spreading through six regions. Kael journeys between six villages, learns six powers, and ultimately confronts Lord Vaelor. Lyra guides his journey.

HEALTH AND MAGIC — KEEP THE APPROVED DESIGN
- Start with three red hearts at the top left.
- Place the slim blue magic bar directly below them.
- Keep their appearance and positioning consistent across every region.
- Use half-heart damage increments, brief invulnerability after damage, and clear hit feedback.
- Magic powers consume the same shared blue bar.
- Regenerate magic slowly after a short delay; pickups and village rest points can restore it.
- Death returns Kael to his latest checkpoint without removing unlocked powers or completed quests.
- Expose health, damage, magic costs, regeneration, and cooldowns as configurable values.

PHONE CONTROLS
- Bottom left: separate left and right movement buttons.
- Bottom right: sword attack, jump, and selected magic power.
- Support simultaneous movement, jumping, and attacking through real multitouch.
- Use a responsive jump with coyote time and jump buffering.
- Hold jump briefly for additional height.
- Tap the magic button to cast; hold it to open a six-slot power wheel that pauses gameplay.
- Lock unavailable powers visibly.
- Keep controls within safe areas and comfortable thumb reach.
- Include pause, sound settings, and adjustable control size.
- Keep touch input responsive after interruptions, app resume, or fingers sliding off buttons.

SIX VILLAGES AND SIX POWERS
Each region contains a safe village hub plus surrounding playable routes, enemies, a dungeon, secrets, and a boss. Unlock powers in this order:

1. WILLOWBROOK — Whispering Forest
   Visuals: mossy ruins, waterfalls, wooden homes, sunlight through trees.
   Power: Arcane Bolt.
   Function: ranged blue magic projectile; activates crystal switches.
   Role: teach movement, sword combat, jumping, and casting.

2. EMBERHEARTH — Ember Depths
   Visuals: volcanic stone, warm lanterns, blacksmiths, lava caves.
   Power: Flame Burst.
   Function: short-range fire attack; ignites braziers and burns marked vine barriers.
   Role: introduce environmental hazards and stronger enemies.

3. FROSTHAVEN — Frozen Citadel
   Visuals: snowy roofs, ice caverns, frozen waterways.
   Power: Frost Bind.
   Function: briefly freezes ordinary enemies; freezes marked water surfaces into temporary platforms.
   Role: combine combat timing with platform puzzles.

4. WINDREST — Shattered Skies
   Visuals: mountain homes, windmills, hanging bridges, floating ruins.
   Power: Wind Dash.
   Function: short forward dash, usable once per airtime; resets on landing.
   Role: cross gaps and access previously unreachable paths.

5. STORMWATCH — Thunder Highlands
   Visuals: storm-lit cliffs, stone towers, ancient machinery.
   Power: Lightning Chain.
   Function: jumps between a limited number of nearby enemies; powers marked electrical mechanisms.
   Role: enemy groups and connected-switch puzzles.

6. DUSKVEIL — Shadow Fortress Border
   Visuals: violet lanterns, dark stone homes, corrupted forests, distant fortress.
   Power: Guardian Light.
   Function: timed protective shield that absorbs a limited amount of damage; reveals marked hidden paths and purifies Void seals.
   Role: combine all six powers before the final fortress and Lord Vaelor.

Keep each power mechanically distinct. Bosses can resist crowd control but must clearly communicate that resistance. Add readable visual cues for every interactive environmental object.

PROGRESSION AND VILLAGE LIFE
- Each village has a guide, healer/rest point, merchant, and quest giver.
- Include a main quest, optional side quest, and checkpoint.
- Track objectives in a compact journal.
- Unlock travel between discovered villages.
- Allow backtracking with new powers to discover optional rewards.
- Save checkpoints, unlocked powers, inventory, quests, settings, and discovered villages locally.
- The game must work offline without login or a paid backend.

COMBAT AND LEVEL DESIGN
- Implement a responsive sword combo with clear attack timing.
- Give enemies readable telegraphs, hit reactions, and predictable movement.
- Use fair hitboxes and prevent repeated damage every frame.
- Include melee, ranged, and flying enemies gradually.
- Build bosses around readable patterns and the region’s power.
- Keep platform edges obvious and separate dangerous hazards from decoration.
- Add restrained camera follow, landing feedback, sound, and optional screen shake.
- Avoid effects that obscure enemies or controls.

VISUAL QUALITY AND PERFORMANCE
Use stylized 3D characters and scenery with side-on gameplay. Aim for the attached sample’s composition and clarity, adapting asset complexity to Android performance.

Use lightweight materials, limited particles, simple collision, and baked lighting where practical. Provide adjustable quality settings. Aim for stable 60 FPS on the tested target phone, with a 30 FPS option. Report the actual device and measured results; do not promise unmeasured performance.

Use assets with suitable licenses and retain attribution. Clearly label temporary assets and remaining visual work.

IMPLEMENTATION ORDER
1. Audit the repository and report what already works.
2. Build a complete Willowbrook vertical slice first:
   - Kael movement and multitouch controls.
   - Sword combat and Arcane Bolt.
   - Approved hearts and magic HUD.
   - Village NPC interaction and one quest.
   - A playable forest route, crystal puzzle, checkpoint, and mini-boss.
   - Death, respawn, pause, save, and load.
3. Make this slice playable and verify it before expanding.
4. Build reusable systems and add the remaining five villages and powers in order.
5. Complete the final fortress, progression, audio, optimization, and Android packaging.

VALIDATION
Verify simultaneous touch input, ledge jumps, combat collisions, magic depletion, power selection, death and respawn, save/load, scene transitions, and app background/resume.

Run automated checks where useful and perform real gameplay checks. If an Android device or emulator is unavailable, state that Android behavior remains unverified.

DELIVERABLES
- Working project committed to the repository.
- README with setup, controls, current features, and known limitations.
- Actual gameplay screenshots in the README, clearly separate from the concept image.
- Asset license and attribution list.
- Android build instructions and an installable APK when export tooling is available.
- A concise evidence-based progress report.

Start implementing the first playable village now. Continue through the agreed scope without repeatedly asking permission for routine work.