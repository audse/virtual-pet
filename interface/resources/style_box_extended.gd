@tool
class_name StyleBoxExtended
extends Control


@export_category("Dashed border")
@export var dashed_border: bool = false
@export var dash_size: float = 10.0
@export var gap_size: float = 5.0
@export var dash_offset: float = 0.0


func _get_dash_points(rect: Rect2) -> PackedVector2Array:
	var points: PackedVector2Array = []
	var prev_pos := rect.position
	for i in range(floor(_get_num_h_dashes(rect) as int)):
		prev_pos += Vector2(dash_size, 0)
		points.append(prev_pos)
		prev_pos += Vector2(gap_size, 0)
		points.append(prev_pos)
	return points


func _get_num_dashes(rect: Rect2) -> float:
	return (rect.size.x * 2 + rect.size.y * 2) / (dash_size + gap_size)


func _get_num_h_dashes(rect: Rect2) -> float:
	return rect.size.x / (dash_size + gap_size)


func _get_num_v_dashes(rect: Rect2) -> float:
	return rect.size.y / (dash_size + gap_size)
