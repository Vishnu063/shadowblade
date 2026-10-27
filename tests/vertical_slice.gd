extends Node
var checks=0
var failures=0
var world: Node3D
func check(value: bool,message: String) -> void:
	checks+=1
	print(("PASS: " if value else "FAIL: ")+message)
	if not value: failures+=1
func step(count: int=2) -> void:
	for i in count:await get_tree().physics_frame
func _ready() -> void:
	Progress.save_path="user://slice-production-sentinel.json"
	Progress.data=Progress.DEFAULTS.duplicate(true)
	Progress.save_game()
	var before=FileAccess.get_file_as_bytes(Progress.save_path)
	world=load("res://scenes/willowbrook_3d.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	await step(10)
	check(Progress.save_path=="user://guardian-3d-slice.json","3D scene uses an isolated save slot")
	check(world.player.motion.skeleton is Skeleton3D and world.player.motion.skeleton.get_bone_count()==21,"Kael uses the 21-bone weighted skeleton")
	check(world.player.is_on_floor() and world.player.position.y<1,"Hero is grounded at the preview checkpoint")
	var skeleton=world.player.motion.skeleton
	var bone=skeleton.find_bone("ArmL")
	var before_pose: Transform3D=skeleton.get_bone_global_pose(bone)
	world.player.select_power(0)
	check(world.player.cast(),"Skinned hero can cast through the real gameplay API")
	await step(12)
	check(not before_pose.is_equal_approx(skeleton.get_bone_global_pose(bone)),"Cast clip changes deform-bone pose")
	world.open_pause()
	var timeline: float=world.player.motion.player.current_animation_position
	await step(6)
	check(timeline==world.player.motion.player.current_animation_position,"Pause freezes skinned animation")
	world.resume()
	world.controls.keys.right=true
	var x: float=world.player.position.x
	await step(15)
	world.controls.reset_input()
	check(world.player.position.x>x+.5,"Movement works with the new mesh")
	world.player.request_jump()
	world.controls.keys.jump=true
	await step(3)
	check(world.player.velocity.y>0 and not world.player.is_on_floor(),"Skinned hero physically jumps")
	world.controls.reset_input()
	world.player.restore_at(Vector3(49.5,.85,0))
	var boss=world.enemies[0]
	boss.set_physics_process(false)
	boss.position=Vector3(51,1.2,0)
	world.player.facing=1
	world.player.attack()
	await step(15)
	check(boss.health<boss.max_health,"Sword hit reaches the rebuilt Warden")
	check(not is_instance_valid(world.reference_background),"3D scene has no image background")
	world.queue_free()
	await step(3)
	check(Progress.save_path=="user://slice-production-sentinel.json","Leaving restores the campaign save path")
	check(FileAccess.get_file_as_bytes(Progress.save_path)==before,"Preview never changes the campaign save bytes")
	for path in ["user://slice-production-sentinel.json","user://guardian-3d-slice.json"]:
		for suffix in ["", ".bak", ".tmp"]:DirAccess.remove_absolute(path+suffix)
	print("VERTICAL SLICE RESULTS: %d/%d passed" % [checks-failures,checks])
	get_tree().quit(1 if failures else 0)
