extends Node
const Puppet=preload("res://scripts/image_puppet.gd")
var world: Node3D
var checks=0
var failures=0
func check(value: bool,message: String) -> void:
	checks+=1
	print(("PASS: " if value else "FAIL: ")+message)
	if not value:failures+=1
func step(count: int=2) -> void:
	for i in count:await get_tree().physics_frame
func _ready() -> void:
	Progress.save_path="user://image-campaign-sentinel.json"
	Progress.data=Progress.DEFAULTS.duplicate(true)
	Progress.save_game()
	var saved=FileAccess.get_file_as_bytes(Progress.save_path)
	world=load("res://scenes/image_preview.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	await step(10)
	var hero=world.player.body_art
	var boss=world.enemies[0]
	check(hero.has_meta("image_character") and boss.model.has_meta("image_character"),"Hero and Warden use painted image rigs")
	check(hero.find_children("*","MeshInstance3D",true,false).is_empty() and boss.model.find_children("*","MeshInstance3D",true,false).is_empty(),"Characters contain no 3D character meshes")
	check(hero.find_children("*","Sprite3D",true,false).size()>=15 and boss.model.find_children("*","Sprite3D",true,false).size()>=11,"Body parts are separately drawable and animatable")
	check(Puppet.textures("kael").size()==16 and Puppet.textures("warden").size()==12,"Both transparent part sheets load")
	check(world.player.is_on_floor(),"Painted hero stands on the actual platform")
	var x: float=world.player.position.x
	world.controls.keys.right=true
	await step(10)
	check(world.player.position.x>x+.4 and world.player.motion.player.current_animation=="run","Run animation follows real movement")
	world.controls.reset_input()
	world.controls.keys.left=true
	await step(4)
	check(hero.scale.x<0 and hero.rotation.y==0,"Left movement flips the artwork without turning it edge-on")
	world.controls.reset_input()
	world.player.request_jump()
	world.controls.keys.jump=true
	await step(3)
	check(world.player.velocity.y>0 and not world.player.is_on_floor(),"Image hero physically jumps")
	world.controls.reset_input()
	world.player.restore_at(Vector3(49.5,.85,0))
	boss.set_physics_process(false)
	boss.position=Vector3(51,1.2,0)
	world.player.facing=1
	world.player.attack()
	await step(15)
	check(boss.health<boss.max_health,"Animated sword hits the image villain")
	world.player.restore_at(Vector3(48,.85,0))
	world.player.invulnerable=0
	world.player.select_power(0)
	check(world.player.cast(),"Image hero casts through the existing gameplay API")
	var before: float=world.player.motion.player.current_animation_position
	world.open_pause()
	await step(6)
	check(world.player.motion.player.current_animation_position==before,"Pause freezes image-part animation")
	world.resume()
	world.player.health=0
	world.respawn()
	check(world.player.health==6 and world.player.motion.action_left==0,"Checkpoint recovery resets image animation state")
	world.queue_free()
	await step(3)
	check(Progress.save_path=="user://image-campaign-sentinel.json" and FileAccess.get_file_as_bytes(Progress.save_path)==saved,"Image preview preserves campaign save bytes and restores its path")
	for path in ["user://image-campaign-sentinel.json","user://image-character-preview.json"]:
		for suffix in ["", ".bak", ".tmp"]:DirAccess.remove_absolute(path+suffix)
	print("IMAGE CHARACTER RESULTS: %d/%d passed" % [checks-failures,checks])
	get_tree().quit(1 if failures else 0)
