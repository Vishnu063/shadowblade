extends RefCounted
## Deterministic, presentation-only forest layers. No physics or quest state.
const Art = preload("res://scripts/shapes.gd")
static var rock_material: ShaderMaterial

static func stone_material() -> ShaderMaterial:
	if rock_material == null:
		rock_material = ShaderMaterial.new()
		rock_material.shader = preload("res://assets/shaders/forest_stone.gdshader")
	return rock_material

static func stone(parent: Node3D, pos: Vector3, size: Vector3, turn: float) -> Node3D:
	var instance = preload("res://assets/forest/stone.glb").instantiate()
	parent.add_child(instance)
	instance.position = pos
	instance.scale = size
	instance.rotation = Vector3(.12 * sin(turn), turn, .1 * cos(turn * 2))
	for geometry in instance.find_children("*", "MeshInstance3D", true, false):
		geometry.material_override = stone_material()
	return instance

static func mountain(parent: Node3D, origin: Vector3, width: float, height: float, color: Color) -> void:
	var mesh = SurfaceTool.new()
	mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	var peaks = [Vector2(-.5,0),Vector2(-.36,.34),Vector2(-.22,.28),Vector2(-.03,1),Vector2(.1,.67),Vector2(.23,.78),Vector2(.5,0)]
	for i in peaks.size() - 1:
		var a = Vector3(peaks[i].x*width,peaks[i].y*height,0)
		var b = Vector3(peaks[i+1].x*width,peaks[i+1].y*height,0)
		for point in [Vector3(a.x, -10, 0),a,b,Vector3(a.x,-10,0),b,Vector3(b.x,-10,0)]:
			mesh.add_vertex(point)
	var visual = MeshInstance3D.new()
	visual.mesh = mesh.commit()
	var material = Art.material(color)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	visual.material_override = material
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(visual)
	visual.position = origin

static func forest_row(parent: Node3D, count: int, start: float, spacing: float, depth: float, tint: Color) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for level in 4:
		var radius = .16-level*.025
		var base = .06+level*.19
		for segment in 9:
			var angle = segment*TAU/9
			var next = (segment+1)*TAU/9
			var a = Vector3(cos(angle)*radius,base,sin(angle)*radius)
			var b = Vector3(cos(next)*radius,base,sin(next)*radius)
			var tip = Vector3(0,base+.4,0)
			var normal = (tip-a).cross(b-a).normalized()
			for point in [a,tip,b]:
				st.set_normal(normal)
				st.add_vertex(point)
	var mesh = st.commit()
	var material = Art.material(tint)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.surface_set_material(0,material)
	var instances = MultiMesh.new()
	instances.transform_format = MultiMesh.TRANSFORM_3D
	instances.use_colors = true
	instances.mesh = mesh
	instances.instance_count = count
	for i in count:
		var height = 1.6+absf(sin(i*7.1))*2.0
		instances.set_instance_transform(i,Transform3D(Basis().scaled(Vector3.ONE*height),Vector3(start+i*spacing,-1.7,depth-sin(i)*1.2)))
		var shade = .78+absf(sin(i*2.1))*.22
		instances.set_instance_color(i,Color(shade,shade,shade,1))
	var visual = MultiMeshInstance3D.new()
	visual.multimesh = instances
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(visual)

static func layers(parent: Node3D) -> void:
	# Taller silhouettes occupy the formerly empty horizon; spacing is world-fixed.
	for i in 12:
		mountain(parent,Vector3(-36+i*12,-3,-35),25,8+sin(i*2.8)*3,Color("a0bdc8"))
	for i in 12:
		mountain(parent,Vector3(-28+i*11,-4,-27),21,5+sin(i*1.8)*2,Color("7298a0"))
	forest_row(parent,65,-20,1.6,-19,Color("477578"))
	forest_row(parent,39,-18,2.5,-10.5,Color("305952"))

static func undergrowth(parent: Node3D) -> void:
	# One instanced mesh for hundreds of leaves; no collision, no per-frame script.
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for blade in 6:
		var angle = blade*TAU/6
		var end = Vector3(cos(angle)*.28,.14+blade*.013,sin(angle)*.28)
		var side = Vector3(-sin(angle),0,cos(angle))*.065
		for point in [Vector3.ZERO,end*.6+side,end,Vector3.ZERO,end,end*.6-side]:
			st.set_normal(Vector3.UP)
			st.add_vertex(point)
	var mesh = st.commit()
	var material = Art.material(Color("547d29"))
	material.vertex_color_use_as_albedo = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.surface_set_material(0,material)
	var instances = MultiMesh.new()
	instances.transform_format = MultiMesh.TRANSFORM_3D
	instances.use_colors = true
	instances.mesh = mesh
	instances.instance_count = 220
	for i in 220:
		var x = -9+fmod(i*1.731,69)
		# Leave the actual pit open visually, matching the unchanged collider gap.
		if x > 15.8 and x < 19.2:
			instances.set_instance_transform(i,Transform3D(Basis().scaled(Vector3.ZERO),Vector3.ZERO))
			continue
		var size = .4+absf(sin(i*7.3))*.65
		var basis = Basis(Vector3.UP,i*2.3).scaled(Vector3.ONE*size)
		instances.set_instance_transform(i,Transform3D(basis,Vector3(x,.015,-.75+sin(i*3.7)*.65)))
		instances.set_instance_color(i,Color(.65+absf(sin(i))*.35,.8+sin(i)*.15,.65,1))
	var visual = MultiMeshInstance3D.new()
	visual.multimesh = instances
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(visual)
	# A second batched mesh gives warm flower clusters without many draw calls.
	var flower_mesh = SphereMesh.new()
	flower_mesh.radius = .045
	flower_mesh.height = .07
	flower_mesh.radial_segments = 6
	flower_mesh.rings = 3
	flower_mesh.material = Art.material(Color("f2dca3"))
	var flowers = MultiMesh.new()
	flowers.transform_format = MultiMesh.TRANSFORM_3D
	flowers.use_colors = true
	flowers.mesh = flower_mesh
	flowers.instance_count = 150
	for i in 150:
		var cluster = i / 5
		var x = -7+cluster*2.2
		var petal = i % 5
		var origin = Vector3(x+cos(petal*TAU/5)*.055,.25,-.65+sin(petal*TAU/5)*.055)
		var basis = Basis.IDENTITY
		if x > 15.7 and x < 19.3:
			basis = basis.scaled(Vector3.ZERO)
		flowers.set_instance_transform(i,Transform3D(basis,origin))
		flowers.set_instance_color(i,Color(1,.9+sin(cluster)*.1,.8,1))
	var flower_visual = MultiMeshInstance3D.new()
	flower_visual.multimesh = flowers
	flower_visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(flower_visual)
