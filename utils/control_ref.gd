class_name ControlRef
extends Object


static func rect(object: Control) -> Rect2:
	return Rect2(object.get_screen_position(), object.size)
