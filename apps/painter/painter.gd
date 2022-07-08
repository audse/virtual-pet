extends Control

const Action = States.PaintState.Action
const Size = States.PaintState.Size
const Shape = States.PaintState.Shape

@onready var tool_buttons := {
	Action.DRAW: %DrawButton,
	Action.ERASE: %EraseButton,
	Action.LINE: %LineButton,
	Action.RECT: %RectangleButton,
}

@onready var shape_buttons := {
	Shape.SQUARE: %SquareButton,
	Shape.SHARP: %SharpButton,
	Shape.ROUND: %RoundButton,
	Shape.CONCAVE: %ConcaveButton,
	Shape.CONCAVE_SHARP: %ConcaveSharpButton,
	Shape.CIRCLE: %CircleButton,
}


func _ready() -> void:
	for tool in tool_buttons.keys():
		tool_buttons[tool].pressed.connect(_on_tool_button_pressed.bind(tool))
	
	for shape in shape_buttons.keys():
		shape_buttons[shape].pressed.connect(_on_shape_button_pressed.bind(shape))
	
	%RotateLeftButton.pressed.connect(_on_rotate_button_pressed.bind(-90))
	%RotateRightButton.pressed.connect(_on_rotate_button_pressed.bind(90))
	
	for swatch_button in %Swatches.get_children():
		swatch_button.pressed.connect(_on_swatch_button_pressed.bind(swatch_button))
	
	States.Paint.action_changed.connect(_on_change_action)
	States.Paint.size_changed.connect(_on_change_size)
	States.Paint.ratio_changed.connect(_on_change_ratio)
	States.Paint.shape_changed.connect(_on_change_shape)
	States.Paint.rotation_changed.connect(_on_change_rotation)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		
		if event.is_action_pressed("number_key"):
			var k := clampi(event.keycode - 49, 0, 9)
			var swatch = %Swatches.get_child(k)
			if swatch: _on_swatch_button_pressed(swatch)
		
		elif event.is_action_pressed("redo"):
			_on_redo_button_pressed()
			
		elif event.is_action_pressed("undo"):
			_on_undo_button_pressed()
		
		elif event.is_action_pressed("increment_size"):
			_on_increase_size_button_pressed()
		
		elif event.is_action_pressed("decrement_size"):
			_on_decrease_size_button_pressed()
		
		elif event.is_action_pressed("zoom_in"):
			_on_zoom_in_button_pressed()
		
		elif event.is_action_pressed("zoom_out"):
			_on_zoom_out_button_pressed()
		
		elif event.is_action_pressed("forward"):
			States.Paint.increment_shape(1)
			
		elif event.is_action_pressed("backward"):
			States.Paint.increment_shape(-1)
			
		else:
			match event.keycode:
				KEY_LEFT: _on_rotate_button_pressed(-90)
				KEY_RIGHT: _on_rotate_button_pressed(90)
				KEY_ESCAPE:
					match States.Paint.get_action():
						Action.LINE, Action.RECT:
							_on_tool_button_pressed(Action.DRAW)
				KEY_R: _on_tool_button_pressed(Action.RECT)
				KEY_L: _on_tool_button_pressed(Action.LINE)
				KEY_E: _on_tool_button_pressed(Action.ERASE)
				KEY_P: _on_tool_button_pressed(Action.DRAW)
				
				# Starts a line from the previous point
				KEY_SHIFT:
					var prev_point = %Undo.prev()
					if prev_point:
						_on_tool_button_pressed(Action.LINE)
						States.Paint.set_line(prev_point.pixels[0].position)


func draw_shape() -> Sprite2D:
	var pixel: Sprite2D = %Canvas.draw_pixel()
	var pixels: Array[Sprite2D] = [pixel]
	%Undo.add(Action.DRAW, pixels)
	return pixel


func rotate(item: Node, delay: float) -> void:
	(get_tree()
		.create_tween()
		.tween_property(item, "rotation", deg2rad(States.Paint.get_rotation()), 0.1 + delay)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))


func draw_segment(is_ghost: bool = false) -> void:
	var action = States.Paint.get_action()
	var start = States.Paint.line()
	var end: Vector2 = %Canvas.cursor_pos()
	var px: Vector2 = States.Paint.size_px()
	
	%Canvas.clear_ghosts()
	var points: Array[Vector2] = []
	
	match action:
		Action.LINE:
			points = Vector2Ref.get_line_points_in_grid(start, end, px)
		Action.RECT:
			points = Vector2Ref.get_rect_points_in_grid(start, end, px)
	
	var pixels: Array[Sprite2D] = %Canvas.draw_pixel_set(points, is_ghost)
	
	%Undo.add(action, pixels)
	
	if not is_ghost:
		var clicked_prev_pixel_again: bool = start.distance_to(end) <= px.x
		
		if action == Action.LINE and not clicked_prev_pixel_again:
			States.Paint.set_line(end)
		else:
			_on_tool_button_pressed(Action.DRAW) # go back to pen tool


