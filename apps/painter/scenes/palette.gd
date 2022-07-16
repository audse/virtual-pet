extends Button

@onready var control: DropMenu = %MenuControl


func _ready() -> void:
	for swatch_button in %Swatches.get_children():
		swatch_button.pressed.connect(_on_swatch_button_pressed.bind(swatch_button))
	
	States.Paint.color_changed.connect(_on_color_changed)


func _on_color_changed(color: Color) -> void:
	%Icon.create_tween().tween_property(%Icon, "modulate", color, 0.1)


func _on_palette_menu_opening() -> void:
	%AreaButton.visible = true


func _on_palette_menu_closing() -> void:
	%AreaButton.visible = false


func _on_palette_button_pressed() -> void:
	if not control.is_open:
		control.open()
	else:
		control.close()


func _on_swatch_button_pressed(swatch_button: Button) -> void:
	States.Paint.color = swatch_button.swatch
	control.close()


func _on_area_button_pressed() -> void:
	print("pressed")
	if control.is_open: control.close()
