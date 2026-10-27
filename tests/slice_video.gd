extends Node
## Recorded from real 3D assets and the actual movement/combat API.
var world: Node3D
var title: Label
var frame=0
var errors=0
func capture() -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result=get_viewport().get_texture().get_image().save_png("res://build/guardian-3d-frames/%04d.png" % frame)
	if result!=OK:errors+=1
	frame+=1
func frames(count: int) -> void:
	for i in count:await capture()
func camera_at(pos: Vector3,target: Vector3,fov: float=38) -> void:
	world.camera.fov=fov
	world.camera.position=pos
	world.camera.look_at(target)
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/guardian-3d-frames")
	var ignore=FileAccess.open("res://build/.gdignore",FileAccess.WRITE)
	ignore.close()
	world=load("res://scenes/willowbrook_3d.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	world.set_process(false)
	world.controls.visible=false
	world.player.set_physics_process(false)
	world.player.invulnerable=0
	world.player.position=Vector3(46,.85,0)
	world.player.body_art.rotation.y=.55
	world.enemies[0].set_physics_process(false)
	var layer=CanvasLayer.new()
	add_child(layer)
	var top=ColorRect.new()
	top.position=Vector2(24,20)
	top.size=Vector2(1232,64)
	top.color=Color(.015,.028,.045,.82)
	layer.add_child(top)
	title=Label.new()
	title.position=Vector2(44,33)
	title.add_theme_font_size_override("font_size",27)
	layer.add_child(title)
	var bottom=Label.new()
	bottom.position=Vector2(34,678)
	bottom.text="SHADOWBLADE • Actual game engine • Staged 3D art preview / work in progress"
	bottom.add_theme_font_size_override("font_size",18)
	bottom.add_theme_color_override("font_shadow_color",Color.BLACK)
	bottom.add_theme_constant_override("shadow_outline_size",5)
	layer.add_child(bottom)
	title.text="WILLOWBROOK • Fully 3D forest clearing"
	for i in 48:
		var t=float(i)/47
		camera_at(Vector3(47.5+t*1.2,3.8-t*.5,12-t),Vector3(48.5,1.4,-1))
		world.player.motion.player.advance(1.0/24)
		await capture()
	title.text="KAEL • Weighted skeleton, rebuilt face, layered armour and cloth"
	for i in 60:
		var t=float(i)/59
		camera_at(Vector3(46.6-t*.6,1.45,4.2),Vector3(46,1.0,0),36)
		world.player.body_art.rotation.y=.25+t*.5
		world.player.motion.player.advance(1.0/24)
		await capture()
	title.text="HOLLOW WARDEN • Interwoven roots, bark and moss"
	for i in 48:
		camera_at(Vector3(51.7-float(i)/47*.8,2.4,6.7),Vector3(51,1.45,0),40)
		world.enemies[0].model.rotation.y=-.2-float(i)/47*.25
		await capture()
	title.text="MOVEMENT • Run, jump and landing"
	world.player.set_physics_process(true)
	world.controls.keys.right=true
	camera_at(Vector3(49,3.1,10),Vector3(49,1.4,-.5),38)
	await frames(10)
	world.controls.reset_input()
	world.controls.keys.jump=true
	world.player.request_jump()
	await frames(23)
	world.controls.reset_input()
	await frames(12)
	title.text="COMBAT • Sword combo and Arcane Bolt"
	world.player.restore_at(Vector3(49,.85,0))
	world.player.invulnerable=0
	world.enemies[0].position=Vector3(50.6,1.2,0)
	camera_at(Vector3(49.7,3.0,9.4),Vector3(49.7,1.35,-.5),38)
	world.player.facing=1
	for i in 48:
		if i%10==0:world.player.attack()
		if i%16==0:
			world.player.cast_cooldown=0
			world.player.select_power(0)
			world.player.cast()
		await capture()
	title.text="THORN SNARE • Warning, growing roots and recovery"
	world.player.restore_at(Vector3(48,.85,0))
	world.player.invulnerable=0
	world.enemies[0].health=world.enemies[0].max_health
	world.enemies[0].position=Vector3(51,1.2,0)
	world.enemies[0].timer=.5
	world.enemies[0].phase="approach"
	world.enemies[0].set_physics_process(true)
	camera_at(Vector3(49.5,3.1,9.8),Vector3(49.5,1.35,-.5),38)
	await frames(72)
	title.text="GUARDIAN LIGHT • Shield and reactive character motion"
	world.player.magic=100
	world.player.cast_cooldown=0
	world.player.select_power(5)
	world.player.cast()
	await frames(36)
	title.text="WILLOWBROOK • New playable 3D art scene"
	world.enemies[0].set_physics_process(false)
	for i in 36:
		var t=float(i)/35
		camera_at(Vector3(49.5-t,3.1+t*.3,9.8+t*1.2),Vector3(49.5,1.35,-1),38)
		await capture()
	print("3D VIDEO: ",frame," frames; frame-save errors=",errors,"; skinned skeleton bones=",world.player.motion.skeleton.get_bone_count())
	get_tree().quit(1 if errors else 0)
