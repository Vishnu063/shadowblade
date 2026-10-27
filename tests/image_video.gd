extends Node
var world: Node3D
var title: Label
var frame=0
var failures=0
func shot() -> void:
	world.update_reference_background()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result=get_viewport().get_texture().get_image().save_png("res://build/image-character-frames/%04d.png" % frame)
	if result!=OK:failures+=1
	frame+=1
func frames(count: int) -> void:
	for i in count:await shot()
func view(x: float,y: float,size: float) -> void:
	world.camera.position=Vector3(x,y,17)
	world.camera.size=size
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/image-character-frames")
	var ignore=FileAccess.open("res://build/.gdignore",FileAccess.WRITE)
	ignore.close()
	world=load("res://scenes/image_preview.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	world.set_process(false)
	world.controls.visible=false
	world.player.set_physics_process(false)
	world.enemies[0].set_physics_process(false)
	world.player.position=Vector3(47,.85,0)
	world.player.invulnerable=0
	world.player.body_art.visible=true
	var layer=CanvasLayer.new()
	add_child(layer)
	var panel=ColorRect.new()
	panel.position=Vector2(24,20)
	panel.size=Vector2(1232,58)
	panel.color=Color(.01,.03,.05,.83)
	layer.add_child(panel)
	title=Label.new()
	title.position=Vector2(43,30)
	title.add_theme_font_size_override("font_size",27)
	layer.add_child(title)
	var footer=Label.new()
	footer.position=Vector2(30,678)
	footer.text="SHADOWBLADE • Painted image characters • Actual engine / staged gameplay"
	footer.add_theme_font_size_override("font_size",18)
	footer.add_theme_color_override("font_shadow_color",Color.BLACK)
	footer.add_theme_constant_override("shadow_outline_size",5)
	layer.add_child(footer)
	title.text="WILLOWBROOK • Painted hero and villain"
	view(49,3.8,5.8)
	for i in 36:
		world.player.motion.update(1.0/24,world.player)
		await shot()
	title.text="KAEL • Moving image parts, scarf and sword"
	view(47,3.2,3.0)
	world.player.motion.player.play("idle")
	for i in 36:
		world.player.motion.player.advance(1.0/24)
		world.player.body_art.secondary_motion(1.0/24,0)
		await shot()
	title.text="HOLLOW WARDEN • Painted limbs, head and hammer"
	view(51,4.0,4.2)
	for i in 36:
		world.enemies[0].model.animate_boss(1.0/24,"approach",0,float(i)/24)
		await shot()
	title.text="MOVEMENT • Run, jump and land"
	world.player.restore_at(Vector3(45,.85,0))
	world.player.invulnerable=0
	world.player.set_physics_process(true)
	view(49,3.8,5.9)
	world.controls.keys.right=true
	await frames(12)
	world.controls.reset_input()
	world.controls.keys.jump=true
	world.player.request_jump()
	await frames(27)
	world.controls.reset_input()
	await frames(9)
	title.text="SWORD • Image hero strikes the image villain"
	world.player.restore_at(Vector3(49.5,.85,0))
	world.player.invulnerable=0
	world.player.facing=1
	world.enemies[0].position=Vector3(51.1,1.2,0)
	view(50.2,3.8,5.6)
	for i in 48:
		if i%12==0:world.player.attack()
		await shot()
	title.text="ARCANE BOLT • Painted casting hand and magic"
	world.player.restore_at(Vector3(48,.85,0))
	world.player.invulnerable=0
	world.player.facing=1
	view(49.6,3.8,5.7)
	for i in 36:
		if i%18==0:
			world.player.cast_cooldown=0
			world.player.select_power(0)
			world.player.cast()
		await shot()
	title.text="THORN SNARE • The villain casts its image-based root attack"
	world.player.restore_at(Vector3(48,.85,0))
	world.player.invulnerable=0
	world.enemies[0].health=world.enemies[0].max_health
	world.enemies[0].position=Vector3(51.5,1.2,0)
	world.enemies[0].timer=.4
	world.enemies[0].phase="approach"
	world.enemies[0].set_physics_process(true)
	await frames(72)
	title.text="IMAGE-BASED CHARACTERS • Playable forest preview"
	world.enemies[0].set_physics_process(false)
	world.player.invulnerable=0
	world.player.body_art.visible=true
	world.player.motion.reset()
	view(49.5,3.8,5.9)
	await frames(48)
	print("IMAGE CHARACTER VIDEO: ",frame," frames; frame errors=",failures,"; hero parts=",world.player.body_art.find_children("*","Sprite3D",true,false).size(),"; villain parts=",world.enemies[0].model.find_children("*","Sprite3D",true,false).size())
	get_tree().quit(1 if failures else 0)
