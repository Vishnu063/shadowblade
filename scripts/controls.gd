extends Control
## Every pointer/key owns its action; canceled gestures never produce a spell.
var world: Node3D
var fingers: Dictionary = {}
var keys: Dictionary = {} # Scripted simulation only; physical keys have separate ownership.
var key_codes: Dictionary = {}
var magic_owner = ""
var magic_timer = 0.0
var magic_pending = false
var wheel_open = false
var wheel_pointer = Vector2.ZERO
var status = ""
var status_time = 0.0
var buttons: Dictionary = {}
var wheel_slots: Array[Vector2] = []
var font: Font
var margin = Vector2(28, 24)
var wheel_scale = 1.0
var style_cache: Dictionary = {}
const Campaign = preload("res://scripts/campaign.gd")
const POWER_NAMES = Campaign.POWERS

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	font = ThemeDB.fallback_font
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout_buttons()

func layout_buttons() -> void:
	var s = get_viewport_rect().size
	var safe = DisplayServer.get_display_safe_area()
	var window = DisplayServer.window_get_size()
	margin = Vector2(28, 24)
	if safe.size.x > 0 and window.x > 0:
		margin.x += maxf(safe.position.x, window.x - safe.end.x) * s.x / window.x
		margin.y += maxf(safe.position.y, window.y - safe.end.y) * s.y / window.y
	var r: float = 48 * Progress.data.settings.controls * minf(s.x / 1280.0, s.y / 720.0)
	r = maxf(r, 24)
	buttons = {
		"left": Rect2(Vector2(margin.x + 8, s.y - margin.y - 24 - r * 2), Vector2.ONE * r * 2),
		"right": Rect2(Vector2(margin.x + 8 + r * 2.7, s.y - margin.y - 24 - r * 2), Vector2.ONE * r * 2),
		"attack": Rect2(Vector2(s.x - margin.x - r * 6.8, s.y - margin.y - 24 - r * 2), Vector2.ONE * r * 2),
		"jump": Rect2(Vector2(s.x - margin.x - r * 4.4, s.y - margin.y - 24 - r * 2), Vector2.ONE * r * 2),
		"magic": Rect2(Vector2(s.x - margin.x - r * 2.0, s.y - margin.y - 24 - r * 2), Vector2.ONE * r * 2),
		"interact": Rect2(Vector2(s.x / 2 - 65, s.y - margin.y - 64), Vector2(130, 54)),
		"pause": Rect2(Vector2(s.x - margin.x - 84, margin.y), Vector2(84, 48))}
	wheel_scale = minf(1, (s.y - margin.y * 2) / 600.0)
	wheel_slots.clear()
	for i in 6:
		wheel_slots.append(s / 2 + Vector2.from_angle(-PI / 2 + i * TAU / 6) * 150 * wheel_scale)

func held(action: String) -> bool:
	if keys.get(action, false) or key_codes.values().has(action):
		return true
	for value in fingers.values():
		if value.action == action:
			return true
	return false

func axis() -> float:
	return float(held("right")) - float(held("left"))

func reset_input() -> void:
	fingers.clear()
	keys.clear()
	key_codes.clear()
	magic_owner = ""
	magic_pending = false
	magic_timer = 0
	wheel_open = false

func notify_text(text: String) -> void:
	status = text
	status_time = 4

func press_action(action: String) -> void:
	match action:
		"jump": world.player.request_jump()
		"attack": world.player.attack()
		"interact": world.interact()
		"pause": world.open_pause()

func begin_magic(owner: String) -> void:
	if not magic_owner.is_empty():
		return
	magic_owner = owner
	magic_timer = 0
	magic_pending = true

func pointer_down(id: int, point: Vector2) -> void:
	if not world.playing:
		return
	# Reused pointer IDs cancel old ownership rather than leaving a pending cast.
	cancel_pointer(id)
	for action in buttons:
		if buttons[action].has_point(point):
			if action == "magic" and not magic_owner.is_empty():
				return
			fingers[id] = {"action": action, "position": point}
			if action == "magic":
				begin_magic("pointer:%d" % id)
			else:
				press_action(action)
			return

func pointer_move(id: int, point: Vector2) -> void:
	if wheel_open:
		if magic_owner == "pointer:%d" % id:
			wheel_pointer = point
		return
	if not fingers.has(id):
		return
	var action: String = fingers[id].action
	if not buttons[action].has_point(point):
		cancel_pointer(id)
	else:
		fingers[id].position = point

func finish_magic(point: Vector2, canceled: bool = false) -> void:
	if wheel_open:
		if not canceled:
			for i in 6:
				if point.distance_to(wheel_slots[i]) < 56 * wheel_scale:
					if world.player.select_power(i):
						notify_text(POWER_NAMES[i]+" selected")
						world.persist()
					else: notify_text("Locked — discover the next villages")
		wheel_open = false
		# Closing a gesture cannot dismiss a real pause/settings/dialogue menu.
		world.playing = world.menu_mode.is_empty() and world.started
		fingers.clear()
		keys.clear()
		key_codes.clear()
	elif magic_pending and world.playing and not canceled:
		if not world.player.cast():
			notify_text("Magic recovering…" if world.player.magic < world.player.spell_cost() else "Spell cooling down")
	magic_owner = ""
	magic_pending = false
	magic_timer = 0

