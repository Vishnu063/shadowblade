extends RefCounted
## Presentation-only scenery. Gameplay colliders remain in world.gd.
const Art = preload("res://scripts/shapes.gd")
static var stone_material: StandardMaterial3D

static func model(parent: Node3D, id: String, pos: Vector3, scale_value: Vector3 = Vector3.ONE) -> Node3D:
	var replacements = {"fern": "fern", "alder": "oak", "cottage": "cottage", "ruin_arch": "ruin"}
	var path = "res://assets/forest/" + replacements[id] + ".glb" if replacements.has(id) else "res://assets/models/" + id + ".tscn"
	var visual: Node3D = load(path).instantiate()
	parent.add_child(visual)
	visual.position = pos
	visual.scale = scale_value
	if id == "alder":
		for geometry in visual.find_children("*", "MeshInstance3D", true, false):
			geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if id == "waterfall":
		for child in visual.get_children():
			if child is MeshInstance3D and child.name not in ["Flow", "Pool"]:
				child.visible = false
		visual.get_node("Pool").material_override = visual.get_node("Pool").material_override.duplicate()
		visual.get_node("Pool").material_override.set_shader_parameter("horizontal", true)
		for side in [-1, 1]:
			for i in 7:
				var rock = load("res://assets/forest/stone.glb").instantiate()
				visual.add_child(rock)
				rock.position = Vector3(side * (2.8 + sin(i * 3.2 + side) * .16), i * .72, -.35)
				rock.scale = Vector3(3.4 + sin(i * 2.3) * .2, 3.0, 2.3)
				rock.rotation = Vector3(.12 * sin(i), i * 1.17, sin(i * 1.9 + side) * .22)
		var particles = CPUParticles3D.new()
		particles.amount = 16
		particles.lifetime = 2.2
		particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		particles.emission_box_extents = Vector3(.9,.1,.1)
		particles.direction = Vector3.UP
		particles.spread = 35
		particles.gravity = Vector3(0,.06,0)
		particles.initial_velocity_min = .25
		particles.initial_velocity_max = .55
		particles.scale_amount_min = .65
		particles.scale_amount_max = 1.4
		var quad = QuadMesh.new()
		quad.size = Vector2(1,1)
		var texture = GradientTexture2D.new()
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(.5,.5)
		texture.fill_to = Vector2(1,.5)
		texture.gradient = Gradient.new()
		texture.gradient.colors = PackedColorArray([Color(1,1,1,.13),Color(1,1,1,0)])
		var material = StandardMaterial3D.new()
		material.albedo_texture = texture
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		quad.material = material
		particles.mesh = quad
		visual.add_child(particles)
		particles.position = Vector3(0,.25,.6)
	return visual

static func triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, color: Color) -> void:
	var normal = (b - a).cross(c - a).normalized()
	for point in [a, c, b]:
		st.set_normal(normal)
		st.set_color(color.srgb_to_linear())
		st.add_vertex(point)

static func vertex_material() -> StandardMaterial3D:
	if stone_material == null:
		stone_material = StandardMaterial3D.new()
		stone_material.vertex_color_use_as_albedo = true
		stone_material.vertex_color_is_srgb = false
		stone_material.roughness = 0.95
	return stone_material

