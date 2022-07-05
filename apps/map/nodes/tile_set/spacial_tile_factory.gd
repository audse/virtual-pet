class_name SpacialTileFactory
extends Node3D
@icon("spacial_tile_factory_icon.svg")

enum Sets {
	BUILDING_01
}

const distort_shader: Shader = preload("res://temp/distort.gdshader")

const textures := {
	stone    = preload("res://temp/stone.png"),
	interior = preload("res://temp/interior.png"),
	floor    = preload("res://temp/floor.png"),
	concrete = preload("res://temp/concrete.png"),
	siding   = preload("res://temp/siding.png"),
}

const normals := {
	clay_normal = preload("res://temp/clay_bake.png"),
	stone       = preload("res://temp/stone_map.png"),
	interior    = preload("res://temp/interior_map.png"),
	floor       = preload("res://temp/floor_map.png"),
	siding      = preload("res://temp/siding_map.png"),
}

const building_01_meshes = {
	CORNER       = preload("res://apps/map/assets/tile_sets/building_01/meshes/building_01_corner_tile.obj"),
	CENTER       = preload("res://apps/map/assets/tile_sets/building_01/meshes/building_01_center_tile.obj"),
	EDGE         = preload("res://apps/map/assets/tile_sets/building_01/meshes/building_01_edge_tile.obj"),
	INNER_CORNER = preload("res://apps/map/assets/tile_sets/building_01/meshes/building_01_inner_corner_tile.obj"),
}


static func get_rotation_deg(id: String) -> int:
	var deg: int = 0
	match id:
		"TOP_LEFT_CORNER", "TOP_LEFT_INNER_CORNER", "LEFT_EDGE":  deg = -90
		"TOP_RIGHT_CORNER", "TOP_RIGHT_INNER_CORNER", "TOP_EDGE":   deg = 180
		"BOTTOM_RIGHT_CORNER", "BOTTOM_RIGHT_INNER_CORNER", "RIGHT_EDGE": deg = 90
	return deg


static func turn(tile: SpacialTile, id: String) -> SpacialTile:
	var deg := get_rotation_deg(id)
	tile.rotate_object_local(Vector3(0, 1.0, 0), deg2rad(deg))
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
	
	for id in bit_option_map.keys():
		if bit_option_map[id] == bitmask_array:
			return id
	return ""


static func make_from_bitmask(tile_set: int, bitmask: BitMask, distort_amount := Vector3.ZERO) -> SpacialTile:
	var tile_index: String = get_id_from_bitmask(bitmask)
	return make(tile_set, tile_index, distort_amount)


static func make(tile_set: int, id := "CENTER", distort_amount := Vector3.ZERO) -> SpacialTile:
	var tile := SpacialTile.new()
	tile.id = id
	
	var tile_type: String = id_to_generic(tile.id)
	
	if tile_set == Sets.BUILDING_01:
		tile.mesh = building_01_meshes[tile_type].duplicate(true)
		
	# flip floor surface of edge tiles UV when rotated, they do not line up
	var inner_wall_surface: int = tile.mesh.surface_find_by_name("InnerWall")
	var floor_surface: int = tile.mesh.surface_find_by_name("Floor")
	var outer_wall_surface: int = tile.mesh.surface_find_by_name("OuterWall")
	var outer_wall_base_surface: int = tile.mesh.surface_find_by_name("OuterWallBase")
	
	if inner_wall_surface != -1:
		var args := { "albedo_texture": textures.interior, "normal_texture": normals.interior }
		var shader := make_shader(id, tile_type, distort_amount, false, args)
		tile.set_surface_override_material(inner_wall_surface, shader)
	
	if outer_wall_surface != -1:
		var args := { "albedo_texture": textures.siding, "normal_texture": normals.siding }
		var shader := make_shader(id, tile_type, distort_amount, false, args)
		tile.set_surface_override_material(outer_wall_surface, shader)
	
	if outer_wall_base_surface != -1:
		var args := { "albedo_texture": textures.stone, "normal_texture": normals.stone, "normal_depth": 2.0 }
		var shader := make_shader(id, tile_type, distort_amount, false, args)
		tile.set_surface_override_material(outer_wall_base_surface, shader)
	
	if floor_surface != -1:
		var args := { "albedo_texture": textures.floor, "normal_texture": normals.floor }
		var shader := make_shader(id, tile_type, distort_amount, true, args)
		tile.set_surface_override_material(floor_surface, shader)
	
	tile = turn(tile, id)
	return tile


static func id_to_generic(id: String) -> String:
	return (
		"INNER_CORNER" if "INNER_CORNER" in id
		else "CORNER" if "CORNER" in id
		else "EDGE" if "EDGE" in id
		else "CENTER"
	)


static func make_shader(id: String, tile_type: String, distortion_amount: Vector3, rotate_uv: bool, args: Dictionary = {}) -> ShaderMaterial:
	var shader := ShaderMaterial.new()
	shader.shader = distort_shader
	
	var distort_edge: bool = Utils.Random.randi_range(0, 2) == 2
	
	if !(tile_type == "EDGE" and not distort_edge):
		shader.set_shader_param("distort_amount", distortion_amount)
	
	if tile_type == "CORNER":
		shader.set_shader_param("is_corner", true)
	
	for arg in args.keys():
		shader.set_shader_param(arg, args[arg])
	
	if rotate_uv:
		var degree := get_rotation_deg(id)
		
		@warning_ignore(shadowed_global_identifier)
		var sign: int = sign(degree)
		
		if tile_type != "CENTER" and degree != 0:
			shader.set_shader_param("uv_rotation", deg2rad(degree * -sign))
	
	return shader
