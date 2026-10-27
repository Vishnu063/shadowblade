extends Node
## Capture real renderer output from an isolated demo session.
var world: Node3D

func settle(count: int = 15) -> void:
	for i in count:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

func capture(file: String) -> void:
	var image = get_viewport().get_texture().get_image()
	var result = image.save_png("res://docs/screenshots/" + file + ".png")
	print("CAPTURE ", file, ": ", error_string(result))

func _ready() -> void:
	Progress.save_path = "user://capture.json"
	Progress.data = Progress.DEFAULTS.duplicate(true)
	world = load("res://scenes/main.tscn").instantiate()
	add_child(world)
	await settle()
	capture("title")
	world.start_game(true)
	world.controls.status_time = 0
	await settle(12)
	world.player.invulnerable = 0
	await settle(2)
	capture("willowbrook")
	Progress.data.quest = 1
	world.player.restore_at(Vector3(26, 0.9, 0))
	world.player.invulnerable = 0
	world.camera.position.x = 27
	await settle(10)
	world.player.cast()
	await settle(3)
	capture("forest")
	world.playing = false
	world.controls.visible = false
	world.camera.size = 3.0
	world.camera.position = world.player.position + Vector3(0, 2.4, 17)
	await settle(2)
	capture("kael-detail")
	world.camera.size = 10.5
	world.controls.visible = true
	world.playing = true
	await settle(5)
	world.controls.pointer_down(7, world.controls.buttons.magic.get_center())
	await get_tree().create_timer(0.4).timeout
	await settle(2)
	capture("powers")
	world.controls.pointer_up(7, Vector2.ZERO)
	for suffix in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(Progress.save_path + suffix)
	world.queue_free()
	await get_tree().process_frame
	get_tree().quit()
