class_name BuildingObjectData
extends WorldObjectData

enum IntersectionType {
	OPEN_DOORWAY,
	CLOSED_DOORWAY,
	WINDOW,
}

@export var intersection_type: IntersectionType
@export var intersection_rect_position: Vector3
@export var intersection_rect_size: Vector3


func intersect_tile(tile: SpacialTile) -> void:
	var pos := intersection_rect_position.rotated(Vector3(0, 1, 0), rotation)
	tile.intersect(pos, intersection_rect_size)
