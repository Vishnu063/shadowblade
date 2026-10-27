extends Node
var world: Node3D
func settle(count: int=3) -> void:
	for i in count:await get_tree().process_frame
	await RenderingServer.frame_post_draw
func capture(name: String) -> void:
	print("IMAGE CAPTURE ",name,": ",error_string(get_viewport().get_texture().get_image().save_png("res://build/image-"+name+".png")))
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("res://build")
	var ignore=FileAccess.open("res://build/.gdignore",FileAccess.WRITE)
	ignore.close()
	world=load("res://scenes/image_preview.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	world.controls.visible=false
	world.set_process(false)
	world.player.set_physics_process(false)
	world.enemies[0].set_physics_process(false)
	world.player.position=Vector3(47,.85,0)
	world.player.body_art.visible=true
	world.player.invulnerable=0
	world.camera.position=Vector3(49,3.8,17)
	world.camera.size=5.9
	world.update_reference_background()
	await settle(5)
	capture("pair")
	world.camera.size=2.8
	world.camera.position=Vector3(47,3.2,17)
	world.update_reference_background()
	await settle(2)
	capture("hero")
	world.camera.size=4.2
	world.camera.position=Vector3(51,3.7,17)
	world.update_reference_background()
	await settle(2)
	capture("warden")
	get_tree().quit()
