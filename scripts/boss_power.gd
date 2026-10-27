extends Node3D
## Each regional guardian has a distinct telegraphed attack. No physics colliders.
const Art = preload("res://scripts/shapes.gd")
const Campaign = preload("res://scripts/campaign.gd")
var world: Node3D
var caster: Node3D
var power = 0
var elapsed = 0.0
var warning_time = .8
var spent = false
var direction = 1.0
var visual: Node3D
var marker: MeshInstance3D
const TITLES = ["THORN SNARE","MAGMA ERUPTION","ICE PRISON","CYCLONE DIVE","THUNDER STRIKE","SHADOW RIFT"]
const COLORS = [Color("68cf76"),Color("ff8739"),Color("92def6"),Color("85e5c5"),Color("c3a1ff"),Color("b67aed")]
func _ready() -> void:
	set_meta("encounter_effect",true)
	visual = Node3D.new()
	add_child(visual)
	var ring = TorusMesh.new()
	ring.inner_radius = .85
	ring.outer_radius = 1.0
	ring.rings = 24
	ring.ring_segments = 6
	marker = MeshInstance3D.new()
	marker.mesh = ring
	marker.material_override = Art.material(COLORS[power],.8)
	marker.position.y = -.02
	add_child(marker)
	var caption = Art.label(self,Vector3(0,.35,0),TITLES[power],COLORS[power])
	caption.font_size = 22
	caption.pixel_size = .006
	for i in (7 if power in [0,2] else 5):
		var angle = i*TAU/7
		if power in [0,2]:
			var spike = MeshInstance3D.new()
			var mesh = CylinderMesh.new()
			mesh.top_radius = 0
			mesh.bottom_radius = .09 if power == 0 else .14
			mesh.height = .8 if power == 0 else 1.15
			mesh.radial_segments = 5
			spike.mesh = mesh
			spike.material_override = Art.material(COLORS[power],.5)
			visual.add_child(spike)
			spike.position = Vector3(cos(angle)*.65,.4,sin(angle)*.25)
		else:
			var orb = Art.orb(visual,Vector3(sin(angle)*.6,.3+i*.18,0),.16,COLORS[power],1)
			orb.scale = Vector3(.6,2.0,.6) if power == 1 else Vector3(1,1,1)
	visual.visible = false
func _physics_process(delta: float) -> void:
	if not is_instance_valid(world) or not is_instance_valid(caster) or not caster.alive:
		queue_free()
		return
	if not world.playing: return
	elapsed += delta
	if elapsed < warning_time:
		marker.scale = Vector3.ONE*(.8+.15*sin(elapsed*18))
		return
	visual.visible = true
	marker.visible = false
	visual.scale.y = minf(1,(elapsed-warning_time)*12)
	if power == 3: position.x += direction*7*delta
	if power == 4:
		visual.scale = Vector3(.3,3.5,.3)
	elif power == 5:
		visual.rotation.z += delta*4
		visual.scale.x = 1.6
	var hero = world.player
	var distance: Vector3 = hero.global_position-global_position
	var range_x = 1.2 if power == 5 else .85
	var high = 4.0 if power == 4 else 1.25
	if not spent and absf(distance.x) < range_x and distance.y < high and distance.y > -.5 and world.clear_line(global_position+Vector3(0,.4,0),hero,3):
		spent = true
		if hero.damage(1):
			if power in [0,2]: hero.slow_time = .8 if power == 0 else 1.2
			if power == 3: hero.velocity.x = direction*10
	if elapsed >= warning_time + (.6 if power != 3 else .8): queue_free()
