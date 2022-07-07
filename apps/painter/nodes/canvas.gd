extends SubViewportContainer

signal canvas_gui_input(event: InputEvent)

@onready var canvas = %Canvas
@onready var cursor = %Cursor
@onready var ghost = %Canvas/Ghost


func move_cursor(event: InputEvent) -> void:
	if ControlRef.rect(canvas).has_point(event.global_position):
		var pos = States.Paint.SizePx[States.Paint.get_size()]
		var offset = cursor.get_offset()
		cursor.position = (event.position + offset).snapped(Vector2(pos, pos))


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


func resize() -> void:
	var s = States.Paint.get_size()
	cursor.resize(s)
	resize_axis("grid_x", s)
	resize_axis("grid_y", s)


func resize_axis(axis: String, to: int) -> void:
	print(canvas.material.get_shader_param(axis))
	(get_tree()
		.create_tween()
		.tween_method(
			set_shader_param.bind(axis), 
			float(canvas.material.get_shader_param(axis)), 
			States.Paint.SizePx[to], 
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
