class_name VertexData
extends Resource

## JSON file containing mesh vertices in vertex groups (exported from blender)
@export_file("*.json") var data_file 

var file := File.new()
var json := JSON.new()

var data: Array[Dictionary]
var groups: Dictionary # { surface_index: Array[VertexGroup] }


func load_data(mesh_data: MeshDataToolPlus = null, surface: int = 0) -> Array[Dictionary]:
	var loaded_data: Array[Dictionary] = []
	
	file.open(data_file, File.READ)
	
	var error := json.parse(file.get_as_text())
	if error == OK: loaded_data = json.get_data()["groups"]
	file.close()
	
	# create groups
	groups[surface] = []
	for group in loaded_data:
		var existing_group := get_group(group["group_name"], surface)
		if not existing_group: groups[surface].append(create_group(group, mesh_data))
		else: existing_group.update_vertices_from_mesh(mesh_data)
	
	return loaded_data


static func create_group(group_data: Dictionary, mesh_data: MeshDataToolPlus = null) -> VertexGroup:
	var vertices: Array[Vector3] = []
	for vertex in group_data["vertices"]:
		var new_vertex := Vector3(vertex["x"], vertex["z"], -vertex["y"])
		vertices.append(new_vertex)
	return VertexGroup.new(group_data["group_name"], vertices, mesh_data)


func get_group(group_name: String, surface: int = -1) -> VertexGroup:
	# Find within particular surface, if needed
	if surface != -1 and surface in groups.keys():
		for group in groups[surface]:
			if group.group_name == group_name: return group
	# Or just find the first matching group
	for surface in groups.values():
		for group in groups[surface]:
			if group.group_name == group_name: return group
	return null


func get_groups(group_name: String, surfaces: Array = []) -> Array[VertexGroup]:
	# if no surface list is provided, just search them all
	var surface_list: Array[int] = surfaces
	if len(surfaces) == 0: surface_list = groups.keys()
	
	var group_list: Array[VertexGroup] = []
	
	for surface in surface_list:
		if not surface in groups: continue
		for group in groups[surface]:
			if group.group_name == group_name: group_list.append(group)
	
	return group_list
