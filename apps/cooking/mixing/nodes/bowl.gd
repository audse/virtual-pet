class_name Bowl
extends StaticBody3D
@icon("bowl.svg")

@onready var res := get_viewport().get_visible_rect().size
@onready var center := res / 2.0

var prev_mouse_pos: Vector2
var speed_delta: Vector2
var is_clockwise: bool


func _input(_event: InputEvent) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	is_clockwise = Vector2Ref.is_moving_clockwise(center, prev_mouse_pos, mouse_pos)
	speed_delta = mouse_pos - prev_mouse_pos
	prev_mouse_pos = mouse_pos