func erase() -> void:
	var pixel = %Canvas.find_pixel(%Canvas.cursor_pos())
	if pixel:
		var pixels: Array[Sprite2D] = [pixel]
		%Canvas.clear(pixels)
		print(pixel)
		%Undo.add(Action.ERASE, pixels)


func selected(button: Button) -> void:
	button.theme_type_variation = "SuccessButton"


func deselected(button: Button) -> void:
	button.theme_type_variation = ""


var _dragging: int = 0
func _on_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		_dragging += 1
	if event is InputEventMouseMotion:
		_on_mouse_motion(event)
	if event.is_action_released("tap"):
		if _dragging < 5:
			_on_press(event)
		else:
			_dragging = 0


func _on_mouse_motion(event: InputEventMouseMotion) -> void:
	%Canvas.move_cursor(event)
	
	if States.Paint.has_line():
		# Draw ghost if a line is being created
		draw_segment(true)


func _on_press(_event: InputEvent) -> void:
	match States.Paint.get_action():
		Action.DRAW:
			draw_shape()
		Action.ERASE:
			erase()
		Action.LINE, Action.RECT:
			if not States.Paint.has_line():
				States.Paint.set_line(%Canvas.cursor_pos())
			else:
				draw_segment(false)


func _on_change_action(action: int) -> void:
	for tool in tool_buttons.values():
		deselected(tool)
	selected(tool_buttons[action])
	
	match action:
		Action.ERASE:
			for shape_button in shape_buttons.values():
				shape_button.disabled = true
		_:
			for shape_button in shape_buttons.values():
				shape_button.disabled = false


func _on_shape_button_pressed(shape: int) -> void:
	States.Paint.set_shape(shape)


func _on_change_shape(shape: int) -> void:
	for button in shape_buttons.values():
		deselected(button)
	
	selected(shape_buttons[shape])
	%Canvas.cursor.shape(shape_buttons[shape].get_child(0).texture)


func _on_rotate_button_pressed(delta: int) -> void:
	States.Paint.set_rotation(delta)


func _on_change_rotation(_value: int) -> void:
	var delay := 0.0
	for button in shape_buttons.values():
		rotate(button.get_child(0), delay)
		delay += 0.05
	rotate(%Canvas.cursor, delay)


func _on_swatch_button_pressed(swatch_button: Button) -> void:
	for button in %Swatches.get_children():
		deselected(button)
	selected(swatch_button)
	var color = swatch_button.swatch
	%Canvas.cursor.color(color)


func _on_undo_button_pressed() -> void:
	if not %Undo.can_undo(): return
	var action = %Undo.undo()
	match action.action:
		Action.ERASE:
			%Canvas.add(action.pixels)
		_: 
			%Canvas.clear(action.pixels)


func _on_redo_button_pressed() -> void:
	if not %Undo.can_redo(): return
	var action = %Undo.redo()
	match action.action:
		Action.ERASE:
			%Canvas.clear(action.pixels)
		_: 
			%Canvas.add(action.pixels)


func _on_tool_button_pressed(tool: int) -> void:
	States.Paint.set_action(tool)


func _on_undo_updated() -> void:
	%UndoButton.disabled = not %Undo.can_undo()
	%RedoButton.disabled = not %Undo.can_redo()


func _on_odd_button_pressed() -> void:
	States.Paint.set_ratio(States.PaintState.Ratio.ODD)


func _on_even_button_pressed() -> void:
	States.Paint.set_ratio(States.PaintState.Ratio.EVEN)


func _on_change_ratio(ratio: int) -> void:
	var is_even: bool = ratio == States.PaintState.Ratio.EVEN
	%EvenButton.disabled = not is_even
	%OddButton.disabled = is_even


func _on_increase_size_button_pressed() -> void:
	States.Paint.increment_size(1)


func _on_decrease_size_button_pressed() -> void:
	States.Paint.increment_size(-1)


func _on_change_size(new_size: int) -> void:
	%IncreaseSizeButton.disabled = new_size >= Size.XXL
	%DecreaseSizeButton.disabled = new_size <= Size.XS


func _on_zoom_in_button_pressed() -> void:
	States.Paint.increment_zoom(0.2)


func _on_zoom_out_button_pressed() -> void:
	States.Paint.increment_zoom(-0.2)


func _on_recenter_button_pressed() -> void:
	States.Paint.set_zoom(1.0)
