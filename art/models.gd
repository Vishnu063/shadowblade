extends RefCounted
## Source of the original Willowbrook art. Build script packs reusable editable scenes.
## No third-party geometry, textures or reference-game assets.
static var palette: Dictionary = {}

static func mat(hex: String, glow: float = 0.0) -> StandardMaterial3D:
	var key = hex + str(glow)
	if palette.has(key):
		return palette[key]
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(hex)
	m.roughness = 0.86
	m.vertex_color_use_as_albedo = true
	m.vertex_color_is_srgb = false
	if glow > 0:
		m.emission_enabled = true
		m.emission = Color(hex)
		m.emission_energy_multiplier = glow
	palette[key] = m
	return m

static func node(parent: Node3D, name: String, pos: Vector3 = Vector3.ZERO) -> Node3D:
	var n = Node3D.new()
	n.name = name
	parent.add_child(n)
	n.position = pos
	return n

static func mesh(parent: Node3D, name: String, geometry: Mesh, pos: Vector3, color: String, glow: float = 0.0) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	n.name = name
	n.mesh = geometry
	n.material_override = mat(color, glow)
	parent.add_child(n)
	n.position = pos
	return n

static func box(parent: Node3D, name: String, pos: Vector3, size: Vector3, color: String) -> MeshInstance3D:
	var b = BoxMesh.new()
	b.size = size
	return mesh(parent, name, b, pos, color)

static func cylinder(parent: Node3D, name: String, pos: Vector3, height: float, bottom: float, top: float, color: String, sides: int = 7) -> MeshInstance3D:
	var m = CylinderMesh.new()
	m.height = height
	m.bottom_radius = bottom
	m.top_radius = top
	m.radial_segments = sides
	m.rings = 1
	return mesh(parent, name, m, pos, color)

static func triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, color: Color = Color.WHITE) -> void:
	var normal = (b - a).cross(c - a).normalized()
	for v in [a, c, b]:
		st.set_normal(normal)
		st.set_color(color)
		st.add_vertex(v)

static func rock(parent: Node3D, name: String, pos: Vector3, size: Vector3, color: String, seed_value: float = 0.0) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: Array = []
	for j in 4:
		var points: Array[Vector3] = []
		for i in 7:
			var angle = i * TAU / 7 + (j % 2) * 0.1
			var radius: float = [0.7, 1.0, 0.85, 0.22][j] * (1 + sin(i * 9.1 + seed_value * 2.4 + j) * 0.12)
			points.append(Vector3(cos(angle) * radius * 0.5, [-0.5, -0.15, 0.35, 0.52][j], sin(angle) * radius * 0.5) * size)
		rings.append(points)
	for j in 3:
		for i in 7:
			var k = (i + 1) % 7
			var shade = Color.WHITE * (0.84 + 0.16 * sin(i * 3.0 + j + seed_value))
			shade.a = 1
			triangle(st, rings[j][i], rings[j + 1][i], rings[j + 1][k], shade)
			triangle(st, rings[j][i], rings[j + 1][k], rings[j][k], shade)
	for i in 7:
		triangle(st, Vector3(0, size.y * 0.52, 0), rings[3][(i + 1) % 7], rings[3][i])
		triangle(st, Vector3(0, -size.y * 0.5, 0), rings[0][i], rings[0][(i + 1) % 7])
	return mesh(parent, name, st.commit(), pos, color)

static func gem(parent: Node3D, name: String, pos: Vector3, size: Vector3, color: String) -> MeshInstance3D:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 6:
		var a = Vector3(cos(i * TAU / 6) * size.x, 0, sin(i * TAU / 6) * size.z)
		var b = Vector3(cos((i + 1) * TAU / 6) * size.x, 0, sin((i + 1) * TAU / 6) * size.z)
		triangle(st, a, Vector3(0, size.y, 0), b)
		triangle(st, b, Vector3(0, -size.y * 0.7, 0), a, Color(0.7, 0.85, 1))
	return mesh(parent, name, st.commit(), pos, color, 0.45)

