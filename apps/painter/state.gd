extends Object


enum Action { DRAW, ERASE, LINE, RECT }
enum Shape { SQUARE, SHARP, ROUND, CONCAVE, CONCAVE_SHARP }
enum Size { XXS, XS, SM, MD, LG, XL, XXL }
enum Ratio { ODD, EVEN }

signal action_changed(to: Action)
signal size_changed(to: Size)
signal zoom_changed(to: float)
signal shape_changed(to: Shape)
signal ratio_changed(to: Ratio)
signal rotation_changed(to: int)

const SizePx := {
	Size.XS: 1000.0 / 64.0,
	Size.SM: 1000.0 / 32.0,
	Size.MD: 1000.0 / 16.0,
	Size.LG: 1000.0 / 8.0,
	Size.XL: 1000.0 / 4.0,
	Size.XXL: 1000.0 / 2.0,
}

const OddSizePx := {
	Size.XS: 1000.0 / 81.0,
	Size.SM: 1000.0 / 27.0,
	Size.MD: 1000.0 / 18.0,
	Size.LG: 1000.0 / 9.0,
	Size.XL: 1000.0 / 3.0,
	Size.XXL: 1000.0 / 1.0,
}

var properties := {
	curr_action = Action.DRAW,
	prev_action = Action.DRAW,
	shape = Shape.SQUARE,
	size = Size.MD,
	ratio = Ratio.EVEN,
	rotation = 0,
	curr_line = null,
	zoom = 1.0,
}


func _ready() -> void:
	size_changed.emit()


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
	action_changed.emit(properties.curr_action)


func is_action(value: Action) -> bool:
	return properties.curr_action == value


func shape() -> int:
	return properties.shape


func set_shape(value: Shape) -> void:
	properties.shape = value
	shape_changed.emit(properties.shape)


func increment_shape(value: int) -> void:
	properties.shape += value
	if properties.shape > Shape.CONCAVE_SHARP:
		properties.shape = Shape.SQUARE
	elif properties.shape < Shape.SQUARE:
		properties.shape = Shape.CONCAVE_SHARP
	shape_changed.emit(properties.shape)


func get_size() -> int:
	return properties.size


func size_px() -> Vector2:
	var s: float = (
		SizePx[properties.size] 
			if properties.ratio == Ratio.EVEN 
			else OddSizePx[properties.size]
	)
	return Vector2(s, s)


func get_ratio() -> Ratio:
	return properties.ratio


func set_ratio(value: Ratio) -> void:
	properties.ratio = value
	ratio_changed.emit(properties.ratio)


func set_size(value: Size) -> void:
	properties.size = value
	size_changed.emit(properties.size)


func increment_size(delta: int) -> void:
	properties.size += delta
	properties.size = clamp(properties.size, Size.XS, Size.XXL)
	size_changed.emit(properties.size)


func get_rotation() -> int:
	return properties.rotation


func set_rotation(value: int) -> void:
	properties.rotation += value
	# Keep rotation within 360 degrees
	if properties.rotation > 360: properties.rotation -= 360
	elif properties.rotation < 0: properties.rotation += 360
	rotation_changed.emit(properties.rotation)


func line() -> Vector2:
	return properties.curr_line


func set_line(value: Vector2):
	properties.curr_line = value


func has_line() -> bool:
	return properties.curr_line != null


func get_zoom() -> float:
	return properties.zoom


func set_zoom(value: float) -> void:
	properties.zoom = value
	zoom_changed.emit(properties.zoom)


func increment_zoom(value: float) -> void:
	properties.zoom += value
	properties.zoom = clamp(properties.zoom, 0.1, 20.0)
	zoom_changed.emit(properties.zoom)


func is_zoomed() -> bool:
	return abs(1.0 - properties.zoom) > 0.05
