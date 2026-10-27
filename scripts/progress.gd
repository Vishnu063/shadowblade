extends Node
## One offline slot. Validate before replacing live state; retain previous valid save.
const Campaign = preload("res://scripts/campaign.gd")
const DEFAULTS = {"version":2,"checkpoint":2.0,"quest":0,"crystal":false,"boss":false,"secret":false,"powers":[0],"villages":["Willowbrook"],"selected_power":0,"seals":[],"campaign":{"region":0,"unlocked":0,"completed":[],"states":{}},"settings":{"sound":true,"shake":true,"controls":1.0,"fps":60,"quality":1}}
var data: Dictionary = DEFAULTS.duplicate(true)
var save_path = "user://journey.json"
var last_error = ""
func integer(value: Variant, low: int, high: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= low and value <= high
func chapter_valid(value: Variant) -> bool:
	if not value is Dictionary: return false
	for key in ["checkpoint","quest","crystal","boss","secret"]:
		if not value.has(key): return false
	if not integer(value.checkpoint,2,44) or not float(value.checkpoint) in [2.0,24.0,44.0]: return false
	if not integer(value.quest,0,3): return false
	for key in ["crystal","boss","secret"]:
		if not value[key] is bool: return false
	if value.boss and (not value.crystal or int(value.quest) != 3): return false
	if not value.boss and int(value.quest) == 3: return false
	if value.crystal and int(value.quest) < 2 or not value.crystal and int(value.quest) > 1: return false
	if float(value.checkpoint) == 44.0 and not value.crystal: return false
	if value.has("seals"):
		if not value.seals is Array or value.seals.size() > 4: return false
		var seen = []
		for seal in value.seals:
			if not integer(seal,0,5) or not int(seal) in [1,2,4,5] or seen.has(int(seal)): return false
			seen.append(int(seal))
	return true
func valid(value: Variant) -> bool:
	if not value is Dictionary or not chapter_valid(value): return false
	for key in ["version","powers","villages","settings"]:
		if not value.has(key): return false
	if not integer(value.version,1,2) or not value.settings is Dictionary: return false
	var settings: Dictionary = value.settings
	for key in DEFAULTS.settings:
		if not settings.has(key): return false
	if not (settings.sound is bool and settings.shake is bool and (settings.controls is float or settings.controls is int) and is_finite(float(settings.controls)) and settings.controls >= .8 and settings.controls <= 1.4 and integer(settings.fps,30,60) and int(settings.fps) in [30,60] and integer(settings.quality,0,1)): return false
	if int(value.version) == 1: return value.powers is Array and value.powers.size() == 1 and integer(value.powers[0],0,0) and value.villages == ["Willowbrook"]
	for key in ["campaign","selected_power","seals"]:
		if not value.has(key): return false
	if not value.campaign is Dictionary: return false
	var campaign: Dictionary = value.campaign
	for key in ["region","unlocked","completed","states"]:
		if not campaign.has(key): return false
	if not integer(campaign.region,0,6) or not integer(campaign.unlocked,0,6) or campaign.region > campaign.unlocked: return false
	if not campaign.completed is Array or campaign.completed.size() > 7 or campaign.unlocked > campaign.completed.size(): return false
	for i in campaign.completed.size():
		if not integer(campaign.completed[i],i,i): return false
	if not value.powers is Array or value.powers.size() != mini(5,int(campaign.unlocked))+1: return false
	for i in value.powers.size():
		if not integer(value.powers[i],i,i): return false
	if value.villages != Campaign.NAMES.slice(0,mini(6,int(campaign.unlocked)+1)): return false
	if not integer(value.selected_power,0,mini(5,int(campaign.unlocked))): return false
	if bool(value.boss) != (int(campaign.region) < campaign.completed.size()): return false
	if not campaign.states is Dictionary or campaign.states.size() > 7: return false
	for key in campaign.states:
		if not key is String or not key.is_valid_int() or key != str(int(key)) or int(key) < 0 or int(key) > campaign.unlocked: return false
		if not chapter_valid(campaign.states[key]): return false
	for region in campaign.completed.size():
		if region != int(campaign.region) and (not campaign.states.has(str(region)) or not campaign.states[str(region)].boss): return false
	if int(campaign.region) == 6 and value.crystal and value.seals.size() != 4: return false
	return true

func read_valid(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parser = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	return normalize(parser.data) if valid(parser.data) else {}

func normalize(source: Dictionary) -> Dictionary:
	var clean = source.duplicate(true)
	if int(clean.version) == 1:
		clean.campaign = DEFAULTS.campaign.duplicate(true)
		if clean.boss: clean.campaign.completed = [0]
		clean.selected_power = 0
		clean.seals = []
	clean.version = 2
	clean.checkpoint = float(clean.checkpoint)
	clean.quest = int(clean.quest)
	clean.powers = range(mini(5,int(clean.campaign.unlocked))+1)
	clean.selected_power = int(clean.selected_power)
	clean.campaign.region = int(clean.campaign.region)
	clean.campaign.unlocked = int(clean.campaign.unlocked)
	clean.campaign.completed = range(clean.campaign.completed.size())
	var seals = []
	for seal in clean.seals: seals.append(int(seal))
	clean.seals = seals
	clean.settings.controls = float(clean.settings.controls)
	clean.settings.fps = int(clean.settings.fps)
	clean.settings.quality = int(clean.settings.quality)
	return clean

func load_game() -> bool:
	var loaded = read_valid(save_path)
	if loaded.is_empty():
		loaded = read_valid(save_path + ".bak")
	if loaded.is_empty():
		return false
	data = loaded
	return true

func save_game() -> bool:
	last_error = ""
	if not valid(data):
		last_error = "Progress validation failed"
		return false
	data = normalize(data)
	var file = FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null:
		last_error = "Cannot write save"
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()
	if read_valid(save_path + ".tmp").is_empty():
		last_error = "Save verification failed"
		return false
	if not read_valid(save_path).is_empty():
		var backup_error = DirAccess.copy_absolute(save_path, save_path + ".bak")
		if backup_error != OK:
			last_error = "Cannot preserve previous save"
			return false
	if DirAccess.rename_absolute(save_path + ".tmp", save_path) != OK:
		last_error = "Cannot replace save"
		return false
	return true

func new_game() -> void:
	var settings: Dictionary = data.settings.duplicate()
	data = DEFAULTS.duplicate(true)
	data.settings = settings
