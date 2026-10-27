extends Node3D
const Art = preload("res://scripts/shapes.gd")
const Campaign = preload("res://scripts/campaign.gd")
const RegionArt = preload("res://scripts/region_art.gd")
const MagicEffect = preload("res://scripts/magic_effect.gd")
const Player = preload("res://scripts/player.gd")
const Enemy = preload("res://scripts/enemy.gd")
const Bolt = preload("res://scripts/bolt.gd")
const Controls = preload("res://scripts/controls.gd")
const Scenery = preload("res://scripts/scenery.gd")
var region_index = 0
var ice_bridge: StaticBody3D
var ice_time = 0.0
var reveal_time = 0.0
var hazard_cooldown = 0.0
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
	if region_index != int(Progress.data.campaign.region): rebuild_region()
	apply_settings()
	show_title()

func build_environment() -> void:
	var environment = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = [Color("3c80bb"),Color("382c39"),Color("598da9"),Color("62a6c3"),Color("514a71"),Color("373650"),Color("272139")][region_index]
	sky_material.sky_horizon_color = [Color("c3d5d8"),Color("ba8a73"),Color("d5e7e9"),Color("d6e6df"),Color("a7a3bd"),Color("a091ae"),Color("766786")][region_index]
	sky_material.ground_horizon_color = Color("657f88")
	sky.sky_material = sky_material
	env.sky = sky
	env.background_color = Color("88b7d6")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("adc4d0")
	env.ambient_light_energy = 0.18
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("90b1cd")
	env.fog_density = 0.0035
	environment.environment = env
	add_child(environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, -35, 0)
	sun.light_color = [Color("fff1d0"),Color("ffb778"),Color("e1f3ff"),Color("d2f5e3"),Color("cbbaf4"),Color("f2d8b8"),Color("c9b4ea")][region_index]
	sun.light_energy = 1.12
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 48
	add_child(sun)
	RegionArt.backdrop(self,region_index)

func terrain(x: float, y: float, width: float, height: float = 1.5) -> void:
	Scenery.terrain(self, x, y, width, height)

func build_route() -> void:
	terrain(3, 0, 26) # Village and first route: -10 to 16.
	terrain(28.5,0,13) if region_index == 3 else terrain(27,0,16) # Windrest needs air dash.
	terrain(48, 0, 26) # Boss route: 35 to 61.
	terrain(12, 1.8, 3, 0.15)
	terrain(14, 3.3, 2.5, 0.5)
	if region_index != 3: terrain(21,1.0,3,.5)
	terrain(31, 1.4, 3, 0.5)
	Art.solid(self, Vector3(-10, 3, 0), Vector3(1, 9, 3), Color("3d554d"))
	Art.solid(self, Vector3(62, 3, 0), Vector3(1, 9, 3), Color("3d554d"))
	for x in [-4, 1, 6]:
		Scenery.model(self, "cottage", Vector3(x, 0, -2.8))
	Art.box(self, Vector3(1, -0.15, -2.7), Vector3(20, 0.3, 3), Color("718c65"))
	for spec in [[3.0, Campaign.GUIDES[region_index].to_upper()+" • GUIDE", "lyra"], [-2.0, "MIRA • REST", "mira"], [7.0, "ORIN • MERCHANT", "orin"]]:
		var x: float = spec[0]
		Scenery.model(self, spec[2], Vector3(x, 0.8, -0.7))
		npc_labels.append(Art.label(self, Vector3(x, 2.1, -0.7), spec[1], Color("e4d6ad")))
	for x in [24, 44]:
		Scenery.model(self, "waystone", Vector3(x, 0, -0.7))
		npc_labels.append(Art.label(self, Vector3(x, 2.2, 0), "WAYSTONE • USE", Color("9be8e9")))
	Art.box(self, Vector3(9, 1.1, -0.8), Vector3(0.14, 2.2, 0.18), Color("695f49"))
	Art.box(self, Vector3(9, 1.8, -0.8), Vector3(2.1, 0.55, 0.14), Color("7f7959"))
	npc_labels.append(Art.label(self, Vector3(9, 1.83, -0.68), "TRAIL  →", Color("e6ddbb")))
	var switch_body = Art.solid(self, Vector3(33, 2.2, 0), Vector3(0.6, 0.9, 0.6), Color("579fc9"))
	switch_body.collision_layer = 16
	switch_body.set_meta("crystal", true)
	crystal = switch_body.get_child(0)
	var rune = Scenery.rune(self, Vector3.ZERO, Color("78d8ed"))
	crystal.mesh = rune.mesh
	rune.queue_free()
	npc_labels.append(Art.label(self, Vector3(32.5, 3.4, 0), ["BOLT → CRYSTAL","FLAME → VINES","FROST → RUNE","DASH → VANE","CHAIN → CONDUCTOR","LIGHT → SEAL","FOUR SEALS"][region_index], Color("9de4ff")))
	gate = Art.solid(self, Vector3(37, 2.5, 0), Vector3(0.55, 5, 3), Color("54799b"))
	Scenery.model(self, "ruin_arch", Vector3(37, 0, -0.5), Vector3(0.3, 1.05, 1))
	gate.get_child(0).material_override = Art.material(Color("559aa9"), 0.2)
	secret = Scenery.rune(self, Vector3(14, 4.4, 0), Color("f0d189"))
	secret.scale = Vector3.ONE * 0.6
	add_enemy(12, "melee")
	add_enemy(27, "wisp")
	add_enemy(42, "melee")
	add_enemy(51, "boss")

	Art.label(self,Vector3(59,2.5,0),Campaign.NAMES[region_index].to_upper()+"\nThe eastern trail",Color("e5c79c"))
	RegionArt.landmark(self,region_index)

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
	update_spells(delta)
	rune_clock += delta
	secret.rotation.y = rune_clock
	crystal.rotation.y = rune_clock * 0.6
	hit_flash = maxf(0, hit_flash - delta)
	checkpoint_cooldown = maxf(0, checkpoint_cooldown - delta)
	var target = Vector3(clampf(player.position.x + player.facing * 2.7, 3, 56), clampf(player.position.y * 0.18 + 4.3, 4.3, 5.8), 17)
	camera.position = camera.position.lerp(target, 1 - exp(-5 * delta))
	if hit_flash > 0 and Progress.data.settings.shake:
		camera.position.y += sin(Time.get_ticks_msec() * 0.09) * hit_flash * 0.2
	if not Progress.data.secret and secret.visible and player.position.distance_to(secret.position) < .9:
		Progress.data.secret = true
		secret.visible = false
		persist()
		controls.notify_text(Campaign.SIDE_ITEMS[region_index]+" found! Visit the village merchant.")
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
	if region_index != int(Progress.data.campaign.region): rebuild_region()
	started = true
	playing = true
	menu.visible = false
	menu_mode = ""
	controls.reset_input()
	player.restore_at(Vector3(Progress.data.checkpoint, 1, 0))
	for enemy in enemies:
		enemy.reset_encounter()
	for child in get_children():
		if child.get_script() in [Bolt,MagicEffect]:
			child.queue_free()
	apply_progress()
	camera.position.x = player.position.x + 2
	controls.notify_text("Welcome to "+Campaign.NAMES[region_index]+". Talk to "+Campaign.GUIDES[region_index]+".")

