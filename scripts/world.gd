extends Node3D
const Art = preload("res://scripts/shapes.gd")
const Player = preload("res://scripts/player.gd")
const Enemy = preload("res://scripts/enemy.gd")
const Bolt = preload("res://scripts/bolt.gd")
const Controls = preload("res://scripts/controls.gd")
const Scenery = preload("res://scripts/scenery.gd")
var sun: DirectionalLight3D
var npc_labels: Array[Label3D] = []
var rune_clock = 0.0
var player: CharacterBody3D
var controls: Control
var camera: Camera3D
var gate: StaticBody3D
var crystal: MeshInstance3D
var secret: MeshInstance3D
var enemies: Array = []
var playing = false
var started = false
var menu_mode = "title"
var menu: PanelContainer
var menu_box: VBoxContainer
var hit_flash = 0.0
var session_deaths = 0
var boss_rewards = 0
var audio: AudioStreamPlayer
var checkpoint_cooldown = 0.0

func _ready() -> void:
	build_environment()
	build_route()
	player = Player.new()
	player.world = self
	add_child(player)
	player.position = Vector3(2, 1, 0)
	camera = Camera3D.new()
	add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 10.5
	camera.position = Vector3(5, 5, 17)
	camera.rotation_degrees.x = -8
	camera.current = true
	var layer = CanvasLayer.new()
	add_child(layer)
	controls = Controls.new()
	controls.world = self
	layer.add_child(controls)
	menu = PanelContainer.new()
	layer.add_child(menu)
	menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu.position = Vector2(390, 135)
	menu.custom_minimum_size = Vector2(500, 420)
	menu.add_theme_stylebox_override("panel", controls.panel_style(Color(0.025, 0.065, 0.09, 0.97)))
	var padding = MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		padding.add_theme_constant_override("margin_" + side, 24)
	menu.add_child(padding)
	menu_box = VBoxContainer.new()
	menu_box.add_theme_constant_override("separation", 12)
	padding.add_child(menu_box)
	audio = AudioStreamPlayer.new()
	add_child(audio)
	Progress.load_game()
	apply_settings()
	show_title()

func build_environment() -> void:
	var environment = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("508dc3")
	sky_material.sky_horizon_color = Color("bad0d6")
	sky_material.ground_horizon_color = Color("839fa0")
	sky.sky_material = sky_material
	env.sky = sky
	env.background_color = Color("88b7d6")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("adcec4")
	env.ambient_light_energy = 0.24
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("90b1cd")
	env.fog_density = 0.0025
	environment.environment = env
	add_child(environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, -35, 0)
	sun.light_color = Color("fff1d0")
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 48
	add_child(sun)
	Scenery.backdrop(self)

func terrain(x: float, y: float, width: float, height: float = 1.5) -> void:
	Scenery.terrain(self, x, y, width, height)

func build_route() -> void:
	terrain(3, 0, 26) # Village and first route: -10 to 16.
	terrain(27, 0, 16) # Landing: 19 to 35.
	terrain(48, 0, 26) # Boss route: 35 to 61.
	terrain(12, 1.8, 3, 0.15)
	terrain(14, 3.3, 2.5, 0.5)
	terrain(21, 1.0, 3, 0.5)
	terrain(31, 1.4, 3, 0.5)
	Art.solid(self, Vector3(-10, 3, 0), Vector3(1, 9, 3), Color("3d554d"))
	Art.solid(self, Vector3(62, 3, 0), Vector3(1, 9, 3), Color("3d554d"))
	for x in [-4, 1, 6]:
		Scenery.model(self, "cottage", Vector3(x, 0, -2.8))
	Art.box(self, Vector3(1, -0.15, -2.7), Vector3(20, 0.3, 3), Color("718c65"))
	for spec in [[3.0, "LYRA • GUIDE", "lyra"], [-2.0, "MIRA • REST", "mira"], [7.0, "ORIN • MERCHANT", "orin"]]:
		var x: float = spec[0]
		Scenery.model(self, spec[2], Vector3(x, 0.8, -0.7))
		npc_labels.append(Art.label(self, Vector3(x, 2.1, -0.7), spec[1], Color("e4d6ad")))
	for x in [24, 44]:
		Scenery.model(self, "waystone", Vector3(x, 0, -0.7))
		npc_labels.append(Art.label(self, Vector3(x, 2.2, 0), "WAYSTONE • USE", Color("9be8e9")))
	Art.box(self, Vector3(9, 1.1, -0.8), Vector3(0.14, 2.2, 0.18), Color("695f49"))
	Art.box(self, Vector3(9, 1.8, -0.8), Vector3(2.1, 0.55, 0.14), Color("7f7959"))
	npc_labels.append(Art.label(self, Vector3(9, 1.83, -0.68), "FOREST  →", Color("e6ddbb")))
	var switch_body = Art.solid(self, Vector3(33, 2.2, 0), Vector3(0.6, 0.9, 0.6), Color("579fc9"))
	switch_body.collision_layer = 16
	switch_body.set_meta("crystal", true)
	crystal = switch_body.get_child(0)
	var rune = Scenery.rune(self, Vector3.ZERO, Color("78d8ed"))
	crystal.mesh = rune.mesh
	rune.queue_free()
	npc_labels.append(Art.label(self, Vector3(32.5, 3.4, 0), "BOLT → CRYSTAL", Color("9de4ff")))
	gate = Art.solid(self, Vector3(37, 2.5, 0), Vector3(0.55, 5, 3), Color("54799b"))
	Scenery.model(self, "ruin_arch", Vector3(37, 0, -0.5), Vector3(0.3, 1.05, 1))
	gate.get_child(0).material_override = Art.material(Color("559aa9"), 0.2)
	secret = Scenery.rune(self, Vector3(14, 4.4, 0), Color("f0d189"))
	secret.scale = Vector3.ONE * 0.6
	add_enemy(12, "melee")
	add_enemy(27, "wisp")
	add_enemy(42, "melee")
	add_enemy(51, "boss")

	Art.label(self, Vector3(59, 2.5, 0), "WILLOWBROOK\nA light returns", Color("e5c79c"))

