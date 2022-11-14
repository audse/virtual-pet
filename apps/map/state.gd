class_name MapState
extends Node

signal foundation_changed (tex: Texture2D)
signal outer_wall_changed (tex: Texture2D)
signal inner_wall_changed (tex: Texture2D)
signal floor_changed (tex: Texture2D)

const DISTORT_SHADER: Shader = preload("res://apps/map/assets/shaders/distort.gdshader")

enum Set { BUILDING_01, BUILDING_02 }

enum Tile { CORNER, CENTER, EDGE, INNER_CORNER }

const Textures := {
	STONE    = preload("res://temp/stone.tres"),
	INTERIOR = preload("res://temp/interior.tres"),
	FLOOR    = preload("res://temp/floor.tres"),
	SIDING   = preload("res://temp/siding.tres"),
}

const Normals := {
	STONE       = preload("res://temp/stone_map.tres"),
	INTERIOR    = preload("res://temp/interior_map.tres"),
	FLOOR       = preload("res://temp/floor_map.tres"),
	SIDING      = preload("res://temp/siding_map.tres"),
}

const Building01Meshes := {
	Tile.CORNER: preload("res://apps/building/assets/tile_sets/building_01/meshes/building_01_corner_tile.tres"),
	Tile.CENTER: preload("res://apps/building/assets/tile_sets/building_01/meshes/building_01_center_tile.tres"),
	Tile.EDGE:   preload("res://apps/building/assets/tile_sets/building_01/meshes/building_01_edge_tile.tres"),
	Tile.INNER_CORNER: preload("res://apps/building/assets/tile_sets/building_01/meshes/building_01_inner_corner_tile.tres"),
}

const Building02Meshes := {
	Tile.CORNER: preload("res://apps/building/assets/tile_sets/building_01/meshes/building_02_corner_tile.obj"),
	Tile.CENTER: preload("res://apps/building/assets/tile_sets/building_01/meshes/building_02_center_tile.obj"),
	Tile.EDGE:   preload("res://apps/building/assets/tile_sets/building_01/meshes/building_02_edge_tile.obj"),
	Tile.INNER_CORNER: preload("res://apps/building/assets/tile_sets/building_01/meshes/building_02_inner_corner_tile.obj"),
}

const Meshes := {
	Set.BUILDING_01: Building01Meshes,
	Set.BUILDING_02: Building02Meshes,
}

var set: Set = Set.BUILDING_02

var foundation_tex: Texture2D = Textures.STONE:
	set(value):
		foundation_tex = value
		foundation_changed.emit(value)
var foundation_normal: Texture2D = Normals.STONE

var outer_wall_tex: Texture2D = Textures.SIDING:
	set(value):
		outer_wall_tex = value
		outer_wall_changed.emit(value)
var outer_wall_normal: Texture2D = Normals.SIDING

var inner_wall_tex: Texture2D = Textures.INTERIOR:
	set(value):
		inner_wall_tex = value
		inner_wall_changed.emit(value)
var inner_wall_normal: Texture2D = Normals.INTERIOR

var floor_tex: Texture2D = Textures.FLOOR:
	set(value):
		floor_tex = value
		floor_changed.emit(value)
var floor_normal: Texture2D = Normals.FLOOR

var shader_args: Dictionary:
	get: return {
		"OuterWallBase": {
			"albedo_texture": foundation_tex,
			"normal_texture": foundation_normal,
			"normal_depth": 2.0,
			"cut_pos": Vector2.ZERO,
			"cut_size": Vector2.ZERO,
		},
		"Exterior": {
			"albedo_texture": outer_wall_tex,
			"normal_texture": outer_wall_normal,
			"cut_pos": Vector2.ZERO,
			"cut_size": Vector2.ZERO,
		},
		"Interior": {
			"albedo_texture": inner_wall_tex,
			"normal_texture": inner_wall_normal,
			"cut_pos": Vector2.ZERO,
			"cut_size": Vector2.ZERO,
		},
		"Floor": {
			"albedo_texture": floor_tex,
			"normal_texture": floor_normal,
			"cut_pos": Vector2.ZERO,
			"cut_size": Vector2.ZERO,
		}
	}

var tile_meshes: Dictionary:
	get: return Meshes[set]

var surfaces := {
	Set.BUILDING_01: {},
	Set.BUILDING_02: {},
}

var default_shader := ShaderMaterial.new()

func _init() -> void:
	default_shader.shader = DISTORT_SHADER
	
	# create a cached list of meshes and their surfaces
	for s in surfaces:
		var meshes: Dictionary = Meshes[s]
		for tile_type in [Tile.CORNER, Tile.CENTER, Tile.EDGE, Tile.INNER_CORNER]:
			var curr_mesh = meshes[tile_type]
			surfaces[s][tile_type] = {}
			for surface in ["Interior", "Exterior", "OuterWallBase", "Floor"]:
				surfaces[s][tile_type][surface] = curr_mesh.surface_find_by_name(surface)


static func id_to_tile_type(id: String) -> int:
	return (
		Tile.INNER_CORNER if "INNER_CORNER" in id
		else Tile.CORNER if "CORNER" in id
		else Tile.EDGE if "EDGE" in id
		else Tile.CENTER
	)


func get_tile(tile_type: int) -> Mesh:
	return tile_meshes[tile_type]
