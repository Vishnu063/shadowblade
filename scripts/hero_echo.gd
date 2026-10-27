extends Node3D
## A brief defeat pose at the impact point preserves immediate checkpoint recovery.
const Motion = preload("res://scripts/hero_motion.gd")
var world: Node3D
var facing = 1.0
var elapsed = 0.0
var body: Node3D
var motion: RefCounted
func _ready() -> void:
	body = load("res://assets/slice3d/kael-guardian-skinned.glb").instantiate() if world.has_meta("guardian_3d") else load("res://scripts/image_puppet.gd").hero()
	add_child(body)
	body.scale.x = facing
	body.rotation.y = .65*facing if world.has_meta("guardian_3d") else 0.0
	motion = load("res://scripts/skinned_motion.gd").new(body) if world.has_meta("guardian_3d") else Motion.new(body)
	motion.player.play("defeat")
	motion.player.advance(0)
func _process(delta: float) -> void:
	if not world.playing: return
	elapsed += delta
	motion.player.advance(delta)
	for node in body.find_children("*","GeometryInstance3D",true,false):
		node.transparency = clampf((elapsed-.45)/.3,0,1)
	if elapsed >= .75: queue_free()
