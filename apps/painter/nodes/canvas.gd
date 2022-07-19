extends Control

signal action_completed(action: int, pixels: Array)
signal resume_draw

const GALLERY_PATH := "user://gallery/"
const EXTENSION := ".canvas"
const MINIMAP_SCALE := 0.25

const Action = States.PaintState.Action

@onready var canvas = %Canvas
@onready var cursor = %Cursor
@onready var ghost = %Canvas/Ghost

var cursor_position: Vector2:
	get: return %CanvasCopy.get_local_mouse_position()

var canvas_rect: Rect2:
	get:
		var rect: Rect2 = %CanvasCopy.get_rect()
		rect.size *= %CanvasCopy.scale
		return rect

var minimap_size: Vector2:
	get: return %CanvasCopy.get_rect().size * MINIMAP_SCALE

var minimap_ref_size: Vector2:
	get:
		var ref_size: Vector2 = Vector2Ref.get_display_area(self).size * MINIMAP_SCALE
		if ref_size.y > ref_size.x: 
			ref_size *= (minimap_size.x / ref_size.x)
		else:
			ref_size *= (minimap_size.y / ref_size.y)
		return ref_size


func _ready() -> void:
	States.Paint.size_changed.connect(resize)
	States.Paint.action_changed.connect(_on_change_action)
	States.Paint.precision_changed.connect(_on_precision_changed)
	States.Paint.ratio_changed.connect(resize)
	States.Paint.zoom_changed.connect(_on_change_zoom)
	States.Paint.rotation_changed.connect(
		func(_x): move_cursor_to(cursor_position)
	)
	States.Paint.canvas_selected.connect(load_canvas)
	
	%Minimap.set_deferred("size", minimap_size)
	%Minimap.set_deferred("anchors_preset", PRESET_BOTTOM_LEFT)
	%MinimapRefRect.set_deferred("size", minimap_ref_size)
	%MinimapRefRect.set_deferred("position", ((minimap_ref_size - minimap_size) / 2) * -1)


var events := {}
var last_drag_distance := 0.0
var zoom_speed := 0.05
var zoom_sensitivity := 10.0

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			# Zoom
			KEY_MINUS: zoom_out()
			KEY_EQUAL: zoom_in()
			
			KEY_W, KEY_A, KEY_S, KEY_D: cursor.move_by_unit(event.keycode)
			KEY_SPACE: draw_shape()
			
			KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN: pan(event.keycode)
	
	if event is InputEventScreenTouch:
		if event.pressed: events[event.index] = event
		else: events.erase(event.index)
		
	if event is InputEventScreenDrag:
		if events.size() == 2:
			var drag_distance = events[0].position.distance_to(events[1].position)
			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
				var new_zoom = (1 + zoom_speed) if drag_distance < last_drag_distance else (1 - zoom_speed)
				States.Paint.zoom = Vector2.ONE * new_zoom
				last_drag_distance = drag_distance




func get_texture() -> ImageTexture:
	clear_ghosts()
	cursor.visible = false
	await RenderingServer.frame_post_draw
	var img: Image = %SubViewport.get_texture().get_image()
	var tex := ImageTexture.new().create_from_image(img)
	cursor.visible = true
	return tex


func move_cursor_to(pos: Vector2) -> void:
#	if pos.x > 0 and pos.y > 0:
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
	var pos: Vector2 = (cursor_position + cursor.get_offset()).snapped(States.Paint.size_px)
	var cursor_rect = Rect2(pos, States.Paint.size_px)
	var pixels = []
	for pixel in canvas.get_children():
		var rect: Rect2 = Rect2(pixel.position, States.Paint.size_px)
		if rect.intersects(cursor_rect) and pixel != cursor:
			pixels.append(pixel)
	return pixels


func resize(_to: int) -> void:
	var s = States.Paint.size_px
	move_cursor_to(cursor_position)
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


