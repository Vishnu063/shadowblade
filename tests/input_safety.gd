extends Node
## Synthetic Godot events and lifecycle notifications, never Android device evidence.
var world: Node3D
var checks = 0
var failures = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	print(("PASS: " if condition else "FAIL: ") + message)
	if not condition:
		failures += 1

func frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func touch(id: int, point: Vector2, down: bool, canceled: bool = false) -> void:
	var event = InputEventScreenTouch.new()
	event.index = id
	event.position = point
	event.pressed = down
	event.canceled = canceled
	get_viewport().push_input(event, true)

func key(code: int, down: bool) -> void:
	var event = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = down
	get_viewport().push_input(event, true)

func drag(id: int, point: Vector2) -> void:
	var event = InputEventScreenDrag.new()
	event.index = id
	event.position = point
	get_viewport().push_input(event, true)

func _ready() -> void:
	Progress.save_path = "user://input-safety.json"
	world = load("res://scenes/main.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	await frames(25)
	var p = world.player
	var c = world.controls
	var outside = Vector2(640, 300)
	p.regen_wait = 10
	p.magic = 100
	touch(0, c.buttons.right.get_center(), true)
	touch(1, c.buttons.jump.get_center(), true)
	touch(2, c.buttons.attack.get_center(), true)
	touch(3, c.buttons.magic.get_center(), true)
	var x: float = p.position.x
	await frames(7)
	touch(3, c.buttons.magic.get_center(), false)
	check(p.position.x > x and p.position.y > 1.1 and p.attack_time > 0 and p.magic == 90, "Four concurrent touches move, jump, sword and cast")
	for id in [0, 1, 2]:
		touch(id, outside, false)
	check(c.axis() == 0 and not c.held("jump") and c.fingers.is_empty(), "Release outside without a drag releases all actions")
	p.cast_cooldown = 0
	touch(4, c.buttons.magic.get_center(), true)
	touch(4, outside, false)
	check(p.magic == 90 and not c.magic_pending, "Magic release outside without drag cancels the cast")
	touch(5, c.buttons.magic.get_center(), true)
	drag(5, outside)
	touch(5, c.buttons.magic.get_center(), false)
	check(p.magic == 90 and c.magic_owner.is_empty(), "Sliding off and back onto magic cannot revive a canceled tap")
	touch(6, c.buttons.magic.get_center(), true)
	touch(6, c.buttons.magic.get_center(), false, true)
	check(p.magic == 90 and not c.magic_pending, "Canceled tap never casts")
	touch(7, c.buttons.right.get_center(), true)
	touch(7, c.buttons.right.get_center(), false, true)
	check(c.axis() == 0, "Canceled movement touch releases ownership")
	# Godot's emulated mouse must still reach GUI menus, but not duplicate gameplay.
	touch(8, c.buttons.magic.get_center(), true)
	var mouse = InputEventMouseButton.new()
	mouse.device = InputEvent.DEVICE_ID_EMULATION
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	mouse.position = c.buttons.magic.get_center()
	get_viewport().push_input(mouse, true)
	check(not c.fingers.has(-1) and c.magic_owner == "pointer:8", "Emulated mouse does not duplicate a touch gesture")
	touch(8, c.buttons.magic.get_center(), false, true)
	touch(9, c.buttons.right.get_center(), true)
	touch(10, c.buttons.magic.get_center(), true)
	await get_tree().create_timer(0.40).timeout
	check(c.wheel_open and not world.playing and p.magic == 90, "Holding the magic owner opens wheel without casting")
	drag(9, c.wheel_slots[1])
	check(c.wheel_pointer == Vector2.ZERO, "A different finger cannot move the wheel selection")
	touch(11, c.buttons.magic.get_center(), true)
	touch(11, c.wheel_slots[0], false)
	check(c.wheel_open and not world.playing, "A second magic finger cannot close the first finger's wheel")
	touch(10, c.wheel_slots[0], false, true)
	check(not c.wheel_open and world.playing and p.magic == 90 and c.axis() == 0, "Canceled wheel resumes safely and clears movement without casting")
	touch(12, c.buttons.magic.get_center(), true)
	await get_tree().create_timer(0.40).timeout
	touch(12, outside, false)
	check(world.playing and p.magic == 90 and not c.wheel_open, "Release outside the power wheel cancels selection")
	key(KEY_A, true)
	key(KEY_LEFT, true)
	key(KEY_A, false)
	check(c.axis() == -1, "Releasing one keyboard alias preserves the other held key")
	key(KEY_LEFT, false)
	check(c.axis() == 0, "Final keyboard alias release stops movement")
	touch(13, c.buttons.magic.get_center(), true)
	key(KEY_K, true)
	key(KEY_K, false)
	check(c.magic_owner == "pointer:13" and p.magic == 90, "Keyboard release cannot steal a touch-owned magic gesture")
	touch(13, outside, false, true)
	# Background/focus signals are injected here, not supplied by an Android OS.
	touch(14, c.buttons.magic.get_center(), true)
	touch(15, c.buttons.right.get_center(), true)
	world._notification(NOTIFICATION_APPLICATION_PAUSED)
	check(not world.playing and world.menu_mode == "pause" and c.fingers.is_empty(), "Application-paused notification clears pending inputs and opens pause")
	world._notification(NOTIFICATION_APPLICATION_RESUMED)
	check(not world.playing, "Application resume does not silently resume combat")
	world.resume()
	touch(14, c.buttons.magic.get_center(), false)
	touch(15, c.buttons.right.get_center(), false)
	check(p.magic == 90 and c.axis() == 0, "Late releases after resume cannot cast or stick movement")
	world.show_settings()
	world._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(world.menu_mode == "settings" and not world.playing, "Focus loss preserves settings instead of replacing it with gameplay pause")
	world.show_title()
	world._notification(NOTIFICATION_APPLICATION_PAUSED)
	check(world.menu_mode == "title" and not world.playing, "Backgrounding the title cannot create a Resume-to-old-game action")
	world.start_game(true)
	p.magic = 100
	touch(16, c.buttons.magic.get_center(), true)
	await get_tree().create_timer(0.40).timeout
	world._notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	touch(16, c.wheel_slots[0], false)
	check(not world.playing and world.menu_mode == "pause" and p.magic == 100, "Android back notification pauses a wheel without accidental cast/resume")
	world.resume()
	world.player.restore_at(Vector3(31, 2.3, 0))
	world.rest(24.0)
	world.activate_crystal()
	check(world.reset_crystal() and not Progress.data.crystal and world.gate.collision_layer == 1, "Crystal reset closes seal only with player and checkpoint on the safe side")
	p.magic = 0
	p.regen_wait = 0
	await frames(85)
	check(p.magic >= p.bolt_cost and p.is_on_floor(), "Empty magic recovers on stable puzzle ledge without consumables")
	p.facing = 1
	p.cast_cooldown = 0
	p.cast()
	await frames(25)
	check(Progress.data.crystal and world.gate.collision_layer == 0, "Recovered magic reopens reset puzzle using an actual bolt")
	world.rest(44.0)
	p.restore_at(Vector3(44, 1, 0))
	check(not world.reset_crystal() and Progress.data.crystal, "Gate cannot close around the far-side player or checkpoint")
	world.boss_defeated()
	p.restore_at(Vector3(31, 2.3, 0))
	world.rest(24.0)
	check(not world.reset_crystal() and Progress.data.quest == 3, "Puzzle reset cannot remove a completed boss quest")
	var invalid = Progress.DEFAULTS.duplicate(true)
	invalid.boss = true
	check(not Progress.valid(invalid), "Save schema rejects contradictory boss and quest progress")
	invalid = Progress.DEFAULTS.duplicate(true)
	invalid.checkpoint = 44.0
	check(not Progress.valid(invalid), "Save schema rejects a checkpoint behind a closed seal")
	world.start_game(true)
	check(not Progress.data.crystal and not Progress.data.boss and Progress.data.quest == 0, "New Journey resets crystal and encounters together")
	p.restore_at(Vector3(15.5, 0.81, 0))
	await frames(5)
	var safe_x: float = p.safe_position.x
	c.keys.right = true
	await frames(6)
	check(p.safe_position.x <= 15.66 and p.safe_position.x >= safe_x, "Pit recovery point is not replaced by a partly supported ledge position")
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(Progress.save_path + suffix)
	world.queue_free()
	await frames(2)
	print("INPUT/SAFETY RESULTS: ", checks - failures, "/", checks, " passed")
	get_tree().quit(1 if failures else 0)
