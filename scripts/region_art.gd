extends RefCounted
const Art = preload("res://scripts/shapes.gd")
const Scenery = preload("res://scripts/scenery.gd")
const Detail = preload("res://scripts/forest_detail.gd")
static var materials: Dictionary = {}
static func theme_terrain(parent: Node3D,index: int) -> void:
	if index == 0: return
	if not materials.has(index):
		var material = ShaderMaterial.new()
		material.shader = preload("res://assets/shaders/forest_stone.gdshader")
		var colors = {1:[Color("291f22"),Color("665048"),Color("45271b"),Color("a05a2e")],2:[Color("729eac"),Color("d9eced"),Color("a6cbd4"),Color("edf4ee")],3:[Color("4b5c62"),Color("a1ae9c"),Color("4a6c3c"),Color("92ae67")],4:[Color("383449"),Color("7c738c"),Color("4d4e58"),Color("898a79")],5:[Color("262533"),Color("544b60"),Color("303b32"),Color("657250")],6:[Color("25222f"),Color("555064"),Color("393043"),Color("65546b")]}[index]
		for i in 4:
			var color: Color = colors[i]
			material.set_shader_parameter(["rock_dark","rock_light","moss_dark","moss_light"][i],Vector3(color.r,color.g,color.b))
		materials[index] = material
	for geometry in parent.find_children("*","GeometryInstance3D",true,false):
		if geometry.material_override is ShaderMaterial and geometry.material_override.shader == preload("res://assets/shaders/forest_stone.gdshader"): geometry.material_override = materials[index]
static func backdrop(parent: Node3D,index: int) -> void:
	if index in [0,5]:
		Scenery.backdrop(parent)
		return
	if index != 6: Detail.layers(parent)
	match index:
		1:
			for i in 14: Detail.stone(parent,Vector3(-12+i*6,1,-7-sin(i)*2),Vector3(5,8+sin(i)*3,5),i*.7)
			for x in [14,27,43,58]:
				var lava = Art.box(parent,Vector3(x,2,-5.5),Vector3(.7,6,.12),Color("de6127"))
				lava.material_override.emission_enabled = true
				lava.material_override.emission = Color("a53b12")
		2:
			for i in 15:
				var shard = Scenery.rune(parent,Vector3(-10+i*5,1.8,-5-sin(i)*1.5),Color("b4dfe9"))
				shard.scale = Vector3(2.2,5.5+sin(i)*1.7,2)
			for x in [-4,1,6]: Art.box(parent,Vector3(x,2.55,-2.8),Vector3(3,.12,2),Color("dfeef0"))
		3:
			for i in 14:
				var x = -10+i*5.4
				var height = 1.4+sin(i*2.3)*2
				Detail.stone(parent,Vector3(x,height,-8),Vector3(4,2.5,4),i*.7)
				if i%3 == 0: Scenery.model(parent,"ruin_arch",Vector3(x,height+.6,-8),Vector3.ONE*.65)
			for i in 22:
				var cloud = Art.orb(parent,Vector3(-12+i*3.8,-1.8+sin(i)*.7,-13),1.5,Color("d9e9e9"))
				cloud.scale = Vector3(1.8,.35,.6)
		4,6:
			for i in 12:
				var x = -12+i*6.7
				var height = 4.0+sin(i*1.7)*1.8
				var stone = Color("464052") if index == 6 else Color("666477")
				Art.box(parent,Vector3(x,height/2,-6),Vector3(3.4,height,3),stone)
				for side in [-1,0,1]: Art.box(parent,Vector3(x+side*1.1,height+.3,-6),Vector3(.65,.7,3),stone.lightened(.06))
				for y in [1.5,3.0]: Art.box(parent,Vector3(x,y,-4.45),Vector3(.35,.7,.04),Color("b494e5") if index == 6 else Color("d6c7a1"))
			if index == 6:
				Art.box(parent,Vector3(27,1.8,-10),Vector3(90,7,2),Color("302b40"))
				for x in [12,27,42,57]: Scenery.model(parent,"ruin_arch",Vector3(x,0,-3.8),Vector3.ONE*1.3)
static func landmark(parent: Node3D,index: int) -> void:
	if index == 0: return
	theme_terrain(parent,index)
	for x in [-4,1,6]: Art.box(parent,Vector3(x,2.6,-1.8),Vector3(.5,1,.06),[Color.WHITE,Color("9a582c"),Color("a5d5e0"),Color("829f88"),Color("756789"),Color("655477"),Color("483e59")][index])
	match index:
		1:
			for x in [22,29,40,55]:
				Art.box(parent,Vector3(x,-.03,-.8),Vector3(2.2,.1,1.5),Color("cf5726"))
				for i in 3: Art.orb(parent,Vector3(x-.5+i*.5,.15,-1.3),.15,Color("f4ad4a"),1)
			Art.box(parent,Vector3(33,2.1,.15),Vector3(.35,1.4,.3),Color("4e5829"))
		2:
			Art.box(parent,Vector3(17.5,-.5,-.3),Vector3(3,.12,2.2),Color("528eac"))
			for x in [12,23,32,47,56]:
				var shard = Scenery.rune(parent,Vector3(x,.5,-1),Color("a8e9fa"))
				shard.scale = Vector3(.5,1.7,.5)
		3:
			for x in [7,27,48]:
				Art.box(parent,Vector3(x,2,-3),Vector3(.3,4,.3),Color("6d6858"))
				for i in 4:
					var blade = Art.box(parent,Vector3(x,4,-2.8),Vector3(.22,3,.1),Color("bfcba7"))
					blade.rotation.z = i*PI/2+.4
		4:
			for x in [22,33,47]:
				Art.box(parent,Vector3(x,1,-1.1),Vector3(.25,2,.25),Color("72638f"))
				for side in [-1,1]: Art.box(parent,Vector3(x+side*.4,2,-1.1),Vector3(.15,.7,.15),Color("bb96ed"))
		5:
			for x in [11,28,38,53]: Art.box(parent,Vector3(x,.03,-.8),Vector3(1.8,.08,1.2),Color("58375c"))
		6:
			for i in 4: Scenery.rune(parent,Vector3(31.9+i*.65,3.5,-.3),[Color("ff9a44"),Color("9be5f6"),Color("d1b6ff"),Color("ffe5a2")][i])
