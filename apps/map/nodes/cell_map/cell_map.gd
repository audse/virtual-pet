class_name CellMap
extends Node3D
@icon("cell_map_icon.svg")

@export var grid: Resource
@export var use_autotile: bool = true

var UseSpacialTiles = Modules.import(Modules.UseSpacialTiles, self) if use_autotile else null

var cells: Array[Cell]
var _cached_coords: Dictionary = {}


func set_cell(x: int, y: int, tile: MeshInstance3D = null, set_many: bool = true) -> Cell:
	return set_cellv(Vector3i(x, 0, y), tile, set_many)


func set_cellv(coord: Vector3i, tile: MeshInstance3D = null, set_many: bool = false) -> Cell:
	var cell_exists: Cell = find_cell_by_coordv(coord)
	if not cell_exists:
		var cell := Cell.new()
		cell.coord = coord
		cells.append(cell)
		_cached_coords[coord] = cell
		
		if use_autotile:
			if not set_many: UseSpacialTiles.connect_tile.call(cell, tile)
		else: cell.draw_tile(self, grid.cell_size, tile)
		
		return cell
	return null


func set_cells_between(start_x: int, start_y: int, start_z: int, end_x: int, end_y: int, end_z: int, tile: MeshInstance3D = null) -> void:
	set_cells_betweenv(
		Vector3i(start_x, start_y, start_z),
		Vector3i(end_x, end_y, end_z),
		tile
	)


func set_cells_betweenv(start_coord: Vector3i, end_coord: Vector3i, tile: MeshInstance3D = null) -> void:
	var empty_coords := get_empty_coords_betweenv(start_coord, end_coord)
	var new_cells: Array[Cell] = []
	for coord in empty_coords:
		new_cells.append(set_cellv(coord, tile, true))
	if use_autotile: UseSpacialTiles.connect_many(new_cells, tile)


func erase_cell(cell: Cell) -> void:
	if cell:
		var neighbors := get_neighbors_of(cell)
		cells.erase(cell)
		for neighbor in neighbors.list():
			if neighbor: Bits.update_bits(neighbor, get_neighbors_of)
	if cell.coord in _cached_coords: _cached_coords.erase(cell.coord)
	kill_cell(cell)


func erase_cell_at_coord(x: int, y: int, z: int) -> void:
	erase_cell_at_coordv(Vector3i(x, y, z))


func erase_cell_at_coordv(coord: Vector3i) -> void:
	var cell := find_cell_by_coordv(coord)
	erase_cell(cell)


func erase_cells_between(start_x: int, start_y: int, start_z: int, end_x: int, end_y: int, end_z: int) -> void:
	erase_cells_betweenv(
		Vector3i(start_x, start_y, start_z),
		Vector3i(end_x, end_y, end_z)
	)


func erase_cells_betweenv(start_coord: Vector3i, end_coord: Vector3i) -> void:
	var cells_to_erase := get_cells_betweenv(start_coord, end_coord)
	for cell in cells_to_erase:
		erase_cell(cell)


func clear() -> void:
	for cell in cells:
		kill_cell(cell)
	cells = []


func kill_cell(cell: Cell) -> void:
	if cell.tile: cell.tile.free()
	if cell: cell.free()


func get_cells_between(start_x: int, start_y: int, start_z: int, end_x: int, end_y: int, end_z: int) -> Array[Cell]:
	return get_cells_betweenv(
		Vector3i(start_x, start_y, start_z),
		Vector3i(end_x, end_y, end_z)
	)


func get_cells_betweenv(start_coord: Vector3i, end_coord: Vector3i) -> Array[Cell]:
	var cells_between: Array[Cell] = []
	
	var direction: Vector3i = Vector3Ref.sign_no_zeros(end_coord - start_coord)
	
	for x in range(start_coord.x, end_coord.x + direction.x, direction.x):
		for y in range(0, 1):
			for z in range(start_coord.z, end_coord.z + direction.z, direction.z):
				var cell := find_cell_by_coord(x, y, z)
				if cell: cells_between.append(cell)
	
	return cells_between


func get_empty_cells_between(start_x: int, start_y: int, start_z: int, end_x: int, end_y: int, end_z: int) -> Array[Vector3i]:
	return get_empty_coords_betweenv(
		Vector3i(start_x, start_y, start_z),
		Vector3i(end_x, end_y, end_z)
	)


func get_empty_coords_betweenv(start_coord: Vector3i, end_coord: Vector3i) -> Array[Vector3i]:
	var coords_between: Array[Vector3i] = []
	
	var direction: Vector3i = Vector3Ref.sign_no_zeros(end_coord - start_coord)
	
	for x in range(start_coord.x, end_coord.x + direction.x, direction.x):
		for y in range(0, 1):
			for z in range(start_coord.z, end_coord.z + direction.z, direction.z):
				var cell := find_cell_by_coord(x, y, z)
				if not cell: coords_between.append(Vector3i(x, y, z))
	
	return coords_between


func find_cell_by_coord(x: int, y: int, z: int) -> Cell:
	return find_cell_by_coordv(Vector3i(x, y, z))


func find_cell_by_coordv(coord: Vector3i) -> Cell:
	if coord in _cached_coords and _cached_coords[coord] != null: return _cached_coords[coord]
	for cell in cells:
		if cell.coord == coord:
			return cell
	return null


func get_neighbors_of(to_cell: Cell) -> NeighborGroup:
	var neighbors: NeighborGroup = NeighborGroup.new(to_cell)
	for cell in cells:
		neighbors.set_relation(to_cell.get_relation_of(cell.coord), cell)
	return neighbors


func world_to_map(world_pos: Vector3) -> Vector3i:
	if not grid: return Vector3i.ZERO
	var map_pos: Vector3 = world_pos / grid.cell_size
	@warning_ignore(narrowing_conversion)
	return Vector3i(round(map_pos.x), floor(map_pos.y), round(map_pos.z))


func map_to_world(coords: Vector3i, center: bool = false) -> Vector3:
	if not grid: return Vector3.ZERO
	var world_pos: Vector3 = Vector3(coords) * grid.cell_size
	if center: world_pos += (grid.cell_size / 2.0)
	return world_pos


func world_to_map_to_world(world_pos: Vector3, center: bool = false) -> Vector3:
	var coords := world_to_map(world_pos)
	return map_to_world(coords, center)
