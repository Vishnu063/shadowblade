extends Node
## Staged encounters exercise the shipped boss AI and power scripts unchanged.
const Campaign = preload("res://scripts/campaign.gd")
const BossPower = preload("res://scripts/boss_power.gd")
var world: Node3D
var heading: Label
var state: Label
var health: Label
var frame = 0
var capture_failures = 0
func overlay_label(parent: Node,text: String,pos: Vector2,size: int) -> Label:
	var label = Label.new()
	parent.add_child(label)
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size",size)
	return label
func capture_frame() -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result = get_viewport().get_texture().get_image().save_png("res://build/villain-power-frames/%04d.png" % frame)
	if result != OK: capture_failures += 1
	frame += 1
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/villain-power-frames")
	Progress.save_path = "user://villain-power-preview.json"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(Progress.save_path+suffix)
	world = load("res://scenes/main.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	world.set_process(false)
	world.player.set_physics_process(false)
	var layer = CanvasLayer.new()
	add_child(layer)
	var panel = ColorRect.new()
	panel.color = Color(.02,.04,.075,.88)
	panel.position = Vector2(20,20)
	panel.size = Vector2(1240,112)
	layer.add_child(panel)
	heading = overlay_label(layer,"",Vector2(42,32),30)
	state = overlay_label(layer,"",Vector2(42,78),22)
	health = overlay_label(layer,"",Vector2(1050,78),22)
	var footer = ColorRect.new()
	footer.color = Color(.02,.04,.075,.88)
	footer.position = Vector2(20,658)
	footer.size = Vector2(1240,42)
	layer.add_child(footer)
	overlay_label(layer,"SHADOWBLADE  •  Actual game engine / staged encounters  •  Current prototype animation",Vector2(42,666),19)
	var verified = 0
	for region in 6:
		if region > 0:
			world.boss_defeated()
			if not world.travel_to(region):
				push_error("Could not stage region")
				get_tree().quit(1)
		world.menu.visible = false
		world.controls.visible = false
		world.started = false
		for enemy in world.enemies:
			enemy.set_physics_process(false)
			enemy.visible = false
		var boss = world.enemies[3]
		boss.position = Vector3(51.5,1.4,0)
		boss.home = boss.position
		boss.visible = true
		boss.timer = .5
		boss.set_physics_process(true)
		world.player.restore_at(Vector3(48,.85,0))
		world.player.invulnerable = 0
		world.player.facing = 1
		world.player.body_art.rotation = Vector3(0,.65,0)
		world.player.body_art.scale.x = 1
		world.player.body_art.visible = true
		world.camera.size = 6.2
		world.camera.position = Vector3(49.8,3.7,17)
		world.camera.rotation_degrees = Vector3(-8,0,0)
		world.update_reference_background()
		heading.text = "%d / 6   %s  •  %s" % [region+1,Campaign.BOSSES[region],BossPower.TITLES[region]]
		var saw_warning = false
		var saw_power = false
		for i in 60:
			world.player.motion.player.advance(1.0/20)
			var phase = "APPROACH"
			for child in world.get_children():
				if child.get_script() == BossPower and child.power == region:
					if child.elapsed < child.warning_time:
						saw_warning = true
						phase = "WARNING • Move away from the marked area"
					else:
						saw_power = true
						phase = "POWER ACTIVE"
			if boss.phase == "recover" and phase == "APPROACH": phase = "RECOVERY"
			state.text = Campaign.REGIONS[region]+"  |  "+phase
			health.text = "KAEL  %d / 6 HP" % world.player.health
			await capture_frame()
		print("VILLAIN POWER CAPTURE ",region,": warning=",saw_warning," active=",saw_power," target_health=",world.player.health)
		if saw_warning and saw_power and world.player.health < 6: verified += 1
		boss.set_physics_process(false)
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(Progress.save_path+suffix)
	print("VILLAIN POWER PREVIEW: ",verified,"/6 attacks verified; ",frame," frames; frame errors=",capture_failures)
	world.queue_free()
	await get_tree().process_frame
	get_tree().quit(0 if verified == 6 and capture_failures == 0 else 1)
