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
# save as JSON
# upload JSON
# shape libraries
# max number of pictures
# preset canvases
# fill tool ???
# optimization ???
# color picker

func _ready() -> void:
	for tool in tool_buttons:
		tool_buttons[tool].pressed.connect(_on_tool_button_pressed.bind(tool))
#
	States.Paint.action_changed.connect(_on_action_changed)
	States.Paint.size_changed.connect(_on_size_changed)
	
#	%CanvasNameField.text = "Canvas %d" % (%Gallery.num_canvases + 1)

var event_map := {
#	"number_key": func(event: InputEventKey):
#		var k := clampi(event.keycode - 49, 0, 9)
#		var swatch = %Swatches.get_child(k)
#		if swatch: _on_swatch_button_pressed(swatch),
	"redo": func(_e): _on_redo_button_pressed(),
	"undo": func(_e): _on_undo_button_pressed(),
	"forward": func(_e): States.Paint.shape += 1,
	"backward": func(_e): States.Paint.shape -= 1,
}


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		
		for e in event_map.keys():
			if event.is_action_pressed(e): event_map[e].call(event)
		
		match event.keycode:
			
			# Rotation
			KEY_COMMA: _on_rotate_button_pressed(-90)
			KEY_PERIOD: _on_rotate_button_pressed(90)
			
			# Size
			KEY_BRACELEFT: _on_decrease_size_button_pressed()
			KEY_BRACERIGHT: _on_increase_size_button_pressed()
			
			# Cancel action
			KEY_ESCAPE:
				match States.Paint.action:
					Action.LINE, Action.RECT:
						_on_tool_button_pressed(Action.DRAW)
			
			KEY_R: _on_tool_button_pressed(Action.RECT)
			KEY_L: _on_tool_button_pressed(Action.LINE)
			KEY_E: _on_tool_button_pressed(Action.ERASE)
			KEY_P, KEY_B: _on_tool_button_pressed(Action.DRAW)
			
			# Starts a line from the previous point
			KEY_SHIFT:
				var prev_point = %Undo.prev()
				if prev_point:
					_on_tool_button_pressed(Action.LINE)
					States.Paint.line = prev_point.pixels[0].position


func selected(button: Button) -> void:
	button.theme_type_variation = "SuccessButton"


func deselected(button: Button) -> void:
	button.theme_type_variation = ""


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


func _on_save_button_pressed() -> void:
	var canvas_texture: ImageTexture = %Canvas.get_texture()
	%SaveButton.update_texture(canvas_texture)
#	var canvas_name: String = %CanvasNameField.text
#	if len(canvas_name) < 1: return
#	%Canvas.save_canvas(canvas_name)
#	%Gallery.load_gallery() # reload gallery grid


func _on_gallery_button_pressed() -> void:
	%Gallery.open()


func _on_ok_button_pressed() -> void:
	States.Paint.set_action(States.Paint.prev_action)


func _on_canvas_action_completed(action: int, pixels: Array) -> void:
	%Undo.add(action, pixels)


func _on_canvas_resume_draw() -> void:
	_on_tool_button_pressed(Action.DRAW)
