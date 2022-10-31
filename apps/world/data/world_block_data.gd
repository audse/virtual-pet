class_name WorldBlockData
extends Resource

@export var coord: Vector2

@export_category("Object layers")
@export var foliage_layer: FoliageData
@export var building_layer: WorldObjectData
@export var floor_object_layer: WorldObjectData
@export var wall_object_layer: WorldObjectData

var can_be_occupied: bool:
	get: return (
		not floor_object_layer == null
		and (not foliage_layer or foliage_layer.type == FoliageData.FoliageType.GRASS)
	)

var layers: Array[WorldObjectData]:
	get: return [foliage_layer, building_layer, floor_object_layer, wall_object_layer].filter(
		func(layer: WorldObjectData): return layer != null
	)


func _init(coord_value: Vector2, objects: Array[WorldObjectData]) -> void:
	coord = coord_value
	for object in objects:
		match object.layer:
			WorldObjectData.Layer.FOLIAGE_LAYER:
				foliage_layer = object as FoliageData
			WorldObjectData.Layer.BUILDING_LAYER:
				building_layer = object
			WorldObjectData.Layer.FLOOR_OBJECT_LAYER:
				floor_object_layer = object
			WorldObjectData.Layer.WALL_OBJECT_LAYER:
				wall_object_layer = object


func has_layer_with_object_flag(flag: WorldObjectData.Flag) -> bool:
	return (
		(foliage_layer and flag in foliage_layer.flags)
		or (building_layer and flag in building_layer.flags)
		or (floor_object_layer and flag in floor_object_layer.flags)
		or (wall_object_layer and flag in wall_object_layer.flags)
	)