static func hero(tunic: String = "294c69", cape_color: String = "2469ad") -> Node3D:
	var root = Node3D.new()
	root.name = "Kael"
	cylinder(root, "Tunic", Vector3(0, -0.04, 0), 0.64, 0.28, 0.23, tunic, 8)
	cylinder(root, "Collar", Vector3(0, 0.29, 0), 0.12, 0.24, 0.19, "286fbb", 8)
	cylinder(root, "Belt", Vector3(0, -0.24, 0), 0.10, 0.29, 0.28, "443832", 8)
	box(root, "Buckle", Vector3(0, -0.22, 0.27), Vector3(0.12, 0.1, 0.05), "d4ad62")
	rock(root, "Head", Vector3(0, 0.49, 0.015), Vector3(0.43, 0.43, 0.39), "dbaf86", 0.8)
	cylinder(root, "Hair", Vector3(0, 0.67, -0.02), 0.21, 0.245, 0.15, "302d35", 7)
	for i in 5:
		var lock = gem(root, "HairLock%d" % i, Vector3(-0.16 + i * 0.075, 0.61 - (i % 2) * 0.04, 0.17), Vector3(0.075, 0.12, 0.05), "302d35")
		lock.rotation_degrees.z = -20
	for x in [-0.1, 0.1]:
		box(root, "Eye", Vector3(x, 0.5, 0.205), Vector3(0.055, 0.04, 0.018), "243443")
	box(root, "Nose", Vector3(0.05, 0.44, 0.22), Vector3(0.07, 0.07, 0.07), "c99170")
	var scarf = node(root, "Scarf", Vector3(-0.1, 0.3, -0.18))
	var cloth = SurfaceTool.new()
	cloth.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 4:
		var a = Vector3(-i * 0.23, sin(i * 1.6) * 0.08, 0)
		var b = Vector3(-(i + 1) * 0.23, sin((i + 1) * 1.6) * 0.08, 0)
		triangle(cloth, a, b, b + Vector3(0, -0.14, 0))
		triangle(cloth, a, b + Vector3(0, -0.14, 0), a + Vector3(0, -0.14, 0))
	var ribbon = mesh(scarf, "Ribbon", cloth.commit(), Vector3.ZERO, cape_color)
	ribbon.material_override = mat(cape_color).duplicate()
	ribbon.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	for i in 2:
		var side = -1 if i == 0 else 1
		var leg = node(root, "LeftLeg" if i == 0 else "RightLeg", Vector3(side * 0.15, -0.31, 0))
		cylinder(leg, "Trousers", Vector3(0, -0.14, 0), 0.32, 0.09, 0.1, "293b49", 6)
		box(leg, "Boot", Vector3(0.035, -0.37, 0.035), Vector3(0.23, 0.24, 0.29), "433d37")
		box(leg, "BootTrim", Vector3(0, -0.25, 0), Vector3(0.21, 0.08, 0.25), "8e7555")
	var left = node(root, "LeftArm", Vector3(-0.31, 0.18, 0))
	cylinder(left, "Sleeve", Vector3(0, -0.13, 0), 0.26, 0.09, 0.13, "cec7ae")
	cylinder(left, "Bracer", Vector3(0, -0.32, 0), 0.19, 0.10, 0.1, "655747")
	rock(left, "Hand", Vector3(0, -0.45, 0), Vector3.ONE * 0.18, "dbaf86")
	var right = node(root, "SwordArm", Vector3(0.31, 0.18, 0.04))
	rock(right, "Pauldron", Vector3.ZERO, Vector3(0.34, 0.25, 0.4), "aeb7b4")
	cylinder(right, "Sleeve", Vector3(0.08, -0.12, 0), 0.3, 0.09, 0.12, "cec7ae")
	rock(right, "Hand", Vector3(0.13, -0.29, 0), Vector3.ONE * 0.18, "dbaf86")
	var sword = node(root, "Sword", Vector3(0.47, -0.09, 0.08))
	box(sword, "Grip", Vector3(0.03, 0, 0), Vector3(0.22, 0.09, 0.09), "4d4545")
	box(sword, "Guard", Vector3(0.16, 0, 0), Vector3(0.065, 0.31, 0.11), "ceaa62")
	var blade = gem(sword, "Blade", Vector3(0.57, 0, 0), Vector3(0.065, 0.52, 0.025), "62c9fa")
	blade.rotation_degrees.z = -90
	box(sword, "Rune", Vector3(0.47, 0, 0.035), Vector3(0.61, 0.025, 0.02), "88e8ff")
	return root

