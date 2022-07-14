extends SubViewportContainer

signal canvas_gui_input(event: InputEvent)

const GALLERY_PATH := "user://gallery/"
const EXTENSION := ".canvas"

@onready var canvas = %Canvas
@onready var cursor = %Cursor
@onready var ghost = %Canvas/Ghost


func _ready() -> void:
	States.Paint.size_changed.connect(resize)
	States.Paint.action_changed.connect(_on_change_action)
	States.Paint.precision_changed.connect(_on_precision_changed)
	States.Paint.ratio_changed.connect(resize)
	States.Paint.zoom_changed.connect(_on_change_zoom)
	States.Paint.rotation_changed.connect(
		func(_x): move_cursor_to(get_local_mouse_position())
	)
	States.Paint.canvas_selected.connect(load_canvas)
	%CanvasCopy.size = size


func _on_change_zoom(new_zoom: float) -> void:
	size = Vector2(800, 800)
	var is_zoomed: bool = States.Paint.is_zoomed()
	%Minimap.visible = is_zoomed
	if not is_zoomed:
		%CanvasCopy.position = Vector2(0, 0)
	(
		AnimBuilder
			.new(%CanvasCopy)
			.keyframe("zoom", 0.125)
			.prop("scale", { zoom = Vector2(new_zoom, new_zoom) })
			.complete()
	)


func _on_change_action(_new_action: int) -> void:
	clear_ghosts()


func _on_precision_changed(precision: float) -> void:
	canvas.material.set_shader_param("minigrid_x", precision)
	canvas.material.set_shader_param("minigrid_y", precision)


func move_cursor(event: InputEvent) -> void:
	move_cursor_to(event.position)


func move_cursor_to(pos: Vector2) -> void:
	if pos.x < 800 and pos.y < 800:
		cursor.position = (pos + cursor.get_offset()).snapped(States.Paint.size_px)


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


func get_pixels_under_mouse() -> Array[Sprite2D]:
	var pos = (%CanvasCopy.get_local_mouse_position() - (States.Paint.size_px / 2)).snapped(States.Paint.size_px)
	var cursor_rect = Rect2(pos, States.Paint.size_px)
	var pixels = []
	for pixel in canvas.get_children():
		var rect: Rect2 = Rect2(pixel.position, States.Paint.size_px)
		if rect.intersects(cursor_rect) and pixel != cursor:
			pixels.append(pixel)
	return pixels


func cursor_pos() -> Vector2:
	return cursor.position


func resize(_to: int) -> void:
	var s = States.Paint.size_px
	resize_axis("grid_x", s.x)
	resize_axis("grid_y", s.y)


func resize_axis(axis: String, to: float) -> void:
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


func pan(keycode: int) -> void:
	var unit: Vector2 = States.Paint.size_px
	var target: Vector2 = %CanvasCopy.position
	match keycode:
		KEY_LEFT: target.x += unit.x
		KEY_RIGHT: target.x -= unit.x
		KEY_UP: target.y += unit.y
		KEY_DOWN: target.y -= unit.y
	(get_tree()
		.create_tween()
		.tween_property(%CanvasCopy, "position", target, 0.15)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))


func save_canvas(canvas_name: String) -> int:
	var file := File.new()
	var err := file.open(GALLERY_PATH + canvas_name + EXTENSION, File.WRITE)
	if not err == OK: return err
	
	for pixel in canvas.get_children():
		if pixel not in [cursor, ghost]: file.store_var(pixel, true)
	file.close()
	return OK


func clear_canvas() -> void:
	for pixel in canvas.get_children():
		if pixel not in [cursor, ghost]: pixel.queue_free()


func load_canvas(from_canvas: SubViewport) -> void:
	clear_canvas()
	for pixel in from_canvas.get_children():
		if pixel is Node2D: canvas.add_child(pixel.duplicate())
	cursor.raise()
