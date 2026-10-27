extends "res://scripts/world.gd"
## Opt-in 3D art slice. It uses an isolated save and the existing combat/controls.
var normal_save_path = ""
func _ready() -> void:
	normal_save_path = Progress.save_path
	Progress.save_path = "user://guardian-3d-slice.json"
	set_meta("guardian_3d",true)
	Progress.data = Progress.DEFAULTS.duplicate(true)
	Progress.save_game()
	super._ready()
	camera.projection=Camera3D.PROJECTION_PERSPECTIVE
	camera.fov=38
func build_environment() -> void:
	var we = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var material = ProceduralSkyMaterial.new()
	material.sky_top_color=Color("365d7e")
	material.sky_horizon_color=Color("8cabb9")
	material.ground_horizon_color=Color("62725c")
	sky.sky_material=material
	env.sky=sky
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color=Color("b4c4c8")
	env.ambient_light_energy=.2
	env.tonemap_mode=Environment.TONE_MAPPER_FILMIC
	env.fog_enabled=true
	env.fog_light_color=Color("7493a1")
	env.fog_density=.0045
	we.environment=env
	add_child(we)
	sun=DirectionalLight3D.new()
	sun.rotation_degrees=Vector3(-38,-30,0)
	sun.light_color=Color("ffe2aa")
	sun.light_energy=1.05
	sun.shadow_enabled=true
	sun.directional_shadow_max_distance=42
	add_child(sun)
	var fill=DirectionalLight3D.new()
	fill.rotation_degrees=Vector3(-18,145,0)
	fill.light_color=Color("b2d3ed")
	fill.light_energy=.18
	add_child(fill)
	var face_fill=OmniLight3D.new()
	face_fill.position=Vector3(49,3.2,4)
	face_fill.omni_range=13
	face_fill.light_energy=.35
	face_fill.light_color=Color("d1e7f5")
	add_child(face_fill)
	var stage=load("res://assets/slice3d/willowbrook-ravine.gltf").instantiate()
	add_child(stage)
	stage.position.x=40
	var water = ShaderMaterial.new()
	water.shader=load("res://assets/shaders/slice_waterfall.gdshader")
	for mesh in stage.find_children("*","MeshInstance3D",true,false):
		for surface in mesh.mesh.get_surface_count():
			var mat = mesh.mesh.surface_get_material(surface)
			if mat != null and "WaterfallStream" in mat.resource_name: mesh.set_surface_override_material(surface,water)
			if mat != null and mat.resource_name in ["Ravine layered stone","Mossy limestone"]:
				var stone_shader=ShaderMaterial.new()
				stone_shader.shader=load("res://assets/shaders/slice_stone.gdshader")
				mesh.set_surface_override_material(surface,stone_shader)
			if mat != null and mat.resource_name.begins_with("Leaf"):
				var wind=ShaderMaterial.new()
				wind.shader=load("res://assets/shaders/slice_foliage.gdshader")
				wind.set_shader_parameter("leaf_color",mat.albedo_color)
				mesh.set_surface_override_material(surface,wind)
	var river=MeshInstance3D.new()
	var plane=PlaneMesh.new()
	plane.size=Vector2(50,35)
	plane.subdivide_width=70
	plane.subdivide_depth=40
	river.mesh=plane
	var river_material=ShaderMaterial.new()
	river_material.shader=load("res://assets/shaders/slice_river.gdshader")
	river.material_override=river_material
	add_child(river)
	river.position=Vector3(49,-1.72,0)

func build_route() -> void:
	var floor = Art.solid(self,Vector3(49,-.7,0),Vector3(20,1.4,3.2),Color("46523c"))
	floor.get_child(0).visible=false
	for x in [39,59]:
		var wall=Art.solid(self,Vector3(x,3,0),Vector3(.5,8,3),Color.WHITE)
		wall.visible=false
	gate=Art.solid(self,Vector3(37,2,0),Vector3(.2,4,2),Color.WHITE)
	gate.visible=false
	gate.collision_layer=0
	crystal=Art.orb(self,Vector3(32,3,0),.1,Color.WHITE)
	crystal.visible=false
	secret=Art.orb(self,Vector3(14,4,0),.1,Color.WHITE)
	secret.visible=false
	add_enemy(51,"boss")
func setup_reference_background() -> void:
	pass
func update_reference_background() -> void:
	if is_instance_valid(stage_frame): stage_frame.visible=false
func start_game(fresh: bool=false) -> void:
	super.start_game(true)
	Progress.data.powers=range(6)
	Progress.data.quest=2
	Progress.data.crystal=true
	Progress.data.checkpoint=44.0
	player.restore_at(Vector3(44,.85,0))
	camera.position=Vector3(46,3.1,10.8)
	camera.look_at(Vector3(46,1.4,-.5))
	camera.size=6.5
	controls.notify_text("3D art preview • Six powers ready • Defeat the Hollow Warden")
func objective() -> String:
	return "3D ART PREVIEW • Defeat the Hollow Warden" if not Progress.data.boss else "Warden freed • Follow the eastern trail"
func show_title() -> void:
	playing=false
	clear_menu("Willowbrook • New 3D art", "title")
	paragraph("A playable art preview with a weighted Kael, a rebuilt Warden and fully 3D forest scenery. Concept-detail matching and Android performance remain in progress.")
	button("Play 3D scene",func(): start_game(true))
	button("Return to campaign",return_to_campaign)
func show_completion() -> void:
	clear_menu("The Warden is free","pause")
	paragraph("3D art scene complete. This is a visual candidate; the six-world campaign remains available separately.")
	button("Play again",func(): start_game(true))
	button("Return to campaign",return_to_campaign)
func show_travel() -> void:
	clear_menu("Willowbrook • Clearing","pause")
	paragraph("Explore this clearing and face the Hollow Warden. Your campaign is available separately.")
	button("Resume",resume)
	button("Return to campaign",return_to_campaign)
func return_to_campaign() -> void:
	Progress.save_path=normal_save_path
	get_tree().change_scene_to_file("res://scenes/main.tscn")
func _exit_tree() -> void:
	Progress.save_path=normal_save_path
	super._exit_tree()

func persist() -> void:
	# The all-powers art sandbox resets each run; never write its artificial progression.
	pass

func _process(delta: float) -> void:
	var previous=camera.position
	super._process(delta)
	if playing:
		var x=clampf(player.position.x+2.0,44,54)
		var y=3.1+maxf(0,player.position.y-.85)*.15
		camera.position=previous.lerp(Vector3(x,y,10.8),1-exp(-5*delta))
		camera.look_at(Vector3(x,1.4,-.5))
