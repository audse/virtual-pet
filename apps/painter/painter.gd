extends Control

@onready var tool_buttons := {
	PaintState.Action.DRAW: %DrawButton,
	PaintState.Action.ERASE: %EraseButton,
	PaintState.Action.LINE: %LineButton,
	PaintState.Action.RECT: %RectangleButton,
}

# TODO features:
# mirror mode
# in-game preview
# pixel size ratio / width + height
# height map
# save as JSON / upload JSON
# shape libraries
# max number of pictures
# preset canvases
# fill tool ???
# optimization ???
# - remove stuff under "square" shape
# color picker
# alert before exiting
# rectangular select
# replace color
# overwriting warning
# change canvas names


func _ready() -> void:
	for tool in tool_buttons:
		tool_buttons[tool].pressed.connect(_on_tool_button_pressed.bind(tool))
		
	States.Paint.action_changed.connect(_on_action_changed)
	
	%SaveButton.name_field.text = "Canvas %d" % (%Gallery.num_canvases + 1)
	%SaveButton.save_pressed.connect(
		func(canvas_name: String):
			%Canvas.save_canvas(canvas_name)
			%Gallery.load_gallery()
	)
	
	var display_rect := Utils.get_display_area(self)
	
	# landscape
	if display_rect.size.x > display_rect.size.y:
		%ShapePanelButton.button_pressed = true
		%SwatchPanelButton.button_pressed = true
		%ToolsPanelButton.button_pressed = true
		%CanvasTools.add_theme_constant_override("margin_left", display_rect.size.x * 0.05)
		%CanvasTools.add_theme_constant_override("margin_right", display_rect.size.x * 0.05)
	
	%Gallery.canvas_selected.connect(
		func(canvas: SubViewport, canvas_name: String):
			States.Paint.canvas_selected.emit(canvas, canvas_name)
	)
	
	States.Paint.canvas_selected.connect(
		func(_canvas: SubViewport, canvas_name: String):
			%SaveButton.update_name_field(canvas_name + " copy")
	)


var event_map := {
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
			KEY_COMMA: States.Paint.rotation -= 90
			KEY_PERIOD: States.Paint.rotation += 90
			
			# PaintState.Size
			KEY_BRACELEFT: States.Paint.size -= 1
			KEY_BRACERIGHT: States.Paint.size += 1
			
			# Cancel PaintState.Action
			KEY_ESCAPE:
				match States.Paint.action:
					PaintState.Action.LINE, PaintState.Action.RECT:
						_on_tool_button_pressed(PaintState.Action.DRAW)
			
			KEY_R: _on_tool_button_pressed(PaintState.Action.RECT)
			KEY_L: _on_tool_button_pressed(PaintState.Action.LINE)
			KEY_E: _on_tool_button_pressed(PaintState.Action.ERASE)
			KEY_P, KEY_B: _on_tool_button_pressed(PaintState.Action.DRAW)
			
			# Starts a line from the previous point
			KEY_SHIFT:
				var prev_point = %Undo.prev()
				if prev_point:
					_on_tool_button_pressed(PaintState.Action.LINE)
					States.Paint.line = prev_point.pixels[0].position


func selected(button: Button) -> void:
	button.theme_type_variation = "Selected_Button"


func deselected(button: Button) -> void:
	button.theme_type_variation = ""


func _on_action_changed(action: int) -> void:
	for tool in tool_buttons.values():
		deselected(tool)
	selected(tool_buttons[action])
	
	match States.Paint.prev_action:
		PaintState.Action.LINE, PaintState.Action.RECT: States.Paint.line = null
	
	# update current tool button icon
	var icon: Texture = PaintState.ToolIcon[States.Paint.action]
	%ToolsPanelButton.start_icon = icon
	%CurrentTool.texture = icon
	
	# toggle "ok" button (to complete/end current PaintState.Action)
	match PaintState.Action:
		PaintState.Action.LINE, PaintState.Action.RECT: Anim.pop_enter(%OkButton)
		_: Anim.pop_exit(%OkButton)


func _on_undo_button_pressed() -> void:
	if not %Undo.can_undo(): return
	var action = %Undo.undo()
	match action.action:
		PaintState.Action.ERASE:
			%Canvas.add(action.pixels)
		_: 
			%Canvas.clear(action.pixels)


func _on_redo_button_pressed() -> void:
	if not %Undo.can_redo(): return
	var action = %Undo.redo()
	match action.action:
		PaintState.Action.ERASE:
			%Canvas.clear(action.pixels)
		_: 
			%Canvas.add(action.pixels)


func _on_tool_button_pressed(tool: int) -> void:
	States.Paint.set_action(tool)
	if %ToolsPanelButton.button_pressed:
		%ToolsPanelButton.close()


func _on_undo_updated() -> void:
	%UndoButton.disabled = not %Undo.can_undo()
	%RedoButton.disabled = not %Undo.can_redo()


func _on_zoom_in_button_pressed() -> void:
	States.Paint.zoom += 0.2


func _on_zoom_out_button_pressed() -> void:
	States.Paint.zoom -= 0.2


func _on_save_button_pressed() -> void:
	var canvas_texture: ImageTexture = await %Canvas.get_texture()
	%SaveButton.update_texture(canvas_texture)


func _on_gallery_button_pressed() -> void:
	%Gallery.open()


func _on_ok_button_pressed() -> void:
	States.Paint.set_action(States.Paint.prev_action)


func _on_canvas_action_completed(action: int, pixels: Array) -> void:
	%Undo.add(action, pixels)


func _on_canvas_resume_draw() -> void:
	_on_tool_button_pressed(PaintState.Action.DRAW)


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://main_menu.tscn"))
