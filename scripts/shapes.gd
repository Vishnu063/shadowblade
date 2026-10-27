extends RefCounted
## Original temporary art, authored from engine primitives. No downloaded assets.
static func material(color: Color, glow: float = 0.0) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.92
	if glow > 0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = glow
	return mat

static func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var node = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = material(color)
	parent.add_child(node)
	node.position = pos
	return node

static func orb(parent: Node3D, pos: Vector3, radius: float, color: Color, glow: float = 0.0) -> MeshInstance3D:
	var node = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 12
	mesh.rings = 6
	node.mesh = mesh
	node.material_override = material(color, glow)
	parent.add_child(node)
	node.position = pos
	return node

static func solid(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body = StaticBody3D.new()
	parent.add_child(body)
	body.position = pos
	box(body, Vector3.ZERO, size, color)
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	return body

static func label(parent: Node3D, pos: Vector3, text: String, color: Color = Color.WHITE) -> Label3D:
	var node = Label3D.new()
	node.text = text
	node.font_size = 36
	node.pixel_size = 0.008
	node.modulate = color
	node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(node)
	node.position = pos
	return node
