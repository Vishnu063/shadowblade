extends CharacterBody3D
const Art = preload("res://scripts/shapes.gd")
@export var move_speed = 6.0
@export var jump_speed = 10.2
@export var gravity = 25.0
@export var max_health = 6 # Half hearts.
@export var max_magic = 100.0
@export var bolt_cost = 10.0
@export var regen_rate = 8.0
@export var regen_delay = 1.5
@export var invulnerability_time = 1.0
@export var coyote_time = 0.12
@export var jump_buffer_time = 0.14
var world: Node3D
var health = 6
var magic = 100.0
var facing = 1.0
var invulnerable = 0.0
var regen_wait = 0.0
var cast_cooldown = 0.0
var attack_time = 0.0
var attack_cooldown = 0.0
var combo = 0
var combo_wait = 0.0
var coyote = 0.0
var jump_buffer = 0.0
var hit_targets: Array = []
var safe_position = Vector3(2, 1, 0)
var body_art: Node3D
var legs: Array[MeshInstance3D] = []
var stride = 0.0
var sword: MeshInstance3D

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var col = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = 0.28
	shape.height = 1.6
	col.shape = shape
	add_child(col)
	body_art = Node3D.new()
	add_child(body_art)
	Art.box(body_art, Vector3(0, -0.05, 0), Vector3(0.55, 0.65, 0.4), Color("326e90"))
	Art.orb(body_art, Vector3(0, 0.5, 0), 0.25, Color("dcae83"))
	Art.box(body_art, Vector3(0, 0.7, 0), Vector3(0.47, 0.14, 0.42), Color("29303f"))
	for x in [-0.16, 0.16]:
		legs.append(Art.box(body_art, Vector3(x, -0.57, 0), Vector3(0.2, 0.5, 0.27), Color("25354b")))
	Art.box(body_art, Vector3(-0.1, -0.08, -0.25), Vector3(0.5, 0.72, 0.06), Color("793e56"))
	sword = Art.box(body_art, Vector3(0.62, 0, 0), Vector3(0.8, 0.1, 0.1), Color("c1e6ed"))

func request_jump() -> void:
	jump_buffer = jump_buffer_time

func _physics_process(delta: float) -> void:
	if world == null or not world.playing:
		return
	invulnerable = maxf(0, invulnerable - delta)
	regen_wait = maxf(0, regen_wait - delta)
	cast_cooldown = maxf(0, cast_cooldown - delta)
	attack_cooldown = maxf(0, attack_cooldown - delta)
	combo_wait = maxf(0, combo_wait - delta)
	if regen_wait == 0:
		magic = minf(max_magic, magic + regen_rate * delta)
	var direction: float = world.controls.axis()
	if direction != 0:
		facing = signf(direction)
	velocity.x = move_toward(velocity.x, direction * move_speed, 45 * delta)
	velocity.z = 0
	position.z = 0
	if is_on_floor():
		coyote = coyote_time
		if position.y > 0.7:
			safe_position = position
	else:
		coyote = maxf(0, coyote - delta)
	velocity.y -= gravity * delta
	if jump_buffer > 0 and coyote > 0:
		velocity.y = jump_speed
		coyote = 0
		jump_buffer = 0
	if not world.controls.held("jump") and velocity.y > jump_speed * 0.45:
		velocity.y = jump_speed * 0.45
	jump_buffer = maxf(0, jump_buffer - delta)
	move_and_slide()
	stride += delta * absf(velocity.x) * 2.5
	for i in legs.size():
		legs[i].rotation.z = sin(stride + i * PI) * minf(absf(velocity.x) * 0.08, 0.5) if is_on_floor() else (0.35 if i == 0 else -0.35)
	body_art.scale.x = facing
	body_art.visible = invulnerable == 0 or fmod(invulnerable, 0.12) > 0.04
	if attack_time > 0:
		attack_time -= delta
		sword.rotation.z = sin(attack_time * 22) * 1.3
		if attack_time < 0.20:
			for enemy in world.enemies:
				if enemy.alive and not enemy in hit_targets and absf(enemy.position.y - position.y) < 1.7:
					var dx: float = enemy.position.x - position.x
					if dx * facing > -0.25 and dx * facing < 2.0:
						var ray = PhysicsRayQueryParameters3D.create(global_position, enemy.global_position, 5)
						var hit = get_world_3d().direct_space_state.intersect_ray(ray)
						if not hit.is_empty() and hit.collider == enemy:
							enemy.take_hit(2 if combo == 3 else 1)
							hit_targets.append(enemy)
	else:
		sword.rotation.z = -0.5
	if position.y < -5:
		fall()

func attack() -> bool:
	if attack_cooldown > 0 or not world.playing:
		return false
	combo = combo % 3 + 1 if combo_wait > 0 else 1
	combo_wait = 0.8
	attack_time = 0.3
	attack_cooldown = 0.34
	hit_targets.clear()
	world.tone(260 + combo * 80, 0.07)
	return true

func cast() -> bool:
	if cast_cooldown > 0 or magic < bolt_cost or not world.playing:
		return false
	magic -= bolt_cost
	regen_wait = regen_delay
	cast_cooldown = 0.28
	world.spawn_bolt(position + Vector3(facing * 0.7, 0.1, 0), facing, true)
	world.tone(620, 0.1)
	return true

func damage(amount: int) -> bool:
	if invulnerable > 0 or not world.playing:
		return false
	health = maxi(0, health - amount)
	invulnerable = invulnerability_time
	world.hit_flash = 0.25
	world.tone(110, 0.15)
	if health == 0:
		world.respawn()
	return true

func fall() -> void:
	if damage(1) and health > 0:
		position = safe_position + Vector3(0, 0.15, 0)
		velocity = Vector3.ZERO
	elif invulnerable > 0:
		position = safe_position + Vector3(0, 0.15, 0)
		velocity = Vector3.ZERO

func restore_at(pos: Vector3) -> void:
	position = pos
	safe_position = pos
	velocity = Vector3.ZERO
	health = max_health
	magic = max_magic
	invulnerable = invulnerability_time
	attack_time = 0
	attack_cooldown = 0
	combo_wait = 0
	combo = 0
	cast_cooldown = 0
	jump_buffer = 0