static func stalker() -> Node3D:
	var root = Node3D.new()
	root.name = "Thornling"
	rock(root, "Shell", Vector3(0, -0.12, 0), Vector3(0.95, 0.7, 0.7), "5d6755", 1.2)
	rock(root, "Mask", Vector3(0.27, 0.02, 0.12), Vector3(0.57, 0.52, 0.53), "99866c", 1.3)
	for side in [-1, 1]:
		for i in 2:
			var leg = node(root, "Leg%d%d" % [side, i], Vector3(-0.29 + i * 0.52, -0.2, side * 0.25))
			var shape = cylinder(leg, "Root", Vector3(0, -0.2, 0), 0.43, 0.07, 0.10, "554e43", 5)
			shape.rotation_degrees.z = 28 * side
		var thorn = gem(root, "Thorn", Vector3(-0.23, 0.38, side * 0.18), Vector3(0.13, 0.4, 0.1), "6f9b68")
		thorn.rotation_degrees.z = -25
		mesh(root, "Eye", SphereMesh.new(), Vector3(0.44, 0.14, side * 0.18), "ffbc64", 0.8).scale = Vector3.ONE * 0.075
	return root

static func wisp() -> Node3D:
	var root = Node3D.new()
	root.name = "VeilMoth"
	gem(root, "Core", Vector3.ZERO, Vector3(0.23, 0.45, 0.22), "c092e0")
	for side in [-1, 1]:
		var wing = node(root, "LeftWing" if side == -1 else "RightWing")
		for i in 3:
			var petal = gem(wing, "Feather%d" % i, Vector3(side * (0.32 + i * 0.13), 0.16 - i * 0.16, 0), Vector3(0.17, 0.4 - i * 0.06, 0.08), "725a9c" if i % 2 else "b2a3cb")
			petal.rotation_degrees.z = side * (-40 + i * 12)
	for i in 3:
		gem(root, "Tail%d" % i, Vector3(-0.08 + i * 0.08, -0.5 - i * 0.14, 0), Vector3(0.10 - i * 0.02, 0.17, 0.07), "866caf")
	for x in [-0.1, 0.1]:
		box(root, "Eye", Vector3(x, 0.07, 0.21), Vector3(0.07, 0.05, 0.04), "fbe7b2")
	return root

static func warden() -> Node3D:
	var root = Node3D.new()
	root.name = "HollowWarden"
	rock(root, "Torso", Vector3(0, -0.08, 0), Vector3(1.35, 1.45, 0.85), "4d6564", 4)
	rock(root, "Mask", Vector3(0, 0.66, 0.1), Vector3(0.66, 0.65, 0.6), "b0a58a", 1)
	gem(root, "HeartRune", Vector3(0, 0.03, 0.46), Vector3(0.18, 0.29, 0.04), "71cdd8")
	for side in [-1, 1]:
		rock(root, "Shoulder", Vector3(side * 0.76, 0.34, 0), Vector3(0.62, 0.58, 0.7), "6a8171", side)
		var arm = node(root, "LeftArm" if side == -1 else "RightArm", Vector3(side * 0.8, 0.14, 0))
		cylinder(arm, "BarkArm", Vector3(side * 0.07, -0.39, 0), 0.85, 0.23, 0.21, "4d4d42", 6)
		rock(arm, "StoneFist", Vector3(side * 0.10, -0.87, 0), Vector3(0.5, 0.38, 0.52), "7d8872")
		rock(root, "Leg", Vector3(side * 0.33, -0.94, 0), Vector3(0.5, 0.55, 0.55), "525c54")
		box(root, "Foot", Vector3(side * 0.34 + 0.05, -1.14, 0.06), Vector3(0.58, 0.22, 0.68), "494e49")
		var horn = cylinder(root, "BranchHorn", Vector3(side * 0.47, 1.04, 0), 0.9, 0.13, 0.035, "6e6652", 5)
		horn.rotation_degrees.z = side * -35
		var tip = cylinder(root, "HornFork", Vector3(side * 0.72, 1.32, 0), 0.44, 0.065, 0.01, "8c8063", 5)
		tip.rotation_degrees.z = side * 38
		box(root, "Eye", Vector3(side * 0.15, 0.72, 0.39), Vector3(0.13, 0.06, 0.04), "ffcd78")
	return root

