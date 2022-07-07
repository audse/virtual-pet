@tool
extends Button

var panel_stylebox: StyleBoxFlat = preload("res://apps/painter/assets/themes/swatch_button_panel.tres").duplicate()
var panel: Panel = null

@export_color_no_alpha var swatch:
	get: return swatch
	set(value):
		swatch = value
		panel_stylebox.bg_color = value


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			remake_panel()


func _process(_delta) -> void:
	make_panel()


func remake_panel():
	if panel:
		remove_child(panel)
		panel = null
	make_panel()


func make_panel() -> void:
	if not panel:
		print("Remaking panel")
		panel = Panel.new()
		panel.add_theme_stylebox_override("panel", panel_stylebox) 
		panel.set_anchors_preset(Control.PRESET_WIDE)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(panel)
