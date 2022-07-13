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

# TODO features:
# mirror mode
# tile mode
# in-game preview
# pixel size ratio / width + height
# "advanced" menu
# height map
# save to gallery
# open + edit
# save as PNG
# save as JSON
# paw print shape

func _ready() -> void:
	for tool in tool_buttons.keys():
		tool_buttons[tool].pressed.connect(_on_tool_button_pressed.bind(tool))
	
	for swatch_button in %Swatches.get_children():
		swatch_button.pressed.connect(_on_swatch_button_pressed.bind(swatch_button))
	
	States.Paint.action_changed.connect(_on_action_changed)
	States.Paint.size_changed.connect(_on_size_changed)
	States.Paint.ratio_changed.connect(_on_ratio_changed)


var event_map := {
	"number_key": func(event: InputEventKey):
		var k := clampi(event.keycode - 49, 0, 9)
		var swatch = %Swatches.get_child(k)
		if swatch: _on_swatch_button_pressed(swatch),
	"redo": func(_e): _on_redo_button_pressed(),
	"undo": func(_e): _on_undo_button_pressed(),
	"forward": func(_e): States.Paint.shape += 1,
	"backward": func(_e): States.Paint.shape -= 1,
}

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Hide cursor when outside of canvas
		if ControlRef.rect(%Canvas).has_point(event.global_position):
			%Canvas.cursor.modulate.a = 1
		else:
			%Canvas.cursor.modulate.a = 0
	
	if event is InputEventKey and event.is_pressed():
		
		for e in event_map.keys():
			if event.is_action_pressed(e): event_map[e].call(event)
		
		match event.keycode:
			# Zoom
			KEY_MINUS: _on_zoom_out_button_pressed()
			KEY_EQUAL: _on_zoom_in_button_pressed()
			
			# Rotation
			KEY_COMMA: _on_rotate_button_pressed(-90)
			KEY_PERIOD: _on_rotate_button_pressed(90)
			
			# Size
			KEY_BRACELEFT: _on_decrease_size_button_pressed()
			KEY_BRACERIGHT: _on_increase_size_button_pressed()
			
			KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN: %Canvas.pan(event.keycode)
			
			# Cancel action
			KEY_ESCAPE:
				match States.Paint.action:
					Action.LINE, Action.RECT:
						_on_tool_button_pressed(Action.DRAW)
			
			KEY_R: _on_tool_button_pressed(Action.RECT)
			KEY_L: _on_tool_button_pressed(Action.LINE)
			KEY_E: _on_tool_button_pressed(Action.ERASE)
			KEY_P, KEY_B: _on_tool_button_pressed(Action.DRAW)
			
			KEY_W, KEY_A, KEY_S, KEY_D: %Canvas.cursor.move_by_unit(event.keycode)
			KEY_SPACE: draw_shape()
			
			# Starts a line from the previous point
			KEY_SHIFT:
				var prev_point = %Undo.prev()
				if prev_point:
					_on_tool_button_pressed(Action.LINE)
					States.Paint.line = prev_point.pixels[0].position


func draw_shape() -> Sprite2D:
	var pixel: Sprite2D = %Canvas.draw_pixel()
	var pixels: Array[Sprite2D] = [pixel]
	%Undo.add(Action.DRAW, pixels)
	return pixel


func draw_segment(is_ghost: bool = false) -> void:
	var action = States.Paint.action
	var start = States.Paint.line
	var end: Vector2 = %Canvas.cursor_pos()
	var px: Vector2 = States.Paint.size_px
	
	%Canvas.clear_ghosts()
	var points: Array[Vector2] = []
	
	match action:
		Action.LINE:
			points = Vector2Ref.get_line_points_in_grid(start, end, px)
		Action.RECT:
			points = Vector2Ref.get_rect_points_in_grid(start, end, px)
	
	var pixels: Array[Sprite2D] = %Canvas.draw_pixel_set(points, is_ghost)
	
	if not is_ghost:
		%Undo.add(action, pixels)
		
		var clicked_prev_pixel_again: bool = start.distance_to(end) <= px.x
		
		if action == Action.LINE and not clicked_prev_pixel_again:
			States.Paint.line = end
		else:
			_on_tool_button_pressed(Action.DRAW) # go back to pen tool


