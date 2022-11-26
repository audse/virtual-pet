class_name Polygon3
extends Object


static func get_center(polygon: PackedVector3Array) -> Vector3:
	var center := Vector3.ZERO
	for p in polygon:
		center += p
	center /= polygon.size()
	return center


static func sort(polygon, normal := Vector3.FORWARD) -> PackedVector3Array:
	assert(polygon is PackedVector3Array or polygon is Array, "Expected `PackedVector3Array` or `Array[PackedVector3]`")
	if polygon.size() < 3: return polygon
	var p := Array(polygon)
	
	var start_vert: Vector3 = polygon[0]
	
	p.sort_custom(
		func(a: Vector3, b: Vector3) -> bool:
			return a.distance_to(start_vert) < b.distance_to(start_vert)
	)
	
	var ref: Vector3 = p[1] - start_vert
	var results := p.slice(1)
	results.sort_custom(
		func(a: Vector3, b: Vector3) -> bool:
			return ref.angle_to(a - start_vert) < ref.angle_to(b - start_vert)
	)
	
	results.insert(0, start_vert)
	
	if ((results[1] - results[0]).cross(results[2] - results[0]).normalized() + normal.normalized()).length() < sqrt(2.0):
		results.reverse()
	
	return PackedVector3Array(results)


static func get_facing(edge1, edge2, flip_normal: bool = false) -> Vector3:
	assert((edge1 is Vector2 and edge2 is Vector2) or (edge1 is Vector3 and edge2 is Vector3), "Edge points must be either `Vector2` or `Vector3`")
	
	var facing := Vector3.ZERO
	var normal = edge1.direction_to(edge2)
	
	if normal is Vector2:
		normal = normal.rotated(deg_to_rad(90))
		facing = Vector3(normal.x, 0, normal.y)
	elif normal is Vector3:
		normal = (normal as Vector3).rotated(Vector3.UP, deg_to_rad(90))
		facing = normal
	
	if flip_normal: facing *= -1
	return facing
