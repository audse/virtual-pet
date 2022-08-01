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
			"x": return Vector3(0, p.x, p.x)
			"y": return Vector3(p.x, 0, p.y)
			"z": return Vector3(p.x, p.y, 0)
	
	return {
		position = to_vec3.call(rect.position),
		size = to_vec3.call(rect.size),
		end = to_vec3.call(rect.end)
	}


static func project_position_to_floor(camera: Camera3D, pos: Vector2) -> Vector3:
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


static func quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r
