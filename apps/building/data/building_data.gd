class_name BuildingData
extends Resource

signal coords_changed

const DefaultInteriorWall := preload("res://apps/building/assets/resources/default_interior_wall.tres")
const DefaultExteriorWall := preload("res://apps/building/assets/resources/default_exterior_wall.tres")
const DefaultFloor := preload("res://apps/building/assets/resources/default_floor.tres")

const DefaultDesign := {
	DesignData.DesignType.INTERIOR_WALL: DefaultInteriorWall,
	DesignData.DesignType.EXTERIOR_WALL: DefaultExteriorWall,
	DesignData.DesignType.FLOOR: DefaultFloor,
}

@export var coords: Array[Vector3i] = []
@export var designs: Array[DesignData] = []
@export var data_path: String

var instance: Node3D

var full_data_path: String:
	get: return "user://buildings/" + data_path + ".tres"


func get_design(design_type: DesignData.DesignType) -> DesignData:
	var design := designs.filter(
		func(design: DesignData) -> bool: design.category_id == design_type
	)
	if len(design) > 0: return design[0]
	else: return DefaultDesign[design_type]


func add_area(added_coords: Array[Vector3i]) -> void:
	for coord in added_coords:
		if not coord in coords: coords.append(coord)
	coords_changed.emit()


func remove_area(removed_coords: Array[Vector3i]) -> void:
	for coord in removed_coords: coords.erase(coord)
	coords_changed.emit()


func save_data() -> void:
	ResourceSaver.save(self, full_data_path)