func add_enemy(x: float, kind: String) -> void:
	var enemy = Enemy.new()
	enemy.world = self
	enemy.kind = kind
	enemy.home = Vector3(x, 1.4 if kind == "boss" else (2 if kind == "wisp" else 0.8), 0)
	add_child(enemy)
	enemy.position = enemy.home
	enemies.append(enemy)

func spawn_bolt(pos: Vector3, direction: float, friendly: bool) -> Node3D:
	var bolt = Bolt.new()
	bolt.world = self
	bolt.direction = direction
	bolt.friendly = friendly
	add_child(bolt)
	bolt.position = pos
	return bolt

func _process(delta: float) -> void:
	if menu.visible:
		menu.position = get_viewport().get_visible_rect().size / 2 - menu.size / 2
	for label in npc_labels:
		label.visible = started and absf(player.position.x - label.position.x) < 5.5
	if not playing:
		return
	rune_clock += delta
	secret.rotation.y = rune_clock
	crystal.rotation.y = rune_clock * 0.6
	hit_flash = maxf(0, hit_flash - delta)
	checkpoint_cooldown = maxf(0, checkpoint_cooldown - delta)
	var target = Vector3(clampf(player.position.x + player.facing * 2.7, 3, 56), clampf(player.position.y * 0.18 + 4.3, 4.3, 5.8), 17)
	camera.position = camera.position.lerp(target, 1 - exp(-5 * delta))
	if hit_flash > 0 and Progress.data.settings.shake:
		camera.position.y += sin(Time.get_ticks_msec() * 0.09) * hit_flash * 0.2
	if not Progress.data.secret and player.position.distance_to(secret.position) < 0.9:
		Progress.data.secret = true
		secret.visible = false
		persist()
		controls.notify_text("Sun shard found! Bring it to Orin in Willowbrook.")
	if player.position.x > 57 and Progress.data.boss:
		playing = false
		show_completion()

func persist() -> void:
	if not Progress.save_game():
		controls.notify_text("Save failed: " + Progress.last_error)

func start_game(fresh: bool = false) -> void:
	if fresh:
		Progress.new_game()
		persist()
	else:
		Progress.load_game()
	started = true
	playing = true
	menu.visible = false
	menu_mode = ""
	controls.reset_input()
	player.restore_at(Vector3(Progress.data.checkpoint, 1, 0))
	for enemy in enemies:
		enemy.reset_encounter()
	for child in get_children():
		if child.get_script() == Bolt:
			child.queue_free()
	apply_progress()
	camera.position.x = player.position.x + 2
	controls.notify_text("Welcome to Willowbrook. Talk to Lyra to begin.")

func apply_progress() -> void:
	gate.visible = not Progress.data.crystal
	gate.collision_layer = 0 if Progress.data.crystal else 1
	secret.visible = not Progress.data.secret
	crystal.material_override = Art.material(Color("87e5ce") if Progress.data.crystal else Color("579fc9"), 1)

func activate_crystal() -> void:
	if Progress.data.crystal:
		return
	Progress.data.crystal = true
	Progress.data.quest = maxi(2, int(Progress.data.quest))
	apply_progress()
	persist()
	controls.notify_text("Crystal seal opened. The Hollow Warden waits beyond.")
	tone(850, 0.3)

