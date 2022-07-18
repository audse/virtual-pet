extends Button

@onready var menu = %DropMenu
@onready var area_button: Button = %AreaButton
@onready var even_button: Button = %EvenButton
@onready var odd_button: Button = %OddButton
@onready var precision_toggle: Button = %PrecisionToggle
@onready var recenter_button: Button = %RecenterButton


func _ready() -> void:
	menu.opening.connect(toggle_area_button.bind(true))
	menu.closing.connect(toggle_area_button.bind(false))


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
	States.Paint.ratio = States.PaintState.Ratio.EVEN


func _on_odd_button_pressed() -> void:
	Themes.deselect(even_button)
	Themes.select(odd_button)
	States.Paint.ratio = States.PaintState.Ratio.ODD


func _on_precision_toggle_pressed() -> void:
	if States.Paint.is_precision_mode():
		Themes.deselect(precision_toggle)
		precision_toggle.text = "Enabled"
	else:
		Themes.select(precision_toggle)
		precision_toggle.text = "Enable"
	States.Paint.toggle_precision_mode()


func _on_recenter_button_pressed() -> void:
	States.Paint.zoom = 1.0
	States.Paint.recenter.emit()


func _on_menu_opening() -> void:
	%AreaButton.visible = true


func _on_menu_closing() -> void:
	%AreaButton.visible = false


func _on_area_button_pressed() -> void:
	menu.queue_close()
