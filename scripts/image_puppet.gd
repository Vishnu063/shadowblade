extends Node3D
## Painted cutout characters. No character meshes, lights or imported 3D models.
static var texture_cache: Dictionary = {}
var pivots: Dictionary = {}
var is_warden = false
var boss_index=0
const BOSS_KINDS=["warden","cinder","frost","gale","tempest","void"]
static func textures(kind: String) -> Array:
	if texture_cache.has(kind):return texture_cache[kind]
	var base="res://assets/image_characters/"+kind+"-parts"
	var source: Image=load(base+".png").get_image()
	if source.is_compressed():source.decompress()
	source.convert(Image.FORMAT_RGBA8)
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(base+".json"))
	var result=[]
	for info in data.parts:
		var r=info.rect
		var rectangle=Rect2i(int(r[0]),int(r[1]),int(r[2]),int(r[3]))
		var original=source.get_region(rectangle)
		var mask=Image.create(rectangle.size.x,rectangle.size.y,false,Image.FORMAT_RGBA8)
		mask.fill(Color.TRANSPARENT)
		for run in info.runs:mask.fill_rect(Rect2i(int(run[1]),int(run[0]),int(run[2]),1),Color.WHITE)
		var isolated=Image.create(rectangle.size.x,rectangle.size.y,false,Image.FORMAT_RGBA8)
		isolated.fill(Color.TRANSPARENT)
		isolated.blit_rect_mask(original,mask,Rect2i(Vector2i.ZERO,rectangle.size),Vector2i.ZERO)
		result.append(ImageTexture.create_from_image(isolated))
	texture_cache[kind]=result
	return result
static func pivot(root: Node3D,parent: Node3D,title: String,pos: Vector3) -> Node3D:
	var node=Node3D.new()
	node.name=title
	parent.add_child(node)
	node.position=pos
	node.owner=root
	return node
static func piece(parent: Node3D,texture: Texture2D,width: float,height: float,anchor: Vector2,depth: float=0.0) -> Sprite3D:
	var sprite=Sprite3D.new()
	sprite.texture=texture
	sprite.shaded=false
	sprite.double_sided=true
	sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR
	sprite.pixel_size=height/texture.get_height()
	sprite.scale.x=width/(texture.get_width()*sprite.pixel_size)
	sprite.position=Vector3((.5-anchor.x)*width,(anchor.y-.5)*height,depth)
	parent.add_child(sprite)
	return sprite
static func hero() -> Node3D:
	var root=load("res://scripts/image_puppet.gd").new()
	root.name="PaintedKael"
	root.set_meta("image_character",true)
	var t=textures("kael")
	var far_leg=pivot(root,root,"LeftLeg",Vector3(-.10,.015,-.02))
	piece(far_leg,t[10],.15,.43,Vector2(.5,.08))
	var far_knee=pivot(root,far_leg,"Knee",Vector3(.01,-.37,0))
	piece(far_knee,t[11],.24,.49,Vector2(.49,.07))
	var near_leg=pivot(root,root,"RightLeg",Vector3(.105,.015,.005))
	piece(near_leg,t[8],.16,.43,Vector2(.5,.08))
	var near_knee=pivot(root,near_leg,"KneeNear",Vector3(.01,-.37,0))
	piece(near_knee,t[9],.24,.49,Vector2(.49,.07))
	var back_tail=pivot(root,root,"BackCoat",Vector3(-.045,.04,-.015))
	piece(back_tail,t[14],.30,.60,Vector2(.5,.05))
	var front_tail=pivot(root,root,"FrontCoat",Vector3(.065,.04,.025))
	piece(front_tail,t[13],.25,.56,Vector2(.5,.04))
	var torso=pivot(root,root,"Chest",Vector3(0,.055,.035))
	piece(torso,t[1],.40,.57,Vector2(.52,.95))
	var hips=pivot(root,root,"Belt",Vector3(.005,.055,.045))
	piece(hips,t[2],.44,.17,Vector2(.5,.28))
	var head=pivot(root,root,"Head",Vector3(.015,.60,.048))
	piece(head,t[0],.265,.30,Vector2(.50,.93))
	var scarf=pivot(root,root,"Scarf",Vector3(-.035,.60,.016))
	piece(scarf,t[3],.75,.34,Vector2(.96,.21))
	var far_arm=pivot(root,root,"LeftArm",Vector3(-.17,.56,-.01))
	piece(far_arm,t[6],.195,.34,Vector2(.54,.10))
	var far_elbow=pivot(root,far_arm,"Elbow",Vector3(-.02,-.265,0))
	piece(far_elbow,t[7],.17,.34,Vector2(.47,.08))
	var near_arm=pivot(root,root,"SwordArm",Vector3(.185,.56,.07))
	piece(near_arm,t[4],.20,.34,Vector2(.51,.1))
	var near_elbow=pivot(root,near_arm,"ElbowNear",Vector3(.025,-.265,0))
	piece(near_elbow,t[5],.15,.34,Vector2(.49,.08))
	var sword=pivot(root,root,"Sword",Vector3(.24,-.005,.082))
	piece(sword,t[12],.18,.90,Vector2(.5,.88))
	sword.rotation.z=-PI/2
	root.pivots={"head":head,"coat_front":front_tail,"coat_back":back_tail}
	return root
