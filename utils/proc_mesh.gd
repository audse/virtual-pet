class_name ProcMesh
extends Object


static func new_polygon(polygon: PackedVector2Array, params := ProcMeshParams.new()) -> ArrayMesh:
	var verts := Geometry2D.triangulate_polygon(polygon)
	
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3(0, 1, 0))
	surface.set_uv(Vector2.ZERO)
	
	for i in verts:
		surface.add_vertex(Vector3(polygon[i].x, 0.0, polygon[i].y) + params.offset)
	
	return surface.commit()


static func new_wall(polygon: PackedVector2Array, params := ProcMeshParams.new()) -> ArrayMesh:
	var faces = []
	# Create a face for each edge of the polygon
	var num_points := polygon.size()
	if not params.join: num_points -= 1
	for i in num_points:
		var point: Vector2 = polygon[i]
		var prev: Vector2 = polygon[i - 1]
		faces.append(PackedVector3Array([
			Vector3(point.x, 0, point.y),
			Vector3(prev.x, 0, prev.y),
			Vector3(prev.x, params.height, prev.y),
			Vector3(point.x, params.height, point.y)
		]))
	
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.ZERO)
	surface.set_uv(Vector2.ZERO)
	
	for face in faces:
		for vert in [0, 2, 1, 0, 3, 2]:
			surface.add_vertex(face[vert] + params.offset)
	
	surface.generate_normals()
	surface.generate_tangents()
	
	var arrays := surface.commit_to_arrays()
	if len(arrays) > 0 and arrays[0] and len(arrays[0]) > 0:
		params.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return params.mesh


static func new_outline_polygon(polygon: PackedVector2Array, params := ProcMeshParams.new()) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3(0, 1, 0))
	surface.set_uv(Vector2.ZERO)
	
	for face in Polygon.to_outline(polygon, -params.thickness):
		for p in Polygon.sort(face):
			surface.add_vertex(Vector3(p.x, 0.0, p.y) + params.offset)
	
	surface.generate_normals()
	surface.generate_tangents()
	
	var arrays := surface.commit_to_arrays()
	if len(arrays) > 0 and arrays[0] and len(arrays[0]) > 0:
		params.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return params.mesh


static func new_wall_with_rect_cutouts(edge1: Vector2, edge2: Vector2, cutouts: Array[Rect2], params := ProcMeshParams.new()) -> ArrayMesh:
	var faces: Array[PackedVector3Array] = []
	
	# Sort cutouts from leftmost to rightmost
	cutouts.sort_custom(
		func(a: Rect2, b: Rect2) -> bool:
			return a.position.x < b.position.x
	)
	
	var edge_size := (edge2 - edge1).abs()
	var edge_length: float = max(edge_size.x, edge_size.y)
	
	var num_cutouts := len(cutouts)
	for i in num_cutouts:
		var cutout: Rect2 = cutouts[i]
		var percent: float = cutout.position.x / edge_length
		var end_percent: float = cutout.end.x / edge_length
		var top_left := Vector3(
			lerp(edge1.x, edge2.x, percent), 
			params.height - cutout.position.y, 
			lerp(edge1.y, edge2.y, percent)
		)
		var top_right := Vector3(
			lerp(edge1.x, edge2.x, end_percent),
			params.height - cutout.position.y,
			lerp(edge1.y, edge2.y, end_percent)
		)
		var bottom_left := Vector3(
			top_left.x,
			params.height - cutout.end.y,
			top_left.z,
		)
		var bottom_right := Vector3(
			top_right.x,
			params.height - cutout.end.y,
			top_right.z
		)
		
		var far_left: Vector2 = edge1
		if i > 0:
			var far_left_percent: float = cutouts[i - 1].end.x / edge_length
			far_left = edge1.lerp(edge2, far_left_percent)
		
		# Left face
		faces.append(Polygon3.sort([
			Vector3(far_left.x, 0, far_left.y),
			Vector3(far_left.x, params.height, far_left.y),
			Vector3(top_left.x, params.height, top_left.z),
		], params.facing))
		faces.append(Polygon3.sort([
			Vector3(far_left.x, 0, far_left.y),
			Vector3(top_left.x, params.height, top_left.z),
			Vector3(top_left.x, 0, top_left.z),
		], params.facing))
		
		var far_right: Vector2 = edge2
		if i < (num_cutouts - 1):
			var far_right_percent: float = cutouts[i + 1].position.x / edge_length
			far_right = edge1.lerp(edge2, far_right_percent)
		
		# Right face
		faces.append(Polygon3.sort([
			Vector3(top_right.x, 0, top_right.z),
			Vector3(top_right.x, params.height, top_right.z),
			Vector3(far_right.x, params.height, far_right.y),
		], params.facing))
		faces.append(Polygon3.sort([
			Vector3(top_right.x, 0, top_right.z),
			Vector3(far_right.x, params.height, far_right.y),
			Vector3(far_right.x, 0, far_right.y),
		], params.facing))
		
		# Above face
		faces.append(Polygon3.sort([
			Vector3(top_left.x, params.height, top_left.z),
			top_left,
			top_right,
		], params.facing))
		faces.append(Polygon3.sort([
			Vector3(top_left.x, params.height, top_left.z),
			top_right,
			Vector3(top_right.x, params.height, top_right.z),
		], params.facing))
		
		# Below face
		faces.append(Polygon3.sort([
			Vector3(bottom_left.x, 0, bottom_left.z),
			bottom_left,
			bottom_right,
		], params.facing))
		faces.append(Polygon3.sort([
			Vector3(bottom_left.x, 0, bottom_left.z),
			bottom_right,
			Vector3(bottom_right.x, 0, bottom_right.z),
		], params.facing))
	
	if num_cutouts == 0:
		faces.append(Polygon3.sort([
			Vector3(edge1.x, 0, edge1.y),
			Vector3(edge1.x, params.height, edge1.y),
			Vector3(edge2.x, params.height, edge2.y),
		], params.facing))
		faces.append(Polygon3.sort([
			Vector3(edge1.x, 0, edge1.y),
			Vector3(edge2.x, 0, edge2.y),
			Vector3(edge2.x, params.height, edge2.y),
		], params.facing))
	
	if not params.mesh: params.mesh = ArrayMesh.new()
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(params.facing)
	surface.set_uv(Vector2.ZERO)
	
	var colors := [
		ColorRef.FUCHSIA_400,
		ColorRef.FUCHSIA_300,
		ColorRef.SKY_400,
		ColorRef.SKY_300,
		ColorRef.INDIGO_400,
		ColorRef.INDIGO_300,
		ColorRef.EMERALD_400,
		ColorRef.EMERALD_300,
	]
	
	var i := 0
	for face in faces:
		surface.set_color(colors[i % 8])
		for vert in face:
			surface.add_vertex(vert + params.offset)
		i += 1
	surface.generate_normals()
	surface.generate_tangents()
	
	var arrays := surface.commit_to_arrays()
	if len(arrays) > 0 and arrays[0] and len(arrays[0]) > 0:
		params.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return params.mesh


