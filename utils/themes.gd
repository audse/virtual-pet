class_name Themes
extends Object


static func select(control: Control) -> void:
	control.theme_type_variation = "Selected_" + control.get_class()


static func deselect(control: Control) -> void:
	control.theme_type_variation = ""
