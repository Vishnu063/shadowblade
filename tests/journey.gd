extends Node
var world: Node3D
var failures = 0

func expect(value: bool, message: String) -> void:
	print(("PASS: " if value else "FAIL: ") + message)
	if not value:
		failures += 1

func step(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func walk_to(x: float, limit: int = 400) -> bool:
	for i in limit:
		var dx: float = x - world.player.position.x
		if absf(dx) < 0.18:
			world.controls.keys.erase("right")
			world.controls.keys.erase("left")
			await step(5)
			return true
		world.controls.keys["right" if dx > 0 else "left"] = true
		world.controls.keys.erase("left" if dx > 0 else "right")
		await step(1)
	print("Walk timed out at ", world.player.position, " target ", x, " playing ", world.playing)
	world.controls.reset_input()
	return false

func _ready() -> void:
	Progress.save_path = "user://journey-regression.json"
	world = load("res://scenes/main.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	await step(20)
	world.interact()
	expect(Progress.data.quest == 1 and not world.playing, "Lyra gives the main quest and pauses for dialogue")
	world.resume()
	expect(await walk_to(15.5), "Kael walks from Willowbrook to the forest gap")
	world.controls.keys.right = true
	world.controls.keys.jump = true
	world.player.request_jump()
	await step(44)
	world.controls.reset_input()
	await step(25)
	expect(world.player.position.x > 19 and world.player.is_on_floor() and world.session_deaths == 0, "Held jump crosses the authored gap and lands safely")
	expect(await walk_to(24), "Forest route reaches the first waystone")
	world.interact()
	expect(Progress.data.checkpoint == 24, "Waystone saves a stable route checkpoint")
	# Jump onto the low crystal ledge using the same input as normal play.
	expect(await walk_to(29.0), "Route reaches the crystal ledge")
	world.controls.keys.jump = true
	world.player.request_jump()
	world.controls.keys.right = true
	await step(22)
	world.controls.reset_input()
	await step(25)
	expect(world.player.position.x > 30 and world.player.position.y > 2 and world.player.is_on_floor(), "Jump reaches the crystal puzzle platform")
	world.player.facing = 1
	world.player.cast()
	await step(25)
	expect(Progress.data.crystal and not world.gate.visible, "Casting from the ledge opens the seal")
	expect(await walk_to(44), "Opened seal allows reaching the boss checkpoint")
	world.interact()
	expect(Progress.data.checkpoint == 44, "Boss checkpoint restores resources and saves")
	var boss = world.enemies[3]
	for i in 1500:
		if not boss.alive:
			break
		var dx: float = boss.position.x - world.player.position.x
		world.controls.keys.erase("left")
		world.controls.keys.erase("right")
		if absf(dx) > 1.45:
			world.controls.keys["right" if dx > 0 else "left"] = true
		world.player.facing = signf(dx)
		if boss.phase == "warn":
			world.controls.keys.jump = true
			if world.player.is_on_floor():
				world.player.request_jump()
		else:
			world.controls.keys.erase("jump")
		world.player.attack()
		world.player.cast()
		await step(1)
	world.controls.reset_input()
	expect(not boss.alive and Progress.data.quest == 3, "Normal sword and bolt combat defeats the Warden")
	expect(world.session_deaths == 0, "Complete route and boss without a forced respawn")
	expect(await walk_to(56.7), "Kael reaches the eastern trail after the boss")
	world.controls.keys.right = true
	await step(12)
	expect(not world.playing and world.menu_mode == "pause", "Eastern trail opens the milestone completion screen")
	var saved_checkpoint: float = Progress.data.checkpoint
	world.queue_free()
	await step(2)
	Progress.data = Progress.DEFAULTS.duplicate(true)
	world = load("res://scenes/main.tscn").instantiate()
	add_child(world)
	world.start_game(false)
	await step(3)
	expect(Progress.data.boss and Progress.data.crystal and world.player.position.x == saved_checkpoint, "A newly instantiated game restores the saved completed journey")
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(Progress.save_path + suffix)
	world.queue_free()
	await step(2)
	print("JOURNEY FAILURES: ", failures)
	get_tree().quit(1 if failures else 0)
