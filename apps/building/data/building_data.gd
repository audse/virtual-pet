class_name BuildingData
extends SaveableResource

const COST_PER_COORD := 50

signal rerender
signal coords_changed
signal objects_changed
signal object_added(object: WorldObjectData)
signal design_changed(design_type: DesignData.DesignType, design: DesignData, prev: DesignData)

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
	get: return Polygon.get_bounding_box(shape)

var center: Vector2:
	get: 
		var rect := bounding_rect
		return rect.size / 2 + rect.position

var cost: int:
	get: return BuildingData.get_cost(shape)


func setup() -> BuildingData:
	for object in objects: 
		object.building_data = self
		object.changed.connect(save_data)
	return super.setup()


func add_object(object: WorldObjectData) -> void:
	if not object in objects: objects.append(object.setup())
	object.changed.connect(emit_changed)
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


func contains_coord(coord: Vector3) -> bool:
	return Geometry2D.is_point_in_polygon(Vector2(coord.x, coord.z), shape)


func has_world_position(world_pos: Vector3) -> bool:
	var p: Vector3i = WorldData.to_grid(world_pos)
	var i: int = shape.find(Vector2(p.x, p.z))
	return i != -1


func point_is_on_edge(point: Vector2, tolerance := 0.25) -> bool:
	var edge := Polygon.closest_edge(shape, point)
	if edge.size() == 0: return false
	var snapped_point := Polygon.snap_to_edge(shape[edge[0]], shape[edge[1]], point)
	if snapped_point.distance_to(point) < tolerance: return true
	return false


func add_design(design_type: DesignData.DesignType, design: DesignData) -> void:
	var prev: DesignData = designs[design_type]
	designs[design_type] = design
	emit_changed()
	design_changed.emit(design_type, design, prev)


static func get_cost(polygon: PackedVector2Array) -> int:
	var size: Vector2 = Polygon.get_bounding_box(polygon).size
	return size.x as int * COST_PER_COORD + size.y as int * COST_PER_COORD


func _get_dir() -> String:
	return "buildings"


func save_data() -> void:
	# Delete empty buildings
	if is_empty: delete_data()
	else: super.save_data()
