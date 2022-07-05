class_name BitMask
extends Object

enum {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT
}

var top_left := false
var top_right := false
var bottom_left := false
var bottom_right := false


func add_top_left() -> void:
	top_left = true


func add_top_right() -> void:
	top_right = true


func add_bottom_left() -> void:
	bottom_left = true
	

func add_bottom_right() -> void:
	bottom_right = true


func remove_top_left() -> void:
	top_left = false


func remove_top_right() -> void:
	top_right = false


func remove_bottom_left() -> void:
	bottom_left = false
	

func remove_bottom_right() -> void:
	bottom_right = false


func has(bit: int) -> bool:
	if bit == TOP_LEFT: return top_left
	if bit == TOP_RIGHT: return top_right
	if bit == BOTTOM_LEFT: return bottom_left
	if bit == BOTTOM_RIGHT: return bottom_right
	return false


func add(bit: int) -> void:
	if bit == TOP_LEFT: add_top_left()
	if bit == TOP_RIGHT: add_top_right()
	if bit == BOTTOM_LEFT: add_bottom_left()
	if bit == BOTTOM_RIGHT: add_bottom_right()


func remove(bit: int) -> void:
	if bit == TOP_LEFT: remove_top_left()
	if bit == TOP_RIGHT: remove_top_right()
	if bit == BOTTOM_LEFT: remove_bottom_left()
	if bit == BOTTOM_RIGHT: remove_bottom_right()


func as_array() -> Array[int]:
	var bit_array: Array[int] = []
	if top_left: bit_array.append(TOP_LEFT)
	if top_right: bit_array.append(TOP_RIGHT)
	if bottom_left: bit_array.append(BOTTOM_LEFT)
	if bottom_right: bit_array.append(BOTTOM_RIGHT)
	return bit_array


func as_bool_array() -> Array[bool]:
	return [top_left, top_right, bottom_left, bottom_right]


func as_string_array() -> Array[String]:
	var bit_array: Array[String] = []
	if top_left: bit_array.append("TOP_LEFT")
	if top_right: bit_array.append("TOP_RIGHT")
	if bottom_left: bit_array.append("BOTTOM_LEFT")
	if bottom_right: bit_array.append("BOTTOM_RIGHT")
	return bit_array


func get_coord() -> Vector2i:
	var coord := Vector2i.ZERO
	
	match [top_left, top_right, bottom_left, bottom_right]:
		[false, false, true,  false]: coord = Vector2i(0, 0)
		[false, true,  false,  true]: coord = Vector2i(1, 0)
		[true,  false, true,   true]: coord = Vector2i(2, 0)
		[false, false, true,   true]: coord = Vector2i(3, 0)
		[true,  false, false,  true]: coord = Vector2i(0, 1)
		[false, true,  true,   true]: coord = Vector2i(1, 1)
		[true,  true,  true,   true]: coord = Vector2i(2, 1)
		[true,  true,  true,  false]: coord = Vector2i(3, 1)
		[false, true,  false, false]: coord = Vector2i(0, 2)
		[true,  true,  false, false]: coord = Vector2i(1, 2)
		[true,  true,  false,  true]: coord = Vector2i(2, 2)
		[true,  false, true,  false]: coord = Vector2i(3, 2)
		[false, false, false, false]: coord = Vector2i(0, 3)
		[false, false, false,  true]: coord = Vector2i(1, 3)
		[false, true,  true,  false]: coord = Vector2i(2, 3)
		[true,  false, false, false]: coord = Vector2i(3, 3)
	
	return coord


static func bits() -> Array[int]:
	return [TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT]


static func top_bits() -> Array[int]:
	return [TOP_LEFT, TOP_RIGHT]


static func bottom_bits() -> Array[int]:
	return [BOTTOM_LEFT, BOTTOM_RIGHT]


static func left_bits() -> Array[int]:
	return [TOP_LEFT, BOTTOM_LEFT]


static func right_bits() -> Array[int]:
	return [TOP_RIGHT, BOTTOM_RIGHT]
