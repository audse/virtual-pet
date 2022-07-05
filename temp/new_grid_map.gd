class_name AutotileGridMap
extends Node3D

enum Neighbor {
	TOP_LEFT,
	TOP,
	TOP_RIGHT,
	LEFT,
	RIGHT,
	BOTTOM_LEFT,
	BOTTOM,
	BOTTOM_RIGHT,
}

var cells: Array[Cell]


func set_cell() -> void:
	pass


func find_cell_by_coord(x: int, y: int) -> Cell:
	for cell in cells:
		if cell.coord.x == x and cell.coord.y == y:
			return cell
	return null


func find_cell_by_coordv(coord: Vector3i) -> Cell:
	for cell in cells:
		if cell.coord == coord:
			return cell
	return null


static func get_neighbor_cells(cell_list: Array[Cell], to_cell: Cell) -> Dictionary:
	var neighbor_cells: Dictionary = {
		Neighbor.TOP_LEFT: null,
		Neighbor.TOP: null,
		Neighbor.TOP_RIGHT: null,
		Neighbor.LEFT: null,
		Neighbor.RIGHT: null,
		Neighbor.BOTTOM_LEFT: null,
		Neighbor.BOTTOM: null,
		Neighbor.BOTTOM_RIGHT: null
	}
	
	for cell in cell_list:
		if cell.x == (to_cell.x - 1):
			if cell.y == (to_cell.y - 1): neighbor_cells[Neighbor.TOP_LEFT] = cell
			elif cell.y == to_cell.y: neighbor_cells[Neighbor.LEFT] = cell
			elif cell.y == (to_cell.y + 1): neighbor_cells[Neighbor.BOTTOM_LEFT] = cell
			
		elif cell.x == to_cell.x:
			if cell.y == (to_cell.y - 1): neighbor_cells[Neighbor.TOP] = cell
			elif cell.y == to_cell.y: pass # center
			elif cell.y == (to_cell.y + 1): neighbor_cells[Neighbor.BOTTOM] = cell
				
		elif cell.x == (to_cell.x + 1):
			if cell.y == (to_cell.y - 1): neighbor_cells[Neighbor.TOP_RIGHT] = cell
			elif cell.y == to_cell.y: neighbor_cells[Neighbor.RIGHT] = cell
			elif cell.y == (to_cell.y + 1): neighbor_cells[Neighbor.BOTTOM_RIGHT] = cell
		
	return neighbor_cells
