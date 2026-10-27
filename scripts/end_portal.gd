extends Node3D
## Final doorway reuses the established victory trigger; save progression unchanged.
const Art = preload("res://scripts/shapes.gd")
var world: Node3D
var surface: MeshInstance3D
var clock = 0.0
var spiral: Node3D
var runes: Array[MeshInstance3D] = []
func _ready() -> void:
	for side in [-1,1]:
		for i in 6:
			Art.box(self,Vector3(side*1.03,.25+i*.43,-.2),Vector3(.38,.4,.65),Color("454858"))
		Art.box(self,Vector3(side*1.03,0,-.2),Vector3(.65,.22,.85),Color("535364"))
	for i in 7:
		var a = PI*i/6
		var stone = Art.box(self,Vector3(cos(a)*1.03,2.45+sin(a)*.9,-.2),Vector3(.47,.38,.65),Color("535364"))
		stone.rotation.z = a-PI/2
	var mesh = TorusMesh.new()
	mesh.inner_radius = .89
	mesh.outer_radius = 1.0
	mesh.rings = 36
	mesh.ring_segments = 6
	surface = MeshInstance3D.new()
	surface.mesh = mesh
	surface.material_override = Art.material(Color("79d9f6"),1.2)
	add_child(surface)
	surface.position = Vector3(0,1.6,-.12)
	surface.rotation_degrees.x = 90
	surface.scale = Vector3(1,1,1.5)
	spiral = Node3D.new()
	add_child(spiral)
	spiral.position = Vector3(0,1.6,-.13)
	for j in 3:
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in 40:
			var t = float(i)/40
			var a = t*TAU*1.5+j*TAU/3
			var b = a+TAU*1.5/40
			var r = .08+t*.84
			var next_r = r+.84/40
			var p = Vector3(cos(a)*r,sin(a)*r,0)
			var q = Vector3(cos(b)*next_r,sin(b)*next_r,0)
			var side = Vector3(-sin(a),cos(a),0)*.022
			for point in [p-side,p+side,q+side,p-side,q+side,q-side]: st.add_vertex(point)
		var ribbon = MeshInstance3D.new()
		ribbon.mesh = st.commit()
		ribbon.material_override = Art.material(Color("e9bf73") if j==0 else Color("5bafc5"),.35)
		ribbon.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
		spiral.add_child(ribbon)
	spiral.scale.y = 1.5
	var colors = ["68cf76","ff8739","92def6","85e5c5","c3a1ff","ffe7a4"]
	for i in 6:
		var side = -1 if i<3 else 1
		var rune = Art.orb(self,Vector3(side*1.03,.75+(i%3)*.8,.16),.1,Color(colors[i]),.6)
		runes.append(rune)
	Art.label(self,Vector3(0,3.58,0),"DAWN GATE",Color("f3dfad"))
func _process(delta: float) -> void:
	var unlocked: bool = Progress.data.boss
	surface.visible = unlocked
	spiral.visible = unlocked
	spiral.rotation.z = clock*.4
	if world.playing: clock += delta
	if unlocked:
		surface.rotation.y = sin(clock*.8)*.13
		surface.material_override.emission_energy_multiplier = 1.0+.2*sin(clock*2)
	for i in runes.size(): runes[i].visible = Progress.data.campaign.completed.has(i)
