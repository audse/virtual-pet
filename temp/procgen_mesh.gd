extends MeshInstance3D

var rand := RandomNumberGenerator.new()
var data := MeshDataTool.new()

var mesh_copy := mesh.duplicate()

func _ready() -> void:
	data.create_from_surface(mesh, 0)
	rand.randomize()


func rand_distort() -> void:
	
	var distort_1_x := rand.randf_range(-0.1, 0.1)
	var distort_1_z := rand.randf_range(-0.1, 0.1)
	var distort_2_x := rand.randf_range(-0.1, 0.1)
	var distort_2_z := rand.randf_range(-0.1, 0.1)
	var distort_3_x := rand.randf_range(-0.1, 0.1)
	var distort_3_z := rand.randf_range(-0.1, 0.1)
	var distort_4_x := rand.randf_range(-0.1, 0.1)
	var distort_4_z := rand.randf_range(-0.1, 0.1)
	
	for i in range(data.get_vertex_count()):
		var vertex := data.get_vertex(i)
		
		var is_right := vertex.x > 0.5
		var is_left := vertex.x < -0.5
		var is_back := vertex.z < -0.5
		var is_front := vertex.z > 0.5
		
		if is_right and is_front:
			vertex.x += distort_1_x
			vertex.z += distort_1_z
		elif is_right and is_back:
			vertex.x += distort_2_x
			vertex.z += distort_2_z
		elif is_left and is_front:
			vertex.x += distort_3_x
			vertex.z += distort_3_z
		elif is_left and is_back:
			vertex.x += distort_4_x
			vertex.z += distort_4_z
		
		data.set_vertex(i, vertex)
	
	mesh.clear_surfaces()
	data.commit_to_surface(mesh)


func _on_timer_timeout() -> void:
	mesh.clear_surfaces()
	data.create_from_surface(mesh_copy, 0)
	data.commit_to_surface(mesh)
	rand_distort()
