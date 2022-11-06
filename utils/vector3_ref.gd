class_name Vector3Ref
extends Object


static func which_elements_equal(a: Vector3, b: Vector3, precision: int = 3) -> Dictionary:
	return {
		x = Math.is_float_equal_approx(a.x, b.x, precision),
		y = Math.is_float_equal_approx(a.y, b.y, precision),
		z = Math.is_float_equal_approx(a.z, b.z, precision)
	}


static func all_elements_equal(a: Vector3, b: Vector3, precision: int = 3) -> bool:
	var equal_elements = which_elements_equal(a, b, precision)
	return equal_elements.x and equal_elements.y and equal_elements.z


static func sign_no_zeros(a: Vector3i, replacement: int = 1) -> Vector3i:
	@warning_ignore(shadowed_global_identifier)
	var sign: Vector3i = sign(a)
	if sign.x == 0: sign.x = replacement
	if sign.y == 0: sign.y = replacement
	if sign.z == 0: sign.z = replacement
	return sign


static func to_rect3(rect: Rect2, ignore_axis = "y") -> Dictionary:
	var to_vec3 = func (p: Vector2) -> Vector3:
		match ignore_axis.to_lower():
			"x": return Vector3(0, p.x, p.y)
			"y": return Vector3(p.x, 0, p.y)
			"z": return Vector3(p.x, p.y, 0)
	
	return {
		position = to_vec3.call(rect.position),
		size = to_vec3.call(rect.size),
		end = to_vec3.call(rect.end)
	}


static func project_position_to_floor(camera: Camera3D, pos: Vector2, exclude: Array = []) -> Vector3:
	# NOTE: (since I know I will forget again)
	# If `direct_space_state` is null, that means this call needs to go in `physics_process`
	var origin := camera.project_ray_origin(pos)
	
	var space_state := camera.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.collide_with_areas = true
	query.to = origin + camera.project_ray_normal(pos) * 2000
	query.hit_back_faces = false
	query.exclude = exclude
	var intersection := space_state.intersect_ray(query)
	
	if "position" in intersection: return intersection.position
	else: return Vector3.ZERO


static func project_position_to_floor_simple(camera: Camera3D, pos: Vector2) -> Vector3:
	var origin := camera.project_ray_origin(pos)
	var direction := camera.project_ray_normal(pos)
	var distance := -origin.y / (direction.y if direction.y != 0 else 1.0)
	return origin + direction * distance


static func smooth_curve(path: Curve3D) -> Curve3D:
	var line := Curve3D.new()
	var points = path.tessellate()
	var size = points.size()
	if size % 2 == 0 and size > 1: 
		var a = points[size-1]
		var b = points[size-2]
		var c = a.linear_interpolate(b, 0.5)
		points.insert(size-1, c)
	line.add_point(points[0])
	var last_m = Vector3()
	for i in range(0, size - 1, 2): 
		var a = points[i]
		var b = points[i+1]
		var c = points[i+2]
		var m1 = quadratic_bezier(a, b, c, 0.2)
		var m2 = quadratic_bezier(a, b, c, 0.4)
		var m3 = quadratic_bezier(a, b, c, 0.6)
		var m4 = quadratic_bezier(a, b, c, 0.8)
		if (i != 0):
			var e = last_m
			var f = points[i]
			var g = m1
			var n1 = quadratic_bezier(e, f, g, 0.33)
			var n2 = quadratic_bezier(e, f, g, 0.66)
			line.add_point(n1)
			line.add_point(n2)
		line.add_point(m1)
		line.add_point(m2)
		line.add_point(m3)
		line.add_point(m4)
		last_m = m4
	line.add_point(points[size-1])
	return line


static func quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	var q0 := p0.lerp(p1, t)
	var q1 := p1.lerp(p2, t)
	var r := q0.lerp(q1, t)
	return r


static func rad(degrees: Vector3) -> Vector3:
	return Vector3(deg_to_rad(degrees.x), deg_to_rad(degrees.y), deg_to_rad(degrees.z))


static func lerp_all(from: Vector3, to: Vector3, weight: Vector3) -> Vector3:
	var new := Vector3.ZERO
	new.x = lerp(from.x, to.x, weight.x)
	new.y = lerp(from.y, to.y, weight.y)
	new.z = lerp(from.z, to.z, weight.z)
	return new


static func deg(radians: Vector3) -> Vector3:
	return Vector3(rad_to_deg(radians.x), rad_to_deg(radians.y), rad_to_deg(radians.z))


static func from_vec2_array(array: Array[Vector2], y := 0.0) -> Array[Vector3]:
	return (
		Iter.new(array)
			.map(func (p: Vector2) -> Vector3:
				return Vector3(p.x, y, p.y))
			.array()
	)
