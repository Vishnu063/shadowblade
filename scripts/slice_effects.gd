extends RefCounted
## Curved solid-root geometry for the first 3D scene; damage stays in BossPower.
static func roots(parent: Node3D) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	var st=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for root in 7:
		var angle=root*TAU/7
		for ring in 14:
			var t=float(ring)/14
			var next_t=float(ring+1)/14
			var a=Vector3(cos(angle+t*.8)*(.62-t*.18),t*(.85+float(root%3)*.15),sin(angle+t*.8)*.33)
			var b=Vector3(cos(angle+next_t*.8)*(.62-next_t*.18),next_t*(.85+float(root%3)*.15),sin(angle+next_t*.8)*.33)
			var width=.065*(1-t)+.002
			var next_width=.065*(1-next_t)+.002
			for side in 7:
				var q=TAU*side/7
				var r=TAU*(side+1)/7
				var p0=a+Vector3(cos(q)*width,0,sin(q)*width)
				var p1=a+Vector3(cos(r)*width,0,sin(r)*width)
				var p2=b+Vector3(cos(q)*next_width,0,sin(q)*next_width)
				var p3=b+Vector3(cos(r)*next_width,0,sin(r)*next_width)
				for vertex in [p0,p1,p3,p0,p3,p2]:st.add_vertex(vertex)
	st.generate_normals()
	var mesh=MeshInstance3D.new()
	mesh.mesh=st.commit()
	var material=StandardMaterial3D.new()
	material.albedo_color=Color("52643b")
	material.roughness=.88
	mesh.material_override=material
	parent.add_child(mesh)
