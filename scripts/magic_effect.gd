extends Node3D
## Bounded mesh effects; gameplay targeting remains in world.gd.
const Art = preload("res://scripts/shapes.gd")
var world: Node3D
var color = Color.WHITE
var radius = 1.0
var target = Vector3.ZERO
var beam = false
var elapsed = 0.0
var power = 0
var direction = 1.0
var style = ""
var visuals: Array[GeometryInstance3D] = []
var lifetime = .5
func mesh_node(mesh: Mesh,pos: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var visual = MeshInstance3D.new()
	visual.mesh = mesh
	visual.material_override = Art.material(color,1.1)
	visual.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visual.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	add_child(visual)
	visual.position = pos
	visuals.append(visual)
	return visual
func ribbon(points: Array,width: float) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in points.size()-1:
		var a: Vector3 = points[i]
		var b: Vector3 = points[i+1]
		var delta = (b-a).normalized()
		var side = Vector3(-delta.y,delta.x,0)*width
		for point in [a-side,a+side,b+side,a-side,b+side,b-side]: st.add_vertex(point)
	mesh_node(st.commit())
func _ready() -> void:
	if not world.has_meta("guardian_3d") and style!="slash":
		var puppet=load("res://scripts/image_puppet.gd")
		if beam:
			var end=target-global_position
			var sprite=puppet.piece(self,puppet.textures("tempest")[11],.4,maxf(.1,end.length()),Vector2(.5,.5))
			sprite.position=end*.5
			sprite.rotation.z=atan2(end.y,end.x)+PI/2
			visuals.append(sprite)
			lifetime=.3
		elif power==5:
			add_child(puppet.guardian())
		else:
			var kind="kael" if power==0 else puppet.BOSS_KINDS[power]
			var texture=puppet.textures(kind)[15 if power==0 else 11]
			var sprite=puppet.piece(self,texture,[.9,2.5,2.4,2.1,.8][power],[.9,1.7,1.5,1.4,2.5][power],Vector2(.5,.5))
			visuals.append(sprite)
			if power==3:lifetime=.24
		return
	if style == "slash":
		lifetime = .23
		var points = []
		for i in 17:
			var angle = -.9+float(i)/16*2.5
			points.append(Vector3(cos(angle)*radius*direction,sin(angle)*radius,0))
		ribbon(points,.045)
	elif beam:
		lifetime = .3
		var points = [Vector3.ZERO]
		var end = target-global_position
		for i in range(1,9): points.append(end*float(i)/9+Vector3(0,(.16 if i%2 else -.16),0))
		points.append(end)
		ribbon(points,.035)
	elif power == 1:
		for i in 8:
			var cone = CylinderMesh.new()
			cone.top_radius = 0
			cone.bottom_radius = .12+(i%3)*.035
			cone.height = .5+(i%3)*.12
			cone.radial_segments = 7
			var tongue = mesh_node(cone,Vector3((float(i)/7-.4)*2.4*direction,-.4+(i%2)*.28,(i%3-1)*.17))
			tongue.rotation.z = -.35*direction
	elif power == 2:
		for i in 7:
			var ice = CylinderMesh.new()
			ice.top_radius = 0
			ice.bottom_radius = .13
			ice.height = .55+(i%3)*.2
			ice.radial_segments = 5
			mesh_node(ice,Vector3((float(i)/6-.5)*2.3,-.25,(i%2-.5)*.3))
	elif power == 3:
		lifetime = .24
		for j in 3:
			var points = []
			for i in 14:
				var t = float(i)/13
				points.append(Vector3((t*1.9-1.3)*direction,sin(t*PI+j*1.8)*.35,cos(t*PI+j*1.8)*.18))
			ribbon(points,.025)
	else:
		for i in (3 if power == 5 else 1):
			var ring = TorusMesh.new()
			ring.inner_radius = radius*.9
			ring.outer_radius = radius
			ring.rings = 24
			ring.ring_segments = 6
			var visual = mesh_node(ring)
			visual.rotation_degrees = Vector3(90,0,0) if i == 0 else Vector3(0,0,35 if i == 1 else -35)
func _process(delta: float) -> void:
	if not is_instance_valid(world) or not world.playing: return
	elapsed += delta
	if power == 3: position = world.player.position
	var t = clampf(elapsed/lifetime,0,1)
	if not beam and style != "slash": scale = Vector3.ONE*(.7+t*.35)
	for visual in visuals: visual.transparency = maxf(0,(t-.55)/.45)
	if elapsed >= lifetime: queue_free()
