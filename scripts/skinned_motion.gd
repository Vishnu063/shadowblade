extends RefCounted
## Manual AnimationPlayer clips deform the exported weighted Skeleton3D.
var player: AnimationPlayer
var actor: Node3D
var skeleton: Skeleton3D
var action = ""
var action_left = 0.0
var last_floor = true
const BONES = {"l":"ThighL","r":"ThighR","kl":"ShinL","kr":"ShinR","fl":"FootL","fr":"FootR","a":"ArmL","b":"ArmR","ea":"ForearmL","eb":"ForearmR","s":"Sword","c":"Scarf","ct":"ScarfTip","cl":"CoatL","cr":"CoatR","ch":"Chest","hd":"Head","sp":"Spine"}
func _init(body: Node3D) -> void:
	actor = body
	skeleton = body.find_child("Skeleton3D",true,false)
	player = AnimationPlayer.new()
	body.add_child(player)
	player.root_node = NodePath("..")
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var lib = AnimationLibrary.new()
	player.add_animation_library("",lib)
	clip(lib,"idle",2.4,[{}, {"h":.005,"ch":.012,"hd":-.01,"c":.045,"ct":-.05}, {}],true)
	var run = []
	for i in 9:
		var a = TAU*i/8
		run.append({"l":sin(a)*.62,"r":-sin(a)*.62,"kl":maxf(0,-sin(a))*.92,"kr":maxf(0,sin(a))*.92,"fl":sin(a+.5)*.13,"fr":-sin(a+.5)*.13,"a":-sin(a)*.42,"b":sin(a)*.32,"ea":-.24,"eb":.22,"ch":sin(a)*.035,"hd":-sin(a)*.025,"h":absf(sin(a))*.035,"c":.13+sin(a-1)*.05,"ct":sin(a-1.5)*.10,"cl":sin(a)*.1,"cr":-sin(a)*.1})
	clip(lib,"run",.7,run,true)
	clip(lib,"rise",.3,[{"l":.35,"r":-.3,"kl":.8,"kr":.6,"a":-.35,"b":.22,"c":.2,"ct":.1}])
	clip(lib,"fall",.3,[{"l":-.2,"r":.3,"kl":.35,"kr":.55,"a":.45,"b":-.2,"c":-.12,"ct":-.1}])
	clip(lib,"land",.18,[{"h":-.10,"l":-.15,"r":.2,"kl":.6,"kr":.5,"ch":-.08},{}])
	for i in 3:
		var sign = -1.0 if i==1 else 1.0
		clip(lib,"slash_%d" % (i+1),.3,[{"b":-.7*sign,"eb":.5,"s":-.4,"ch":-.08*sign,"a":.25}, {"b":1.0*sign,"eb":-.08,"s":.65*sign,"ch":.12*sign,"l":-.1,"r":.15}, {}])
	for i in [0,1,2,4,5]:
		clip(lib,"cast_%d" % i,.5,[{"a":-.3,"ea":.65,"ch":-.03},{"a":1.20 if i!=5 else .7,"ea":-.3,"b":-.22,"ch":.04,"c":.15,"ct":.2,"h":-.06 if i==2 else 0.0},{}])
	clip(lib,"dash",.2,[{"l":.65,"r":-.5,"kl":.8,"kr":1,"a":.4,"b":.35,"ch":-.15,"c":.3,"ct":.25,"h":-.06}])
	clip(lib,"hit",.22,[{"ch":-.12,"hd":-.15,"a":.5,"b":-.4,"kl":.3,"kr":.3,"h":-.04},{}])
	clip(lib,"defeat",.75,[{}, {"h":-.35,"l":-.4,"r":.3,"kl":1.2,"kr":1,"ch":-.2,"hd":-.3}, {"h":-.65,"l":-.6,"r":.4,"kl":1.5,"kr":1.2,"ch":-.35,"hd":-.45}])
	player.play("idle")
	player.advance(0)
func clip(lib: AnimationLibrary,name: String,duration: float,poses: Array,loop: bool=false) -> void:
	var anim = Animation.new()
	anim.length = duration
	if loop: anim.loop_mode = Animation.LOOP_LINEAR
	for key in BONES:
		var bone = skeleton.find_bone(BONES[key])
		assert(bone>=0,"Missing deform bone "+BONES[key])
		var track = anim.add_track(Animation.TYPE_ROTATION_3D)
		anim.track_set_path(track,NodePath(str(actor.get_path_to(skeleton))+":"+BONES[key]))
		var axis: Vector3 = skeleton.get_bone_global_rest(bone).basis.inverse()*Vector3(0,0,1)
		for i in poses.size():
			var value: float = poses[i].get(key,0.0)
			if key=="s": value -= .55
			anim.rotation_track_insert_key(track,duration*i/maxi(1,poses.size()-1),skeleton.get_bone_rest(bone).basis.get_rotation_quaternion()*Quaternion(axis.normalized(),value))
	var h = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(h,NodePath(".:position:y"))
	for i in poses.size(): anim.track_insert_key(h,duration*i/maxi(1,poses.size()-1),poses[i].get("h",0.0)-.85)
	lib.add_animation(name,anim)
func trigger(name: String,duration: float) -> void:
	action=name
	action_left=duration
	player.play(name,.045)
	player.advance(0)
func reset() -> void:
	action=""
	action_left=0
	last_floor=true
	player.play("idle")
	player.advance(0)
func update(delta: float,hero: CharacterBody3D) -> void:
	action_left=maxf(0,action_left-delta)
	if hero.is_on_floor() and not last_floor and action_left==0: trigger("land",.18)
	last_floor=hero.is_on_floor()
	var desired="idle"
	if action_left>0: desired=action
	elif hero.dash_time>0: desired="dash"
	elif not hero.is_on_floor(): desired="rise" if hero.velocity.y>0 else "fall"
	elif absf(hero.velocity.x)>.3: desired="run"
	if player.current_animation != desired: player.play(desired,.10)
	player.speed_scale=clampf(absf(hero.velocity.x)/6,.6,1.5) if desired=="run" else 1.0
	player.advance(delta)
