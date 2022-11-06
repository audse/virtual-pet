class_name SpacialTileFactory
extends Node3D
@icon("spacial_tile_factory_icon.svg")


static func get_rotation_deg(id: String) -> int:
	var deg: int = 0
	match id:
		"TOP_LEFT_CORNER",     "TOP_LEFT_INNER_CORNER",     "LEFT_EDGE" : deg = -90
		"TOP_RIGHT_CORNER",    "TOP_RIGHT_INNER_CORNER",    "TOP_EDGE"  : deg = 180
		"BOTTOM_RIGHT_CORNER", "BOTTOM_RIGHT_INNER_CORNER", "RIGHT_EDGE": deg =  90
	return deg


static func turn(tile: SpacialTile, id: String) -> SpacialTile:
	var deg := get_rotation_deg(id)
	tile.rotate_object_local(Vector3(0, 1.0, 0), deg_to_rad(deg))
	return tile


static func get_id_from_bitmask(bitmask: BitMask) -> String:
	var bit_option_map := {
		TOP_LEFT_CORNER     = [false, false, false, true],
		TOP_RIGHT_CORNER    = [false, false, true, false],
		BOTTOM_LEFT_CORNER  = [false, true, false, false],
		BOTTOM_RIGHT_CORNER = [true, false, false, false],
		TOP_EDGE    = [false, false, true, true],
		BOTTOM_EDGE = [true, true, false, false],
		LEFT_EDGE   = [false, true, false, true],
		RIGHT_EDGE  = [true, false, true, false],
		TOP_LEFT_INNER_CORNER     = [false, true, true, true],
		TOP_RIGHT_INNER_CORNER    = [true, false, true, true],
		BOTTOM_LEFT_INNER_CORNER  = [true, true, false, true],
		BOTTOM_RIGHT_INNER_CORNER = [true, true, true, false],
		CENTER = [true, true, true, true],
	}

	var bitmask_array: Array[bool] = bitmask.as_bool_array()
	
	for id in bit_option_map:
		if bit_option_map[id] == bitmask_array:
			return id
	return ""


static func make_from_bitmask(bitmask: BitMask, distort_amount := Vector3.ZERO) -> SpacialTile:
	var tile_index: String = get_id_from_bitmask(bitmask)
	return make(tile_index, distort_amount)


static func make(id := "CENTER", distort_amount := Vector3.ZERO) -> SpacialTile:
	var tile := SpacialTile.new()
	tile.id = id
	
	var tile_type: int = MapState.id_to_tile_type(tile.id)
	
	tile.mesh = States.Map.tile_meshes[tile_type]
	
	var surfaces: Dictionary = States.Map.surfaces[States.Map.set][tile_type]
	var args: Dictionary = States.Map.shader_args
	
	# Rotate UV on floor surfaces
	var degree := get_rotation_deg(id)
	if tile_type != States.Map.Tile.CENTER and degree != 0:
		args["Floor"]["uv_rotation"] = deg_to_rad(degree * -sign(degree))
	
	for surface in surfaces:
		if surfaces[surface] != -1:
			var shader := make_shader(tile_type, distort_amount, args[surface])
			tile.set_surface_override_material(surfaces[surface], shader)
	
	tile = turn(tile, id)
	return tile


static func make_shader(tile_type: int, distortion_amount: Vector3, args: Dictionary = {}) -> ShaderMaterial:
	var material: ShaderMaterial = States.Map.default_shader.duplicate()
	
	var distort_edge: bool = Auto.Random.randi_range(0, 2) == 2
	if !(tile_type == States.Map.Tile.EDGE and not distort_edge):
		material.set_shader_parameter("distort_amount", distortion_amount)
	
	if tile_type == States.Map.Tile.CORNER:
		material.set_shader_parameter("is_corner", true)
	
	for arg in args:
		if args[arg] != null: material.set_shader_parameter(arg, args[arg])

	return material