func apply_progress() -> void:
	gate.visible = not Progress.data.crystal
	gate.collision_layer = 0 if Progress.data.crystal else 1
	secret.visible = not Progress.data.secret and (region_index != 5 or reveal_time > 0)
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
	if not Progress.data.campaign.completed.has(region_index): Progress.data.campaign.completed.append(region_index)
	boss_rewards += 1
	player.magic = player.max_magic
	persist()
	controls.notify_text(Campaign.BOSSES[region_index]+" falls. Follow the eastern trail.")

func respawn() -> void:
	session_deaths += 1
	controls.reset_input()
	player.restore_at(Vector3(Progress.data.checkpoint, 1, 0))
	for enemy in enemies:
		enemy.reset_encounter()
	for child in get_children():
		if child.get_script() in [Bolt,MagicEffect]:
			child.queue_free()
	clear_temporary_magic()
	controls.notify_text("Returned to your waystone. Powers and quest progress preserved.")

func objective() -> String:
	match int(Progress.data.quest):
		0: return "Talk to "+Campaign.GUIDES[region_index]+" in "+Campaign.NAMES[region_index]
		1: return Campaign.PUZZLES[region_index]
		2: return "Beyond the seal: defeat "+Campaign.BOSSES[region_index]
	return Campaign.NAMES[region_index]+" restored • Follow the eastern trail"

