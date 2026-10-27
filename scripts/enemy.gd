extends CharacterBody3D
const Art = preload("res://scripts/shapes.gd")
var world: Node3D
var kind = "melee"
var home = Vector3.ZERO
var health = 3
var alive = true
var timer = 1.0
var phase = "approach"
var facing = -1.0
var hit_cooldown = 0.0
var model: Node3D
var anim_time = 0.0
var frozen_time = 0.0
var max_health = 3
var warning: Label3D

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	max_health = (28 if world.region_index == 6 else 14+world.region_index*2) if kind == "boss" else 3+int(world.region_index/3)
	health = max_health
	var col = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.height = 2.4 if kind == "boss" else 1.2
	shape.radius = 0.5 if kind == "boss" else 0.35
	col.shape = shape
	add_child(col)
	var model_path = "res://assets/models/" + {"melee": "thornling", "wisp": "veil_moth", "boss": "hollow_warden"}[kind] + ".tscn"
	model = load("res://assets/forest/veil_moth.glb" if kind == "wisp" else model_path).instantiate()
	add_child(model)
	warning = Art.label(self, Vector3(0, 1.9 if kind == "boss" else 1.2, 0), "")

func _physics_process(delta: float) -> void:
	if not alive or not world.playing:
		return
	frozen_time = maxf(0,frozen_time-delta)
	if frozen_time > 0:
		warning.text = "RESISTS FROST" if kind == "boss" else "FROZEN"
		return
	if warning.text in ["FROZEN","RESISTS FROST"]: warning.text = ""
	timer -= delta
	hit_cooldown = maxf(0, hit_cooldown - delta)
	var dx: float = world.player.position.x - position.x
	if phase == "approach" and absf(dx) > 0.1:
		facing = signf(dx)
	velocity.x = 0
	velocity.z = 0
	position.z = 0
	if kind == "wisp":
		velocity.y = (home.y + sin(Time.get_ticks_msec() * 0.002) * 0.3 - position.y) * 2
	else:
		velocity.y -= 25 * delta
	var active = world.player.position.x > 9.5 and absf(dx) < (11 if kind == "boss" else 8)
	if phase == "approach" and active:
		if absf(dx) > (5 if kind == "wisp" else 1.5):
			velocity.x = facing * (1.5 if kind != "boss" else 2.2)
		if timer <= 0:
			phase = "warn"
			timer = (.65 if world.region_index == 6 and health < max_health/2 else .8) if kind == "boss" else .65
			warning.text = "!  SHOCKWAVE" if kind == "boss" else "!"
	elif phase == "warn" and timer <= 0:
		phase = "strike"
		timer = 0.18
		warning.text = ""
		if kind in ["wisp", "boss"]:
			world.spawn_bolt(position + Vector3(facing * 0.9, 0, 0), facing, false)
			if kind == "boss" and world.region_index >= 4 and health < max_health/2:
				world.spawn_bolt(position+Vector3(-facing*.9,.5,0),-facing,false)
	elif phase == "strike":
		if active and dx * facing > -0.2 and absf(dx) < (2.2 if kind == "boss" else 1.4) and absf(world.player.position.y - position.y) < 1.3:
			world.player.damage(2 if kind == "boss" else 1)
		if timer <= 0:
			phase = "recover"
			timer = 1.2
	elif phase == "recover" and timer <= 0:
		phase = "approach"
		timer = 0.5
	anim_time += delta
	model.scale = Vector3(facing, 1, 1) * (1.07 if phase == "warn" else 1.0)
	model.rotation.z = sin(anim_time * 15) * 0.12 if hit_cooldown > 0 else 0.0
	if kind == "wisp":
		model.find_child("LeftWing").rotation.y = sin(anim_time * 10) * 0.5
		model.find_child("RightWing").rotation.y = -sin(anim_time * 10) * 0.5
	elif kind == "boss":
		var lift = -0.7 if phase == "warn" else (0.6 if phase == "strike" else 0.0)
		model.get_node("LeftArm").rotation.z = lift
		model.get_node("RightArm").rotation.z = -lift
	else:
		for i in 4:
			var side = -1 if i < 2 else 1
			model.get_node("Leg%d%d" % [side, i % 2]).rotation.z = sin(anim_time * 9 + i * PI / 2) * minf(absf(velocity.x) * 0.2, 0.3)
	move_and_slide()
	# Encounters stay in their authored route rather than pursuing into the village.
	position.x = clampf(position.x, maxf(10.0, home.x - 4), home.x + 4)

func take_hit(amount: int) -> void:
	if not alive or hit_cooldown > 0:
		return
	hit_cooldown = 0.18
	health -= amount
	world.tone(180, 0.06)
	if health <= 0:
		alive = false
		visible = false
		collision_layer = 0
		if kind == "boss":
			world.boss_defeated()

func reset_encounter() -> void:
	alive = not (kind == "boss" and Progress.data.boss)
	health = max_health
	position = home
	velocity = Vector3.ZERO
	visible = alive
	collision_layer = 4 if alive else 0
	timer = 1.0
	phase = "approach"
	hit_cooldown = 0
	frozen_time = 0
	warning.text = ""
