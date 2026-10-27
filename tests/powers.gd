extends Node
const Art = preload("res://scripts/shapes.gd")
var world: Node3D
var checks = 0
var failures = 0
func check(value: bool,message: String) -> void:
	checks += 1
	print(("PASS: " if value else "FAIL: ")+message)
	if not value: failures += 1
func step(count: int = 2) -> void:
	for i in count: await get_tree().physics_frame
func prepare(index: int) -> void:
	world.player.magic = 100
	world.player.cast_cooldown = 0
	world.player.select_power(index)
	world.player.facing = 1
func _ready() -> void:
	Progress.save_path = "user://power-regression.json"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(Progress.save_path+suffix)
	world = load("res://scenes/main.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	await step(15)
	check(not world.player.select_power(5),"Locked powers cannot be selected")
	# Staged setup; the campaign suite separately traverses the complete journey.
	for region in range(1,6):
		Progress.data.crystal = true
		Progress.data.quest = 2
		world.boss_defeated()
		world.travel_to(region)
		await step(2)
	check(Progress.data.powers.size() == 6,"Six powers selectable after discovery")
	world.player.restore_at(Vector3(11,.85,0))
	var target = world.enemies[0]
	target.position = Vector3(13,.8,0)
	target.health = 10
	prepare(1)
	check(world.player.cast() and world.player.magic == 80,"Flame consumes 20 magic")
	check(target.health == 7,"Flame damages visible nearby enemy")
	prepare(2)
	check(world.player.cast() and target.frozen_time > 2,"Frost freezes ordinary enemy")
	var frozen_position: Vector3 = target.position
	await step(30)
	check(target.position == frozen_position,"Frozen enemy cannot move or attack")
	world.travel_to(2)
	await step(3)
	world.player.restore_at(Vector3(15,.85,0))
	prepare(2)
	world.player.cast()
	check(is_instance_valid(world.ice_bridge),"Frost creates a physical ice bridge")
	world.player.position = Vector3(17.5,.85,0)
	await step(15)
	check(not world.player.stable_ground(),"Temporary ice cannot become permanent recovery point")
	world.ice_time = .01
	await step(3)
	check(not is_instance_valid(world.ice_bridge) and world.player.position.x < 16,"Ice expiry returns occupant to solid ground")
	world.player.restore_at(Vector3(25,3,0))
	prepare(3)
	check(world.player.cast() and world.player.magic == 85,"Air dash costs 15 magic")
	var magic: float = world.player.magic
	world.player.cast_cooldown = 0
	check(not world.player.cast() and world.player.magic == magic,"Second air dash blocked without spending magic")
	Art.solid(world,Vector3(37,2.5,0),Vector3(.55,5,3),Color("3b4150"))
	await step(2)
	world.player.restore_at(Vector3(36,.85,0))
	prepare(3)
	world.player.cast()
	await step(20)
	check(world.player.position.x < 36.5,"Dash cannot tunnel through a solid wall")
	world.player.restore_at(Vector3(11,.85,0))
	for i in 3:
		world.enemies[i].position = Vector3(13+i*1.5,.85,0)
		world.enemies[i].health = 10
		world.enemies[i].alive = true
		world.enemies[i].collision_layer = 4
	prepare(4)
	world.player.cast()
	check(world.enemies[0].health == 8 and world.enemies[1].health == 8 and world.enemies[2].health == 8,"Lightning chains through three targets")
	world.player.restore_at(Vector3(35,.85,0))
	world.enemies[0].position = Vector3(39,.85,0)
	world.enemies[0].health = 10
	prepare(4)
	world.player.cast()
	check(world.enemies[0].health == 10,"Lightning cannot cross a solid wall")
	prepare(5)
	world.player.invulnerable = 0
	world.player.cast()
	var health: int = world.player.health
	world.player.damage(2)
	world.player.invulnerable = 0
	world.player.damage(1)
	check(world.player.health == health and world.player.shield_hits == 0,"Guardian absorbs exactly two hits")
	world.player.invulnerable = 0
	world.player.damage(1)
	check(world.player.health == health-1,"Damage resumes after shield charges exhaust")
	prepare(5)
	world.player.cast()
	world.player.invulnerable = 0
	health = world.player.health
	world.player.fall()
	check(world.player.health == health-1,"Shield cannot cancel pit damage")
	prepare(1)
	world.player.magic = 19
	check(not world.player.cast() and world.player.magic == 19,"Insufficient magic never casts or spends partial cost")
	prepare(5)
	world.player.select_power(4)
	check(Progress.save_game() and Progress.load_game() and Progress.data.selected_power == 4,"Selected power survives disk reload")
	world.player.shield_time = 1
	world.open_pause()
	await step(20)
	check(world.player.shield_time == 1,"Pause freezes shield duration")
	world.resume()
	world.respawn()
	check(world.player.shield_time == 0 and world.player.dash_time == 0,"Respawn clears temporary spells")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(Progress.save_path+suffix)
	world.queue_free()
	await step(2)
	print("POWER RESULTS: %d/%d passed" % [checks-failures,checks])
	get_tree().quit(1 if failures else 0)