static func new_rounded_plane(rect: Rect2, params := ProcMeshParams.new()) -> ArrayMesh:
	var radius_vec := Vector2(params.corner_radius, params.corner_radius)
	var inner_rect_x := Rect2(
		Vector2(rect.position.x, rect.position.y + params.corner_radius),
		Vector2(rect.size.x, rect.size.y - params.corner_radius * 2)
	)
	var inner_rect_y := Rect2(
		Vector2(rect.position.x + params.corner_radius, rect.position.y),
		Vector2(rect.size.x - params.corner_radius * 2, rect.size.y)
	)
	var inner_rect_tris := [
		Polygon.sort([inner_rect_x.position, inner_rect_x.end, Vector2(inner_rect_x.position.x, inner_rect_x.end.y)]),
		Polygon.sort([inner_rect_x.position, inner_rect_x.end, Vector2(inner_rect_x.end.x, inner_rect_x.position.y)]),
		Polygon.sort([inner_rect_y.position, inner_rect_y.end, Vector2(inner_rect_y.position.x, inner_rect_y.end.y)]),
		Polygon.sort([inner_rect_y.position, inner_rect_y.end, Vector2(inner_rect_y.end.x, inner_rect_y.position.y)]),
	]
	var corners := [rect.position, rect.end, Vector2(rect.position.x, rect.end.y), Vector2(rect.end.x, rect.position.y)]
	var inner_corners := [corners[0] + radius_vec, corners[1] - radius_vec, corners[2] + radius_vec * Vector2(1, -1), corners[3] + radius_vec * Vector2(-1, 1)]
	
	var corner_tris: Array[PackedVector2Array] = []
	
	for c in corners.size():
		var corner := corners[c]
		var inner_corner := inner_corners[c]
		
		var corner_points := PackedVector2Array([Vector2(corner.x, inner_corner.y)])
		
		for p in params.corner_points:
			var angle_1 := inner_corner.angle_to_point(Vector2(corner.x, inner_corner.y))
			var angle_2 := inner_corner.angle_to_point(Vector2(inner_corner.x, corner.y))
			var percent: float = (p + 1) as float / params.corner_points as float
			var degree: float = lerp_angle(angle_1, angle_2, percent)
			
			corner_points.append(Vector2(
				inner_corner.x + (params.corner_radius * cos(degree)),
				inner_corner.y + (params.corner_radius * sin(degree))
			))
		
		corner_points.append(Vector2(inner_corner.x, corner.y))
		
		for p in range(1, corner_points.size()):
			corner_tris.append(Polygon.sort([
				inner_corner,
				corner_points[p],
				corner_points[p - 1]
			]))
	
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(params.facing)
	surface.set_uv(Vector2.ZERO)
	
	var to_v3 := func(v2: Vector2) -> Vector3:
		if params.facing.is_equal_approx(Vector3.UP) or params.facing.is_equal_approx(Vector3.DOWN): 
			return Vector3(v2.x, 0, v2.y)
		elif params.facing.is_equal_approx(Vector3.FORWARD) or params.facing.is_equal_approx(Vector3.BACK): 
			return Vector3(v2.x, v2.y, 0)
		else: return Vector3(0, v2.x, v2.y)
	
	for tri in inner_rect_tris:
		for vert in tri: surface.add_vertex(to_v3.call(vert))
	for tri in corner_tris:
		for vert in tri: surface.add_vertex(to_v3.call(vert))
	
	surface.generate_normals()
	surface.generate_tangents()
	
	var arrays := surface.commit_to_arrays()
	if len(arrays) > 0 and arrays[0] and len(arrays[0]) > 0:
		params.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return params.mesh

