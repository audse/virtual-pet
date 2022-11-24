class_name Polygon


static func get_center(polygon: PackedVector2Array) -> Vector2:
	var center := Vector2.ZERO
	for p in polygon:
		center += p
	center /= polygon.size()
	return center


static func get_center_3d(polygon: PackedVector3Array) -> Vector3:
	var center := Vector3.ZERO
	for p in polygon:
		center += p
	center /= polygon.size()
	return center


static func sort(polygon: PackedVector2Array) -> PackedVector2Array:
	var a := Array(polygon)
	var center := get_center(polygon)
	a.sort()
	a.sort_custom(
		func(a: Vector2, b: Vector2) -> bool: return (a - center).angle() < (b - center).angle()
	)
	return PackedVector2Array(a)


static func grow(polygon: PackedVector2Array, delta: float) -> PackedVector2Array:
	var points := Geometry2D.offset_polygon(polygon, delta, Geometry2D.JOIN_MITER)
	return Polygon.sort(points[0]) if len(points) > 0 else PackedVector2Array()


static func shrink(polygon: PackedVector2Array, delta: float) -> PackedVector2Array:
	return Polygon.grow(polygon, -delta)


## Returns a list of triangle faces that make up an outline of the given polygon
static func to_outline(polygon: PackedVector2Array, width: float) -> Array[PackedVector2Array]:
	var faces: Array[PackedVector2Array] = []
	
	polygon = Polygon.sort(polygon)
	var offset_polygon := Polygon.sort(Polygon.grow(polygon, width))
	
	if polygon.size() == offset_polygon.size():
	
		for i in polygon.size():
			var point: Vector2 = polygon[i]
			var prev: Vector2 = polygon[i - 1]
			var inner_point: Vector2 = offset_polygon[i]
			var inner_prev: Vector2 = offset_polygon[i - 1]
			faces.append(PackedVector2Array([
				point,
				inner_point,
				prev
			]))
			faces.append(PackedVector2Array([
				inner_point,
				inner_prev,
				prev
			]))
		
	return faces


static func merge(polygons: Array[PackedVector2Array]) -> PackedVector2Array:
	var merged: Array[PackedVector2Array] = [PackedVector2Array()]
	for polygon in polygons:
		merged = Geometry2D.merge_polygons(merged[0], Polygon.sort(polygon))

	for polygon in merged.slice(1, len(merged)):
		for point in polygon:
			if not merged[0].has(point): merged[0].append(point)

	return Polygon.sort(merged[0])


static func alpha_hull(points: PackedVector2Array, alpha := 2.0) -> PackedVector2Array:
	# Get triangulated shape
	var triangulated_points: PackedInt32Array = Geometry2D.triangulate_delaunay(points)
	var polygon := PackedVector2Array()
	var edges: Array[Array] = []
	
	var add_edge := func (p1: Vector2, p2: Vector2) -> void:
		if [p1, p2] in edges or [p2, p1] in edges:
			edges.erase([p2, p1])
			return
		edges.append([p1, p2])	
	
	for i in range(0, len(triangulated_points), 3):
		var ia: int = triangulated_points[i]
		var ib: int = triangulated_points[i + 1]
		var ic: int = triangulated_points[i + 2]
		var pa: Vector2 = points[ia]
		var pb: Vector2 = points[ib]
		var pc: Vector2 = points[ic]
		
		var a := sqrt((pa[0] - pb[0]) ** 2 + (pa[1] - pb[1]) ** 2)
		var b := sqrt((pb[0] - pc[0]) ** 2 + (pb[1] - pc[1]) ** 2)
		var c := sqrt((pc[0] - pa[0]) ** 2 + (pc[1] - pa[1]) ** 2)
		var s := (a + b + c) / 2.0
		var area := sqrt(s * (s - a) * (s - b) * (s - c))
		var circum_r := (a * b * c / (4.0 * area)) if area > 0.0 else alpha
		
		if circum_r < alpha:
			add_edge.call(pa, pb)
			add_edge.call(pb, pc)
			add_edge.call(pc, pa)
	
	for edge in range(len(edges) - 1, -1, -1):
		var p1: Vector2 = edges[edge][0]
		var p2: Vector2 = edges[edge][1]
		var prev_p1: Vector2 = edges[edge - 1][0]
		var prev_p2: Vector2 = edges[edge - 1][1]
		
		if prev_p1 != p1: polygon.append(p1)
		if prev_p2 != p2: polygon.append(p2)
	
	return Polygon.sort(polygon)
#
#
#static func triangulate(polygon: PackedVector2Array) -> PackedVector2Array:
#	var faces := Geometry2D.triangulate_polygon(polygon)
#	var polygons := PackedVector2Array()
#
#	for face in faces:
#		for point in face:
#			polygons.append(polygon[point])
#
#	return polygons


static func get_edges(polygon: PackedVector2Array, join: bool = true) -> Array[PackedVector2Array]:
	var edges: Array[PackedVector2Array] = []
	
	var num_points := polygon.size()
	if not join: num_points -= 1
	for i in num_points:
		var p1 := polygon[i]
		var p2 := polygon[i - 1]
		edges.append(PackedVector2Array([p2, p1]))
	
	return edges