static func warden(index: int=0) -> Node3D:
	var root=load("res://scripts/image_puppet.gd").new()
	root.name="PaintedVillain"
	root.set_meta("image_character",true)
	root.is_warden=true
	root.boss_index=clampi(index,0,5)
	root.set_meta("image_kind",BOSS_KINDS[root.boss_index])
	var k=root.boss_index
	var t=textures(BOSS_KINDS[k])
	var shoulder=[.48,.54,.32,.37,.59,.34][k]
	var arm_width=[.47,.55,.28,.34,.60,.30][k]
	var arm_height=[.72,.78,.57,.62,.82,.61][k]
	var fore_width=[.38,.50,.26,.30,.64,.29][k]
	var fore_height=[.72,.74,.60,.58,.78,.62][k]
	var leg_width=[.56,.54,.40,.35,.62,.44][k]
	var far_leg=pivot(root,root,"LeftLeg",Vector3(-.22,-.15,-.02))
	piece(far_leg,t[9],leg_width,1.23,Vector2(.5,.10))
	var near_leg=pivot(root,root,"RightLeg",Vector3(.23,-.15,.01))
	piece(near_leg,t[8],leg_width,1.25,Vector2(.50,.10))
	var chest=pivot(root,root,"Chest",Vector3(0,-.12,.035))
	piece(chest,t[1],[1.04,1.22,.67,.76,1.35,.74][k],[1.15,1.05,1.10,1.08,1.12,1.10][k],Vector2(.50,.93))
	var hips=pivot(root,root,"Pelvis",Vector3(0,-.1,.05))
	piece(hips,t[2],[1.0,1.02,.80,.75,1.12,.78][k],.47,Vector2(.5,.22))
	var head=pivot(root,root,"Head",Vector3(-.04,.77,.065))
	var face=piece(head,t[0],[.92,.62,.42,.60,.70,.54][k],[1.00,.68,.72,.70,.64,.76][k],Vector2(.53,.87))
	face.flip_h=k in [2,3]
	var branch=pivot(root,root,"CrownBranch",Vector3(.18 if k==0 else 0,.91,-.025))
	piece(branch,t[3],[.68,1.3,1.25,1.70,1.70,1.20][k],[.62,1.7,2.15,1.2,.65,2.2][k],Vector2(.50,.85 if k in [0,4] else (.65 if k==3 else .06)))
	var far_arm=pivot(root,root,"RightArm",Vector3(shoulder,.67,-.01))
	piece(far_arm,t[6],arm_width,arm_height,Vector2(.5,.14))
	var far_elbow=pivot(root,far_arm,"ElbowFar",Vector3(.025,-arm_height*.78,0))
	piece(far_elbow,t[7],fore_width,fore_height,Vector2(.50,.12))
	var near_arm=pivot(root,root,"LeftArm",Vector3(-shoulder,.67,.07))
	piece(near_arm,t[4],arm_width,arm_height,Vector2(.5,.14))
	var near_elbow=pivot(root,near_arm,"ElbowNear",Vector3(-.02,-arm_height*.78,0))
	piece(near_elbow,t[5],fore_width,fore_height,Vector2(.5,.12))
	var hammer=pivot(root,near_elbow,"Hammer",Vector3(.01,-fore_height*.74,.02))
	piece(hammer,t[10],[.61,.72,.40,.38,.55,.55][k],[1.34,1.40,2.2,1.20,1.15,2.3][k],Vector2(.48,.72))
	hammer.rotation.z=-.3
	root.pivots={"head":head,"l":far_leg,"r":near_leg,"ea":far_elbow,"eb":near_elbow,"branch":branch,"weapon":hammer,"near_arm":near_arm,"far_arm":far_arm}
	return root
func animate_boss(delta: float,phase: String,speed: float,clock: float) -> void:
	var gait=minf(.26,absf(speed)*.13)
	if boss_index in [2,5]:gait*=.2
	pivots.l.rotation.z=sin(clock*6)*gait
	pivots.r.rotation.z=-sin(clock*6)*gait
	pivots.ea.rotation.z=lerp_angle(pivots.ea.rotation.z,-.2 if phase=="warn" else .12,delta*8)
	pivots.eb.rotation.z=lerp_angle(pivots.eb.rotation.z,.32 if phase=="strike" else -.10,delta*8)
	pivots.head.rotation.z=sin(clock*1.7)*.025
	pivots.branch.rotation.z=sin(clock*2)*.045
	position.y=sin(clock*2.0)*.012+absf(sin(clock*6))*gait*.08
	if boss_index in [2,5]:
		mage_cast=move_toward(mage_cast,1.0 if phase=="warn" else 0.0,delta*5)
		pivots.near_arm.rotation.z=-.12+sin(clock*.8)*.02
		pivots.eb.rotation.z=-.08
		pivots.far_arm.rotation.z=.05-mage_cast*.95
		pivots.weapon.rotation.z=.12-pivots.near_arm.rotation.z-pivots.eb.rotation.z

var mage_cast=0.0
var detail_clock=0.0
func secondary_motion(delta: float,speed: float) -> void:
	if is_warden:return
	detail_clock+=delta
	var strength=clampf(absf(speed)/6,0,1)
	pivots.head.rotation.z=sin(detail_clock*2.0)*.012
	pivots.coat_front.rotation.z=sin(detail_clock*9)*.055*strength
	pivots.coat_back.rotation.z=-sin(detail_clock*9+.5)*.08*strength

static func guardian() -> Node3D:
	var root=Node3D.new()
	var texture=textures("kael")[15]
	var aura=piece(root,texture,1.55,2.10,Vector2(.5,.5),.08)
	var material=ShaderMaterial.new()
	material.shader=load("res://assets/shaders/painted_glow.gdshader")
	material.set_shader_parameter("art_texture",texture)
	material.set_shader_parameter("glow_color",Color("ffe09a"))
	material.set_shader_parameter("opacity",.17)
	aura.material_override=material
	return root
