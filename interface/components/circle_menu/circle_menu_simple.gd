@tool
class_name CircleMenuSimple
extends CircleContainer

@export var open: bool = false:
	set(value):
		open = value
		if open: _reset_opened()
		else: _reset_closed()

@export_category("Controls")
@export var open_button_path: NodePath
@export var close_button_path: NodePath
@export var tap_outside_to_close: bool = false
@export var start_open: bool = false
@export var test_open: bool = false:
	set(value):
		test_open = value
		if Engine.is_editor_hint():
			if test_open: _on_open()
			else: _on_close()

@export_category("Style")
@export var animation_duration: float = 0.6
@export var background_color: Color = Color("#3f3f46"):
	set(value):
		background_color = value
		queue_redraw()

@export var border_color: Color = Color.TRANSPARENT:
	set(value):
		border_color = value
		queue_redraw()

@export var border_width: float = 0.0:
	set(value):
		border_width = value
		if open: _temp_background_radius = _background_radius
		queue_redraw()

## the distance between the radius of the background circle 
## and the radius of the container circle
@export var background_margin: float = 0.0:
	set(value):
		background_margin = value
		queue_redraw()

var _open_button: Button:
	get: return get_node_or_null(open_button_path)

var _close_button: Button:
	get: return get_node_or_null(close_button_path)

var _background_radius: float:
	get: return (min(size.x, size.y) / 2.0) - extra_margin - background_margin

var _temp_background_radius: float = _background_radius:
	set(value):
		_temp_background_radius = value
		queue_redraw()


func _ready() -> void:
	if start_open: _on_open()
	else: _reset_closed()
	
	if _open_button: _open_button.pressed.connect(_on_open)
	if _close_button: _close_button.pressed.connect(_on_close)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and tap_outside_to_close and open:
		_on_close()


func _draw() -> void:
	draw_circle(center, _temp_background_radius, background_color)
	if border_width > 0:
		draw_arc(center, _temp_background_radius, 0, deg_to_rad(360), 360, border_color, border_width)


func _reset_opened() -> void:
	_temp_background_radius = _background_radius
	_temp_degree_range = degree_range
	_temp_degree_offset = degree_offset
	_temp_extra_margin = extra_margin
	
	for child in get_controlled_children():
		child.rotation = 0
		child.scale = Vector2.ONE
		child.modulate.a = 1
	
	if _open_button:
		_open_button.scale = Vector2.ZERO
		_open_button.rotation = deg_to_rad(45)
		
	if _close_button:
		_close_button.scale = Vector2.ONE
		_close_button.rotation = 0
	
	queue_redraw()


func _reset_closed() -> void:
	_temp_background_radius = 0
	_temp_degree_range = 0
	_temp_degree_offset = degree_offset - 45
	_temp_extra_margin = _background_radius
	
	_reset_nested_menus(self)
	
	for child in get_controlled_children():
		child.rotation = deg_to_rad(35)
		child.scale = Vector2.ZERO
		child.modulate.a = 0
	
	if _open_button:
		_open_button.scale = Vector2.ONE
		_open_button.rotation = 0
		
	if _close_button:
		_close_button.scale = Vector2.ZERO
		_close_button.rotation = deg_to_rad(45)
	
	queue_redraw()


func _on_open() -> void:
	_reset_closed()
	if is_inside_tree():
		var duration := (
			animation_duration if not Settings.data.limit_animations
			else 0.0
		) if not Engine.is_editor_hint() else animation_duration
		var menu_tween := create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		menu_tween.tween_property(self, "_temp_background_radius", _background_radius, duration)
		menu_tween.tween_property(self, "_temp_degree_range", degree_range, duration)
		menu_tween.tween_property(self, "_temp_degree_offset", degree_offset, duration)
		menu_tween.tween_property(self, "_temp_extra_margin", extra_margin, duration)
		
		var i := 0
		var children := get_controlled_children()
		for child in children:
			var delay: float = (
				clamp((len(children) - i) * 0.05, 0.0, 0.2) if Engine.is_editor_hint() or not Settings.data.limit_animations
				else 0.0
			)
			var tween := child.create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(child, "scale", Vector2.ONE, duration * 0.75).set_delay(delay)
			tween.tween_property(child, "rotation", 0, duration * 0.75).set_delay(delay)
			tween.tween_property(child, "modulate:a", 1.0, duration * 0.5).set_delay(delay)
			i += 1
		
		if _open_button: _hide_button(_open_button)
		if _close_button: _show_button(_close_button)
		
		await menu_tween.finished
		open = true


func _reset_nested_menus(from: Node) -> void:
	for child in from.get_children():
		if child is CircleMenuSimple: child._reset_closed()
		else: _reset_nested_menus(child)


func _close_nested_menus(from: Node) -> void:
	for child in from.get_children():
		if child is CircleMenuSimple: child._on_close()
		else: _close_nested_menus(child)


func _on_close() -> void:
	_reset_opened()
	if is_inside_tree():
		var close_duration := (
			(animation_duration * 0.85) if Engine.is_editor_hint() or not Settings.data.limit_animations
			else 0.1
		)
		var menu_tween := create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		menu_tween.tween_property(self, "_temp_background_radius", 0, close_duration)
		menu_tween.tween_property(self, "_temp_degree_range", 0, close_duration)
		menu_tween.tween_property(self, "_temp_degree_offset", degree_offset - 270, close_duration)
		menu_tween.tween_property(self, "_temp_extra_margin", _background_radius, close_duration)
		
		# Close child menus
		_close_nested_menus(self)
		
		var i := 0
		var children := get_controlled_children()
		for child in children:			
			var delay: float = (
				clamp(i * 0.05, 0.0, 0.25) if Engine.is_editor_hint() or not Settings.data.limit_animations
				else 0.1
			)
			var tween := child.create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_property(child, "scale", Vector2.ZERO, close_duration * 0.7).set_delay(delay)
			tween.tween_property(child, "rotation", deg_to_rad(135), close_duration * 0.7).set_delay(delay)
			tween.tween_property(child, "modulate:a", 0.0, close_duration * 0.5).set_delay(delay)
			i += 1
		
		if _close_button: _hide_button(_close_button)
		if _open_button: _show_button(_open_button)
		
		await menu_tween.finished
		open = false


func _hide_button(button: Button) -> void:
	button.disabled = true
	button.pivot_offset = button.size / 2
	var duration := animation_duration * 0.5
	var tween := button.create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(button, "scale", Vector2.ZERO, duration)
	tween.tween_property(button, "rotation", deg_to_rad(-45), duration)
	await tween.finished
	button.disabled = false
	


func _show_button(button: Button) -> void:
	button.disabled = true
	button.scale = Vector2.ZERO
	button.rotation = deg_to_rad(45)
	button.pivot_offset = button.size / 2
	var delay := animation_duration * 0.45
	var duration := animation_duration * 0.65
	var tween := button.create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, duration).set_delay(delay)
	tween.tween_property(button, "rotation", 0.0, duration).set_delay(delay)
	await tween.finished
	button.disabled = false
	