static func surface(parent: Node3D, st: SurfaceTool, pos: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var visual = MeshInstance3D.new()
	visual.mesh = st.commit()
	visual.material_override = vertex_material()
	parent.add_child(visual)
	visual.position = pos
	return visual

static func backdrop(parent: Node3D) -> void:
	Art.box(parent, Vector3(25, -2.6, -11), Vector3(105, 3.2, 17), Color("3c5c50"))
	for layer in 3:
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var z = -32.0 + layer * 7
		var color = Color(["a0bac4", "86a6b0", "668d94"][layer])
		for i in 30:
			var x = -55.0 + i * 7
			var y1 = -3.5 - layer * 1.5 + sin(i * 1.71 + layer) * (3.3 - layer * 0.7)
			var y2 = -3.5 - layer * 1.5 + sin((i + 1) * 1.71 + layer) * (3.3 - layer * 0.7)
			triangle(st, Vector3(x, -9, z), Vector3(x + 7, -9, z), Vector3(x + 7, y2, z), color)
			triangle(st, Vector3(x, -9, z), Vector3(x + 7, y2, z), Vector3(x, y1, z), color)
		var visual = surface(parent, st)
		visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in 8:
		if i in [6, 7, 8, 9]:
			continue
		var tree = model(parent, "alder", Vector3(-14 + i * 10.2, -0.6, -12 - (i % 3)), Vector3.ONE * (1.3 + (i % 3) * 0.18))
		tree.rotation_degrees.y = i * 47
	for i in 9:
		if i in [5, 6, 7, 8]:
			continue
		var tree = model(parent, "alder", Vector3(-12 + i * 9.0, -0.2, -5.8 - (i % 2) * 1.6), Vector3.ONE * (0.78 + (i % 3) * 0.13))
		tree.rotation_degrees.y = i * 31
	for x in [17, 34, 49, 59]:
		model(parent, "ruin_arch", Vector3(x, -0.2, -4.5), Vector3.ONE * (1.1 if x == 49 else 1))
	for i in 9:
		model(parent, "alder", Vector3(-9 + i * 9.0, -2.0, -14 - (i % 3)), Vector3.ONE * (0.55 + (i % 4) * 0.06))
	for x in [19, 39]:
		var framing_tree = model(parent, "alder", Vector3(x, -.2, -3.7), Vector3.ONE * 1.1)
		for geometry in framing_tree.find_children("*", "MeshInstance3D", true, false):
			geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	for i in 32:
		model(parent, "fern", Vector3(-5 + i * 2.1, 0, -.9), Vector3.ONE * (.8 + (i % 3) * .15))
	model(parent, "castle", Vector3(35, -3.5, -24), Vector3.ONE * 0.65)
	model(parent, "waterfall", Vector3(28.5, 0, -3.2))

static func terrain(parent: Node3D, x: float, y: float, width: float, height: float) -> void:
	var body = Art.solid(parent, Vector3(x, y - height / 2, 0), Vector3(width, height, 3), Color("465b56"))
	body.get_child(0).visible = false
	var source = load("res://assets/forest/stone.glb").instantiate()
	var rock_mesh: Mesh = source.find_children("*", "MeshInstance3D", true, false)[0].mesh
	var rocks = MultiMesh.new()
	rocks.transform_format = MultiMesh.TRANSFORM_3D
	rocks.mesh = rock_mesh
	rocks.use_colors = true
	var count = maxi(2, int(ceil(width / 0.7)))
	var layers = 2 if y == 0 else 1
	rocks.instance_count = count * layers
	var step = width / count
	for row in layers:
		for i in count:
			var scale_value = Vector3(step * (1.55 + .16 * sin(i * 5.1)), (1.0 + .08 * sin(i * 2.3)) if y == 0 else height / .72, 0.9)
			var basis = Basis(Vector3.UP, sin(i * 2.7 + row) * 0.12).scaled(scale_value)
			var pos = Vector3(x - width / 2 + (i + .5 + sin(i * 4.7 + row) * .12) * step, y - (.34 if y == 0 else height / 2) - row * .43 + sin(i * 3.3) * .015, 1.0)
			rocks.set_instance_transform(row * count + i, Transform3D(basis, pos))
			var shade = .86 + sin(i * 3.4 + row) * .12
			rocks.set_instance_color(row * count + i, Color(shade,shade,shade,1))
	var rock_instances = MultiMeshInstance3D.new()
	rock_instances.multimesh = rocks
	parent.add_child(rock_instances)
	source.free()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Exact collision-aligned paving surface; irregular stones form the fascia below it.
	for i in count:
		var left = x - width / 2 + i * step
		var right = left + step
		triangle(st, Vector3(left,y,1.5),Vector3(right,y,-1.5),Vector3(left,y,-1.5),Color("72825a"))
		triangle(st, Vector3(left,y,1.5),Vector3(right,y,1.5),Vector3(right,y,-1.5),Color("72825a"))
		for j in 12:
			var gx = left + step * (j + 0.5) / 12
			var h = 0.06 + absf(sin(i * 27.3 + j * 9.2)) * 0.12
			var z = 1.15 + sin(j * 7.1) * 0.15
			triangle(st,Vector3(gx-.025,y,z),Vector3(gx+.025,y,z),Vector3(gx-.04,y+h,z),Color("4c722e"))
		if i % 2 == 0:
			for leaf in 9:
				var vx = left + 0.17 + sin(leaf * 1.4) * 0.06
				var vy = y - leaf * 0.085
				triangle(st,Vector3(vx,vy,1.51),Vector3(vx-.09,vy+.025,1.53),Vector3(vx-.03,vy-.10,1.53),Color("466d29"))
	surface(parent, st)

static func rune(parent: Node3D, pos: Vector3, color: Color) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var size = Vector3(0.28, 0.48, 0.21)
	for i in 6:
		var a = Vector3(cos(i * TAU / 6) * size.x, 0, sin(i * TAU / 6) * size.z)
		var b = Vector3(cos((i + 1) * TAU / 6) * size.x, 0, sin((i + 1) * TAU / 6) * size.z)
		triangle(st, a, Vector3(0, size.y, 0), b, Color.WHITE)
		triangle(st, b, Vector3(0, -size.y, 0), a, Color(0.7, 0.8, 1))
	var visual = surface(parent, st, pos)
	visual.material_override = Art.material(color, 0.6)
	return visual
