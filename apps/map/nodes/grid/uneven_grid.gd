class_name UnevenGrid
extends Resource

# TODO
# - [ ] Dual grid

## The distance (in meters?) between each grid point
@export var cell_size: Vector3 = Vector3(1, 1, 1)

## The minimum and maximum offset of each grid point (to be randomized) 
## on the x axis. For creating irregular grids.
@export var x_offset_range: Array[float] = [-0.15, 0.15]

## The minimum and maximum offset of each grid point (to be randomized) 
## on the z axis. For creating irregular grids.
@export var z_offset_range: Array[float] = [-0.15, 0.15]

var points: Array[UnevenPoint] = make_grid()


## Returns a list of grid points and their metadata
func make_grid() -> Array[UnevenPoint]:
	var new_points := []
	for x in range(-10, 10):
		for z in range(-10, 10):
			var new_cell := UnevenPoint.new(Vector3i(x, 0, z))
			new_cell.offset = Vector3(
				randf_range(x_offset_range[0], x_offset_range[1]),
				0.0,
				randf_range(z_offset_range[0], z_offset_range[1])
			)
			new_cell.world_position = Vector3(
				x * cell_size.x + new_cell.offset.x,
				0.0,
				z * cell_size.z + new_cell.offset.z
			)
			new_points.append(new_cell)
	return new_points


func get_point_at(coord: Vector3i) -> UnevenPoint:
	for point in points:
		if point.coord == coord: return point
	return null


func get_offset_at(coord: Vector3i) -> Vector3:
	var point := get_point_at(coord)
	if point: return point.offset
	else: return Vector3.ZERO
