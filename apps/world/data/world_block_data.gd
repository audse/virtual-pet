class_name WorldBlockData
extends Resource

@export var coord: Vector3i


var is_occupiable: bool:
	get:
		if not is_occupiable_by_object(null): return false
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


func is_buildable_by_building(start_building: BuildingData) -> bool:
	if get_objects().size() != 0: return false
	for building in get_buildings():
		if building != start_building: return false
	return true


func is_occupiable_by_object(start_object: WorldObjectData) -> bool:
	if not is_land(): return false
	
	for object in get_objects():
		if object.item_data.physical_data == null: continue
		if object.item_data.physical_data.stackable: continue
		if start_object != null and object != start_object: return false
		if start_object == null and not object.item_data.physical_data.world_layer in [
			WorldObjectData.Layer.WALL_OBJECT_LAYER, 
			WorldObjectData.Layer.RUG_OBJECT_LAYER
		]: return false
	
	for building in get_buildings():
		var has_point: bool = building.point_is_on_edge(Vector2(coord.x, coord.z))
		if start_object and start_object.building_data:
			if not has_point: return false
		else: if has_point: return false
	
	return true


func is_occupiable_by_pet() -> bool:
	for object in get_objects():
		if object.item_data.physical_data == null: continue
		if object.item_data.physical_data.stackable or object.item_data.physical_data.walkable: continue
		if not object.item_data.physical_data.world_layer in [
			WorldObjectData.Layer.WALL_OBJECT_LAYER, 
			WorldObjectData.Layer.RUG_OBJECT_LAYER
		]: return false
	return true


func is_land() -> bool:
	return WorldData.terrain.has_coord(coord)


func get_objects() -> Array[WorldObjectData]:
	if _object_cache_is_valid: return _cached_objects
	var objects: Array[WorldObjectData] = WorldData.objects.filter(
		func(obj: WorldObjectData) -> bool:
			return Vector2i(coord.x, coord.z) in obj.used_coords
	)
	_object_cache_is_valid = true
	_cached_objects = objects
	
	return objects


func get_buildings() -> Array[BuildingData]:
	if _building_cache_is_valid: return _cached_buildings
	
	var buildings: Array[BuildingData] = WorldData.buildings.filter(
		func(building: BuildingData) -> bool: return building.contains_coord(coord)
	)
	_building_cache_is_valid = true
	_cached_buildings = buildings
	
	return buildings


func get_pets() -> Array[PetData]:
	if _pet_cache_is_valid: return _cached_pets
	
	var pets: Array[PetData] = WorldData.pets.filter(
		func(pet: PetData) -> bool:
			return Vector3i(pet.world_coord.x, 0, pet.world_coord.y) == coord
	)
	_pet_cache_is_valid = true
	_cached_pets = pets
	
	return pets
	
