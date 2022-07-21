extends Control


@export var bg := Color.WHITE
@export var radius_tl := 0.0
@export var radius_tr := 0.0
@export var radius_bl := 0.0
@export var radius_br := 0.0

var rect := Rect2(0, 0, 200, 100)

func _draw() -> void:
	draw_arc(rect.position +  v(radius_tl), radius_tl, r(180), r(270), 12, bg)
	pass


func v(x, y = null) -> Vector2:
	return Vector2(x, y if y != null else x)


func r(degrees: float) -> float:
	return deg2rad(degrees)


func setup(rect_val: Rect2) -> void:
	rect = rect_val
