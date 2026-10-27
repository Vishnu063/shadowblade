extends Node
## One offline slot. Validate before replacing live state; retain previous valid save.
const DEFAULTS = {"version": 1, "checkpoint": 2.0, "quest": 0, "crystal": false,
	"boss": false, "secret": false, "powers": [0], "villages": ["Willowbrook"],
	"settings": {"sound": true, "shake": true, "controls": 1.0, "fps": 60, "quality": 1}}
var data: Dictionary = DEFAULTS.duplicate(true)
var save_path = "user://journey.json"
var last_error = ""

func valid(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	for key in DEFAULTS:
		if not value.has(key):
			return false
	if value.version != 1 or not value.checkpoint is float and not value.checkpoint is int:
		return false
	if not float(value.checkpoint) in [2.0, 24.0, 44.0]:
		return false
	if not value.quest is float and not value.quest is int:
		return false
	if float(value.quest) not in [0.0, 1.0, 2.0, 3.0]:
		return false
	for key in ["crystal", "boss", "secret"]:
		if not value[key] is bool:
			return false
	if not value.powers is Array or value.powers.size() != 1 or value.powers[0] != 0:
		return false
	if value.villages != ["Willowbrook"] or not value.settings is Dictionary:
		return false
	# Reject internally contradictory saves instead of silently skipping encounters.
	if value.boss and (not value.crystal or int(value.quest) != 3):
		return false
	if not value.boss and int(value.quest) == 3:
		return false
	if value.crystal and int(value.quest) < 2 or not value.crystal and int(value.quest) > 1:
		return false
	if float(value.checkpoint) == 44.0 and not value.crystal:
		return false
	var settings: Dictionary = value.settings
	for key in DEFAULTS.settings:
		if not settings.has(key):
			return false
	return settings.sound is bool and settings.shake is bool and (settings.controls is float or settings.controls is int) \
		and settings.controls >= 0.8 and settings.controls <= 1.4 \
		and settings.fps in [30.0, 60.0, 30, 60] and settings.quality in [0.0, 1.0, 0, 1]

func read_valid(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parser = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	return normalize(parser.data) if valid(parser.data) else {}

func normalize(source: Dictionary) -> Dictionary:
	# JSON represents all numbers as floats; restore the schema's stable types.
	var clean = source.duplicate(true)
	clean.version = int(clean.version)
	clean.checkpoint = float(clean.checkpoint)
	clean.quest = int(clean.quest)
	clean.powers = [0]
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
