extends "res://scripts/world.gd"
## Painted-image characters and stage. Existing physics and combat stay in use.
var campaign_save_path=""
var selected_villain=0
func _ready() -> void:
	campaign_save_path=Progress.save_path
	Progress.save_path="user://image-character-preview.json"
	Progress.data=Progress.DEFAULTS.duplicate(true)
	Progress.save_game()
	super._ready()
	camera.size=6.2
func build_environment() -> void:
	var we=WorldEnvironment.new()
	var env=Environment.new()
	env.background_mode=Environment.BG_COLOR
	env.background_color=Color("173b4c")
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color=Color.WHITE
	env.ambient_light_energy=.8
	we.environment=env
	add_child(we)
	sun=DirectionalLight3D.new()
	sun.light_energy=.8
	add_child(sun)
func build_route() -> void:
	StageArt.platform(self,49,0,20,1.5)
	for x in [39,59]:
		var wall=Art.solid(self,Vector3(x,3,0),Vector3(.5,8,3),Color.WHITE)
		wall.visible=false
	gate=Art.solid(self,Vector3(37,2,0),Vector3(.2,4,2),Color.WHITE)
	gate.visible=false
	gate.collision_layer=0
	crystal=MeshInstance3D.new()
	add_child(crystal)
	crystal.position=Vector3(32,3,0)
	secret=MeshInstance3D.new()
	add_child(secret)
	secret.position=Vector3(14,4,0)
	add_enemy(51,"boss")
func start_game(fresh: bool=false) -> void:
	super.start_game(true)
	if region_index != selected_villain:
		for enemy in enemies:
			remove_child(enemy)
			enemy.queue_free()
		enemies.clear()
		region_index=selected_villain
		add_enemy(51,"boss")
	Progress.data.powers=range(6)
	Progress.data.quest=2
	Progress.data.crystal=true
	Progress.data.checkpoint=44.0
	player.restore_at(Vector3(44,.85,0))
	camera.position=Vector3(47,3.7,17)
	camera.size=6.2
	controls.notify_text("Painted character preview • Move, jump, sword and magic")
func objective() -> String:
	return "Defeat "+Campaign.BOSSES[region_index] if not Progress.data.boss else "The Warden is free • Follow the eastern trail"
func show_title() -> void:
	playing=false
	clear_menu("Willowbrook • Painted characters","title")
	paragraph("Kael and six guardians move using layered painted images. Run, jump, strike and cast in the forest clearing.")
	button("Play image character scene",func(): start_game(true))
	button("Choose a villain",choose_villain)
	button("Return to campaign",return_to_campaign)
func show_completion() -> void:
	clear_menu(Campaign.BOSSES[region_index]+" defeated","pause")
	paragraph("The forest clearing is safe again.")
	button("Play again",func():start_game(true))
	button("Return to campaign",return_to_campaign)
func show_travel() -> void:
	clear_menu("Willowbrook • Clearing","pause")
	button("Resume",resume)
	button("Return to campaign",return_to_campaign)
func return_to_campaign() -> void:
	Progress.save_path=campaign_save_path
	get_tree().change_scene_to_file("res://scenes/main.tscn")
func persist() -> void:
	# Art sandbox unlocks all powers for this run without changing campaign data.
	pass
func _exit_tree() -> void:
	Progress.save_path=campaign_save_path
	super._exit_tree()

func choose_villain() -> void:
	clear_menu("Choose a painted villain","pause")
	for index in 6:
		var pick=index
		button(Campaign.BOSSES[index],func():
			selected_villain=pick
			start_game(true))
	button("Back",show_title)

func update_reference_background() -> void:
	var chosen=region_index
	region_index=0
	super.update_reference_background()
	region_index=chosen
