extends Node
## Deterministic staged studio capture using the actual runtime rig and effects.
const Campaign = preload("res://scripts/campaign.gd")
const EndPortal = preload("res://scripts/end_portal.gd")
var world: Node3D
var title: Label
var frame = 0
func draw_frame() -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()
	var result = image.save_png("res://build/animation-frames/%04d.png" % frame)
	if result != OK:
		push_error("Preview frame could not be saved")
		get_tree().quit(1)
	frame += 1
func pose(name: String,caption: String,frames: int = 15) -> void:
	title.text = caption
	world.player.motion.player.play(name)
	world.player.motion.player.advance(0)
	for i in frames:
		world.player.motion.player.advance(1.0/15)
		await draw_frame()
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/animation-frames")
	DirAccess.make_dir_recursive_absolute("res://docs/screenshots")
	Progress.save_path = "user://animation-preview.json"
	world = load("res://scenes/main.tscn").instantiate()
	add_child(world)
	world.set_process(false)
	world.player.set_physics_process(false)
	for enemy in world.enemies: enemy.set_physics_process(false)
	for child in world.get_children():
		if child is Node3D and child != world.camera and child != world.sun: child.visible = false
		if child is CanvasLayer: child.visible = false
		if child is WorldEnvironment:
			child.environment.background_mode = Environment.BG_COLOR
			child.environment.background_color = Color("f4f3ef")
			child.environment.fog_enabled = false
			child.environment.ambient_light_energy = .35
	world.sun.light_energy = .65
	for child in world.camera.get_children():
		if child is Node3D: child.visible = false
	world.playing = true
	world.player.visible = true
	world.player.position = Vector3(0,0,0)
	world.player.body_art.rotation = Vector3(0,.65,-.02)
	world.player.body_art.visible = true
	world.player.invulnerable = 0
	world.camera.size = 3.1
	world.camera.position = Vector3(0,.1,8)
	world.camera.rotation = Vector3.ZERO
	var layer = CanvasLayer.new()
	add_child(layer)
	title = Label.new()
	title.position = Vector2(40,35)
	title.add_theme_font_size_override("font_size",28)
	title.add_theme_color_override("font_color",Color("24344b"))
	layer.add_child(title)
	var note = Label.new()
	note.text = "SHADOWBLADE  •  Actual engine animation / staged preview  •  Concept art is a higher-detail target"
	note.position = Vector2(40,675)
	note.add_theme_font_size_override("font_size",18)
	note.add_theme_color_override("font_color",Color("4b5767"))
	layer.add_child(note)
	await pose("idle","KAEL • Guardian armor / idle")
	get_viewport().get_texture().get_image().save_png("res://docs/screenshots/hero-studio.png")
	await pose("run","RUN • Opposing stride and knee motion",24)
	await pose("rise","JUMP • Rise",7)
	await pose("fall","JUMP • Fall",7)
	await pose("land","JUMP • Landing",5)
	for i in 3: await pose("slash_%d" % (i+1),"SWORD • Combo %d" % (i+1),8)
	for i in 6:
		world.effect(Vector3(.65 if i in [1,2] else 0,0,.2),i,1.0,Vector3(1.8,.2,0) if i==4 else null)
		await pose("dash" if i==3 else "cast_%d" % i,"POWER • "+Campaign.POWERS[i],12)
	await pose("hit","HIT • Recoil",7)
	await pose("defeat","DEFEAT • Pose study",12)
	world.player.visible = false
	world.camera.size = 4.5
	world.camera.position = Vector3(0,.35,8)
	for i in 6:
		var model = load("res://assets/forest/"+["hollow-warden-v2","cinder-sentinel","frostbound-keeper","gale-harrier","tempest-colossus","void-herald"][i]+".glb").instantiate()
		add_child(model)
		model.rotation.y = .35
		title.text = Campaign.BOSSES[i]+" • "+["Thorn Snare","Magma Eruption","Ice Prison","Cyclone Dive","Thunder Strike","Shadow Rift"][i]
		for j in 20:
			model.rotation.y = .35+sin(j*.12)*.18
			model.get_node("LeftArm").rotation.z = -.15*sin(j*.15)
			model.get_node("RightArm").rotation.z = .15*sin(j*.15)
			await draw_frame()
			if j==10: get_viewport().get_texture().get_image().save_png("res://docs/screenshots/villain-%d.png" % (i+1))
		model.queue_free()
	Progress.data.boss = true
	Progress.data.campaign.completed = range(7)
	var portal = EndPortal.new()
	portal.world = world
	add_child(portal)
	world.camera.size = 6.0
	world.camera.position = Vector3(0,1.5,8)
	title.text = "DAWN GATE • Final victory opens the teleport doorway"
	for i in 20: await draw_frame()
	get_viewport().get_texture().get_image().save_png("res://docs/screenshots/dawn-gate.png")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(Progress.save_path+suffix)
	print("ANIMATION PREVIEW FRAMES: ",frame)
	get_tree().quit()
