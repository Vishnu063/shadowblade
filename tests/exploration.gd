extends Node
var world: Node3D
var failures = 0

func step(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func expect(condition: bool, message: String) -> void:
	print(("PASS: " if condition else "FAIL: ") + message)
	if not condition:
		failures += 1

func walk_to(x: float) -> void:
	for i in 300:
		var dx: float = x - world.player.position.x
		if absf(dx) < 0.12:
			break
		world.controls.keys.erase("left")
		world.controls.keys.erase("right")
		world.controls.keys["right" if dx > 0 else "left"] = true
		await step(1)
	world.controls.reset_input()
	await step(5)

func _ready() -> void:
	Progress.save_path = "user://exploration.json"
	world = load("res://scenes/main.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	await step(15)
	await walk_to(9.0)
	world.controls.keys.jump = true
	world.controls.keys.right = true
	world.player.request_jump()
	await step(28)
	world.controls.reset_input()
	await step(22)
	expect(world.player.is_on_floor() and world.player.position.y > 2.5, "Jump reaches first optional ruin ledge")
	await walk_to(11.7)
	world.controls.keys.jump = true
	world.controls.keys.right = true
	world.player.request_jump()
	await step(28)
	world.controls.reset_input()
	await step(25)
	await walk_to(14.0)
	expect(world.player.is_on_floor() and world.player.position.y > 4, "Second ledge is reachable without new powers")
	expect(Progress.data.secret and not world.secret.visible, "High-route sun shard is collected through player proximity")
	# Travel to the discovered village, then claim the merchant's repeatable service.
	world.open_pause()
	world.rest(2.0)
	world.player.restore_at(Vector3(2, 1, 0))
	world.resume()
	await walk_to(7.0)
	world.player.magic = 0
	world.interact()
	for child in world.menu_box.get_children():
		if child is Button and child.text == "Restore magic":
			child.pressed.emit()
			break
	expect(world.player.magic == 100 and world.playing, "Merchant restores magic after the optional quest")
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(Progress.save_path + suffix)
	world.queue_free()
	await step(2)
	print("EXPLORATION FAILURES: ", failures)
	get_tree().quit(1 if failures else 0)