func erase() -> void:
	var pixels: Array[Sprite2D] = %Canvas.get_pixels_under_mouse()
	%Canvas.clear(pixels)
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


var _debounce_draw_ghost: int = 0
func _on_mouse_motion(event: InputEventMouseMotion) -> void:
	%Canvas.move_cursor(event)
	
	if States.Paint.has_line():
		if _debounce_draw_ghost > 5:
			# Draw ghost if a line is being created
			draw_segment(true)
			_debounce_draw_ghost = 0
		else:
			_debounce_draw_ghost += 1


func _on_press(_event: InputEvent) -> void:
	match States.Paint.action:
		Action.DRAW:
			draw_shape()
		Action.ERASE:
			erase()
		Action.LINE, Action.RECT:
			if not States.Paint.has_line():
				States.Paint.line = %Canvas.cursor_pos()
			else:
				draw_segment(false)


func _on_action_changed(action: int) -> void:
	for tool in tool_buttons.values():
		deselected(tool)
	selected(tool_buttons[action])
	
	match States.Paint.prev_action:
		Action.LINE, Action.RECT: States.Paint.line = null
	
	# update current tool button icon
	var icon: Texture
	match action:
		Action.DRAW: icon = load("res://apps/painter/assets/icons/pencil.svg")
		Action.ERASE: icon = load("res://apps/painter/assets/icons/eraser.svg")
		Action.LINE: icon = load("res://apps/painter/assets/icons/line.svg")
		Action.RECT: icon = load("res://apps/painter/assets/icons/rectangle.svg")
	%DrawToolsWindow.menu_open_icon = icon
	
	# toggle "ok" button (to complete/end current action)
	match action:
		Action.LINE, Action.RECT: Anim.pop_enter(%OkButton)
		_: Anim.pop_exit(%OkButton)


func _on_rotate_button_pressed(delta: int) -> void:
	States.Paint.rotation += delta


func _on_swatch_button_pressed(swatch_button: Button) -> void:
	States.Paint.color = swatch_button.swatch


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
	States.Paint.ratio = States.PaintState.Ratio.ODD


func _on_even_button_pressed() -> void:
	States.Paint.ratio = States.PaintState.Ratio.EVEN


func _on_ratio_changed(ratio: int) -> void:
	var is_even: bool = ratio == States.PaintState.Ratio.EVEN
	if is_even:
		selected(%EvenButton)
		deselected(%OddButton)
	else:
		deselected(%EvenButton)
		selected(%OddButton)


func _on_increase_size_button_pressed() -> void:
	States.Paint.size += 1


func _on_decrease_size_button_pressed() -> void:
	States.Paint.size -= 1


func _on_size_changed(new_size: int) -> void:
	%IncreaseSizeButton.disabled = new_size >= Size.XXL
	%DecreaseSizeButton.disabled = new_size <= Size.XS


func _on_zoom_in_button_pressed() -> void:
	States.Paint.zoom += 0.2


func _on_zoom_out_button_pressed() -> void:
	States.Paint.zoom -= 0.2


func _on_recenter_button_pressed() -> void:
	States.Paint.zoom = 1.0


func _on_load_save_button_pressed() -> void:
	%Canvas.load_canvas()


func _on_save_button_pressed() -> void:
	var canvas_name: String = %CanvasNameField.text
	if len(canvas_name) < 1: return
	%Canvas.save_canvas(canvas_name)


func _on_gallery_button_pressed() -> void:
	%Gallery.open()


func _on_ok_button_pressed() -> void:
	States.Paint.set_action(States.Paint.prev_action)
