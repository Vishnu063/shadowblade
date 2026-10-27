extends RefCounted
## Image-based stage dressing over the original physical platform boxes.
const Art = preload("res://scripts/shapes.gd")
const PLATFORM = preload("res://assets/stage/forest-platform.png")
const FOLIAGE = preload("res://assets/stage/forest-foliage.png")
const PLATFORM_RECT = Rect2(28,210,2120,438)
const FOLIAGE_RECT = Rect2(50,178,1668,570)
const FLOOR_PIXEL = 300.0
const FRONT_Z = 1.25

static func sprite(parent: Node3D,texture: Texture2D,region: Rect2) -> Sprite3D:
	var visual = Sprite3D.new()
	visual.texture = texture
	visual.region_enabled = true
	visual.region_rect = region
	visual.shaded = false
	visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	visual.double_sided = true
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(visual)
	return visual

static func platform(parent: Node3D,x: float,y: float,width: float,height: float) -> void:
	# These are the exact same dimensions used by the original terrain builder.
	var body = Art.solid(parent,Vector3(x,y-height/2,0),Vector3(width,height,3),Color("53694b"))
	body.get_child(0).visible = false
	var count = maxi(1,int(ceil(width/7.5)))
	var step = width/count
	for i in count:
		var visual = sprite(parent,PLATFORM,PLATFORM_RECT)
		visual.name = "MossStoneLedge"
		visual.pixel_size = (step+.035)/PLATFORM_RECT.size.x
		var vertical_scale = minf(1.0,(height+.08)/(338*visual.pixel_size))
		visual.scale.y = vertical_scale
		# Align the illustrated walking surface to the collider at y, allowing
		# for the camera's slight downward angle and the front-face depth.
		var offset = (FLOOR_PIXEL-PLATFORM_RECT.position.y-PLATFORM_RECT.size.y/2)*visual.pixel_size*vertical_scale
		visual.position = Vector3(x-width/2+(i+.5)*step,y+offset+FRONT_Z*tan(deg_to_rad(8)),FRONT_Z)
	if y == 0:
		for i in maxi(1,int(width/3.4)):
			var position_x = x-width/2+1.0+i*3.4
			if position_x > x+width/2-.7: continue
			var leaves = sprite(parent,FOLIAGE,FOLIAGE_RECT)
			leaves.pixel_size = (.85+absf(sin(i*2.3))*.3)/FOLIAGE_RECT.size.x
			leaves.position = Vector3(position_x,y+FOLIAGE_RECT.size.y*leaves.pixel_size/2-.04,-.3)
			leaves.flip_h = i%2 == 1

static func frame(camera: Camera3D) -> Node3D:
	var root = Node3D.new()
	root.name = "ForestForeground"
	camera.add_child(root)
	for side in [-1,1]:
		var leaves = sprite(root,FOLIAGE,FOLIAGE_RECT)
		leaves.name = "Left" if side == -1 else "Right"
		leaves.pixel_size = 3.5/FOLIAGE_RECT.size.x
		leaves.flip_h = side == 1
	return root

static func layout_frame(root: Node3D,camera: Camera3D,aspect: float) -> void:
	for side in [-1,1]:
		var leaves = root.get_node("Left" if side == -1 else "Right")
		leaves.position = Vector3(side*(camera.size*aspect/2-.65),-camera.size/2+.10,-4)
