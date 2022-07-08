extends SubViewportContainer

signal canvas_gui_input(event: InputEvent)

@onready var canvas = %Canvas
@onready var cursor = %Cursor
@onready var ghost = %Canvas/Ghost


func _ready() -> void:
	States.Paint.size_changed.connect(resize)
	States.Paint.action_changed.connect(_on_change_action)
	States.Paint.zoom_changed.connect(_on_change_zoom)


func _on_change_zoom(new_zoom: float) -> void:
	var is_zoomed: bool = States.Paint.is_zoomed()
	%Minimap.visible = is_zoomed
	size = Vector2(1000, 1000)
	%CanvasCopy.scale = Vector2(new_zoom, new_zoom)
	if not is_zoomed:
		%CanvasCopy.position = Vector2(0, 0)


func _on_change_action(_new_action: int) -> void:
	clear_ghosts()


func move_cursor(event: InputEvent) -> void:
	if event.position.x < 1000 and event.position.y < 1000:
		var pos = States.Paint.size_px()
		var offset = cursor.get_offset()
		cursor.position = (event.position + offset).snapped(pos)


func draw_pixel(is_ghost: bool = false) -> Sprite2D:
	var pixel = cursor.into_pixel()
	var pixels: Array[Sprite2D] = [pixel]
	add(pixels, is_ghost)
	return pixel


func draw_pixel_set(points: Array[Vector2], is_ghost: bool = false) -> Array[Sprite2D]:
	var pixels: Array[Sprite2D] = []
	for point in points:
		var pixel: Sprite2D = draw_pixel(is_ghost)
		pixel.position = point
		pixels.append(pixel)
	return pixels


func find_pixel(pos: Vector2) -> Sprite2D:
	for pixel in canvas.get_children():
		var rect: Rect2 = Rect2(pixel.position, States.Paint.size_px())
		if rect.has_point(pos) and pixel != cursor:
			return pixel
	return null


func cursor_pos() -> Vector2:
	return cursor.position


func resize(_to: int) -> void:
	var s = States.Paint.size_px()
	resize_axis("grid_x", s.x)
	resize_axis("grid_y", s.y)


func resize_axis(axis: String, to: float) -> void:
	print(canvas.material.get_shader_param(axis))
	(get_tree()
		.create_tween()
		.tween_method(
			set_shader_param.bind(axis), 
			float(canvas.material.get_shader_param(axis)), 
			to,
			0.15
		)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))


func set_shader_param(to: float, axis: String) -> void:
	# this just changes the order of the args so we can bind them
	canvas.material.set_shader_param(axis, to)


func add(pixels: Array[Sprite2D], is_ghost: bool = false) -> void:
	for pixel in pixels:
		if not is_ghost:
			canvas.add_child(pixel)
			cursor.raise()
		else:
			ghost.add_child(pixel)


func clear(pixels: Array[Sprite2D]) -> void:
	for pixel in pixels:
		canvas.remove_child(pixel)


func clear_ghosts() -> void:
	for child in ghost.get_children():
		child.queue_free()


func _on_canvas_gui_input(event: InputEvent) -> void:
	canvas_gui_input.emit(event)
	
	if event is InputEventScreenDrag:
		%CanvasCopy.position += event.relative
