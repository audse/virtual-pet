@tool
class_name DropMenu
extends Control

enum Origin {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	LEFT_TOP,
	LEFT_CENTER,
	LEFT_BOTTOM,
	RIGHT_TOP,
	RIGHT_CENTER,
	RIGHT_BOTTOM,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT,
}

const TRIANGLE_PATH := "DropMenuTriangle"
const TRIANGLE_OUTLINE_PATH := "DropMenuTriangleOutline"

@export var origin: Origin = Origin.TOP_LEFT
@export var triangle_size := Vector2(25, 50):
	set(value):
		triangle_size = value
		_reset()

@export var triangle_outline_size := Vector3i(0, 0, 0):
	set(value):
		triangle_outline_size = value
		_reset()

@export var margin := Vector2.ZERO:
	set(value):
		margin = value
		_reset()

@export var remake: bool:
	set(_value): _remake()

var triangle_points: Array[Vector2]:
	get: return [
			Vector2(triangle_size.x / 2, 0),
			Vector2(triangle_size.x, triangle_size.y),
			Vector2(0, triangle_size.y)
		]

var triangle_outline_points: Array[Vector2]:
	get:
		var line := triangle_outline_size
		var top_point: Vector2 = triangle_points[0]
		var right_point: Vector2 = triangle_points[1]
		var left_point: Vector2 = triangle_points[2]
		
		left_point += Vector2(-line.x, line.y)
		right_point += Vector2(line.z, line.y)
		
		if line.x != 0 and line.y == 0:
			top_point.x -= line.x
			# move point a little to keep outline lined up
			# like: //\ instead of /\/\
			top_point.y -= (triangle_size.x / triangle_size.y) * line.x
			
		if line.z != 0 and line.y == 0:
			top_point.x += line.z
			# move point a little to keep outline lined up
			# like: /\\ instead of /\/\
			top_point.y -= (triangle_size.x / triangle_size.y) * line.z
		
		top_point.y -= line.y
		return [top_point, right_point, left_point]

var triangle_rotation: int:
	get: match origin:
		Origin.TOP_LEFT, Origin.TOP_CENTER, Origin.TOP_RIGHT: return 0
		Origin.LEFT_TOP, Origin.LEFT_CENTER, Origin.LEFT_BOTTOM: return -90
		Origin.RIGHT_TOP, Origin.RIGHT_CENTER, Origin.RIGHT_BOTTOM: return 90
		Origin.BOTTOM_LEFT, Origin.BOTTOM_CENTER, Origin.BOTTOM_RIGHT, _: return 180

var triangle: Polygon2D:
	get: 
		var node: Polygon2D = get_node_or_null(TRIANGLE_PATH)
		if not node: node = _remake_triangle()
		return node

var triangle_outline: Polygon2D:
	get:
		var node: Polygon2D = triangle.get_node_or_null(TRIANGLE_OUTLINE_PATH)
		if not node: node = _remake_triangle_outline()
		return node


func _reset() -> void:
	print("reset")
	triangle.polygon = triangle_points
	triangle.rotation = triangle_rotation
	triangle_outline.polygon = triangle_outline_points


func _remake_triangle() -> Polygon2D:
	var existing_triangle := get_node_or_null(TRIANGLE_PATH)
	if existing_triangle: existing_triangle.queue_free()
	var triangle := Polygon2D.new()
	add_child(triangle)
	triangle.name = TRIANGLE_PATH
	triangle.polygon = triangle_points
	triangle.rotation = triangle_rotation
	return triangle


func _remake_triangle_outline() -> Polygon2D:
	var existing_triangle := get_node_or_null(TRIANGLE_OUTLINE_PATH)
	if existing_triangle: existing_triangle.queue_free()
	var triangle := Polygon2D.new()
	add_child(triangle)
	triangle.name = TRIANGLE_OUTLINE_PATH
	triangle.polygon = triangle_outline_points
	triangle.show_behind_parent = true
	return triangle


func _remake() -> void:
	_remake_triangle()
