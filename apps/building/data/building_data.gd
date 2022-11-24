class_name BuildingData
extends SaveableResource

signal coords_changed
signal objects_changed
signal object_added(object: BuildingObjectData)
signal design_changed(design_type: DesignData.DesignType, design: DesignData)

signal shape_changed(prev_shape: PackedVector2Array, current_shape: PackedVector2Array)

const DefaultInteriorWall := preload("res://apps/building/assets/resources/default_interior_wall.tres")
const DefaultExteriorWall := preload("res://apps/building/assets/resources/default_exterior_wall.tres")
const DefaultFloor := preload("res://apps/building/assets/resources/default_floor.tres")
const DefaultRoof := preload("res://apps/building/assets/resources/default_roof.tres")

const DefaultDesign := {
	DesignData.DesignType.INTERIOR_WALL: DefaultInteriorWall,
	DesignData.DesignType.EXTERIOR_WALL: DefaultExteriorWall,
	DesignData.DesignType.FLOOR: DefaultFloor,
	DesignData.DesignType.ROOF: DefaultRoof,
}

@export var coords: Array[Vector3i] = []
@export var shape: PackedVector2Array
@export var designs := {}

@export var objects: Array[BuildingObjectData] = []

var instance: Node3D

var is_empty: bool:
	get: return len(coords) == 0

var bounding_rect: Dictionary:
	get:
		if len(coords) == 0: return { size = Vector3.ZERO, position = Vector3.ZERO, end = Vector3.ZERO }
		var min_coord := coords[0]
		var max_coord := coords[1]
		for coord in coords:
			for axis in ["x", "y", "z"]:
				if coord[axis] < min_coord[axis]: min_coord[axis] = coord[axis]
				if coord[axis] > max_coord[axis]: max_coord[axis] = coord[axis]
		return {
			size = max_coord - min_coord,
			position = min_coord,
			end = max_coord
		}

var center_coord: Vector3i:
	get: 
		var rect := bounding_rect
		return rect.size / 2 + rect.position


func add_area(added_coords: Array[Vector3i]) -> void:
	for coord in added_coords:
		if not coord in coords: coords.append(coord)
	var prev_shape := shape.duplicate()
	shape = get_shape_from_coords()
	shape_changed.emit(prev_shape, shape)
	coords_changed.emit()
	emit_changed()


func remove_area(removed_coords: Array[Vector3i]) -> void:
	for coord in removed_coords: coords.erase(coord)
	var prev_shape := shape.duplicate()
	shape = get_shape_from_coords()
	shape_changed.emit(prev_shape, shape)
	coords_changed.emit()
	emit_changed()


func add_object(object: BuildingObjectData) -> void:
	if not object in objects: objects.append(object.setup())
	objects_changed.emit()
	object_added.emit(object)
	emit_changed()


func remove_object(object: BuildingObjectData) -> void:
	objects.erase(object)
	objects_changed.emit()
	emit_changed()


func has_coord(coord: Vector3i) -> bool:
	return coord in coords


func has_world_position(world_pos: Vector3) -> bool:
	return has_coord(WorldData.to_grid(world_pos))


func get_shape_from_coords() -> PackedVector2Array:
	var points := PackedVector2Array()
	coords.sort()
	for coord in coords:
		var polygon := [
			Vector2(coord.x, coord.z),
			Vector2(coord.x, coord.z + 1),
			Vector2(coord.x + 1, coord.z + 1),
			Vector2(coord.x + 1, coord.z),
		]
		points.append_array(polygon)
	
	return Polygon.alpha_hull(points)


func get_coords_from_shape() -> Array[Vector3i]:
	var coords_list: Array[Vector3i] = []
	if shape.size() == 0: return coords_list
	var min_coord := Vector2i(shape[0])
	var max_coord := min_coord
	for point in shape:
		if point.x < min_coord.x: min_coord.x = int(point.x)
		if point.x > max_coord.x: max_coord.x = int(point.x)
		if point.y < min_coord.y: min_coord.y = int(point.y)
		if point.y > max_coord.y: max_coord.y = int(point.y)
	for x in range(min_coord.x, max_coord.x):
		for y in range(min_coord.y, max_coord.y):
			var coord := Vector2(x, y)
			if Geometry2D.is_point_in_polygon(coord, shape): 
				coords_list.append(Vector3i(int(coord.x), 0, int(coord.y)))
	return coords_list


func add_design(design_type: DesignData.DesignType, design: DesignData) -> void:
	designs[design_type] = design
	emit_changed()
	design_changed.emit(design_type, design)


func _get_dir() -> String:
	return "buildings"


func save_data() -> void:
	# Delete empty buildings
	if len(coords) == 0: delete_data()
	else: super.save_data()
