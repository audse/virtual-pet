extends Object

enum Action { DRAW, ERASE, LINE, RECT }
enum Shape { SQUARE, ROUND, SHARP, HALF_SHARP, CONCAVE, CONCAVE_SHARP }
enum Size { Xxs = 1, Xs = 2, Sm = 3, Md = 4, Lg = 5, Xl = 6 }

const SizePx := {
	Size.Xxs: 12.5,
	Size.Xs: 25.0,
	Size.Sm: 50.0,
	Size.Md: 100.0,
	Size.Lg: 200.0,
	Size.Xl: 400.0,
}

var properties := {
	curr_action = Action.DRAW,
	prev_action = Action.DRAW,
	shape = Shape.SQUARE,
	size = Size.Sm,
	rotation = 0,
	curr_line = null,
}


func get_action() -> int:
	return properties.curr_action


func set_action(value: Action) -> void:
	match value:
		Action.LINE, Action.RECT:
			if properties.curr_action == value:
				properties.curr_line = null # restart line if they click the button again
		_: properties.curr_line = null
	
	properties.prev_action = properties.curr_action
	properties.curr_action = value


func is_action(value: Action) -> bool:
	return properties.curr_action == value


func shape() -> int:
	return properties.shape


func set_shape(value: Shape) -> void:
	properties.shape = value


func get_size() -> int:
	return properties.size


func size_px() -> Vector2:
	var s: float = SizePx[properties.size]
	return Vector2(s, s)


func set_size(value: Size) -> void:
	properties.size = value


func increment_size(delta: int) -> void:
	properties.size += delta


func get_rotation() -> int:
	return properties.rotation


func set_rotation(value: int) -> void:
	properties.rotation += value
	# Keep rotation within 360 degrees
	if properties.rotation > 360: properties.rotation -= 360
	elif properties.rotation < 0: properties.rotation += 360


func line():
	return properties.curr_line


func set_line(value: Vector2):
	properties.curr_line = value


func has_line() -> bool:
	return properties.curr_line != null