static func tree() -> Node3D:
	var root = Node3D.new()
	root.name = "Alder"
	cylinder(root, "Trunk", Vector3(0, 2.75, 0), 5.5, 0.42, 0.18, "5f6250", 7)
	for side in [-1, 1]:
		var branch = cylinder(root, "Bough", Vector3(side * 0.65, 3.8, 0), 2.5, 0.16, 0.08, "5f6250", 6)
		branch.rotation_degrees.z = side * -45
	for i in 9:
		var angle = i * 2.4
		var radial = 0.8 + (i % 3) * 0.5
		rock(root, "Crown%d" % i, Vector3(cos(angle) * radial, 5.8 + sin(i * 3.2) * 0.65, sin(angle) * radial), Vector3(3.4, 1.85, 2.8), ["32685b", "417b61", "619a70"][i % 3], i * 0.7)
	for i in 5:
		var angle = i * TAU / 5
		var buttress = cylinder(root, "Root", Vector3(cos(angle) * 0.35, 0.21, sin(angle) * 0.35), 1.2, 0.2, 0.08, "5f6250", 5)
		buttress.rotation_degrees.z = 50
		buttress.rotation.y = angle
	return root

static func house() -> Node3D:
	var root = Node3D.new()
	root.name = "WillowCottage"
	box(root, "Plaster", Vector3(0, 1, 0), Vector3(2.5, 2, 1.9), "c5b58d")
	for x in [-1.17, 0, 1.17]:
		box(root, "Frame", Vector3(x, 1.0, 1), Vector3(0.13, 2, 0.12), "655d4d")
	box(root, "Sill", Vector3(0, 0.15, 1.0), Vector3(2.55, 0.14, 0.13), "7b7055")
	var roof = PrismMesh.new()
	roof.size = Vector3(3.2, 1.25, 2.35)
	mesh(root, "Roof", roof, Vector3(0, 2.5, 0), "40596c")
	for side in [-1, 1]:
		for row in 4:
			for col in 4:
				var shingle = box(root, "Shingle", Vector3(side * (0.24 + row * 0.39), 3.06 - row * 0.305, -0.91 + col * 0.62), Vector3(0.51, 0.075, 0.62), "496579" if (row + col) % 3 else "5c7887")
				shingle.rotation_degrees.z = -side * 38
	box(root, "DoorFrame", Vector3(-0.3, 0.77, 1.05), Vector3(0.76, 1.54, 0.14), "514d43")
	for i in 5:
		box(root, "DoorPlank", Vector3(-0.57 + i * 0.14, 0.74, 1.14), Vector3(0.12, 1.4, 0.05), "827659" if i % 2 else "75694f")
	box(root, "Latch", Vector3(-0.11, 0.75, 1.19), Vector3(0.06, 0.07, 0.03), "d5b971")
	box(root, "WindowFrame", Vector3(0.68, 1.25, 1.03), Vector3(0.66, 0.75, 0.13), "665f4c")
	box(root, "Window", Vector3(0.68, 1.25, 1.11), Vector3(0.48, 0.58, 0.04), "e5be72")
	for size in [Vector3(0.52, 0.055, 0.04), Vector3(0.05, 0.62, 0.04)]:
		box(root, "Mullion", Vector3(0.68, 1.25, 1.15), size, "766c4f")
	var gable = SurfaceTool.new()
	gable.begin(Mesh.PRIMITIVE_TRIANGLES)
	triangle(gable, Vector3(-1.4, 1.99, 1.181), Vector3(1.4, 1.99, 1.181), Vector3(0, 3.08, 1.181))
	mesh(root, "Gable", gable.commit(), Vector3.ZERO, "c7ba97")
	box(root, "Beam", Vector3(0, 2.04, 1.2), Vector3(2.9, 0.12, 0.13), "625540")
	box(root, "Attic", Vector3(0, 2.5, 1.22), Vector3(0.13, 0.9, 0.1), "625540")
	box(root, "Chimney", Vector3(-0.7, 2.87, -0.4), Vector3(0.45, 1.2, 0.5), "7f8275")
	box(root, "ChimneyRim", Vector3(-0.7, 3.5, -0.4), Vector3(0.59, 0.14, 0.62), "9a9b84")
	for i in 5:
		rock(root, "Foundation", Vector3(-1.1 + i * 0.54, 0.04, 1.05), Vector3(0.7, 0.3, 0.45), "7d8270", i)
	return root

