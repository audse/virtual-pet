extends PanelButton


func _ready() -> void:
	for swatch_button in %Swatches.get_children():
		swatch_button.pressed.connect(_on_swatch_button_pressed.bind(swatch_button))
	
	States.Paint.color_changed.connect(_on_color_changed)
	super._ready()


func _on_color_changed(color: Color) -> void:
	%Icon.create_tween().tween_property(%Icon, "modulate", color, 0.1)


func _on_swatch_button_pressed(swatch_button: Button) -> void:
	States.Paint.color = swatch_button.swatch
