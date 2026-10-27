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
var model: MeshInstance3D
var warning: Label3D

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	health = 14 if kind == "boss" else 3
	var col = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.height = 2.4 if kind == "boss" else 1.2
	shape.radius = 0.5 if kind == "boss" else 0.35
	col.shape = shape
	add_child(col)
	var color = Color("9264ac") if kind == "wisp" else Color("8a534b")
	model = Art.orb(self, Vector3.ZERO, 0.8 if kind == "boss" else 0.45, color)
	Art.orb(self, Vector3(-0.18, 0.16, 0.38), 0.08, Color("ffb67c"), 1)
	Art.orb(self, Vector3(0.18, 0.16, 0.38), 0.08, Color("ffb67c"), 1)
	if kind == "boss":
		Art.box(self, Vector3(0, 0.9, 0), Vector3(1.5, 0.25, 0.5), Color("464d65"))
	warning = Art.label(self, Vector3(0, 1.5, 0), "")

func _physics_process(delta: float) -> void:
	if not alive or not world.playing:
		return
	timer -= delta
	hit_cooldown = maxf(0, hit_cooldown - delta)
	var dx: float = world.player.position.x - position.x
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
			timer = 0.8 if kind == "boss" else 0.65
			warning.text = "!  SHOCKWAVE" if kind == "boss" else "!"
	elif phase == "warn" and timer <= 0:
		phase = "strike"
		timer = 0.18
		warning.text = ""
		if kind in ["wisp", "boss"]:
			world.spawn_bolt(position + Vector3(facing * 0.9, 0, 0), facing, false)
	elif phase == "strike":
		if active and absf(dx) < (2.2 if kind == "boss" else 1.4) and absf(world.player.position.y - position.y) < 1.3:
			world.player.damage(2 if kind == "boss" else 1)
		if timer <= 0:
			phase = "recover"
			timer = 1.2
	elif phase == "recover" and timer <= 0:
		phase = "approach"
		timer = 0.5
	model.scale = Vector3.ONE * (1.12 if phase == "warn" else 1.0)
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
	health = 14 if kind == "boss" else 3
	position = home
	velocity = Vector3.ZERO
	visible = alive
	collision_layer = 4 if alive else 0
	timer = 1.0
	phase = "approach"
	hit_cooldown = 0
	warning.text = ""