func reset_crystal() -> bool:
	# Never close the gate around a player/checkpoint on its far side.
	if player.position.x > 34.5 or Progress.data.checkpoint == 44.0 or Progress.data.boss:
		controls.notify_text("The seal is stable here. Continue your journey.")
		return false
	Progress.data.crystal = false
	Progress.data.quest = mini(1, int(Progress.data.quest))
	apply_progress()
	persist()
	controls.notify_text("Crystal reset. Wait for magic to recover, then cast again from the ledge.")
	return true

func boss_defeated() -> void:
	if Progress.data.boss:
		return
	Progress.data.boss = true
	Progress.data.quest = 3
	boss_rewards += 1
	player.magic = player.max_magic
	persist()
	controls.notify_text("The Hollow Warden falls. Return to Lyra, or follow the eastern trail.")

func respawn() -> void:
	session_deaths += 1
	controls.reset_input()
	player.restore_at(Vector3(Progress.data.checkpoint, 1, 0))
	for enemy in enemies:
		enemy.reset_encounter()
	for child in get_children():
		if child.get_script() == Bolt:
			child.queue_free()
	controls.notify_text("Returned to your waystone. Powers and quest progress preserved.")

func objective() -> String:
	match int(Progress.data.quest):
		0: return "Talk to Lyra in the village [E / TALK]"
		1: return "Forest path: cast Arcane Bolt at the blue crystal"
		2: return "Beyond the seal: defeat the Hollow Warden"
	return "Willowbrook restored • Return to Lyra or explore east"

func interact() -> void:
	var x: float = player.position.x
	if absf(x - 3) < 2:
		if Progress.data.quest == 0:
			Progress.data.quest = 1
			persist()
			show_dialogue("Lyra • The forest is fading", "Kael, the Void has bound our forest guardian. You already carry Arcane Bolt. Follow the eastern trail, strike the blue crystal with magic, and free the Hollow Warden.\n\nSword: J • Jump: Space • Magic: tap K or hold for powers.")
		elif Progress.data.boss:
			show_dialogue("Lyra • A light returns", "You freed Willowbrook, Kael. Beyond the forest lies Emberhearth. Its chapter is still in development. Rest here before your next journey.")
		else:
			show_dialogue("Lyra • Follow the blue light", "Magic returns if you wait. The crystal opens the forest seal. The Warden signals each strike — jump the amber shockwave, then close in with your sword.")
	elif absf(x + 2) < 2:
		rest(2.0)
		show_dialogue("Mira • Rest point", "Your hearts and magic are restored. Your journey is saved here in Willowbrook.")
	elif absf(x - 7) < 1.8:
		show_merchant()
	elif absf(x - 24) < 2:
		rest(24.0)
	elif absf(x - 33) < 1.5:
		if Progress.data.crystal and not Progress.data.boss and Progress.data.checkpoint != 44.0:
			clear_menu("The forest crystal", "pause")
			paragraph("The seal is open. You can reset this puzzle to practice again. Magic always recovers while you wait on the ledge.")
			button("Reset crystal puzzle", func():
				reset_crystal()
				resume())
			button("Keep it open", resume)
		else:
			controls.notify_text("Arcane Bolt opens the seal. Magic recovers here while you wait.")
	elif absf(x - 44) < 2:
		rest(44.0)
	else:
		controls.notify_text("Move near a villager or glowing waystone to talk / use.")

func rest(x: float) -> void:
	Progress.data.checkpoint = x
	player.health = player.max_health
	player.magic = player.max_magic
	player.safe_position = Vector3(x, 1, 0)
	persist()
	controls.notify_text("Waystone attuned • Hearts and magic restored • Journey saved")

func clear_menu(title: String, mode: String) -> void:
	playing = false
	if audio != null:
		audio.stop()
	controls.reset_input()
	menu.visible = true
	menu_mode = mode
	for child in menu_box.get_children():
		menu_box.remove_child(child)
		child.queue_free()
	var label = Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 27)
	label.modulate = Color("b8e3e5")
	menu_box.add_child(label)

