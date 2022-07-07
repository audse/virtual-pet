class_name Vector2Ref
extends Object

# Calculates the interpolated points between start/end vec2, snapped to a grid
# [x _ _]
# [_ x _]
# [_ _ x]
static func get_line_points_in_grid(start: Vector2, end: Vector2, grid_size: Vector2) -> Array[Vector2]:
	# a^2 + b^2 = c^2
	var size: Vector2 = abs(grid_size)
	var delta: float = sqrt(pow(size.x, 2) + pow(size.y, 2))
	var points: Array[Vector2] = [start]
	
	var last_pos: Vector2 = start
	
	while end.distance_to(last_pos) > 10:
		var new_pos = last_pos.move_toward(end, delta).snapped(grid_size)
		points.append(new_pos)
		last_pos = new_pos
	
	return points


static func get_rect_points_in_grid(start: Vector2, end: Vector2, grid_size: Vector2) -> Array[Vector2]:
	var points: Array[Vector2] = []
	
	var width := int((end.x - start.x) / grid_size.x)
	var height := int((end.y - start.y) / grid_size.y)
	
	if width != 0 and height != 0:
		for x in range(0, width, sign(width)):
			for y in range(0, height, sign(height)):
				var delta = grid_size * Vector2(x, y)
				var new_point = start + delta
				points.append(new_point)
	
	return points