static func ruin() -> Node3D:
	var root = Node3D.new()
	root.name = "AetherianArch"
	for side in [-1, 1]:
		for i in 5:
			var block = box(root, "Pillar", Vector3(side * 1.6, 0.4 + i * 0.7, 0), Vector3(0.7, 0.66, 0.8), "78877f" if i % 2 else "8a9685")
			block.rotation_degrees.y = i * side * 2
		box(root, "Plinth", Vector3(side * 1.6, 0.2, 0), Vector3(1.0, 0.4, 1.1), "65776e")
	for i in 9:
		var angle = float(i) / 8 * PI
		var block = box(root, "ArchStone", Vector3(cos(angle) * 1.6, 3.1 + sin(angle) * 1.6, 0), Vector3(0.62, 0.72, 0.86), "98a18b" if i % 2 else "829384")
		block.rotation.z = angle - PI / 2
	for i in 6:
		rock(root, "Moss", Vector3(-1.7 + i * 0.09, 3.9 - i * 0.46, 0.46), Vector3(0.35, 0.48, 0.12), "5f8762", i)
	gem(root, "Keystone", Vector3(0, 4.65, 0.47), Vector3(0.12, 0.26, 0.025), "8bc8bc")
	return root

static func waystone() -> Node3D:
	var root = Node3D.new()
	root.name = "Waystone"
	rock(root, "Foot", Vector3(0, 0.18, 0), Vector3(0.9, 0.45, 0.75), "677b72")
	cylinder(root, "Column", Vector3(0, 0.7, 0), 1.0, 0.29, 0.18, "82958c", 6)
	gem(root, "Heart", Vector3(0, 1.45, 0), Vector3(0.23, 0.38, 0.2), "8be4e5")
	for side in [-1, 1]:
		var fork = cylinder(root, "Cradle", Vector3(side * 0.29, 1.1, 0), 0.54, 0.06, 0.04, "a9aa8c", 5)
		fork.rotation_degrees.z = -side * 28
	return root

static func waterfall() -> Node3D:
	var root = Node3D.new()
	root.name = "Silverfall"
	for side in [-1, 1]:
		for j in 5:
			rock(root, "Cliff", Vector3(side * (1.65 + sin(j * 3.1) * 0.12), 0.4 + j * 1.1, -0.6), Vector3(2.3, 1.7, 2.1), "657a75", j + side * 2)
	var sheet = QuadMesh.new()
	sheet.size = Vector2(2.25, 5.3)
	var water = mesh(root, "Flow", sheet, Vector3(0, 2.7, 0), "82cbd0")
	var shader = ShaderMaterial.new()
	shader.shader = load("res://assets/shaders/water.gdshader")
	water.material_override = shader
	var pool = PlaneMesh.new()
	pool.size = Vector2(7.5, 3)
	var basin = mesh(root, "Pool", pool, Vector3(0, 0.01, 0.5), "428d9b")
	var pool_material = shader.duplicate()
	pool_material.set_shader_parameter("flow_speed", 0.13)
	basin.material_override = pool_material
	for i in 5:
		rock(root, "Foam", Vector3(-0.9 + i * 0.45, 0.09, 0.2), Vector3(0.7, 0.16, 0.7), "b5e0da", i)
	return root

