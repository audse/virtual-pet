extends Node

signal pets_changed
signal pet_added(PetData)

signal objects_changed
signal buildings_changed

@export var grid_size := 1
@export var size := Vector2(100, 100)

@export var terrain := TerrainData.load_data()

@export var pets: Array[PetData] = []
@export var objects: Array[WorldObjectData] = []
@export var buildings: Array[BuildingData] = []

# blocks: Dictionary[Vector3i, WorldBlockData]
var blocks: Dictionary = {}

var grid_size_vector: Vector3:
	get: return Vector3(grid_size, grid_size, grid_size)


func _enter_tree() -> void:
	for coord in terrain.get_used_coords():
		blocks[coord] = WorldBlockData.new(coord)
	load_pets()
	load_objects()
	load_buildings()
	
	# Save all objects position & rotation when leaving buy mode
	Game.Mode.exit_state.connect(
		func(state: GameModeState.Mode) -> void:
			if state == GameModeState.Mode.BUY: save_objects()
	)


func add_pet(pet: PetData, save := true) -> void:
	pets.append(pet.setup())
	pets_changed.emit()
	pet_added.emit(pet)
	if save: pet.save_data()


func add_object(object: WorldObjectData, save := true) -> void:
	objects.append(object.setup())
	objects_changed.emit()
	if save: object.save_data()


func remove_object(object: WorldObjectData) -> void:
	objects.erase(object)
	object.delete_data()
	objects_changed.emit()


func add_building(building: BuildingData, save := true) -> void:
	if not building in buildings:
		buildings.append(building.setup())
		buildings_changed.emit()
	if save: building.save_data()


func find_nearby_opportunities(pet: PetData) -> Array[OpportunityData]:
	var opportunities: Array[OpportunityData] = []
	
	# Wants opportunities
	for want in pet.wants_data.wants:
		var opportunity: OpportunityData = OpportunityData.find_want_opportunity(pet, want)
		if opportunity: opportunities.append(opportunity)
	
	return opportunities


func find_nearby_need_source(pet: PetData, need: NeedsData.Need, coord: Vector2i, radius := 15) -> WorldObjectData:	
	return find_all_nearby_need_sources(pet, need, coord, radius).pop_front()


func find_all_nearby_need_sources(pet: PetData, need: NeedsData.Need, coord: Vector2i, radius := 15) -> Array[WorldObjectData]:	
	var nearby_objects: Array[WorldObjectData] = find_nearby_objects(coord, radius).filter(
		func(object: WorldObjectData) -> bool: return (
			object.item_data.use_data
			and need in object.item_data.use_data.fulfills_needs
			and not WorldObjectData.Flag.CLAIMED in object.flags
		)
	)
	# sort owned objects first
	nearby_objects.sort_custom(
		func(a: WorldObjectData, b: WorldObjectData) -> bool:
			return false if (b.owner and b.owner == pet) else true
	)
	return nearby_objects


func find_nearby_objects(coord: Vector2i, radius := 5) -> Array[WorldObjectData]:
	return search_radius(coord, radius,
		func(next_coord: Vector2i) -> Array[WorldObjectData]:
				var _next_coord := Vector3i(next_coord.x, 0, next_coord.y)
				if _next_coord in blocks: return blocks[_next_coord].get_objects()
	)


func get_nearest_occupiable_coord(coord: Vector2i) -> Vector2i:
	var result := search_radius(coord, 10,
		func(next_coord: Vector2i) -> Vector2i:
			var _next_coord := Vector3i(next_coord.x, 0, next_coord.y)
			if _next_coord in blocks and blocks[_next_coord].is_occupiable: return next_coord
			else: return Vector2i.ZERO
	)
	if result.size(): return result[0]
	else: return Vector2i.ZERO


func find_nearby_pets(coord: Vector2i, radius := 5) -> Array[PetData]:
	return search_radius(coord, radius,
		func(next_coord: Vector2i) -> Array[PetData]:
			var _next_coord := Vector3i(next_coord.x, 0, next_coord.y)
			if _next_coord in blocks: return blocks[_next_coord].get_pets()
	)


func search_radius(center: Vector2i, radius: int, filter: Callable, stop_after_found := false) -> Array:
	var nearby: Array = []
	var checked_coords: Array[Vector2i] = []
	var checked_radius := 1
	while checked_radius <= radius:
		for coord in Vector2Ref.get_coordsi_around_position(center, checked_radius):
			if not coord in checked_coords:
				var result = filter.call(coord)
				if result and result is Array: nearby.append_array(result)
				elif result: nearby.append(result)
				if result and stop_after_found: return nearby
			checked_coords.append(coord)
		checked_radius += 1
	return nearby


func to_grid(position) -> Vector3i:
	if position is Vector2:
		return Vector3i(Vector3(position.x / grid_size, 0, position.y / grid_size).snapped(grid_size_vector))
	elif position is Vector3:
		return Vector3i((position / grid_size).snapped(grid_size_vector))
	else: return Vector3i.ZERO


func to_world(position: Vector3i) -> Vector3:
	return Vector3(position) * grid_size_vector


func load_pets() -> void:
	for pet_path in Utils.open_or_make_dir("user://pets").get_files():
		var pet_data := load("user://pets/" + pet_path)
		if pet_data is PetData: add_pet(pet_data, false)


func save_pets() -> void:
	for pet in pets: pet.save_data()


func load_objects() -> void:
	for object_path in Utils.open_or_make_dir("user://world").get_files():
		var object_data := load("user://world/" + object_path)
		if object_data is WorldObjectData: add_object(object_data, false)


func save_objects() -> void:
	for object in objects:  object.save_data()


func load_buildings() -> void:
	for building_path in Utils.open_or_make_dir("user://buildings").get_files():
		var building_data := load("user://buildings/" + building_path)
		if building_data is BuildingData: add_building(building_data, false)


func save_buildings() -> void:
	for building in buildings: building.save_data()
