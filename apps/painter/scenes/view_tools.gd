extends Button


@onready var menu = %DropMenu
@onready var area_button: Button = %AreaButton
@onready var even_button: Button = %EvenButton
@onready var odd_button: Button = %OddButton
@onready var precision_toggle: Button = %PrecisionToggle
@onready var recenter_button: Button = %RecenterButton

@onready var tiling_buttons := {
	PaintState.Tiling.NONE: %TileNoneButton,
	PaintState.Tiling.ALL: %TileAllButton,
	PaintState.Tiling.HORIZONTAL: %TileHButton,
	PaintState.Tiling.VERTICAL: %TileVButton
}


func _ready() -> void:
	menu.opening.connect(toggle_area_button.bind(true))
	menu.closing.connect(toggle_area_button.bind(false))
	
	for tile_mode in tiling_buttons:
		tiling_buttons[tile_mode].pressed.connect(
			func(): States.Paint.tiling = tile_mode
		)
	
	States.Paint.tiling_changed.connect(
		func(value: int):
			for tile_mode in tiling_buttons:
				if tile_mode != value: Themes.deselect(tiling_buttons[tile_mode])
				else: Themes.select(tiling_buttons[tile_mode])
	)


func toggle_area_button(to_show: bool) -> void:
	if to_show:
		area_button.visible = true
		await Anim.fade_in(area_button)
	else: 
		await Anim.fade_out(area_button)
		area_button.visible = false


func _on_view_tools_button_pressed() -> void:
	if not menu.is_open: menu.queue_open()
	else: menu.queue_close()


func _on_even_button_pressed() -> void:
	Themes.select(even_button)
	Themes.deselect(odd_button)
	States.Paint.ratio = PaintState.Ratio.EVEN


func _on_odd_button_pressed() -> void:
	Themes.deselect(even_button)
	Themes.select(odd_button)
	States.Paint.ratio = PaintState.Ratio.ODD


func _on_recenter_button_pressed() -> void:
	States.Paint.zoom = 1.0
	States.Paint.recenter.emit()


func _on_menu_opening() -> void:
	%AreaButton.visible = true


func _on_menu_closing() -> void:
	%AreaButton.visible = false


func _on_area_button_pressed() -> void:
	menu.queue_close()


func _on_tile_none_button_pressed() -> void:
	States.Paint.tiling = PaintState.Tiling.NONE


func _on_tile_all_button_pressed() -> void:
	States.Paint.tiling = PaintState.Tiling.ALL


func _on_tile_h_button_pressed() -> void:
	States.Paint.tiling = PaintState.Tiling.HORIZONTAL


func _on_tile_v_button_pressed() -> void:
	States.Paint.tiling = PaintState.Tiling.VERTICAL


func _on_precision_toggled(_button_pressed: bool) -> void:
	States.Paint.toggle_precision_mode()
	if States.Paint.is_precision_mode():
		%PrecisionToggleLabel.text = "Enabled"
	else:
		%PrecisionToggleLabel.text = "Disabled"
