class_name UnevenPoint
extends Object

var coord: Vector3i
var offset := Vector3.ZERO
var world_position: Vector3


func _init(coord_value: Vector3i = Vector3i.ZERO) -> void:
	coord = coord_value
