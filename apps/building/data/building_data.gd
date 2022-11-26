class_name BuildingData
extends SaveableResource

signal rerender
signal coords_changed
signal objects_changed
signal object_added(object: WorldObjectData)
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

@export var shape: PackedVector2Array:
	set(value):
		var prev := shape.duplicate()
		shape = value
		shape_changed.emit(prev, shape)
		emit_changed()

@export var designs := {}

@export var objects: Array[WorldObjectData] = []

var instance: Node3D

var is_empty: bool:
	get: return len(shape) == 0

var bounding_rect: Dictionary:
	get:
		var min_coord := shape[0]
		var max_coord := shape[1]
		for point in shape:
			for axis in ["x", "y"]:
				if point[axis] < min_coord[axis]: min_coord[axis] = point[axis]
				if point[axis] > max_coord[axis]: max_coord[axis] = point[axis]
		return {
			size = max_coord - min_coord,
			position = min_coord,
			end = max_coord
		}

var center: Vector2:
	get: 
		var rect := bounding_rect
		return rect.size / 2 + rect.position


func setup() -> BuildingData:
	for object in objects: 
		object.building_data = self
		object.changed.connect(save_data)
	return super.setup()


func add_object(object: WorldObjectData) -> void:
	if not object in objects: objects.append(object.setup())
	objects_changed.emit()
	object_added.emit(object)
	emit_changed()


func remove_object(object: WorldObjectData) -> void:
	objects.erase(object)
	objects_changed.emit()
	emit_changed()


func get_objects_on_edge(p1: Vector2, p2: Vector2) -> Array[WorldObjectData]:
	return objects.filter(
		func(object: WorldObjectData) -> bool:
			return Polygon.segment_has_point(p1, p2, Vector2(object.coord))
	)


func has_world_position(world_pos: Vector3) -> bool:
	var p: Vector3i = WorldData.to_grid(world_pos)
	var i: int = shape.find(Vector2(p.x, p.z))
	return i != -1


func add_design(design_type: DesignData.DesignType, design: DesignData) -> void:
	designs[design_type] = design
	emit_changed()
	design_changed.emit(design_type, design)


func _get_dir() -> String:
	return "buildings"


func save_data() -> void:
	# Delete empty buildings
	if is_empty: delete_data()
	else: super.save_data()