func paragraph(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 450
	label.add_theme_font_size_override("font_size", 18)
	menu_box.add_child(label)

func button(text: String, callback: Callable) -> Button:
	var node = Button.new()
	node.text = text
	node.custom_minimum_size.y = 44
	node.pressed.connect(callback)
	menu_box.add_child(node)
	return node

func show_title() -> void:
	clear_menu("SHADOWBLADE", "title")
	paragraph("THE LAST GUARDIAN\nWillowbrook • Guardian of the Silverfall\n\nA forest in shadow. A blacksmith’s apprentice. A light that refuses to fade.")
	var has_save = not Progress.read_valid(Progress.save_path).is_empty() or not Progress.read_valid(Progress.save_path + ".bak").is_empty()
	if has_save:
		button("Continue journey", func(): start_game(false))
	button("New journey", confirm_new if has_save else func(): start_game(true))
	button("Settings", show_settings)
	paragraph("Move A/D • Jump Space • Sword J • Magic K\nTouch: separate movement and action buttons\nOriginal Willowbrook art • Offline • No login")

func confirm_new() -> void:
	clear_menu("Begin again?", "title")
	paragraph("A new journey replaces your current progress. Your previous valid save remains as a recovery backup.")
	button("Start new journey", func(): start_game(true))
	button("Back", show_title)

func resume() -> void:
	controls.reset_input()
	menu.visible = false
	menu_mode = ""
	playing = true

func open_pause() -> void:
	clear_menu("Journey paused", "pause")
	button("Resume", resume)
	button("Quest journal", show_journal)
	button("Settings", show_settings)
	button("Travel to Willowbrook", func():
		rest(2.0)
		player.restore_at(Vector3(2, 1, 0))
		resume())
	button("Save and return to title", func():
		persist()
		show_title())

func show_journal() -> void:
	clear_menu("Kael’s journal", "pause")
	paragraph("MAIN • " + objective() + "\n\nSIDE • " + ("Sun shard recovered. Speak to Orin for a free restoration." if Progress.data.secret else "Orin seeks a sun shard in the high ruins above the forest gap.") + "\n\nPOWER • Arcane Bolt (10 magic). Hold magic to inspect six powers.\n\nVILLAGE • Willowbrook discovered. Travel is available from Pause.")
	button("Return", resume)

func show_merchant() -> void:
	clear_menu("Orin • Relics and remedies", "pause")
	paragraph("Find the sun shard above the forest gap. I will restore your magic whenever you visit.\n\n" + ("You found it! Restoration is yours, free of charge." if Progress.data.secret else "The high ledges hide something bright."))
	if Progress.data.secret:
		button("Restore magic", func():
			player.magic = player.max_magic
			resume())
	button("Leave", resume)

func show_dialogue(title: String, text: String) -> void:
	clear_menu(title, "pause")
	paragraph(text)
	button("Continue", resume)

func show_completion() -> void:
	clear_menu("Willowbrook • A light returns", "pause")
	paragraph("The Hollow Warden is free. Your checkpoint, crystal seal, sun shard and quest progress are saved.\n\nThis is the end of the first prototype. The other five regions and powers remain in development.")
	button("Return to village", func():
		rest(2.0)
		player.restore_at(Vector3(2, 1, 0))
		resume())
	button("Title", show_title)

func show_settings() -> void:
	clear_menu("Settings", "settings")
	button("Sound: " + ("ON" if Progress.data.settings.sound else "OFF"), func():
		Progress.data.settings.sound = not Progress.data.settings.sound
		settings_changed())
	button("Screen shake: " + ("ON" if Progress.data.settings.shake else "OFF"), func():
		Progress.data.settings.shake = not Progress.data.settings.shake
		settings_changed())
	button("Controls: %.0f%%" % (Progress.data.settings.controls * 100), func():
		var value: float = Progress.data.settings.controls + 0.2
		Progress.data.settings.controls = 0.8 if value > 1.41 else value
		settings_changed())
	button("Frame limit: %d FPS" % Progress.data.settings.fps, func():
		Progress.data.settings.fps = 30 if Progress.data.settings.fps == 60 else 60
		settings_changed())
	button("Quality: " + ("Standard" if Progress.data.settings.quality else "Low"), func():
		Progress.data.settings.quality = 1 - Progress.data.settings.quality
		settings_changed())
	button("Back", open_pause if started else show_title)

func settings_changed() -> void:
	apply_settings()
	persist()
	show_settings()

func apply_settings() -> void:
	Engine.max_fps = int(Progress.data.settings.fps)
	get_viewport().scaling_3d_scale = 1.0 if Progress.data.settings.quality else 0.7
	if sun != null:
		sun.shadow_enabled = bool(Progress.data.settings.quality)
	get_viewport().msaa_3d = Viewport.MSAA_2X if Progress.data.settings.quality else Viewport.MSAA_DISABLED

func _notification(what: int) -> void:
	if controls == null:
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		var was_in_game = playing or controls.wheel_open
		controls.reset_input()
		if started and was_in_game:
			open_pause()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if playing or controls.wheel_open:
			open_pause()
		elif menu_mode == "settings":
			if started:
				open_pause()
			else:
				show_title()

func tone(hz: float, duration: float) -> void:
	if audio == null or not Progress.data.settings.sound or not playing:
		return
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var count = int(duration * 22050)
	var samples = PackedByteArray()
	samples.resize(count * 2)
	for i in count:
		var envelope = minf(float(i) / 100.0, 1.0) * minf(float(count - i) / 300.0, 1.0)
		samples.encode_s16(i * 2, int(sin(TAU * hz * i / 22050.0) * envelope * 3000))
	stream.data = samples
	audio.stream = stream
	audio.play()

func _exit_tree() -> void:
	if is_instance_valid(audio):
		audio.stop()
