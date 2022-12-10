class_name Themes
extends Object


static func select(control: Control) -> void:
	control.theme_type_variation = "TagButton_Selected"


static func deselect(control: Control) -> void:
	control.theme_type_variation = "TagButton"
