extends Control

enum Shape {
	SQUARE,
	ROUND,
	SHARP
}

enum Size {
	Xs = 25,
	Sm = 50,
	Md = 100,
	Lg = 200,
	Xl = 400,
}

var state := {
	shape = Shape.SQUARE,
	size = Size.Sm,
	rotate = 0,
	color = 100,
}

var draw_size := {
	Size.Xs: 0.05,
	Size.Sm: 0.1,
	Size.Md: 0.2,
	Size.Lg: 0.4,
	Size.Xl: 0.5,
}

class Action:
	enum Type {
		DRAW,
		ERASE
	}
	var pixel: Sprite2D
	var action: Type
	func _init(t: Type, p: Sprite2D) -> void:
		self.action = t
		self.pixel = p

var undo_stack: Array[Action] = []
var redo_stack: Array[Action] = []

@onready var shapes := [
	{ 
		button = %SquareButton,
		shape = Shape.SQUARE, 
		tex = %SquareButton/TextureRect 
	},
	{ 
		button = %SharpButton,
		shape = Shape.SHARP, 
		tex = %SharpButton/TextureRect 
	},
	{ 
		button = %RoundButton,
		shape = Shape.ROUND, 
		tex = %RoundButton/TextureRect 
	}
]


func _ready() -> void:
	for button in shapes:
		button.button.pressed.connect(set_shape.bind(button))
	%RotateLeftButton.pressed.connect(rotate_shapes.bind(-90))
	%RotateRightButton.pressed.connect(rotate_shapes.bind(90))
	update_undo_redo_buttons()
	
	for swatch_button in %Swatches.get_children():
		swatch_button.get_child(0).mouse_filter = MOUSE_FILTER_IGNORE
		swatch_button.pressed.connect(change_color.bind(swatch_button))


func change_color(swatch_button: Button) -> void:
	var panel: StyleBoxFlat = swatch_button.get_child(0).get("theme_override_styles/panel")
	var color = panel.bg_color
	%Cursor.self_modulate = color


func cursor_offset() -> Vector2:
	var start := vec(state.size / 2)
	
	if state.rotate % 360 == 0:
		return start * -1
	elif state.rotate % 270 == 0:
		return start * Vector2(-1, 1)
	elif state.rotate % 180 == 0:
		return start
	if state.rotate % 90 == 0:
		return start * Vector2(1, -1)
	else:
		return start * -1


func vec(f: float) -> Vector2:
	return Vector2(f, f)


func cursor_size() -> Vector2:
	return %Cursor.texture.get_size() * vec(draw_size[state.size])


func draw_shape() -> void:
	var new_node = %Cursor.duplicate()
	new_node.scale = vec(draw_size[state.size])
	%Canvas.add_child(new_node)
	new_node.get_child(0).queue_free() # remove shadow
	undo_stack.append(Action.new(Action.Type.DRAW, new_node))
	update_undo_redo_buttons()


func set_shape(button: Dictionary) -> void:
	state.shape = button.shape
	
	for each_button in shapes:
		each_button.button.theme_type_variation = ""
	
	button.button.theme_type_variation = "SuccessButton"
	%Cursor.texture = button.tex.texture


func rotate_shapes(delta: int) -> void:
	state.rotate += delta
	if state.rotate > 360: state.rotate -= 360
	if state.rotate < 0: state.rotate += 360
	var delay := 0.0
	for button in shapes:
		rotate(button.tex, delay)
		delay += 0.05
	rotate(%Cursor, delay)


func rotate(item: Node, delay: float) -> void:
	(get_tree()
		.create_tween()
		.tween_property(item, "rotation", deg2rad(state.rotate), 0.1 + delay)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))


func resize_cursor() -> void:
	var new_size = vec(draw_size[state.size])
	(get_tree()
		.create_tween()
		.tween_property(%Cursor, "scale", new_size, 0.15)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))


func _on_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if ControlRef.rect(%Canvas).has_point(event.global_position):
			var event_pos = event.position + cursor_offset()
			%Cursor.position = event_pos.snapped(cursor_size())
	
	if event is InputEventScreenTouch and event.is_pressed():
		draw_shape()


func resize_canvas() -> void:
	%Canvas.material.set_shader_param("grid_x", state.size)
	%Canvas.material.set_shader_param("grid_y", state.size)


func _on_size_selector_value_changed(value: int) -> void:
	match value:
		2:
			state.size = Size.Xs
			resize_cursor()
			resize_canvas()
		3: 
			state.size = Size.Sm
			resize_cursor()
			resize_canvas()
		4:
			state.size = Size.Md
			resize_cursor()
			resize_canvas()
		5:
			state.size = Size.Lg
			resize_canvas()
			resize_cursor()
		6:
			state.size = Size.Xl
			resize_cursor()
			resize_canvas()


func _on_undo_button_pressed() -> void:
	var action: Action = undo_stack.pop_back()
	%Canvas.remove_child(action.pixel)
	redo_stack.append(action)
	update_undo_redo_buttons()


func _on_redo_button_pressed() -> void:
	var action: Action = redo_stack.pop_back()
	%Canvas.add_child(action.pixel)
	undo_stack.append(action)
	update_undo_redo_buttons()
	

func update_undo_redo_buttons() -> void:
	%UndoButton.disabled = len(undo_stack) == 0
	%RedoButton.disabled = len(redo_stack) == 0
		
