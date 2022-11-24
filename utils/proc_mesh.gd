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
	var mesh := ArrayMesh.new()
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
	
	var i := 0
	for face in faces:
		for vert in [0, 2, 1, 0, 3, 2]:
			surface.add_vertex(face[vert] + params.offset)
			i += 1
	
	surface.generate_normals()
	surface.generate_tangents()
	
	var arrays := surface.commit_to_arrays()
	if len(arrays) > 0 and arrays[0] and len(arrays[0]) > 0:
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return mesh


static func new_outline_polygon(polygon: PackedVector2Array, params := ProcMeshParams.new()) -> ArrayMesh:
	var mesh := ArrayMesh.new()
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
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return mesh


static func new_solid_wall(polygon: PackedVector2Array, params := ProcMeshParams.new()) -> ArrayMesh:
	return ArrayMesh.new()
