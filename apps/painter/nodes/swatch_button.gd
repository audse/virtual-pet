@tool
extends Button

const BUTTON_SIZE := Vector2(75, 75)

@export_color_no_alpha var swatch:
	set(value):
		swatch = value
		remake()

@export var reload: bool = false:
	set(_value): remake()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED, NOTIFICATION_VISIBILITY_CHANGED:
			remake()


func _ready() -> void:
	if not Engine.is_editor_hint():
		States.Paint.color_changed.connect(_on_color_changed)
	remake()


func _on_color_changed(new_color: Color) -> void:
	theme_type_variation = "" if new_color != swatch else "Selected_Button"


func remake():
	custom_minimum_size = BUTTON_SIZE
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = swatch
	stylebox.set_corner_radius_all(30)
	stylebox.border_color = Color(Color.WHITE, 0)
	add_theme_stylebox_override("normal", stylebox)
	
	var pressed_stylebox := stylebox.duplicate()
	pressed_stylebox.set_border_width_all(4)
	
	add_theme_stylebox_override("pressed", pressed_stylebox)
	
	var hover_stylebox := stylebox.duplicate()
	hover_stylebox.set_expand_margin_all(2.0)
	hover_stylebox.set_corner_radius_all(31)
	
	add_theme_stylebox_override("hover", hover_stylebox)
	
	var disabled_stylebox := stylebox.duplicate()
	disabled_stylebox.bg_color = Color(swatch, 0.75)
	add_theme_stylebox_override("disabled", disabled_stylebox)
	
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
