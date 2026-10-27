extends Node
const BossPower = preload("res://scripts/boss_power.gd")
const EndPortal = preload("res://scripts/end_portal.gd")
var world: Node3D
var checks = 0
var failures = 0
func check(value: bool,message: String) -> void:
	checks += 1
	print(("PASS: " if value else "FAIL: ")+message)
	if not value: failures += 1
func step(count: int = 2) -> void:
	for i in count: await get_tree().physics_frame
func _ready() -> void:
	Progress.save_path = "user://hero-boss-regression.json"
	world = load("res://scenes/main.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	await step(15)
	world.controls.keys.right = true
	await step(4)
	check(world.player.motion.player.current_animation == "run","Movement drives the run clip")
	world.controls.reset_input()
	world.player.attack()
	check(world.player.motion.player.current_animation == "slash_1" and world.player.attack_time == .3,"Sword animation preserves combat window")
	world.open_pause()
	var before: float = world.player.motion.player.current_animation_position
	await step(10)
	check(world.player.motion.player.current_animation_position == before,"Pause freezes the animation timeline")
	world.resume()
	world.respawn()
	check(world.player.motion.action_left == 0 and world.player.slow_time == 0,"Respawn clears action and slow state")
	for region in 6:
		if region > 0:
			Progress.data.crystal = true
			world.boss_defeated()
			world.travel_to(region)
		await step(2)
		var boss = world.enemies[3]
		check(boss.model.scene_file_path.ends_with(["hollow-warden-v2","cinder-sentinel","frostbound-keeper","gale-harrier","tempest-colossus","void-herald"][region]+".glb"),"Distinct model in region %d" % region)
		world.player.restore_at(Vector3(48,.85,0))
		world.player.invulnerable = 0
		var spell = BossPower.new()
		spell.world = world
		spell.caster = boss
		spell.power = region
		spell.position = Vector3(48,.15,0)
		world.add_child(spell)
		spell.set_physics_process(false)
		spell._physics_process(.79)
		check(world.player.health == 6,"Region %d warning cannot deal early damage" % region)
		spell._physics_process(.02)
		check(world.player.health == 5,"Region %d active power hits once" % region)
		world.player.invulnerable = 0
		spell._physics_process(.03)
		check(world.player.health == 5,"Region %d power cannot hit twice" % region)
		world.open_pause()
		var elapsed: float = spell.elapsed
		spell._physics_process(1)
		check(spell.elapsed == elapsed,"Region %d power respects pause" % region)
		world.resume()
		world.respawn()
		await step(2)
		check(not is_instance_valid(spell),"Region %d respawn clears hostile power" % region)
	Progress.data.crystal = true
	world.boss_defeated()
	world.travel_to(6)
	await step(2)
	var portal: Node3D
	for child in world.get_children():
		if child.get_script() == EndPortal: portal = child
	check(is_instance_valid(portal) and not portal.surface.visible,"Final teleport doorway stays sealed before victory")
	check(not world.use_final_portal(),"Sealed portal cannot teleport before final victory")
	world.boss_defeated()
	await step(2)
	check(portal.surface.visible,"Final victory opens the teleport doorway")
	check(world.use_final_portal() and world.region_index == 0 and Progress.data.boss,"Final portal returns to restored Willowbrook without losing progress")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(Progress.save_path+suffix)
	world.queue_free()
	await step(3)
	print("HERO/BOSS RESULTS: %d/%d passed" % [checks-failures,checks])
	get_tree().quit(1 if failures else 0)
