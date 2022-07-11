@tool
extends Button

const BUTTON_SIZE := Vector2(75, 75)

var panel_stylebox: StyleBoxFlat = preload("res://apps/painter/assets/themes/swatch_button_panel.tres").duplicate()
var panel: Panel = null

@export_color_no_alpha var swatch:
	set(value):
		swatch = value
		panel_stylebox.bg_color = value

@export var reload: bool = false:
	set(_value): remake_panel()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED, NOTIFICATION_VISIBILITY_CHANGED:
			remake_panel()


func _ready() -> void:
	States.Paint.color_changed.connect(_on_color_changed)
	make_panel()


func _on_color_changed(new_color: Color) -> void:
	theme_type_variation = "" if new_color != swatch else "SuccessButton"


func remake_panel():
	custom_minimum_size = BUTTON_SIZE
	if panel:
		remove_child(panel)
		panel = null
	make_panel()


func make_panel() -> void:
	if not panel:
		panel = Panel.new()
		panel.add_theme_stylebox_override("panel", panel_stylebox) 
		panel.set_anchors_preset(Control.PRESET_WIDE)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(panel)
