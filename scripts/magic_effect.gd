extends Node3D
const Art = preload("res://scripts/shapes.gd")
var world: Node3D
var color = Color.WHITE
var radius = 1.0
var target = Vector3.ZERO
var beam = false
var elapsed = 0.0
func _ready() -> void:
	var visual = MeshInstance3D.new()
	if beam:
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var direction = target-global_position
		var side = Vector3(-direction.y,direction.x,0).normalized()*.055
		for point in [-side,side,direction+side,-side,direction+side,direction-side]: st.add_vertex(point)
		visual.mesh = st.commit()
	else:
		var ring = TorusMesh.new()
		ring.inner_radius = radius*.9
		ring.outer_radius = radius
		ring.rings = 24
		ring.ring_segments = 6
		visual.mesh = ring
		visual.rotation_degrees.x = 90
	visual.material_override = Art.material(color,1.3)
	visual.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visual.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	add_child(visual)
func _process(delta: float) -> void:
	if not is_instance_valid(world) or not world.playing: return
	elapsed += delta
	if not beam: scale = Vector3.ONE*(.45+elapsed)
	if elapsed >= .5: queue_free()