func interact() -> void:
	var x: float = player.position.x
	if absf(x - 3) < 2:
		if Progress.data.quest == 0:
			Progress.data.quest = 1
			persist()
			show_dialogue(Campaign.GUIDES[region_index]+" • "+Campaign.NAMES[region_index],Campaign.STORIES[region_index]+"\n\nPower: "+Campaign.POWERS[mini(region_index,5)]+". Hold magic to select.")
		elif Progress.data.boss:
			show_dialogue(Campaign.GUIDES[region_index]+" • A light returns","You freed "+Campaign.NAMES[region_index]+". The eastern trail is open. Return travel is available in the world map.")
		else:
			show_dialogue(Campaign.GUIDES[region_index]+" • Follow the trail",Campaign.PUZZLES[region_index]+". Magic recovers on safe ground. Watch the guardian’s warning before attacking.")
	elif absf(x + 2) < 2:
		rest(2.0)
		show_dialogue("Mira • Rest point", "Your hearts and magic are restored. Your journey is saved here in "+Campaign.NAMES[region_index]+".")
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
			controls.notify_text(Campaign.PUZZLES[region_index]+". Magic recovers while you wait.")
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
	paragraph("THE LAST GUARDIAN\nSix villages • Six powers • One last guardian\n\nA forest in shadow. A blacksmith’s apprentice. A light that refuses to fade.")
	var has_save = not Progress.read_valid(Progress.save_path).is_empty() or not Progress.read_valid(Progress.save_path + ".bak").is_empty()
	if has_save:
		button("Continue journey", func(): start_game(false))
	button("New journey", confirm_new if has_save else func(): start_game(true))
	button("Settings", show_settings)
	paragraph("Move A/D • Jump Space • Sword J • Magic K\nTouch: separate movement and action buttons\nOriginal fantasy adventure • Offline • No login")

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
	button("Travel to Willowbrook",func():
		if region_index == 0:
			rest(2.0)
			player.restore_at(Vector3(2,1,0))
			resume()
		else: travel_to(0))
	button("World map / villages",show_travel)
	button("Save and return to title", func():
		persist()
		show_title())

func show_journal() -> void:
	clear_menu("Kael’s journal","pause")
	var powers = []
	for id in Progress.data.powers: powers.append(Campaign.POWERS[int(id)])
	paragraph("MAIN • "+objective()+"\n\nSIDE • "+Campaign.SIDE_ITEMS[region_index]+(" recovered. Visit the merchant." if Progress.data.secret else " hidden in the high ruins.")+"\n\nPOWERS • "+", ".join(powers)+"\n\nVILLAGES • "+", ".join(Progress.data.villages))
	button("Return",resume)

func show_merchant() -> void:
	clear_menu("Orin • Relics and remedies", "pause")
	paragraph("Find the "+Campaign.SIDE_ITEMS[region_index]+" above the gap. I will restore your magic whenever you visit.\n\n" + ("You found it! Restoration is yours, free of charge." if Progress.data.secret else "The high ledges hide something bright."))
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
	clear_menu("Aetheria restored" if region_index == 6 else Campaign.NAMES[region_index]+" • A light returns","pause")
	if region_index == 6:
		paragraph("Lord Vaelor falls. The six villages kindle their lights together. Kael returns to the forge, carrying a blade that now protects rather than conquers.\n\nTHE END\nYour journey is saved. Return to discover the remaining relics.")
	else:
		paragraph(Campaign.BOSSES[region_index]+" is free. Your quest and checkpoint are saved. Next: "+Campaign.NAMES[region_index+1])
		button("Continue to "+Campaign.NAMES[region_index+1],func(): travel_to(region_index+1))
	button("Return to village",func():
		rest(2.0)
		player.restore_at(Vector3(2,1,0))
		resume())
	button("World map",show_travel)
	button("Title",show_title)

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

func rebuild_region() -> void:
	clear_temporary_magic()
	region_index = int(Progress.data.campaign.region)
	enemies.clear()
	npc_labels.clear()
	for child in get_children():
		if child != player and child != camera and (child is Node3D or child is WorldEnvironment):
			remove_child(child)
			child.queue_free()
	build_environment()
	build_route()
	apply_settings()
func travel_to(index: int) -> bool:
	if not Campaign.enter(index):
		controls.notify_text("Restore the previous village before taking this trail.")
		return false
	controls.reset_input()
	rebuild_region()
	player.restore_at(Vector3(Progress.data.checkpoint,1,0))
	apply_progress()
	camera.position = Vector3(player.position.x+2,4.3,17)
	resume()
	persist()
	controls.notify_text(Campaign.NAMES[index]+" discovered • "+Campaign.POWERS[mini(index,5)]+" ready")
	return true
func show_travel() -> void:
	clear_menu("Aetheria • World map","pause")
	paragraph("Restored: %d / 6 villages. Travel preserves each chapter." % mini(6,Progress.data.campaign.completed.size()))
	for i in int(Progress.data.campaign.unlocked)+1:
		var destination = i
		button(Campaign.NAMES[i]+(" • restored" if Progress.data.campaign.completed.has(i) else " • explore"),func(): travel_to(destination))
	var next = int(Progress.data.campaign.unlocked)+1
	if next <= 6 and Progress.data.campaign.completed.has(next-1): button("New trail • "+Campaign.NAMES[next],func(): travel_to(next))
	button("Back",open_pause)
