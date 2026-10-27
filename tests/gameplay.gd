extends Node
## Exercises the real game scene and physics. Uses an isolated save slot.
var failures = 0
var checks = 0
var world: Node3D

func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func touch(index: int, point: Vector2, pressed: bool) -> void:
	var event = InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = pressed
	get_viewport().push_input(event, true)

func drag(index: int, point: Vector2) -> void:
	var event = InputEventScreenDrag.new()
	event.index = index
	event.position = point
	get_viewport().push_input(event, true)

func menu_press(prefix: String) -> void:
	for child in world.menu_box.get_children():
		if child is Button and child.text.begins_with(prefix):
			child.pressed.emit()
			return
	push_error("Settings button missing: " + prefix)
	failures += 1

func _ready() -> void:
	Progress.save_path = "user://regression.json"
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(Progress.save_path + suffix)
	world = load("res://scenes/main.tscn").instantiate()
	add_child(world)
	await frames(3)
	check(not world.playing and world.menu_mode == "title", "Title opens without starting combat")
	world.start_game(true)
	await frames(30)
	var p = world.player
	var c = world.controls
	check(p.is_on_floor(), "Player settles on physical village terrain")
	check(p.health == 6 and p.magic == 100, "Three full hearts and shared 100 magic at start")
	var start_x: float = p.position.x
	touch(0, c.buttons.right.get_center(), true)
	touch(1, c.buttons.jump.get_center(), true)
	touch(2, c.buttons.attack.get_center(), true)
	await frames(8)
	check(p.position.x > start_x + 0.1 and p.position.y > 1.2 and p.attack_cooldown > 0, "Three simultaneous touch events move, jump and attack")
	drag(0, Vector2(600, 300))
	check(c.axis() == 0, "Sliding finger off movement releases it")
	touch(0, Vector2(600, 300), false)
	touch(1, c.buttons.jump.get_center(), false)
	touch(2, c.buttons.attack.get_center(), false)
	check(c.fingers.is_empty(), "All touch ownership clears on release")
	# Hold threshold uses real process time; wheel must pause without casting.
	p.magic = 100
	touch(3, c.buttons.magic.get_center(), true)
	await get_tree().create_timer(0.42).timeout
	check(c.wheel_open and not world.playing and p.magic == 100, "Magic hold pauses and cancels pending tap")
	touch(3, c.wheel_slots[1], false)
	check(world.playing and not c.wheel_open and p.magic == 100, "Locked wheel slot cannot cast or spend magic")
	p.cast_cooldown = 0
	touch(4, c.buttons.magic.get_center(), true)
	touch(4, c.buttons.magic.get_center(), false)
	check(p.magic == 90, "Magic tap casts once on release")
	p.magic = 0
	p.cast_cooldown = 0
	p.attack_cooldown = 0
	check(not p.cast() and p.attack(), "Empty magic blocks spells while sword remains available")
	p.regen_wait = 0
	await frames(15)
	check(p.magic > 0, "Magic recovers while alive and stationary")
	p.invulnerable = 0
	p.health = 6
	check(p.damage(1) and p.health == 5, "Normal damage is half a heart")
	check(not p.damage(1) and p.health == 5, "Invulnerability blocks repeated damage")
	# Actual sword timing and enemy collision, not merely calling the hit method.
	world.start_game(true)
	await frames(3)
	var enemy = world.enemies[0]
	enemy.position = Vector3(10, 0.65, 0)
	enemy.home = enemy.position
	enemy.timer = 10
	p.restore_at(Vector3(8.8, 0.85, 0))
	p.facing = 1
	p.attack_cooldown = 0
	p.attack()
	await frames(16)
	check(enemy.health == 2, "Sword active window applies exactly one hit to a target")
	# Fire along an actual ray against the crystal collision layer.
	p.restore_at(Vector3(30.5, 2.25, 0))
	world.spawn_bolt(Vector3(31.5, 2.2, 0), 1, true)
	await frames(15)
	check(Progress.data.crystal and world.gate.collision_layer == 0, "Projectile strikes crystal and opens physical seal")
	world.rest(24.0)
	p.invulnerable = 0
	p.health = 1
	p.damage(1)
	check(world.session_deaths == 1 and p.health == 6 and p.position.x == 24, "Lethal damage respawns at stable checkpoint")
	check(Progress.data.crystal and Progress.data.powers == [0], "Death preserves puzzle progress and powers")
	p.safe_position = Vector3(24, 1, 0)
	p.position = Vector3(18, -6, 0)
	p.invulnerable = 0
	p.fall()
	check(p.health == 5 and p.position.x == 24 and p.position.y > 0, "Pit costs half a heart and returns to safe ground")
	var boss = world.enemies[3]
	boss.health = 1
	boss.position = Vector3(51, 1.2, 0)
	boss.timer = 10
	world.spawn_bolt(Vector3(49.5, 1.2, 0), 1, true)
	await frames(14)
	check(not boss.alive and Progress.data.boss, "Physical projectile defeats mini-boss and completes quest")
	world.boss_defeated()
	check(world.boss_rewards == 1 and Progress.data.quest == 3, "Boss progression and reward happen once")
	Progress.data.secret = true
	check(Progress.save_game(), "Current progress saves successfully")
	Progress.data.secret = false
	check(Progress.load_game() and Progress.data.secret and Progress.data.boss, "Local save reload preserves quest, inventory and boss")
	check(Progress.save_game(), "Repeated save retains valid backup")
	var file = FileAccess.open(Progress.save_path, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	Progress.data.secret = false
	check(Progress.load_game() and Progress.data.secret, "Corrupt primary save recovers previous valid backup")
	var invalid = Progress.DEFAULTS.duplicate(true)
	invalid.checkpoint = 9999
	check(not Progress.valid(invalid), "Invalid checkpoint data is rejected")
	invalid = Progress.DEFAULTS.duplicate(true)
	invalid.settings.controls = 100
	check(not Progress.valid(invalid), "Unsafe saved control sizes are rejected")
	touch(9, c.buttons.right.get_center(), true)
	world._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not world.playing and c.fingers.is_empty() and c.axis() == 0, "Focus interruption pauses and clears held input")
	world.resume()
	check(world.playing and c.axis() == 0, "Resume requires fresh movement input")
	world.show_journal()
	check(not world.playing and world.menu_mode == "pause", "Journal pauses encounters")
	world.resume()
	# Check actual collision prevents spells crossing solid gates.
	Progress.data.crystal = false
	world.apply_progress()
	world.spawn_bolt(Vector3(36, 1, 0), 1, true)
	await frames(12)
	var crossed = false
	for child in world.get_children():
		if child.get_script() == world.Bolt and child.friendly and child.position.x > 37.5:
			crossed = true
	check(not crossed, "Spell rays stop at solid barriers")
	var blocked_enemy = world.enemies[2]
	blocked_enemy.home = Vector3(38, 0.7, 0)
	blocked_enemy.position = blocked_enemy.home
	blocked_enemy.health = 3
	blocked_enemy.timer = 10
	p.restore_at(Vector3(36.4, 0.81, 0))
	p.facing = 1
	p.attack()
	await frames(16)
	check(blocked_enemy.health == 3, "Sword cannot damage an enemy through a solid seal")
	# Coyote jump just after a ledge, then a buffered landing jump.
	p.restore_at(Vector3(15.9, 0.82, 0))
	await frames(4)
	c.keys.right = true
	await frames(6)
	p.request_jump()
	c.keys.jump = true
	await frames(2)
	check(p.velocity.y > 0, "Coyote time permits a jump just beyond the ledge")
	c.reset_input()
	p.restore_at(Vector3(5, 1.0, 0))
	p.velocity.y = -3
	p.request_jump()
	c.keys.jump = true
	await frames(8)
	check(p.velocity.y > 0, "Buffered jump fires on landing")
	c.reset_input()
	Progress.data.crystal = true
	world.apply_progress()
	world.show_settings()
	menu_press("Sound:")
	menu_press("Screen shake:")
	check(not Progress.data.settings.sound and not Progress.data.settings.shake, "Settings buttons toggle sound and camera shake")
	menu_press("Controls:")
	c.layout_buttons()
	check(is_equal_approx(Progress.data.settings.controls, 1.2), "Control size button updates layout scale")
	menu_press("Frame limit:")
	menu_press("Quality:")
	check(Engine.max_fps == 30 and is_equal_approx(world.get_viewport().scaling_3d_scale, 0.7), "Frame limit and quality buttons apply renderer settings")
	var saved_settings: Dictionary = Progress.data.settings.duplicate()
	Progress.data.settings = Progress.DEFAULTS.settings.duplicate()
	var loaded_ok = Progress.load_game()
	check(loaded_ok and Progress.data.settings == saved_settings, "Changed settings persist through disk reload")
	Progress.data.settings = Progress.DEFAULTS.settings.duplicate()
	world.apply_settings()
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(Progress.save_path + suffix)
	print("GAMEPLAY RESULTS: ", checks - failures, "/", checks, " passed")
	world.queue_free()
	await get_tree().process_frame
	get_tree().quit(1 if failures else 0)