func cancel_pointer(id: int) -> void:
	fingers.erase(id)
	if magic_owner == "pointer:%d" % id:
		finish_magic(Vector2.ZERO, true)

func pointer_up(id: int, point: Vector2) -> void:
	if not fingers.has(id):
		return
	var action: String = fingers[id].action
	fingers.erase(id)
	if action == "magic" and magic_owner == "pointer:%d" % id:
		finish_magic(point, not wheel_open and not buttons.magic.has_point(point))

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.canceled:
			cancel_pointer(event.index)
		elif event.pressed:
			pointer_down(event.index, event.position)
		else:
			pointer_up(event.index, event.position)
	elif event is InputEventScreenDrag:
		pointer_move(event.index, event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Leave emulated mouse events for Godot's menu buttons, not gameplay actions.
		if event.device == InputEvent.DEVICE_ID_EMULATION:
			return
		if event.pressed:
			pointer_down(-1, event.position)
		else:
			pointer_up(-1, event.position)
	elif event is InputEventMouseMotion:
		if event.device != InputEvent.DEVICE_ID_EMULATION:
			pointer_move(-1, event.position)
	elif event is InputEventKey and not event.echo:
		if event.pressed and world.playing and event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_6:
			if world.player.select_power(event.physical_keycode-KEY_1): world.persist()
			return
		var mapping = {KEY_A: "left", KEY_LEFT: "left", KEY_D: "right", KEY_RIGHT: "right",
			KEY_SPACE: "jump", KEY_J: "attack", KEY_X: "attack", KEY_K: "magic", KEY_C: "magic",
			KEY_E: "interact", KEY_ESCAPE: "pause", KEY_TAB: "journal"}
		var code: int = event.physical_keycode
		if not mapping.has(code):
			return
		var action: String = mapping[code]
		var owner = "key:%d" % code
		if not event.pressed:
			key_codes.erase(code)
			if action == "magic" and magic_owner == owner:
				finish_magic(wheel_slots[0] if wheel_open else Vector2.ZERO)
		elif world.playing:
			key_codes[code] = action
			if action == "magic":
				begin_magic(owner)
			elif action == "journal":
				world.show_journal()
			else:
				press_action(action)
		elif action == "pause" and event.pressed:
			if wheel_open:
				finish_magic(Vector2.ZERO, true)
			elif world.menu_mode == "pause":
				world.resume()

func _process(delta: float) -> void:
	layout_buttons()
	status_time = maxf(0, status_time - delta)
	if magic_pending and world.playing:
		magic_timer += delta
		if magic_timer >= 0.35:
			wheel_open = true
			magic_pending = false
			world.playing = false
			wheel_pointer = Vector2.ZERO
	queue_redraw()

func text_at(point: Vector2, value: String, size_px: int, color: Color = Color.WHITE) -> void:
	draw_string(font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)

func heart(origin: Vector2, fill: float) -> void:
	var points = PackedVector2Array()
	for i in 64:
		var angle = i * TAU / 64
		points.append(Vector2(20 + 16 * pow(sin(angle), 3) * 1.25, 18 - (13 * cos(angle) - 5 * cos(2 * angle) - 2 * cos(3 * angle) - cos(4 * angle)) * 1.15))
	var base = PackedVector2Array()
	for point in points:
		base.append(point + origin)
	draw_colored_polygon(base, Color("442c3b"))
	if fill == 1:
		draw_colored_polygon(base, Color("f45268"))
	elif fill > 0:
		var half = PackedVector2Array([origin + Vector2(0, 8), origin + Vector2(5, 0), origin + Vector2(14, 0), origin + Vector2(20, 6), origin + Vector2(20, 38), origin + Vector2(0, 18)])
		draw_colored_polygon(half, Color("f45268"))

func _draw() -> void:
	if world == null or world.player == null:
		return
	var s = get_viewport_rect().size
	if not world.started:
		return
	var x = margin.x
	var y = margin.y
	draw_style_box(panel_style(Color(0.03, 0.08, 0.12, 0.85)), Rect2(x - 12, y - 12, 230, 125))
	for i in 3:
		heart(Vector2(x + i * 48, y), clampf((world.player.health - i * 2) / 2.0, 0, 1))
	draw_rect(Rect2(x - 3, y + 48, 186, 16), Color("b5a36e"))
	draw_rect(Rect2(x - 1, y + 50, 182, 12), Color("183340"))
	draw_rect(Rect2(x, y + 51, 180, 10), Color("233d55"))
	draw_rect(Rect2(x, y + 51, 180 * world.player.magic / world.player.max_magic, 10), Color("51baf5"))
	text_at(Vector2(x, y + 90), "KAEL / " + POWER_NAMES[int(Progress.data.selected_power)].to_upper(), 16, Color("b5d9e9"))
	text_at(Vector2(s.x / 2 - 165, y + 12), Campaign.REGIONS[world.region_index].to_upper(), 21, Color("d2e7dd"))
	text_at(Vector2(x, y + 142), world.objective(), 18, Color("e8d9a5"))
	for action in buttons:
		var rect: Rect2 = buttons[action]
		var active = held(action)
		if action != "interact":
			draw_circle(rect.get_center(), rect.size.x / 2, Color(0.08, 0.20, 0.24, 0.88) if active else Color(0.025, 0.05, 0.07, 0.67))
			draw_arc(rect.get_center(), rect.size.x / 2 - 1, 0, TAU, 48, Color(0.8, 0.83, 0.79, 0.85), 2, true)
		else:
			draw_style_box(panel_style(Color(0.025, 0.07, 0.1, 0.7)), rect)
		var label: String = {"left": "", "right": "", "attack": "", "jump": "", "magic": "", "interact": "TALK / USE", "pause": ""}[action]
		var center = rect.get_center()
		if action in ["attack", "jump", "magic"]:
			center.y += 10
		if action in ["left", "right"]:
			var sign_value = -1 if action == "left" else 1
			draw_colored_polygon(PackedVector2Array([center + Vector2(sign_value * 13, 0), center + Vector2(-sign_value * 8, -12), center + Vector2(-sign_value * 8, 12)]), Color("d8e3d9"))
		elif action == "pause":
			for offset in [-5, 5]:
				draw_rect(Rect2(center + Vector2(offset - 2, -9), Vector2(4, 18)), Color("dfd6af"))
		elif action == "attack":
			draw_line(center + Vector2(-11, 0), center + Vector2(12, -24), Color("e5e3cb"), 4, true)
			draw_line(center + Vector2(-13, -12), center + Vector2(0, 1), Color("c9ad6c"), 4, true)
		elif action == "jump":
			draw_polyline(PackedVector2Array([center + Vector2(-13, -7), center + Vector2(0, -23), center + Vector2(13, -7)]), Color("dce7d9"), 4, true)
			draw_line(center + Vector2(0, -22), center + Vector2(0, 1), Color("dce7d9"), 4, true)
		elif action == "magic":
			draw_colored_polygon(PackedVector2Array([center + Vector2(3, -28), center + Vector2(-11, -10), center + Vector2(-1, -10), center + Vector2(-4, 6), center + Vector2(12, -15), center + Vector2(3, -15)]), Color("76dbed") if world.player.magic >= world.player.spell_cost() else Color("73858a"))
		var width = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		text_at(center + Vector2(-width / 2, 24 if action in ["attack", "jump", "magic"] else 6), label, 15)
	if world.player.position.x > 43 and not Progress.data.boss:
		var boss = world.enemies[3]
		text_at(Vector2(s.x / 2 - 105, y + 53), Campaign.BOSSES[world.region_index].to_upper(), 17, Color("e5c7a5"))
		draw_rect(Rect2(s.x / 2 - 135, y + 65, 270, 6), Color("263a3b"))
		draw_rect(Rect2(s.x / 2 - 135, y + 65, 270 * maxf(boss.health, 0) / boss.max_health, 6), Color("d3ae77"))
	if status_time > 0:
		var width = font.get_string_size(status, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		draw_rect(Rect2(s.x / 2 - width / 2 - 20, s.y * 0.24 - 30, width + 40, 52), Color(0.02, 0.05, 0.08, 0.9))
		text_at(Vector2(s.x / 2 - width / 2, s.y * 0.24 + 5), status, 22)
	if world.hit_flash > 0:
		draw_rect(Rect2(Vector2.ZERO, s), Color(0.8, 0.1, 0.15, world.hit_flash * 0.5))
	if wheel_open:
		draw_rect(Rect2(Vector2.ZERO, s), Color(0.01, 0.03, 0.06, 0.87))
		text_at(s / 2 + Vector2(-103, -230 * wheel_scale), "CHOOSE YOUR POWER", 23)
		text_at(s / 2 + Vector2(-142, 260 * wheel_scale), "Slide and release • Outside to cancel", 18)
		for i in 6:
			var point = wheel_slots[i]
			draw_circle(point, 54 * wheel_scale, Color("245d7d") if Progress.data.powers.has(i) else Color("26313b"))
			if point.distance_to(wheel_pointer) < 56 * wheel_scale:
				draw_arc(point, 56 * wheel_scale, 0, TAU, 40, Color("c0e5eb"), 3)
			text_at(point + Vector2(-43, 0), ("ACTIVE" if i == int(Progress.data.selected_power) else str(int(Campaign.COSTS[i]))+" MP") if Progress.data.powers.has(i) else "LOCKED", 16)
			text_at(point + Vector2(-46, 22), POWER_NAMES[i], 12)

func panel_style(color: Color) -> StyleBoxFlat:
	var key = color.to_html()
	if style_cache.has(key):
		return style_cache[key]
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(16)
	style.set_border_width_all(1)
	style.border_color = Color(0.5, 0.75, 0.8, 0.3)
	style_cache[key] = style
	return style
