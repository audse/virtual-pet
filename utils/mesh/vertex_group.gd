class_name VertexGroup
extends Object

var group_name: String
var vertices: Array[Vertex] = []


func _init(
	group_name_value: String = "Group",
	vertices_value: Array = [],
	mesh_data: MeshDataToolPlus = null
) -> void:
	group_name = group_name_value
	if not mesh_data: return
	
	add_vertices(vertices_value, mesh_data)


func add_vertices(vertex_array: Array[Vector3], mesh_data: MeshDataToolPlus) -> void:
	if not mesh_data: return
	for vertex in vertex_array:
		var mesh_indices: Array[int] = mesh_data.find_all_vertices(vertex)
		var new_vertex := Vertex.new(vertex, mesh_indices)
		vertices.append(new_vertex)


func update_vertices_from_mesh(mesh_data: MeshDataToolPlus) -> void:
	if not mesh_data: return
	for vertex in vertices:
		vertex.mesh_indices = mesh_data.find_all_vertices(vertex.position)


func move_all(target_position: Vector3) -> void:
	if len(vertices) == 0: return
	var delta: Vector3 = target_position - vertices[0].position
	for vertex in vertices:
		vertex.position += delta


func move_all_by(delta: Vector3) -> void:
	for vertex in vertices:
		vertex.position += delta


func slide_all() -> void: pass


class Vertex:
	var position: Vector3
	var mesh_index: int
	var mesh_indices: Array[int]
	
	func _init(position_value: Vector3 = Vector3.ZERO, mesh_indices_value: Array = []):
		position = position_value
		mesh_indices = mesh_indices_value
