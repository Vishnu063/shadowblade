extends RefCounted
## Rigid skeletal clips share the actor's existing collision and combat timing.
var player: AnimationPlayer
var actor: Node3D
var action = ""
var action_left = 0.0
var last_floor = true
var pivots = {}
var rest = {}

func _init(body: Node3D) -> void:
	actor = body
	var arm = body.find_child("SwordArm")
	var sword = body.find_child("Sword")
	if sword != null and arm != null:
		sword.reparent(arm.find_child("Elbow*"),true)
	pivots = {"l":body.find_child("LeftLeg"),"r":body.find_child("RightLeg"),"a":body.find_child("LeftArm"),"b":arm,"s":sword,"c":body.find_child("Scarf")}
	pivots.kl = pivots.l.find_child("Knee*")
	pivots.kr = pivots.r.find_child("Knee*")
	pivots.ea = pivots.a.find_child("Elbow*")
	pivots.eb = pivots.b.find_child("Elbow*")
	for key in pivots: rest[key] = pivots[key].rotation.z
	rest.s -= .5
	player = AnimationPlayer.new()
	body.add_child(player)
	player.root_node = NodePath("..")
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var library = AnimationLibrary.new()
	player.add_animation_library("",library)
	clip(library,"idle",2.0,[{}, {"h":.008,"c":.08}, {}],true)
	clip(library,"run",.6,[{"l":.6,"r":-.6,"kr":.85,"a":-.4,"b":.22,"h":.02}, {"kl":.5,"kr":.2,"h":-.025}, {"l":-.6,"r":.6,"kl":.85,"a":.4,"b":-.2,"h":.02}, {"kl":.2,"kr":.5,"h":-.025}, {"l":.6,"r":-.6,"kr":.85,"a":-.4,"b":.22,"h":.02}],true)
	clip(library,"rise",.25,[{"l":.4,"r":-.35,"kl":.7,"kr":.9,"a":-.4,"b":.2,"c":.25}])
	clip(library,"fall",.25,[{"l":-.2,"r":.35,"kl":.4,"kr":.6,"a":.65,"b":-.3,"c":-.2}])
	clip(library,"land",.16,[{"h":-.11,"l":-.2,"r":.3,"kl":.7,"kr":.6}, {}])
	for i in 3:
		var swing = -1.0 if i == 1 else 1.0
		clip(library,"slash_%d" % (i+1),.3,[{"b":-.8*swing,"eb":.5,"s":-.5*swing,"a":.3}, {"b":1.1*swing,"eb":-.25,"s":.9*swing,"l":-.15,"r":.18}, {}])
	for i in [0,1,2,4,5]:
		clip(library,"cast_%d" % i,.42,[{"a":-.5,"ea":.9,"b":-.2}, {"a":-1.3 if i != 5 else -.7,"ea":-.25,"l":-.15,"r":.18,"b":.3,"c":.25,"h":-.06 if i == 2 else 0.0}, {}])
	clip(library,"dash",.2,[{"l":.85,"r":-.7,"kl":.8,"kr":1,"a":.6,"b":.5,"c":.5,"h":-.08}])
	clip(library,"hit",.22,[{"a":.65,"b":-.6,"kl":.4,"kr":.3,"h":-.07}, {}])
	clip(library,"defeat",.75,[{}, {"h":-.35,"l":-.5,"r":.25,"kl":1.4,"kr":1.2,"a":.5,"b":.7}, {"h":-.65,"l":-.7,"r":.35,"kl":1.7,"kr":1.4,"a":.8,"b":.9}])
	player.play("idle")
	player.advance(0)

func clip(library: AnimationLibrary,name: String,duration: float,poses: Array,loop: bool = false) -> void:
	var anim = Animation.new()
	anim.length = duration
	if loop: anim.loop_mode = Animation.LOOP_LINEAR
	for key in ["h","l","r","kl","kr","a","b","ea","eb","s","c"]:
		var index = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(index,NodePath(".:position:y") if key == "h" else NodePath(str(actor.get_path_to(pivots[key]))+":rotation:z"))
		for j in poses.size():
			var value: float = poses[j].get(key,0.0) + (0.0 if key == "h" else rest[key])
			anim.track_insert_key(index,duration*j/maxi(1,poses.size()-1),value)
	library.add_animation(name,anim)

func trigger(name: String,duration: float) -> void:
	action = name
	action_left = duration
	player.play(name,.035)
	player.advance(0)

func reset() -> void:
	action = ""
	action_left = 0
	player.play("idle")
	player.advance(0)
	last_floor = true

func update(delta: float,hero: CharacterBody3D) -> void:
	action_left = maxf(0,action_left-delta)
	if hero.is_on_floor() and not last_floor and action_left == 0: trigger("land",.16)
	last_floor = hero.is_on_floor()
	var desired = "idle"
	if action_left > 0: desired = action
	elif hero.dash_time > 0: desired = "dash"
	elif not hero.is_on_floor(): desired = "rise" if hero.velocity.y > 0 else "fall"
	elif absf(hero.velocity.x) > .3: desired = "run"
	if player.current_animation != desired: player.play(desired,.07)
	player.speed_scale = clampf(absf(hero.velocity.x)/6.0,.5,1.8) if desired == "run" else 1.0
	player.advance(delta)
