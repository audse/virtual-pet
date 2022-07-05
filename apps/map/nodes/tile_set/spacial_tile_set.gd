class_name SpacialTileSet
extends Resource

@export var tiles: Array[PackedScene]
var instantiated_tiles: Array[SpacialTile]


func setup() -> void:
	instantiated_tiles = []
	for tile in tiles:
		instantiated_tiles.append(tile.instantiate())


func get_tile_with_bitmask(bitmask: BitMask) -> SpacialTile:
	for tile in instantiated_tiles:
		var tile_bitmask := tile.get_bitmask()
		if tile_bitmask.as_array() == bitmask.as_array(): return tile
	
	# Return the first tile, if no others are found (and one exists)
#	if len(instantiated_tiles) > 0: return instantiated_tiles[0]
	# TODO return the most similar tile ?
	
	return null
