extends Node
var world: Node3D
func settle(frames: int=2) -> void:
	for i in frames: await get_tree().process_frame
	await RenderingServer.frame_post_draw
func shot(name: String) -> void:
	var result = get_viewport().get_texture().get_image().save_png("res://build/slice-"+name+".png")
	print("SLICE STILL ",name,": ",error_string(result))
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("res://build")
	world=load("res://scenes/willowbrook_3d.tscn").instantiate()
	add_child(world)
	world.start_game(true)
	world.set_process(false)
	world.controls.visible=false
	world.player.set_physics_process(false)
	world.enemies[0].set_physics_process(false)
	world.player.invulnerable=0
	world.player.body_art.visible=true
	world.player.position=Vector3(47,.85,0)
	world.player.body_art.rotation.y=.55
	world.camera.projection=Camera3D.PROJECTION_PERSPECTIVE
	world.camera.fov=42
	world.camera.position=Vector3(48,3.3,11)
	world.camera.look_at(Vector3(49,1.4,-1))
	world.camera.size=6.5
	await settle(10)
	shot("wide")
	world.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	world.camera.size=2.5
	world.camera.position=Vector3(47,1.9,5)
	world.camera.look_at(Vector3(47,1.2,0))
	await settle(2)
	shot("hero")
	world.camera.size=4.5
	world.camera.position=Vector3(51,2.9,6)
	world.camera.look_at(Vector3(51,1.5,0))
	await settle(2)
	shot("warden")
	get_tree().quit()
