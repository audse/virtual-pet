extends MeshInstance3D

signal grid_distorted

var rand := RandomNumberGenerator.new()
var data := MeshDataTool.new()

var unique_vertices := [] # [vertex_index, offset_x, offset_z, original_vertex]

func _ready() -> void:
	data.create_from_surface(mesh, 0)
	rand.randomize()
	
	var used_vertices := []
	
	for i in range(data.get_vertex_count()):
		var vertex := data.get_vertex(i)
		
		var is_used := false
		for used_vertex in used_vertices:
			if vertex.distance_to(used_vertex[0]) < 0.25:
				is_used = true
				vertex.x += used_vertex[1]
				vertex.z += used_vertex[2]
				break
		
		if not is_used:
			var offset_x := rand.randf_range(-0.15, 0.15)
			var offset_z := rand.randf_range(-0.15, 0.15)
			used_vertices.append([vertex, offset_x, offset_z])
			unique_vertices.append([i, offset_x, offset_z, vertex])
			vertex.x += offset_x
			vertex.z += offset_z
		
		data.set_vertex(i, vertex)
	
	mesh.clear_surfaces()
	data.commit_to_surface(mesh)
	emit_signal("grid_distorted")
