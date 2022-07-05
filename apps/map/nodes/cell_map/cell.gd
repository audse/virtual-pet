class_name Cell
extends Object

signal bitmask_updated

var coord := Vector3i.ZERO
var tile: MeshInstance3D = null

var bitmask := BitMask.new():
	set (value):
		bitmask = value
		emit_signal("bitmask_updated")


func draw_tile(parent: Node3D, cell_size: Vector3, new_tile: MeshInstance3D = null) -> void:
	if new_tile: tile = new_tile
	tile.position = Vector3(
		cell_size.x * coord.x,
		0.0,
		cell_size.y * coord.z
	)
	parent.add_child(tile)


func get_relation_of(neighbor_coord: Vector3i) -> int:
	return get_relation_between(coord, neighbor_coord)


static func get_relation_between(ref_coord: Vector3i, neighbor_coord: Vector3i) -> int:
	if neighbor_coord.x == ref_coord.x - 1:
		if neighbor_coord.z == ref_coord.z - 1: return NeighborGroup.TOP_LEFT
		elif neighbor_coord.z == ref_coord.z: return NeighborGroup.LEFT
		elif neighbor_coord.z == ref_coord.z + 1: return NeighborGroup.BOTTOM_LEFT
	
	elif neighbor_coord.x == ref_coord.x:
		if neighbor_coord.z == ref_coord.z - 1: return NeighborGroup.TOP
		elif neighbor_coord.z == ref_coord.z: pass # center
		elif neighbor_coord.z == ref_coord.z + 1: return NeighborGroup.BOTTOM
	
	elif neighbor_coord.x == ref_coord.x + 1:
		if neighbor_coord.z == ref_coord.z - 1: return NeighborGroup.TOP_RIGHT
		elif neighbor_coord.z == ref_coord.z: return NeighborGroup.RIGHT
		elif neighbor_coord.z == ref_coord.z + 1: return NeighborGroup.BOTTOM_RIGHT
	
	return -1


func get_neighbor_coords() -> Array[Vector3i]:
	return get_neighbor_coords_of(coord)


static func get_neighbor_coords_of(ref_coord: Vector3i) -> Array[Vector3i]:
	var neighbors: Array[Vector3i] = []
	for x in range(ref_coord.x - 1, ref_coord.x + 1):
		for y in range(ref_coord.z - 1, ref_coord.z + 1):
			neighbors.append(Vector3i(x, 0, y))
	return neighbors
