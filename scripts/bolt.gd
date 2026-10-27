extends Node3D
const Art = preload("res://scripts/shapes.gd")
var world: Node3D
var direction = 1.0
var friendly = true
var life = 2.0

func _ready() -> void:
	Art.orb(self, Vector3.ZERO, 0.16 if friendly else 0.23,
		Color("53d9fa") if friendly else Color("e7a068"), 1)

	if friendly:
		for i in 4:
			Art.orb(self,Vector3(-direction*(i+1)*.14,0,0),.1-i*.018,Color("53bcea"),.7)

func _physics_process(delta: float) -> void:
	if not world.playing:
		return
	if not friendly and position.x < 9.5:
		queue_free()
		return
	life -= delta
	var next = position + Vector3(direction * (13 if friendly else 6) * delta, 0, 0)
	var query = PhysicsRayQueryParameters3D.create(global_position, world.to_global(next), 21 if friendly else 3)
	var hit = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var target: Object = hit.collider
		if friendly and target.has_method("take_hit"):
			target.take_hit(1)
		elif friendly and target.has_meta("crystal"):
			world.attune_mechanism(0)
		elif not friendly and target == world.player:
			world.player.damage(1)
		queue_free()
	position = next
	if life <= 0:
		queue_free()
