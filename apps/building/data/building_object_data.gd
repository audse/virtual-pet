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


## The building_coord is different from the coord because it exists in local (2x2) space
var building_coord: Vector3i:
	get: return CellMap.from_1x1_to_2x2_coords([Vector3i(coord.x, 0, coord.y)])[0]
	set(value):
		var c := CellMap.from_2x2_to_1x1_coords([value])[0]
		coord = Vector2i(c.x, c.z)


func intersect_tile(tile: SpacialTile) -> void:
	var pos := intersection_rect_position.rotated(Vector3(0, 1, 0), rotation)
	tile.intersect(pos, intersection_rect_size)
