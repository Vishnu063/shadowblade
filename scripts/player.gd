extends CharacterBody3D
const Art = preload("res://scripts/shapes.gd")
const Campaign = preload("res://scripts/campaign.gd")
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
var legs: Array[Node3D] = []
var stride = 0.0
var pose_clock = 0.0
var sword: Node3D
var left_arm: Node3D
var right_arm: Node3D
var cape: Node3D
var dash_time = 0.0
var dash_used = false
var shield_time = 0.0
var shield_hits = 0
var shield_visual: MeshInstance3D
var last_grounded = true
var landing_bounce = 0.0

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var col = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = 0.28
	shape.height = 1.6
	col.shape = shape
	add_child(col)
	body_art = preload("res://assets/forest/kael-v2.glb").instantiate()
	add_child(body_art)
	legs = [body_art.find_child("LeftLeg"), body_art.find_child("RightLeg")]
	left_arm = body_art.find_child("LeftArm")
	right_arm = body_art.find_child("SwordArm")
	sword = body_art.find_child("Sword")
	shield_visual = MeshInstance3D.new()
	var shield_mesh = SphereMesh.new()
	shield_mesh.radius = .92
	shield_mesh.height = 2.1
	shield_mesh.radial_segments = 20
	shield_mesh.rings = 10
	shield_visual.mesh = shield_mesh
	var material = Art.material(Color(1,.77,.3,.16),.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shield_visual.material_override = material
	shield_visual.visible = false
	add_child(shield_visual)

func request_jump() -> void:
	jump_buffer = jump_buffer_time

func _physics_process(delta: float) -> void:
	if world == null or not world.playing:
		return
	shield_time = maxf(0,shield_time-delta)
	shield_visual.visible = shield_time > 0 and shield_hits > 0
	dash_time = maxf(0,dash_time-delta)
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
		dash_used = false
		coyote = coyote_time
		if position.y > 0.7 and stable_ground():
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
	if dash_time > 0:
		velocity.x = facing*19
		velocity.y = 0
	move_and_slide()
	if dash_time > 0 and is_on_wall(): dash_time = 0
	if is_on_floor() and not last_grounded:
		landing_bounce = 0.12
	landing_bounce = maxf(0, landing_bounce - delta)
	last_grounded = is_on_floor()
	pose_clock += delta
	body_art.position.y = sin(pose_clock * 2.2) * 0.007 - sin(landing_bounce / 0.12 * PI) * 0.08
	stride += delta * absf(velocity.x) * 2.5
	for i in legs.size():
		legs[i].rotation.z = sin(stride + i * PI) * minf(absf(velocity.x) * 0.08, 0.5) if is_on_floor() else (0.35 if i == 0 else -0.35)
	for i in legs.size():
		var knee = legs[i].find_child("Knee")
		if knee != null:
			knee.rotation.z = maxf(0, sin(stride + i * PI + 0.8)) * minf(absf(velocity.x) * 0.10, 0.65) if is_on_floor() else 0.45
	left_arm.rotation.z = -sin(stride) * minf(absf(velocity.x) * 0.07, 0.45)
	right_arm.rotation.z = sword.rotation.z * 0.45 if attack_time > 0 else sin(stride) * 0.1
	body_art.find_child("Scarf").rotation.z = sin(stride * 0.4) * 0.12
	body_art.rotation.z = -velocity.x * 0.008
	body_art.rotation.y = .65*facing
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

func stable_ground() -> bool:
	# Both sides of the capsule need support before replacing the pit recovery point.
	for offset in [-0.35, 0.35]:
		var from = global_position + Vector3(offset, -0.6, 0)
		var to = global_position + Vector3(offset, -1.1, 0)
		var hit = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 1))
		if hit.is_empty() or hit.collider.has_meta("temporary_platform"):
			return false
	return true

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

func spell_cost() -> float:
	return Campaign.COSTS[int(Progress.data.selected_power)]
func select_power(index: int) -> bool:
	if not Progress.data.powers.has(index): return false
	Progress.data.selected_power = index
	return true
func cast() -> bool:
	var index = int(Progress.data.selected_power)
	var cost = spell_cost()
	if cast_cooldown > 0 or magic < cost or not world.playing: return false
	if index == 3 and dash_used: return false
	if not world.cast_power(index): return false
	magic -= cost
	regen_wait = regen_delay
	cast_cooldown = Campaign.COOLDOWNS[index]
	world.tone(620+index*80,.1)
	return true

func damage(amount: int, bypass_shield: bool = false) -> bool:
	if invulnerable > 0 or not world.playing:
		return false
	if not bypass_shield and shield_time > 0 and shield_hits > 0:
		shield_hits -= 1
		invulnerable = .35
		world.tone(900,.08)
		return false
	health = maxi(0, health - amount)
	invulnerable = invulnerability_time
	world.hit_flash = 0.25
	world.tone(110, 0.15)
	if health == 0:
		world.respawn()
	return true

func fall() -> void:
	if damage(1,true) and health > 0:
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
	dash_time = 0
	dash_used = false
	shield_time = 0
	shield_hits = 0
	shield_visual.visible = false
	jump_buffer = 0
