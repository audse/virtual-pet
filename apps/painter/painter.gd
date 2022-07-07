extends Control

const Action = States.PaintState.Action

@onready var tools := [
	{
		button = %RectangleButton,
		action = Action.RECT,
	},
	{
		button = %LineButton,
		action = Action.LINE,
	},
	{
		button = %EraseButton,
		action = Action.ERASE,
	},
	{
		button = %DrawButton,
		action = Action.DRAW,
	},
]

@onready var shapes := [
	{ 
		button = %SquareButton,
		shape = States.Paint.Shape.SQUARE, 
		tex = %SquareButton/TextureRect 
	},
	{ 
		button = %SharpButton,
		shape = States.Paint.Shape.SHARP, 
		tex = %SharpButton/TextureRect 
	},
	{ 
		button = %RoundButton,
		shape = States.Paint.Shape.ROUND, 
		tex = %RoundButton/TextureRect 
	},
	{ 
		button = %ConcaveButton,
		shape = States.Paint.Shape.CONCAVE, 
		tex = %ConcaveButton/TextureRect 
	},
	{ 
		button = %ConcaveSharpButton,
		shape = States.Paint.Shape.CONCAVE_SHARP, 
		tex = %ConcaveSharpButton/TextureRect 
	}
]


func _ready() -> void:
	for button in tools:
		button.button.pressed.connect(_on_tool_button_pressed.bind(button))
	
	for button in shapes:
		button.button.pressed.connect(set_shape.bind(button))
	
	%RotateLeftButton.pressed.connect(rotate_shapes.bind(-90))
	%RotateRightButton.pressed.connect(rotate_shapes.bind(90))
	
	for swatch_button in %Swatches.get_children():
		swatch_button.pressed.connect(change_color.bind(swatch_button))


func draw_shape() -> Sprite2D:
	var pixel: Sprite2D = %Canvas.draw_pixel()
	var pixels: Array[Sprite2D] = [pixel]
	%Undo.add(Action.DRAW, pixels)
	return pixel


func change_color(swatch_button: Button) -> void:
	for button in %Swatches.get_children():
		deselected(button)
	selected(swatch_button)
	var color = swatch_button.swatch
	%Canvas.cursor.color(color)


func set_shape(button: Dictionary) -> void:
	States.Paint.set_shape(button.shape)
	
	for each_button in shapes:
		deselected(each_button.button)
	
	selected(button.button)
	%Canvas.cursor.shape(button.tex.texture)


func rotate_shapes(delta: int) -> void:
	States.Paint.set_rotation(delta)
	var delay := 0.0
	for button in shapes:
		rotate(button.tex, delay)
		delay += 0.05
	rotate(%Canvas.cursor, delay)


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
	
	%Canvas.clear_ghosts()
	var points: Array[Vector2] = []
	
	match action:
		Action.LINE:
			points = Vector2Ref.get_line_points_in_grid(start, end, States.Paint.size_px())
		Action.RECT:
			points = Vector2Ref.get_rect_points_in_grid(start, end, States.Paint.size_px())
	
	var pixels: Array[Sprite2D] = %Canvas.draw_pixel_set(points, is_ghost)
	
	%Undo.add(action, pixels)
	
	if not is_ghost:
		_on_tool_button_pressed(tools[3]) # go back to pen tool


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


func _on_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_on_mouse_motion(event)
	if event is InputEventScreenTouch and event.is_pressed():
		_on_press(event)


func _on_mouse_motion(event: InputEventMouseMotion) -> void:
	%Canvas.move_cursor(event)
	
	if States.Paint.has_line():
		# Draw ghost if a line is being created
		draw_segment(true)


func _on_press(_event: InputEventScreenTouch) -> void:
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


func _on_size_selector_value_changed(value: int) -> void:
	States.Paint.set_size(value)
	%Canvas.resize()


func _on_undo_button_pressed() -> void:
	var action = %Undo.undo()
	match action.action:
		Action.ERASE:
			%Canvas.add(action.pixels)
		_: 
			%Canvas.clear(action.pixels)


func _on_redo_button_pressed() -> void:
	var action = %Undo.redo()
	match action.action:
		Action.ERASE:
			%Canvas.clear(action.pixels)
		_: 
			%Canvas.add(action.pixels)


func _on_tool_button_pressed(button: Dictionary) -> void:
	States.Paint.set_action(button.action)
	
	for tool_button in tools:
		deselected(tool_button.button)
	selected(button.button)
	
	match button.action:
		Action.DRAW:
			%Canvas.cursor.self_modulate.a = 1
			for shape_button in shapes:
				shape_button.button.disabled = false
			
		Action.ERASE:
			%Canvas.cursor.self_modulate.a = 0
			for shape_button in shapes:
				shape_button.button.disabled = true
			
		Action.LINE:
			pass
			
		Action.RECT:
			pass


func _on_undo_updated() -> void:
	%UndoButton.disabled = not %Undo.can_undo()
	%RedoButton.disabled = not %Undo.can_redo()


func _on_zoom_in_button_pressed() -> void:
	States.Paint.increment_size(1)
	%Canvas.resize()
	if States.Paint.get_size() >= States.Paint.Size.Xl:
		%ZoomInButton.disabled = true
	%ZoomOutButton.disabled = false


func _on_zoom_out_button_pressed() -> void:
	States.Paint.increment_size(-1)
	%Canvas.resize()
	if States.Paint.get_size() <= States.Paint.Size.Xxs:
		%ZoomOutButton.disabled = true
	%ZoomInButton.disabled = false
