class_name NeighborGroup
extends Object

enum {
	TOP_LEFT,
	TOP,
	TOP_RIGHT,
	LEFT,
	RIGHT,
	BOTTOM_LEFT,
	BOTTOM,
	BOTTOM_RIGHT
}

var center: Cell = null

var top_left: Cell = null
var top: Cell = null
var top_right: Cell = null
var left: Cell = null
var right: Cell = null
var bottom_left: Cell = null
var bottom: Cell = null
var bottom_right: Cell = null


func _init(center_value: Cell = null) -> void:
	center = center_value


func list() -> Array:
	return [top_left, top, top_right, left, right, bottom_left, bottom, bottom_right]


func list_edge_neighbors() -> Array:
	return [top, left, right, bottom]


func set_relation(relation: int, cell: Cell) -> void:
	if relation == TOP_LEFT: top_left = cell
	elif relation == TOP: top = cell
	elif relation == TOP_RIGHT: top_right = cell
	elif relation == LEFT: left = cell
	elif relation == RIGHT: right = cell
	elif relation == BOTTOM_LEFT: bottom_left = cell
	elif relation == BOTTOM: bottom = cell
	elif relation == BOTTOM_RIGHT: bottom_right = cell


func get_relation(relation: int) -> Cell:
	if relation == TOP_LEFT: return top_left
	elif relation == TOP: return top
	elif relation == TOP_RIGHT: return top_right
	elif relation == LEFT: return left
	elif relation == RIGHT: return right
	elif relation == BOTTOM_LEFT: return bottom_left
	elif relation == BOTTOM: return bottom
	elif relation == BOTTOM_RIGHT: return bottom_right
	return null


static func edge_neighbors() -> Array[int]:
	return [TOP, LEFT, RIGHT, BOTTOM]


static func corner_neighbors() -> Array[int]:
	return [TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT]