var _dragging: int = 0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		%CanvasCopy.position += event.relative
		%MinimapRefRect.position = - ((%CanvasCopy.position * MINIMAP_SCALE) / States.Paint.zoom)
		_dragging += 1
	
	if event is InputEventMouseMotion:
		_on_mouse_motion(event)
	if event.is_action_released("tap"):
		if _dragging < 5:
			_on_canvas_pressed(cursor_position)
		else:
			_dragging = 0


var _debounce_draw_ghost: int = 0
func _on_mouse_motion(event: InputEventMouseMotion) -> void:
	move_cursor_to(cursor_position)
	
	# Hide cursor when outside of canvas
	if canvas_rect.has_point(event.position):
		cursor.modulate.a = 1
	else: cursor.modulate.a = 0
	
	if States.Paint.has_line():
		if _debounce_draw_ghost > 5:
			draw_segment(true)
			_debounce_draw_ghost = 0
		else: _debounce_draw_ghost += 1


func _on_canvas_pressed(pos: Vector2) -> void:
	match States.Paint.action:
		Action.DRAW:
			draw_shape()
		Action.ERASE:
			erase()
		Action.LINE, Action.RECT:
			if not States.Paint.has_line():
				States.Paint.line = (pos + cursor.get_offset()).snapped(States.Paint.size_px)
			else:
				draw_segment(false)


func draw_shape() -> Sprite2D:
	var pixel: Sprite2D = draw_pixel()
	var pixels: Array[Sprite2D] = [pixel]
	action_completed.emit(Action.DRAW, pixels)
	return pixel


func draw_segment(is_ghost: bool = false) -> void:
	var action = States.Paint.action
	var start = States.Paint.line
	var end: Vector2 = (cursor_position + cursor.get_offset()).snapped(States.Paint.size_px)
	var px: Vector2 = States.Paint.size_px
	
	clear_ghosts()
	var points: Array[Vector2] = []
	
	match action:
		Action.LINE:
			points = Vector2Ref.get_line_points_in_grid(start, end, px)
		Action.RECT:
			points = Vector2Ref.get_rect_points_in_grid(start, end, px)
	
	var pixels: Array[Sprite2D] = draw_pixel_set(points, is_ghost)
	
	if not is_ghost:
		action_completed.emit(action, pixels)
		
		var clicked_prev_pixel_again: bool = start.distance_to(end) <= min(px.x, px.y)
		
		if action == Action.LINE and not clicked_prev_pixel_again:
			States.Paint.line = end
		else:
			resume_draw.emit()


func erase() -> void:
	var pixels: Array[Sprite2D] = get_pixels_under_mouse()
	clear(pixels)
	action_completed.emit(Action.ERASE, pixels)


func pan(keycode: int) -> void:
	var unit: Vector2 = States.Paint.size_px
	var target: Vector2 = %CanvasCopy.position
	match keycode:
		KEY_LEFT : target.x += unit.x
		KEY_RIGHT: target.x -= unit.x
		KEY_UP   : target.y += unit.y
		KEY_DOWN : target.y -= unit.y
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


func zoom_in() -> void:
	States.Paint.zoom += 0.2


func zoom_out() -> void:
	States.Paint.zoom -= 0.2


func recenter() -> void:
	States.Paint.zoom = 1.0


func _on_change_zoom(new_zoom: float) -> void:
	var is_zoomed: bool = States.Paint.is_zoomed()
	%Minimap.visible = is_zoomed
	(
		AnimBuilder
			.new(%CanvasCopy)
			.keyframe("zoom", 0.125)
			.prop("scale", { zoom = Vector2(new_zoom, new_zoom) })
			.complete()
	)
	(
		AnimBuilder
			.new(%MinimapRefRect)
			.keyframe("zoom", 0.125)
			.prop("size", { zoom = minimap_ref_size / new_zoom })
			.complete()
	)

func _on_change_action(_new_action: int) -> void:
	clear_ghosts()


func _on_precision_changed(precision: float) -> void:
	canvas.material.set_shader_param("minigrid_x", precision)
	canvas.material.set_shader_param("minigrid_y", precision)


func _on_backdrop_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		%CanvasCopy.position += event.relative
		%MinimapRefRect.position = - ((%CanvasCopy.position * MINIMAP_SCALE) / States.Paint.zoom)
