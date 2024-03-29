extends Module

var cell_parent: Node3D
var grid: UnevenGrid
var get_neighbors_func: Callable

func _on_ready(context: Node) -> void:
	cell_parent = context
	grid = context.grid
	get_neighbors_func = context.get_neighbors_of


func connect_tile(cell: Cell, preset_tile: SpacialTile = null) -> void:
	cell.bitmask_updated.connect(replace_tile.bind(cell, preset_tile))
	Bits.update_bits(cell, get_neighbors_func)


func connect_many(cells: Array, preset_tile: SpacialTile = null) -> void:
	# We are replacing multiple tiles, so we want the end value for each tile, not the
	# one generated by it's neighbors
	
	# First, update the bitmask for every cell
	for cell in cells:
		if cell.bitmask_updated.is_connected(replace_tile):
			cell.bitmask_updated.disconnect(replace_tile)
		Bits.update_bits(cell, get_neighbors_func)
	# Then, replace the tiles for every cell
	for cell in cells:
		replace_tile(cell, preset_tile)
		cell.bitmask_updated.connect(replace_tile.bind(cell, preset_tile))


func replace_tile(cell: Cell, preset_tile: SpacialTile = null) -> void:
	var next_tile: SpacialTile
	
	# Find the tile to replace with
	if preset_tile: cell.tile = preset_tile
	else:
		var distort_amount := get_distortion_amount(cell)
		next_tile = get_next_tile(cell, distort_amount)
	
	if next_tile:
		# Remove old tile
		if cell.tile and cell.tile.is_inside_tree():
			cell.tile.exit()
			cell.tile = null
		
		# Set new tile
		cell.tile = next_tile
		
		if cell_parent and grid: 
			cell.draw_tile(cell_parent, (grid as UnevenGrid).cell_size)
			cell.tile.enter()


func get_distortion_amount(cell: Cell) -> Vector3:
	# Find the distortion amount based on the current grid point
	if grid: return grid.get_offset_at(cell.coord)
	else: return Vector3.ZERO


func get_next_tile(cell: Cell, distort_amount: Vector3) -> SpacialTile:
	# Get the ID of the new tile based on the cell's bitmask
	var tile_id: String = SpacialTileFactory.get_id_from_bitmask(cell.bitmask)

	# If the new tile is the same as the old one, don't bother replacing it
	if cell.tile and cell.tile.id == tile_id: return null

	# Otherwise, create the new tile
	return SpacialTileFactory.make_from_bitmask(
		cell.bitmask,
		distort_amount,
	)