func effect(origin: Vector3,power: int,radius: float = 1.0,destination: Variant = null) -> void:
	var node = MagicEffect.new()
	node.world = self
	node.color = Campaign.COLORS[power]
	node.radius = radius
	node.position = origin
	if destination is Vector3:
		node.beam = true
		node.target = to_global(destination)
	add_child(node)
func clear_line(from: Vector3,target: Node3D,mask: int = 5) -> bool:
	var hit = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(to_global(from),target.global_position,mask))
	return hit.is_empty() or hit.collider == target
func nearby_mechanism(power: int,radius: float = 4.5) -> void:
	var delta = crystal.global_position-player.global_position
	if delta.length() <= radius and delta.x*player.facing >= -.4:
		if clear_line(player.position,crystal.get_parent(),17): attune_mechanism(power)
func attune_mechanism(power: int) -> bool:
	if Progress.data.crystal: return false
	if region_index == 6:
		if power not in [1,2,4,5]:
			controls.notify_text("Four seals need Flame, Frost, Lightning and Guardian Light.")
			return false
		if not Progress.data.seals.has(power): Progress.data.seals.append(power)
		effect(crystal.global_position,power,.7)
		if Progress.data.seals.size() < 4:
			persist()
			controls.notify_text("Fortress seals: %d / 4" % Progress.data.seals.size())
			return true
	elif power != region_index:
		controls.notify_text(Campaign.PUZZLES[region_index])
		return false
	activate_crystal()
	return true
func cast_power(power: int) -> bool:
	if not Progress.data.powers.has(power): return false
	match power:
		0: spawn_bolt(player.position+Vector3(player.facing*.7,.1,0),player.facing,true)
		1,2:
			effect(player.position+Vector3(player.facing*1.3,0,0),power,1.3)
			for enemy in enemies:
				var delta: Vector3 = enemy.position-player.position
				if enemy.alive and delta.x*player.facing > -.3 and delta.x*player.facing < 3.8 and absf(delta.y) < 2 and clear_line(player.position,enemy):
					if power == 1: enemy.take_hit(3)
					else: enemy.frozen_time = .45 if enemy.kind == "boss" else 2.5
			if power == 2 and region_index == 2 and absf(player.position.x-17.5) < 4: freeze_pool()
			nearby_mechanism(power)
		3:
			if player.dash_used: return false
			player.dash_time = .20
			player.dash_used = true
			effect(player.position,power,.75)
			nearby_mechanism(power)
		4:
			var origin: Vector3 = player.position
			var hit_targets = []
			for link in 3:
				var nearest: Node3D = null
				var distance = 5.5
				for enemy in enemies:
					var delta: Vector3 = enemy.position-origin
					if enemy.alive and not hit_targets.has(enemy) and delta.length() < distance and (link > 0 or delta.x*player.facing > -.3) and clear_line(origin,enemy):
						nearest = enemy
						distance = delta.length()
				if nearest == null: break
				effect(origin,power,1,nearest.position)
				hit_targets.append(nearest)
				origin = nearest.position
				nearest.take_hit(2)
			nearby_mechanism(power,5.5)
		5:
			player.shield_hits = 2
			player.shield_time = 3.5
			reveal_time = 8
			apply_progress()
			effect(player.position,power,1.1)
			nearby_mechanism(power)
	return true
func freeze_pool() -> void:
	if not is_instance_valid(ice_bridge): ice_bridge = Art.solid(self,Vector3(17.5,-.1,0),Vector3(3.1,.2,2.4),Color("9cd8e5"))
	ice_bridge.set_meta("temporary_platform",true)
	ice_time = 8
	controls.notify_text("Ice bridge • Eight seconds to cross")
func clear_temporary_magic() -> void:
	if is_instance_valid(ice_bridge):
		remove_child(ice_bridge)
		ice_bridge.queue_free()
	ice_bridge = null
	ice_time = 0
	reveal_time = 0
func update_spells(delta: float) -> void:
	hazard_cooldown = maxf(0,hazard_cooldown-delta)
	if ice_time > 0:
		ice_time = maxf(0,ice_time-delta)
		if is_instance_valid(ice_bridge): ice_bridge.get_child(0).visible = ice_time > 2 or fmod(ice_time,.3) > .12
		if ice_time == 0:
			if player.position.x > 15.7 and player.position.x < 19.3 and player.position.y < 1.4:
				player.position = player.safe_position+Vector3(0,.15,0)
				player.velocity = Vector3.ZERO
			clear_temporary_magic()
	if reveal_time > 0:
		reveal_time = maxf(0,reveal_time-delta)
		if region_index == 5 and reveal_time == 0: apply_progress()
	if region_index == 1 and hazard_cooldown == 0 and absf(player.position.x-40) < 1.1 and player.position.y < 1.2:
		player.damage(1)
		hazard_cooldown = .8
