@tool
class_name CheckBoxButton
extends Button

@export var checked_bg_color := Color("#10b981"):
	set(value):
		checked_bg_color = value
		queue_redraw()

@export var check_color := Color("#86efac"):
	set(value):
		check_color = value
		queue_redraw()

@export_range(0.0, 10.0, 1.0) var corner_radius: float = 6.0:
	set(value):
		corner_radius = value
		queue_redraw()

var check_points: Array[Vector2]:
	get: return [
		delta(Vector2(1, 0)),
		delta(Vector2(1.25, 0.25)),
		delta(Vector2(0.5, 1.0)),
		delta(Vector2(0, 0.5)),
		delta(Vector2(0.25, 0.25)),
		delta(Vector2(0.5, 0.6)),
	]

var radius: float:
	get: return size.x / (10.0 - corner_radius)

var h_rect: Rect2:
	get: return Rect2(
		Vector2(0, radius),
		Vector2(size.x, size.y - radius * 2)
	)

var y_rect: Rect2:
	get: return Rect2(
		Vector2(radius, 0),
		Vector2(size.x - radius * 2, size.y)
	)

var circle_positions: Array[Vector2]:
	get: return [
		Vector2(radius, radius),
		Vector2(radius, size.y - radius),
		Vector2(size.x - radius, radius),
		size - Vector2(radius, radius)
	]


func _enter_tree() -> void:
	pressed.connect(queue_redraw)
	toggle_mode = true
	theme_type_variation = "CheckBoxButton"


func _draw() -> void:
	if button_pressed:
		draw_rect(h_rect, checked_bg_color)
		draw_rect(y_rect, checked_bg_color)
		for circle in circle_positions:
			draw_circle(circle, radius, checked_bg_color)
		draw_colored_polygon(check_points, check_color)


func draw_inner() -> void:
	pass


func delta(x) -> Vector2: 
	return (size / 2) * x + (size / 4) - Vector2(size.x / 12, 0)
