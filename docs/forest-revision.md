# Representative forest revision

The rejected capture at `c56f1f9` relied on seven-sided primitives and flat colored cliff strips. This revision changes the source pipeline to Blender-authored glTF meshes, with embedded original albedo variation and a retained native `.blend` source. No concept image is used as a game background.

The forest section around x=26 contains the player, winged enemy, collision-backed stone platforms, trees, ferns, masonry arch and waterfall. It is part of the existing playable route, not an isolated illustration. It does not add new regions or change movement speeds, damage, spell costs, quest rules, checkpoints, saved schema, touch layout, enemy AI or terrain collider dimensions.

Visual iteration found and corrected: hidden waistcoat behind the linen torso; excessive leaf/stone density in the CPU renderer; missing frame space in the character close-up; repeated rock gaps; and overly regular water noise/cliff framing. Distant trees omit cast shadows; the two foreground trees retain them. Rocks use MultiMesh instancing. Mist is capped at 16 particles. Those are workload limits, not Android performance evidence.

See [the side-by-side review](visual-review.html), [current forest](forest.png), [character close-up](kael-detail.png) and [previous rejected capture](forest-before.png). All current captures are actual Godot output. The close-up is explicitly different from the gameplay camera; scene positions are staged for repeatable review.

Remaining gaps: organic cliff composition, denser but optimized foliage, material painting, bespoke keyframed animations, atmospheric/cloud detail and final lighting still trail the concept. The distant castle and NPCs outside this scene remain legacy art. Current animations are procedural, not a finished artist-authored character animation set. This is a review candidate, not a claim of parity or user approval. Do not expand the other regions before approval.

Validation uses the existing 86 automated assertions and a rendered safety run; these exercise game physics/input rules, not artistic quality. No Android device/emulator is attached, so Android behavior/performance remains unverified. The known headless ObjectDB cleanup and Xvfb V-Sync warnings are retained in logs.
