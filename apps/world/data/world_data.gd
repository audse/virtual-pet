extends Node

signal pets_changed
signal objects_changed

@export var grid_size := 1
@export var size := Vector2(100, 100)

@export var pets: Array[PetData] = []
@export var objects: Array[WorldObjectData] = []


var grid_size_vector: Vector3:
	get: return Vector3(grid_size, grid_size, grid_size)


func get_block(coord: Vector2i) -> WorldBlockData:
	return WorldBlockData.new(coord, find_objects_at_coord(coord))


func find_nearby_opportunities(pet: PetData, radius := 5) -> Array[OppportunityData]:
	var coord := pet.world_coord
	var _nearby_objects := find_nearby_objects(coord, radius)
	var _nearby_pets := find_nearby_pets(coord, radius)
	
	var opportunities: Array[OppportunityData] = []
	
	# TODO
	
	return opportunities


func find_objects_at_coord(coord: Vector2i) -> Array[WorldObjectData]:
	return objects.filter(
		func(object: WorldObjectData) -> bool:
			return coord in object.get_used_coords()
	)


func find_pets_at_coord(coord: Vector2i) -> Array[PetData]:
	return pets.filter(
		func(pet: PetData) -> bool:
			return pet.world_coord == coord
	)


func find_nearby_need_source(_pet: PetData, need: NeedsData.Need, coord: Vector2i, radius := 15) -> WorldObjectData:	
	var nearby_objects: Array[WorldObjectData] = find_nearby_objects(coord, radius).filter(
		func(object: WorldObjectData) -> bool: return (
			need in object.buyable_object_data.fulfills_needs
			and not WorldObjectData.Flag.CLAIMED in object.flags
		)
	)
	# sort owned objects first
	# TODO: this is throwing an error, why?
#	nearby_objects.sort_custom(
#		func(a: WorldObjectData, b: WorldObjectData) -> bool:
#			return false if a.owner and a.owner.get_rid() == pet.get_rid() else true
#	)
	if len(nearby_objects): return nearby_objects[0]
	else: return null


func find_nearby_objects(coord: Vector2i, radius := 5) -> Array[WorldObjectData]:
	var nearby_objects: Array[WorldObjectData] = []
	var checked_coords: Array[Vector2i] = []
	var checked_radius := 1
	while checked_radius <= radius:
		for next_coord in Vector2Ref.get_coordsi_around_position(coord, checked_radius):
			if not next_coord in checked_coords:
				nearby_objects.append_array(find_objects_at_coord(next_coord))
				checked_coords.append(coord)
		checked_radius += 1
	return nearby_objects


func find_nearby_pets(coord: Vector2i, radius := 5) -> Array[PetData]:
	var nearby_pets: Array[PetData] = []
	var checked_coords: Array[Vector2i] = []
	var checked_radius := 1
	while checked_radius <= radius:
		for next_coord in Vector2Ref.get_coordsi_around_position(coord, checked_radius):
			if not next_coord in checked_coords:
				nearby_pets.append_array(find_pets_at_coord(next_coord))
				checked_coords.append(coord)
		checked_radius += 1
	return nearby_pets


func to_grid(position) -> Vector3:
	if position is Vector2:
		return Vector3(position.x / grid_size, 0, position.y / grid_size).snapped(grid_size_vector)
	elif position is Vector3:
		return (position / grid_size).snapped(grid_size_vector)
	else: return Vector3.ZERO
