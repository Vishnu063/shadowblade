extends RefCounted
## Presentation-only scenery. Gameplay colliders remain in world.gd.
const Art = preload("res://scripts/shapes.gd")
static var stone_material: StandardMaterial3D

static func model(parent: Node3D, id: String, pos: Vector3, scale_value: Vector3 = Vector3.ONE) -> Node3D:
	var visual: Node3D = load("res://assets/models/" + id + ".tscn").instantiate()
	parent.add_child(visual)
	visual.position = pos
	visual.scale = scale_value
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
	for i in 14:
		if i in [6, 7, 8, 9]:
			continue
		var tree = model(parent, "alder", Vector3(-18 + i * 6.7, -0.6, -12 - (i % 3)), Vector3.ONE * (1.3 + (i % 3) * 0.18))
		tree.rotation_degrees.y = i * 47
	for i in 13:
		if i in [5, 6, 7, 8]:
			continue
		var tree = model(parent, "alder", Vector3(-12 + i * 6.3, -0.2, -5.8 - (i % 2) * 1.6), Vector3.ONE * (0.78 + (i % 3) * 0.13))
		tree.rotation_degrees.y = i * 31
	for x in [17, 34, 49, 59]:
		model(parent, "ruin_arch", Vector3(x, -0.2, -4.5), Vector3.ONE * (1.1 if x == 49 else 1))
	for i in 19:
		model(parent, "fir", Vector3(-9 + i * 3.8, -1.1, -10 - (i % 3)), Vector3.ONE * (0.75 + (i % 4) * 0.13))
	model(parent, "castle", Vector3(35, -3.5, -24), Vector3.ONE * 0.65)
	model(parent, "waterfall", Vector3(28.5, 0, -3.2))

static func terrain(parent: Node3D, x: float, y: float, width: float, height: float) -> void:
	var body = Art.solid(parent, Vector3(x, y - height / 2, 0), Vector3(width, height, 3), Color("465b56"))
	body.get_child(0).visible = false
	var depth = maxf(height, 1.8) if y == 0 else height
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count = maxi(2, int(width / 2.1))
	for i in count:
		var left = x - width / 2 + float(i) / count * width
		var right = x - width / 2 + float(i + 1) / count * width
		var bottom = y - depth + sin(i * 3.7) * 0.14
		var mid_y = y - depth * (0.32 + 0.06 * sin(i * 4.1))
		var mid = Vector3(lerpf(left, right, 0.48), mid_y, 1.59 + sin(i * 8.0) * 0.08)
		var a = Vector3(left, y - 0.13, 1.5)
		var b = Vector3(right, y - 0.13, 1.5)
		var c = Vector3(right, bottom, 1.4)
		var d = Vector3(left, bottom, 1.4)
		triangle(st, a, mid, b, Color("778581").lightened(sin(i * 3.1) * 0.08))
		triangle(st, b, mid, c, Color("617375"))
		triangle(st, c, mid, d, Color("485d63"))
		triangle(st, d, mid, a, Color("63787a"))
		# Keep the bright top edge exactly aligned with the physical platform.
		triangle(st, Vector3(left, y, 1.53), Vector3(right, y, -1.5), Vector3(left, y, -1.5), Color("65894e"))
		triangle(st, Vector3(left, y, 1.53), Vector3(right, y, 1.53), Vector3(right, y, -1.5), Color("65894e"))
		var notch = y - 0.14 - (i % 3) * 0.035
		triangle(st, Vector3(left, y + 0.015, 1.54), Vector3(left, notch, 1.56), Vector3(right, notch - 0.04, 1.56), Color("799e5a"))
		triangle(st, Vector3(left, y + 0.015, 1.54), Vector3(right, notch - 0.04, 1.56), Vector3(right, y + 0.015, 1.54), Color("799e5a"))
		if i % 2 == 0:
			for leaf in 5:
				var vx = left + 0.15 + sin(leaf * 1.7) * 0.07
				var vy = y - 0.15 - leaf * 0.13
				triangle(st, Vector3(vx, vy, 1.64), Vector3(vx - 0.14, vy + 0.04, 1.64), Vector3(vx - 0.04, vy - 0.15, 1.64), Color("527849"))
		# Sparse foreground blades and flowers are baked into this mesh.
		for j in 3:
			var gx = lerpf(left, right, 0.2 + j * 0.24)
			var h = 0.10 + (i % 3) * 0.045
			triangle(st, Vector3(gx - 0.04, y, 1.1), Vector3(gx + 0.03, y, 1.1), Vector3(gx - 0.08, y + h, 1.1), Color("7f9d69"))
			if i % 4 == 0 and j == 1:
				triangle(st, Vector3(gx - 0.05, y + h, 1.13), Vector3(gx + 0.05, y + h, 1.13), Vector3(gx, y + h + 0.08, 1.13), Color("e0c686"))
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
