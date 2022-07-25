@tool
class_name CheckBoxButton
extends Button

@export var checked_bg_color := Color("#10b981"):
	set(value):
		checked_bg_color = value
		update()

@export var check_color := Color("#86efac"):
	set(value):
		check_color = value
		update()

@export_range(0, 10) var corner_radius := 6:
	set(value):
		corner_radius = value
		update()

@onready var check_points: PackedVector2Array = [
	delta(Vector2(1, 0)),
	delta(Vector2(1.25, 0.25)),
	delta(Vector2(0.5, 1.0)),
	delta(Vector2(0, 0.5)),
	delta(Vector2(0.25, 0.25)),
	delta(Vector2(0.5, 0.6)),
]

@onready var corner_size := 10 - corner_radius

@onready var radius := size.x / corner_size
@onready var h_rect := Rect2(0, size.x / corner_size, size.x, (size.y / corner_size) * (corner_size - 2))
@onready var y_rect := Rect2(size.y / corner_size, 0, (size.x / corner_size) * (corner_size - 2), size.y)

@onready var circle_positions: Array[Vector2] = [
	size / corner_size,
	size / corner_size * (corner_size - 1),
	Vector2(size.x / corner_size, size.y / corner_size * (corner_size - 1)),
	Vector2(size.x / corner_size * (corner_size - 1), size.y / corner_size),
]


func _enter_tree() -> void:
	pressed.connect(update)
	toggle_mode = true


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
