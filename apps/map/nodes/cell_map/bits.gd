class_name Bits
extends Object

const instructions = """
	This is how to calculate 2x2 bit masks.
	
	Instructions copied from: 
		https://www.codeproject.com/Articles/106884/Implementing-Auto-tiling-Functionality-in-a-Tile-M
	
	1. When a new tile is placed in the map
		- the four corner bits are extracted from 
			- the 4-bit index of the tile 
			- and its 8 neighbours
	2. For each of the four tiles (left, right, above, below) sharing an edge with the new tile, 
		- new 4-bit indices are constructed by 
		- reusing the 2 bits from 
			- the new tile closest to the shared edge, 
			- and the 2 bits in the neighbouring tile furthest from the edge. 
		- The new 4-bit indices effectively result in 
			- transitory tiles that blend correctly with the new tile.
	3. Similarly, for each of the four remaining neighbours (top-left, top-right, bottom-left, bottom-right) 
	sharing a corner with the new tile, 
		- 4-bit indices are constructing using 
			- the bit from the new tile closest to the shared corner, 
			- and the 3 bits furthers from the shared corner in the neighbouring tile. 
		- These new 4-bit indices likewise result in 
			- four corner neighbours that blend correctly with the new tile.
	4. The neighbouring tiles are replaced with new tiles corresponding to the newly computed 4-bit indices.
"""


static func update_bits(cell: Cell, get_neighbors_func: Callable) -> int:	
	cell.bitmask = get_added_cell_bits(cell, get_neighbors_func)
	update_neighbor_bits(get_neighbors_func, cell)
	return OK


static func get_added_cell_bits(cell: Cell, get_neighbors_func: Callable) -> BitMask:
	var bitmask := BitMask.new()
	var neighbors: NeighborGroup = get_neighbors_func.call(cell)
	
	if neighbors.top_left and neighbors.top and neighbors.left: bitmask.add_top_left()
	if neighbors.top_right and neighbors.top and neighbors.right: bitmask.add_top_right()
	if neighbors.bottom_left and neighbors.bottom and neighbors.left: bitmask.add_bottom_left()
	if neighbors.bottom_right and neighbors.bottom and neighbors.right: bitmask.add_bottom_right()
	return bitmask


static func update_neighbor_bits(get_neighbors_func: Callable, added_cell: Cell) -> void:
	var neighbors: NeighborGroup = get_neighbors_func.call(added_cell)
	
	for edge_relation in NeighborGroup.edge_neighbors():
		var neighbor: Cell = neighbors.get_relation(edge_relation)
		if neighbor: neighbor.bitmask = get_bits_from_edge_relation(neighbor, get_neighbors_func, added_cell, edge_relation)
	
	for corner_relation in NeighborGroup.corner_neighbors():
		var neighbor: Cell = neighbors.get_relation(corner_relation)
		if neighbor: neighbor.bitmask = get_bits_from_corner_relation(neighbor, get_neighbors_func, added_cell, corner_relation)


static func get_bits_from_edge_relation(cell: Cell, get_neighbors_func: Callable, added_cell: Cell, relation: int) -> BitMask:
	var bitmask := BitMask.new()
	var neighbors: NeighborGroup = get_neighbors_func.call(cell)
	
	var neighbor: Cell
	var shared_bits: Array[int] = []
	var opposite_bits: Array[int] = []
	
	if relation == NeighborGroup.TOP:
		neighbor = neighbors.top
		shared_bits = BitMask.top_bits()
		opposite_bits = BitMask.bottom_bits()
		
	elif relation == NeighborGroup.BOTTOM:
		neighbor = neighbors.bottom
		shared_bits = BitMask.bottom_bits()
		opposite_bits = BitMask.top_bits()
			
	elif relation == NeighborGroup.LEFT:
		neighbor = neighbors.left
		shared_bits = BitMask.left_bits()
		opposite_bits = BitMask.right_bits()
			
	elif relation == NeighborGroup.RIGHT:
		neighbor = neighbors.right
		shared_bits = BitMask.right_bits()
		opposite_bits = BitMask.left_bits()
	
	for i in range(2):
		var shared_bit: int = shared_bits[i]
		var opposite_bit: int = opposite_bits[i]
		if added_cell.bitmask.has(shared_bit): bitmask.add(opposite_bit)
	
	if neighbor:
		for i in range(2):
			var shared_bit: int = shared_bits[i]
			var opposite_bit: int = opposite_bits[i]
			if neighbor.bitmask.has(opposite_bit): bitmask.add(shared_bit)
	
	return bitmask


static func get_bits_from_corner_relation(cell: Cell, get_neighbors_func: Callable, added_cell: Cell, relation: int) -> BitMask:
	var bitmask := BitMask.new()
	
	var neighbors: NeighborGroup = get_neighbors_func.call(cell)
	var bits_to_set: Array[int] = BitMask.bits()
	
	if relation == NeighborGroup.TOP_LEFT:
		if added_cell.bitmask.top_left: bitmask.add_bottom_right()
		bits_to_set.erase(NeighborGroup.BOTTOM_RIGHT)
			
	elif relation == NeighborGroup.TOP_RIGHT:
		if added_cell.bitmask.top_right: bitmask.add_bottom_left()
		bits_to_set.erase(NeighborGroup.BOTTOM_LEFT)
			
	elif relation == NeighborGroup.BOTTOM_LEFT:
		if added_cell.bitmask.bottom_left: bitmask.add_top_right()
		bits_to_set.erase(NeighborGroup.TOP_RIGHT)
			
	elif relation == NeighborGroup.BOTTOM_RIGHT:
		if added_cell.bitmask.bottom_right: bitmask.add_top_left()
		bits_to_set.erase(NeighborGroup.TOP_LEFT)
	
	if BitMask.TOP_RIGHT in bits_to_set and neighbors.top_right:
		if neighbors.top_right.bitmask.bottom_left:
			bitmask.add_top_right()
	
	if BitMask.TOP_LEFT in bits_to_set and neighbors.top_left:
		if neighbors.top_left.bitmask.bottom_right:
			bitmask.add_top_left()
	
	if BitMask.BOTTOM_LEFT and neighbors.bottom_left:
		if neighbors.bottom_left.bitmask.top_right:
			bitmask.add_bottom_left()
	
	if BitMask.BOTTOM_RIGHT and neighbors.bottom_right:
		if neighbors.bottom_right.bitmask.top_left:
			bitmask.add_bottom_right()
	
	return bitmask
