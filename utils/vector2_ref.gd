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
	
	while end.distance_to(last_pos) > max(size.x, size.y):
		var new_pos = last_pos.move_toward(end, delta).snapped(grid_size)
		
		if new_pos.distance_to(points[len(points) - 1]) < min(size.x, size.y) / 2:
			break
		
		points.append(new_pos)
		last_pos = new_pos
	
	return points


static func get_rect_points_in_grid(start: Vector2, end: Vector2, grid_size: Vector2) -> Array[Vector2]:
	var points: Array[Vector2] = []
	
	var width := int((end.x - start.x) / grid_size.x)
	var height := int((end.y - start.y) / grid_size.y)
	
	if width != 0 and height != 0:
		for x in range(0, width + sign(width), sign(width)):
			for y in range(0, height + sign(height), sign(height)):
				var delta = grid_size * Vector2(x, y)
				var new_point = start + delta
				points.append(new_point)
	
	return points

static func is_moving_clockwise(center_pos: Vector2, prev_pos: Vector2, current_pos: Vector2) -> bool:
	return (prev_pos.x - center_pos.x) * (current_pos.y - center_pos.y) - (prev_pos.y - center_pos.y) * (current_pos.x - center_pos.x) > 0


static func randf_range(min_val := 0.0, max_val := 1.0) -> Vector2:
	return Vector2(Auto.Random.randf_range(min_val, max_val), Auto.Random.randf_range(min_val, max_val))


static func get_coords_around_position(position: Vector2, radius := 3) -> Array[Vector2]:
	var coords: Array[Vector2] = []
	var x_range := range(position.x - radius, position.x + radius + 1)
	var y_range := range(position.y - radius, position.y + radius + 1)
	for x in x_range: for y in y_range: coords.append(Vector2(x, y))
	coords.erase(position)
	return coords


static func get_coordsi_around_position(position: Vector2i, radius := 3) -> Array[Vector2i]:
	var coords: Array[Vector2i] = []
	var x_range := range(position.x - radius, position.x + radius + 1)
	var y_range := range(position.y - radius, position.y + radius + 1)
	for x in x_range: for y in y_range: coords.append(Vector2i(x, y))
	coords.erase(position)
	return coords
