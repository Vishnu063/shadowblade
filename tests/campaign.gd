extends Node
var world: Node3D
var failures = 0
var checks = 0
const Campaign = preload("res://scripts/campaign.gd")

func expect(value: bool, message: String) -> void:
	checks += 1
	print(("PASS: " if value else "FAIL: ") + message)
	if not value:
		failures += 1

func step(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func walk_to(x: float, limit: int = 400) -> bool:
	for i in limit:
		var dx: float = x - world.player.position.x
		if absf(dx) < 0.18:
			world.controls.keys.erase("right")
			world.controls.keys.erase("left")
			await step(5)
			return true
		world.controls.keys["right" if dx > 0 else "left"] = true
		world.controls.keys.erase("left" if dx > 0 else "right")
		await step(1)
	print("Walk timed out at ", world.player.position, " target ", x, " playing ", world.playing)
	world.controls.reset_input()
	return false

func ready_spell(index: int) -> void:
	world.player.select_power(index)
	for i in 1000:
		if world.player.cast_cooldown <= 0 and world.player.magic >= world.player.spell_cost(): return
		await step(1)
func _ready() -> void:
	Progress.save_path = "user://campaign-regression.json"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(Progress.save_path+suffix)
	world = load("res://scenes/main.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	await step(15)
	expect(not world.travel_to(2),"Undiscovered chapters cannot be skipped")
	var legacy = Progress.DEFAULTS.duplicate(true)
	legacy.version = 1
	for key in ["campaign", "selected_power", "seals"]: legacy.erase(key)
	expect(Progress.valid(legacy),"Version-one Willowbrook save remains readable")
	expect(Progress.normalize(legacy).version == 2,"Old save migrates to campaign schema")
	for region in 7:
		if region > 0: expect(world.travel_to(region),"Travel unlocks "+Campaign.NAMES[region])
		await step(20)
		expect(world.region_index == region and Progress.valid(Progress.data),"Valid chapter state")
		expect(Progress.data.powers == range(mini(region,5)+1),"Powers unlock in order before the regional boss")
		world.player.position.x = 3
		world.interact()
		expect(Progress.data.quest == 1 and not world.playing,"Guide gives regional quest")
		world.resume()
		expect(await walk_to(15.5),"Walk from village to gap")
		world.controls.keys.right = true
		world.controls.keys.jump = true
		world.player.request_jump()
		if region == 3:
			await step(16)
			world.player.cast()
			await step(30)
		else: await step(44)
		world.controls.reset_input()
		await step(30)
		expect(world.player.position.x > (22 if region == 3 else 19) and world.player.is_on_floor(),"Regional gap physically traversable")
		expect(await walk_to(24),"Reach waystone")
		world.interact()
		expect(Progress.data.checkpoint == 24,"Regional checkpoint saves")
		expect(await walk_to(29),"Reach mechanism ledge")
		world.controls.keys.jump = true
		world.controls.keys.right = true
		world.player.request_jump()
		await step(22)
		world.controls.reset_input()
		await step(25)
		world.player.facing = 1
		if region == 0:
			world.player.cast()
			await step(25)
		elif region == 6:
			for power in [1,2,4,5]:
				await ready_spell(power)
				world.player.cast()
				await step(2)
		else:
			await ready_spell(region)
			world.player.cast()
			await step(2)
		expect(Progress.data.crystal and world.gate.collision_layer == 0,"Required regional power opens physical seal")
		expect(await walk_to(44),"Opened gate permits reaching boss checkpoint")
		world.interact()
		await ready_spell(0)
		var boss = world.enemies[3]
		for i in 3500:
			if not boss.alive: break
			var dx: float = boss.position.x-world.player.position.x
			world.controls.keys.erase("left")
			world.controls.keys.erase("right")
			if absf(dx) > 1.45: world.controls.keys["right" if dx > 0 else "left"] = true
			world.player.facing = signf(dx)
			if boss.phase == "warn":
				world.controls.keys.jump = true
				if world.player.is_on_floor(): world.player.request_jump()
			else: world.controls.keys.erase("jump")
			world.player.attack()
			world.player.cast()
			await step(1)
		world.controls.reset_input()
		expect(not boss.alive and Progress.data.boss,"Normal combat defeats "+Campaign.BOSSES[region])
		expect(Progress.data.campaign.completed.has(region),"Victory persists once")
		expect(Progress.save_game() and Progress.load_game(),"Chapter and powers survive JSON reload")
		expect(await walk_to(56.7),"Reach regional exit")
		world.controls.keys.right = true
		await step(12)
		expect(not world.playing and world.menu_mode == "pause","Exit presents next chapter or ending")
	expect(Progress.data.campaign.completed == range(7),"All six villages and final fortress completed")
	expect(Progress.data.villages.size() == 6 and Progress.data.powers.size() == 6,"Exactly six villages and powers discovered")
	expect(world.travel_to(0),"Return travel to Willowbrook works after ending")
	expect(Progress.data.boss and Progress.data.crystal,"Return travel preserves Willowbrook victory")
	expect(world.travel_to(6),"Return to fortress preserves destinations")
	expect(Progress.data.boss and Progress.data.seals.size() == 4,"Final boss and seals survive travel")
	var invalid = Progress.data.duplicate(true)
	invalid.campaign.unlocked = 7
	expect(not Progress.valid(invalid),"Invalid campaign saves rejected")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(Progress.save_path+suffix)
	world.queue_free()
	await step(2)
	print("CAMPAIGN RESULTS: %d/%d passed" % [checks-failures,checks])
	get_tree().quit(1 if failures else 0)
