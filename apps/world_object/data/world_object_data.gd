class_name WorldObjectData
extends Resource

enum {
	ERR_CANT_CONSUME = 100
}

enum Flag {
	CLAIMED, # no other animal will try to enter this space
}

enum Layer {
	FOLIAGE_LAYER,
	BUILDING_LAYER,
	FLOOR_OBJECT_LAYER,
	WALL_OBJECT_LAYER,
}

## The base data for this object- where `WorldObjectData` is an instance, `BuyObjectData` is its prototype
@export var buyable_object_data: BuyableObjectData

@export var scene: PackedScene
@export var collision_scene: PackedScene

@export var coord: Vector2i
@export var rotation: int = 0:
	set(value): rotation = wrapi(int(snapped(value, 45)), 0, 360)

@export var flags: Array[Flag]

@export var owner: PetData

@export var uses_left: int = -1 # infinite

var instance: Node3D
var collision_instance: Node3D


func _init(args: Dictionary = {}) -> void:
	for key in args.keys():
		if key in self: self[key] = args[key]


func get_used_coords() -> Array[Vector2i]:
	var coords: Array[Vector2i] = []
	
	var _tl := -1 * Vector2(buyable_object_data.dimensions.x, buyable_object_data.dimensions.z) / 2
	var _br := Vector2(buyable_object_data.dimensions.x, buyable_object_data.dimensions.z) / 2
	var _tr := Vector2(_br.x, _tl.y)
	var _bl := Vector2(_tl.x, _br.y)
	
	var top_left = coord as Vector2 + _tl.rotated(-deg_to_rad(rotation))
	var top_right = coord as Vector2 + _tr.rotated(-deg_to_rad(rotation))
	var bottom_right = coord as Vector2 + _br.rotated(-deg_to_rad(rotation))
	var bottom_left = coord as Vector2 + _bl.rotated(-deg_to_rad(rotation))
	
	var max_x: int = ceil(max(top_left.x, top_right.x, bottom_right.x, bottom_left.x))
	var max_y: int = ceil(max(top_left.y, top_right.y, bottom_right.y, bottom_left.y))
	var min_x: int = floor(min(top_left.x, top_right.x, bottom_right.x, bottom_left.x))
	var min_y: int = floor(min(top_left.y, top_right.y, bottom_right.y, bottom_left.y))
	
	for x in range(min_x, max_x):
		for y in range(min_y, max_y):
			coords.append(Vector2i(int(x), int(y)))
	
	return coords


func get_world_position() -> Vector3:
	return (WorldData.grid_size if WorldData else 1) * Vector3(coord.x, 0, coord.y)


func get_world_dimensions() -> Vector3:
	return (WorldData.grid_size if WorldData else 1) * Vector3(buyable_object_data.dimensions)


func get_rect() -> Rect2:
	var coords := get_used_coords()
	var min_coord: Vector2i = coords.reduce(
		func(a: Vector2i, b: Vector2i) -> Vector2i: return min(a, b),
		coord
	)
	var max_coord: Vector2i = coords.reduce(
		func(a: Vector2i, b: Vector2i) -> Vector2i: return max(a, b),
		coord
	)
	var size := max_coord - min_coord
	return Rect2(min_coord, size)


func get_screen_rect(camera: Camera3D) -> Rect2:
	var rect := get_rect()
	return Rect2(
		camera.unproject_position(Vector3(rect.position.x, 0.0, rect.position.y)),
		camera.unproject_position(Vector3(rect.size.x, 1.0, rect.size.y))
	)


func set_coord_from_world_position(world_position: Vector3) -> void:
	var world_coord: Vector3 = WorldData.to_grid(world_position)
	coord = Vector2i(int(world_coord.x), int(world_coord.z))


func set_rotation_from_world_rotation(world_rotation: Vector3) -> void:
	rotation = int(rad_to_deg(world_rotation.y))


func can_use() -> bool:
	if instance and "consume" in instance:
		return uses_left > 0
	else: return true


func use() -> int:
	if instance and "consume" in instance:
		if uses_left > 0: 
			uses_left -= 1
			instance.consume()
			return OK
		else: return ERR_CANT_CONSUME
	return OK


func reset_uses() -> void:
	uses_left = buyable_object_data.total_uses
	if instance and "consume" in instance:
		instance.reset()