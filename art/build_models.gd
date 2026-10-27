extends SceneTree
const Models = preload("res://art/models.gd")

func own_children(node: Node, owner_node: Node) -> void:
	for child in node.get_children():
		child.owner = owner_node
		own_children(child, owner_node)

func _initialize() -> void:
	var models = {"fir": Models.fir(), "castle": Models.castle(), "kael": Models.hero(), "thornling": Models.stalker(), "veil_moth": Models.wisp(),
		"hollow_warden": Models.warden(), "alder": Models.tree(), "cottage": Models.house(),
		"ruin_arch": Models.ruin(), "waystone": Models.waystone(), "waterfall": Models.waterfall(),
		"lyra": Models.hero("61857d", "c2b785"), "mira": Models.hero("a8826b", "6c827a"), "orin": Models.hero("8b805d", "53696b")}
	for name in models:
		var root: Node3D = models[name]
		if name in ["fir", "castle", "alder", "cottage", "ruin_arch", "waystone"]:
			Models.merge_static(root)
		if name in ["lyra", "mira", "orin"]:
			root.get_node("Sword").free()
		if name in ["lyra", "mira", "orin"]:
			Models.merge_static(root)
		elif name in ["kael", "thornling", "veil_moth", "hollow_warden"]:
			Models.merge_rig(root)
		own_children(root, root)
		var scene = PackedScene.new()
		var packed = scene.pack(root)
		if packed != OK or ResourceSaver.save(scene, "res://assets/models/" + name + ".tscn") != OK:
			push_error("Cannot save model: " + name)
			quit(1)
			return
		print("Authored model saved: ", name)
		root.free()
	quit()
