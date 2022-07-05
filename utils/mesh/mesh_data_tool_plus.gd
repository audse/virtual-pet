class_name MeshDataToolPlus
extends MeshDataTool

const precision := 4

## Finds the index of the vertex based on the vertex's world position
func find_vertex(vertex: Vector3) -> int:
	return find_vertex_in(self, vertex)


## Finds the index of the vertex within the supplied MeshDataTool
## based on the vertex's world position
static func find_vertex_in(mesh_data: MeshDataTool, vertex: Vector3) -> int:
	if mesh_data.has_method("get_vertex_count"):
		for i in range(mesh_data.get_vertex_count()):
			var mesh_vertex: Vector3 = mesh_data.get_vertex(i)
			if Vector3Ref.all_elements_equal(vertex, mesh_vertex, precision):
				return i
	return -1


func find_all_vertices(vertex: Vector3) -> Array[int]:
	return find_all_vertices_in(self, vertex)


static func find_all_vertices_in(mesh_data: MeshDataTool, vertex: Vector3) -> Array[int]:
	var vertices: Array[int] = []
	if mesh_data.has_method("get_vertex_count"):
		for i in range(mesh_data.get_vertex_count()):
			var mesh_vertex: Vector3 = mesh_data.get_vertex(i)
			if Vector3Ref.all_elements_equal(vertex, mesh_vertex, precision):
				vertices.append(i)
	return vertices
	


## Returns a list of mesh indices based each vertex's world position
func find_vertex_indices(vertices: Array[Vector3]) -> Array[int]:
	return find_vertex_indices_in(self, vertices)


## Returns a list of mesh indices within a supplied MeshDataTool based each 
## vertex's world position
static func find_vertex_indices_in(mesh_data: MeshDataTool, vertices: Array[Vector3]) -> Array[int]:
	var mesh_indices: Array[int] = []
	
	for vertex in vertices:
		var mesh_index := find_vertex_in(mesh_data, vertex)
		if mesh_index != -1:
			mesh_indices.append(vertex)
	
	return mesh_indices
