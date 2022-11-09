class_name WorldBlockData
extends Resource

@export var coord: Vector3i


var is_buildable: bool:
	get: return (
		len(get_objects()) == 0 
		and len(get_buildings()) == 0
	)

var is_occupiable: bool:
	get: 
		for object in get_objects():
			if object.buyable_object_data.world_layer != WorldObjectData.Layer.WALL_OBJECT_LAYER:
				return false
		return true

var _object_cache_is_valid: bool = false
var _cached_objects: Array[WorldObjectData] = []

var _building_cache_is_valid: bool = false
var _cached_buildings: Array[BuildingData] = []

var _pet_cache_is_valid: bool = false
var _cached_pets: Array[PetData] = []


func _init(coord_value: Vector3i) -> void:
	coord = coord_value
	WorldData.objects_changed.connect(
		func() -> void: _object_cache_is_valid = false
	)
	WorldData.buildings_changed.connect(
		func() -> void: _building_cache_is_valid = false
	)
	WorldData.pets_changed.connect(
		func() -> void: _pet_cache_is_valid = false
	)


func is_occupiable_by_object(start_object: WorldObjectData) -> bool:
	for object in get_objects():
		if (
			object.buyable_object_data.world_layer != WorldObjectData.Layer.WALL_OBJECT_LAYER
			and object != start_object
		):
			return false
	return true

func get_objects() -> Array[WorldObjectData]:
	if _object_cache_is_valid: return _cached_objects
	
	var objects: Array[WorldObjectData] = WorldData.objects.filter(
		func(obj: WorldObjectData) -> bool: 
			return Vector3i(obj.coord.x, 0, obj.coord.y) == coord
	)
	_object_cache_is_valid = true
	_cached_objects = objects
	
	return objects


func get_buildings() -> Array[BuildingData]:
	if _building_cache_is_valid: return _cached_buildings
	
	var buildings: Array[BuildingData] = WorldData.buildings.filter(
		func(building: BuildingData) -> bool:
			return coord in building.coords
	)
	_building_cache_is_valid = true
	_cached_buildings = buildings
	
	return buildings


func get_pets() -> Array[PetData]:
	if _pet_cache_is_valid: return _cached_pets
	
	var pets: Array[PetData] = WorldData.pets.filter(
		func(pet: PetData) -> bool:
			return Vector3i(pet.coord.x, 0, pet.coord.y) == coord
	)
	_pet_cache_is_valid = true
	_cached_pets = pets
	
	return pets
	
