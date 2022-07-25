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
