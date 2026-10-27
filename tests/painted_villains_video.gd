extends Node
const Campaign=preload("res://scripts/campaign.gd")
const Power=preload("res://scripts/boss_power.gd")
var world: Node3D
var title: Label
var status: Label
var frame=0
var errors=0
func capture() -> void:
	world.update_reference_background()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png("res://build/painted-villain-frames/%04d.png" % frame)!=OK:errors+=1
	frame+=1
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/painted-villain-frames")
	world=load("res://scenes/image_preview.tscn").instantiate()
	add_child(world)
	world.set_process(false)
	world.player.set_physics_process(false)
	var layer=CanvasLayer.new()
	add_child(layer)
	var panel=ColorRect.new()
	panel.position=Vector2(24,20)
	panel.size=Vector2(1232,94)
	panel.color=Color(.01,.03,.05,.84)
	layer.add_child(panel)
	title=Label.new()
	title.position=Vector2(42,29)
	title.add_theme_font_size_override("font_size",27)
	layer.add_child(title)
	status=Label.new()
	status.position=Vector2(42,72)
	status.add_theme_font_size_override("font_size",20)
	layer.add_child(status)
	var footer=Label.new()
	footer.text="SHADOWBLADE • Six painted villains • Actual engine / staged encounters"
	footer.position=Vector2(30,678)
	footer.add_theme_font_size_override("font_size",18)
	footer.add_theme_color_override("font_shadow_color",Color.BLACK)
	footer.add_theme_constant_override("shadow_outline_size",5)
	layer.add_child(footer)
	var verified=0
	for region in 6:
		world.selected_villain=region
		world.start_game(true)
		world.controls.visible=false
		world.player.set_physics_process(false)
		world.player.restore_at(Vector3(48,.85,0))
		world.player.invulnerable=0
		world.player.body_art.visible=true
		var boss=world.enemies[0]
		boss.position=Vector3(51.5,1.4,0)
		boss.home=boss.position
		boss.timer=.4
		boss.phase="approach"
		world.camera.size=5.9
		world.camera.position=Vector3(49.8,3.8,17)
		title.text="%d / 6   %s • %s" % [region+1,Campaign.BOSSES[region],Power.TITLES[region]]
		var warning=false
		var attack=false
		for i in 72:
			if not world.player.motion.player.is_playing():world.player.motion.player.play("idle")
			world.player.motion.player.advance(1.0/24)
			var phase="APPROACH"
			for child in world.get_children():
				if child.get_script()==Power:
					if child.elapsed<child.warning_time:
						warning=true
						phase="WARNING"
					else:
						attack=true
						phase="POWER ACTIVE"
			if phase=="APPROACH" and boss.phase=="recover":phase="RECOVERY"
			status.text=phase+"   |   KAEL %d / 6 HP" % world.player.health
			await capture()
		print("PAINTED VILLAIN ",region,": warning=",warning," attack=",attack," hero_hp=",world.player.health)
		if warning and attack and world.player.health<6:verified+=1
		boss.set_physics_process(false)
	print("PAINTED VILLAINS VIDEO: ",frame," frames; errors=",errors,"; verified attacks=",verified,"/6")
	get_tree().quit(0 if errors==0 and verified==6 else 1)
