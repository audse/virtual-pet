class_name BuildingData
extends SaveableResource

signal coords_changed
signal objects_changed
signal object_added(object: BuildingObjectData)

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
@export var designs: Array[DesignData] = []
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


func get_design(design_type: DesignData.DesignType) -> DesignData:
	var design := designs.filter(
		func(design: DesignData) -> bool: return design.category_id == design_type
	)
	if len(design) > 0: return design[0]
	else: return DefaultDesign[design_type]


func add_area(added_coords: Array[Vector3i]) -> void:
	for coord in added_coords:
		if not coord in coords: coords.append(coord)
	coords_changed.emit()
	emit_changed()


func remove_area(removed_coords: Array[Vector3i]) -> void:
	for coord in removed_coords: coords.erase(coord)
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
	# Building tiles are 2x2, so we need to check all four subcoords
	# included in each building coord
	for c in CellMap.from_1x1_to_2x2_coords([coord]):
		if c in coords: return true
	return false


func has_world_position(world_pos: Vector3) -> bool:
	return has_coord(WorldData.to_grid(world_pos))


func _get_dir() -> String:
	return "buildings"


func save_data() -> void:
	# Delete empty buildings
	if len(coords) == 0: delete_data()
	else: super.save_data()
