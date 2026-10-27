extends Control
## Each finger owns an action. Sliding off, focus loss and menus release ownership.
var world: Node3D
var fingers: Dictionary = {}
var keys: Dictionary = {}
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
const POWER_NAMES = ["Arcane Bolt", "Flame Burst", "Frost Bind", "Wind Dash", "Lightning", "Guardian Light"]

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
	var r: float = 46 * Progress.data.settings.controls * minf(s.x / 1280.0, s.y / 720.0)
	r = maxf(r, 24)
	buttons = {
		"left": Rect2(Vector2(margin.x, s.y - margin.y - r * 2), Vector2.ONE * r * 2),
		"right": Rect2(Vector2(margin.x + r * 2.4, s.y - margin.y - r * 2), Vector2.ONE * r * 2),
		"attack": Rect2(Vector2(s.x - margin.x - r * 7.2, s.y - margin.y - r * 2), Vector2.ONE * r * 2),
		"jump": Rect2(Vector2(s.x - margin.x - r * 4.8, s.y - margin.y - r * 3.2), Vector2.ONE * r * 2),
		"magic": Rect2(Vector2(s.x - margin.x - r * 2.3, s.y - margin.y - r * 2), Vector2.ONE * r * 2),
		"interact": Rect2(Vector2(s.x / 2 - 65, s.y - margin.y - 64), Vector2(130, 54)),
		"pause": Rect2(Vector2(s.x - margin.x - 84, margin.y), Vector2(84, 48))}
	wheel_slots.clear()
	for i in 6:
		wheel_slots.append(s / 2 + Vector2.from_angle(-PI / 2 + i * TAU / 6) * 150)

func held(action: String) -> bool:
	if keys.get(action, false):
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
		"magic":
			magic_timer = 0
			magic_pending = true
		"interact": world.interact()
		"pause": world.open_pause()

func pointer_down(id: int, point: Vector2) -> void:
	if not world.playing:
		return
	for action in buttons:
		if buttons[action].has_point(point):
			# A second finger on magic must not reset an existing hold or cast twice.
			if action == "magic" and held("magic"):
				return
			fingers[id] = {"action": action, "position": point}
			press_action(action)
			return

func pointer_move(id: int, point: Vector2) -> void:
	if wheel_open:
		wheel_pointer = point
		return
	if not fingers.has(id):
		return
	var action: String = fingers[id].action
	if not buttons[action].has_point(point):
		fingers.erase(id)
		if action == "magic":
			magic_pending = false
	else:
		fingers[id].position = point

func finish_magic(point: Vector2) -> void:
	if wheel_open:
		for i in 6:
			if point.distance_to(wheel_slots[i]) < 56:
				notify_text("Arcane Bolt selected" if i == 0 else "Locked — discover the next villages")
		wheel_open = false
		world.playing = true
		fingers.clear()
		keys.clear()
	elif magic_pending and world.playing:
		if not world.player.cast():
			notify_text("Magic recovering…" if world.player.magic < world.player.bolt_cost else "Spell cooling down")
	magic_pending = false
	magic_timer = 0

func pointer_up(id: int, point: Vector2) -> void:
	if not fingers.has(id):
		return
	var action: String = fingers[id].action
	fingers.erase(id)
	if action == "magic":
		finish_magic(point)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			pointer_down(event.index, event.position)
		else:
			pointer_up(event.index, event.position)
	elif event is InputEventScreenDrag:
		pointer_move(event.index, event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pointer_down(-1, event.position)
		else:
			pointer_up(-1, event.position)
	elif event is InputEventMouseMotion:
		pointer_move(-1, event.position)
	elif event is InputEventKey and not event.echo:
		var mapping = {KEY_A: "left", KEY_LEFT: "left", KEY_D: "right", KEY_RIGHT: "right",
			KEY_SPACE: "jump", KEY_J: "attack", KEY_X: "attack", KEY_K: "magic", KEY_C: "magic",
			KEY_E: "interact", KEY_ESCAPE: "pause", KEY_TAB: "journal"}
		if not mapping.has(event.physical_keycode):
			return
		var action: String = mapping[event.physical_keycode]
		if not event.pressed:
			keys.erase(action)
			if action == "magic":
				finish_magic(wheel_slots[0] if wheel_open else Vector2.ZERO)
		elif world.playing:
			keys[action] = true
			if action == "journal":
				world.show_journal()
			else:
				press_action(action)
		elif action == "pause" and event.pressed:
			if wheel_open:
				finish_magic(Vector2.ZERO)
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
	var points = PackedVector2Array([Vector2(0, 8), Vector2(5, 0), Vector2(14, 0), Vector2(20, 6), Vector2(26, 0), Vector2(35, 0), Vector2(40, 8), Vector2(40, 18), Vector2(20, 38), Vector2(0, 18)])
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
	draw_rect(Rect2(x, y + 51, 180, 10), Color("233d55"))
	draw_rect(Rect2(x, y + 51, 180 * world.player.magic / world.player.max_magic, 10), Color("51baf5"))
	text_at(Vector2(x, y + 90), "KAEL  /  ARCANE BOLT", 16, Color("b5d9e9"))
	text_at(Vector2(s.x / 2 - 165, y + 12), "WILLOWBROOK  •  Whispering Forest", 17, Color("d2e7dd"))
	text_at(Vector2(x, y + 142), world.objective(), 18, Color("e8d9a5"))
	for action in buttons:
		var rect: Rect2 = buttons[action]
		var active = held(action)
		draw_style_box(panel_style(Color(0.18, 0.42, 0.51, 0.9) if active else Color(0.025, 0.07, 0.10, 0.75)), rect)
		var labels = {"left": "<", "right": ">", "attack": "SWORD", "jump": "JUMP", "magic": "BOLT", "interact": "TALK / USE", "pause": "II"}
		var label: String = labels[action]
		var width = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		text_at(rect.get_center() + Vector2(-width / 2, 6), label, 16)
	if status_time > 0:
		var width = font.get_string_size(status, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		draw_rect(Rect2(s.x / 2 - width / 2 - 20, s.y * 0.24 - 30, width + 40, 52), Color(0.02, 0.05, 0.08, 0.9))
		text_at(Vector2(s.x / 2 - width / 2, s.y * 0.24 + 5), status, 22)
	if world.hit_flash > 0:
		draw_rect(Rect2(Vector2.ZERO, s), Color(0.8, 0.1, 0.15, world.hit_flash * 0.5))
	if wheel_open:
		draw_rect(Rect2(Vector2.ZERO, s), Color(0.01, 0.03, 0.06, 0.87))
		text_at(s / 2 + Vector2(-103, -230), "CHOOSE YOUR POWER", 23)
		text_at(s / 2 + Vector2(-142, 260), "Slide and release • Outside to cancel", 18)
		for i in 6:
			var point = wheel_slots[i]
			draw_circle(point, 54, Color("245d7d") if i == 0 else Color("26313b"))
			if point.distance_to(wheel_pointer) < 56:
				draw_arc(point, 56, 0, TAU, 40, Color("c0e5eb"), 3)
			text_at(point + Vector2(-43, 0), "BOLT" if i == 0 else "LOCKED", 16)
			text_at(point + Vector2(-46, 22), POWER_NAMES[i], 12)

func panel_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(16)
	style.set_border_width_all(1)
	style.border_color = Color(0.5, 0.75, 0.8, 0.3)
	return style