static func merge_static(root: Node3D) -> void:
	# Merge compatible surfaces to reduce mobile draw calls while preserving palette.
	var groups: Dictionary = {}
	gather(root, Transform3D.IDENTITY, groups)
	var combined = ArrayMesh.new()
	for group in groups.values():
		group.surface.commit(combined)
	for child in root.get_children():
		child.free()
	var visual = MeshInstance3D.new()
	visual.name = "Geometry"
	visual.mesh = combined
	root.add_child(visual)

static func gather(current: Node3D, transform: Transform3D, groups: Dictionary) -> void:
	if current is MeshInstance3D:
		var source: StandardMaterial3D = current.material_override
		var key = str(source.get_instance_id()) if source.emission_enabled else "opaque" + str(source.cull_mode)
		if not groups.has(key):
			var surface = SurfaceTool.new()
			surface.begin(Mesh.PRIMITIVE_TRIANGLES)
			var merged_material = source if source.emission_enabled else mat("ffffff").duplicate()
			merged_material.cull_mode = source.cull_mode
			surface.set_material(merged_material)
			groups[key] = {"surface": surface}
		var st: SurfaceTool = groups[key].surface
		var arrays = current.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR] if arrays[Mesh.ARRAY_COLOR] != null else PackedColorArray()
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
		var count = vertices.size() if indices.is_empty() else indices.size()
		for i in count:
			var index = i if indices.is_empty() else indices[i]
			var color = colors[index] if not colors.is_empty() else Color.WHITE
			if not source.emission_enabled:
				color *= source.albedo_color
			st.set_color(color.srgb_to_linear())
			st.set_normal((transform.basis.inverse().transposed() * normals[index]).normalized())
			st.add_vertex(transform * vertices[index])
	for child in current.get_children():
		if child is Node3D:
			gather(child, transform * child.transform, groups)

static func merge_rig(root: Node3D) -> void:
	var body = Node3D.new()
	body.name = "Body"
	root.add_child(body)
	for child in root.get_children():
		if child == body:
			continue
		if child is MeshInstance3D:
			root.remove_child(child)
			body.add_child(child)
		elif child is Node3D:
			merge_rig(child)
	if body.get_child_count() > 0:
		merge_static(body)
	else:
		body.free()

static func castle() -> Node3D:
	var root = Node3D.new()
	root.name = "DistantAetheria"
	box(root, "Keep", Vector3(0, 2, 0), Vector3(5.5, 4, 2), "829ba5")
	for i in 5:
		var x = -3.5 + i * 1.75
		var h = 4.6 if i != 2 else 7.0
		cylinder(root, "Tower", Vector3(x, h / 2, 0), h, 0.46, 0.46, "8da8b1", 6)
		cylinder(root, "Spire", Vector3(x, h + 0.9, 0), 1.8, 0.7, 0.0, "597d94", 6)
		for y in [2.0, 3.1]:
			box(root, "Window", Vector3(x, y, 0.47), Vector3(0.12, 0.3, 0.03), "547482")
	return root

static func fir() -> Node3D:
	var root = Node3D.new()
	root.name = "ValleyFir"
	cylinder(root, "Trunk", Vector3(0, 1.7, 0), 3.4, 0.17, 0.08, "455e58", 6)
	for i in 5:
		cylinder(root, "Needles", Vector3(0, 1.5 + i * 0.6, 0), 1.7, 1.15 - i * 0.18, 0.02, "3b665e" if i % 2 else "4e7a69", 7)
	return root
