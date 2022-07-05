extends Node3D


var room_vertices_targets: Array = []
var is_animating := false
var frames := 100

@onready var room: MeshInstance3D = $RoomMesh
@onready var room_data: MeshDataTool = $RoomMesh.data
@onready var grid: MeshInstance3D = $GridMesh
@onready var grid_data: MeshDataTool = $GridMesh.data


func _ready() -> void:
	$RoomMesh.scale.y = 0


func _process(_delta: float) -> void:
	if is_animating and frames > 0 and room and room_data:
		for vertex_arr in room_vertices_targets:
			var current_vertex: Vector3 = room_data.get_vertex(vertex_arr[0])
			var new_vertex: Vector3 = current_vertex.move_toward(vertex_arr[1], 0.02)
			room_data.set_vertex(vertex_arr[0], new_vertex)
		room.mesh.clear_surfaces()
		room_data.commit_to_surface(room.mesh)
		frames += 1


func align_room_to_grid() -> void:
	await get_tree().create_timer(1.0).timeout
	
	room_data = $RoomMesh.data as MeshDataTool
	grid_data = $GridMesh.data as MeshDataTool
	var num_room_vertices := room_data.get_vertex_count()
	
	for grid_arr in $GridMesh.unique_vertices:
		var grid_vertex := grid_data.get_vertex(grid_arr[0])
		
		for i in range(num_room_vertices):
			var room_vertex: Vector3 = room_data.get_vertex(i)
			var x_equal_approx: bool = abs(room_vertex.x - grid_vertex.x) < 0.3
			var z_equal_approx: bool = abs(room_vertex.z - grid_vertex.z) < 0.3
			
			if x_equal_approx and z_equal_approx:
				room_vertex.x += grid_arr[1]
				room_vertex.z += grid_arr[2]
			
			room_data.set_vertex(i, room_vertex)
	
	$RoomMesh.mesh.clear_surfaces()
	room_data.commit_to_surface($RoomMesh.mesh)
	
	var tween := get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($RoomMesh, "scale:y", 1.0, 1.5)
	tween.play()
	tween.tween_callback(expand)


func expand() -> void:
	room = $RoomMesh
	room_data = $RoomMesh.data as MeshDataTool
	
	var bottom_left_start := find_nearest_grid_vertex(Vector3(0, 0, 1))
	var bottom_right_start := find_nearest_grid_vertex(Vector3(1, 0, 1))
	var top_right_start := find_nearest_grid_vertex(Vector3(1, 0, 0))
	
	var bottom_left_target := find_nearest_grid_vertex(Vector3(0, 0, 2))
	var bottom_right_target := find_nearest_grid_vertex(Vector3(2, 0, 2))
	var top_right_target := find_nearest_grid_vertex(Vector3(2, 0, 0))
	
	var bottom_left_delta := bottom_left_target - bottom_left_start
	var bottom_right_delta := bottom_right_target - bottom_right_start
	var top_right_delta := top_right_target - top_right_start
	
	for i in range(room_data.get_vertex_count()):
		var vertex: Vector3 = room_data.get_vertex(i)
		var target := vertex
		if vertex.x > 0.7 and vertex.z > 0.7:
			target.x += bottom_right_delta.x
			target.z += bottom_right_delta.z
		elif vertex.x > 0.7:
			target.x += top_right_delta.x
		elif vertex.z > 0.7:
			target.z += bottom_left_delta.z
		
		room_vertices_targets.append([i, target])
	
	is_animating = true


func find_nearest_grid_vertex(current_vertex: Vector3) -> Vector3:
	if not grid or not grid_data: 
		print("error getting grid")
		return Vector3.ZERO
	
	for arr in grid.unique_vertices:
#		var grid_vertex: Vector3 = grid_data.get_vertex(arr[0])
		var grid_vertex: Vector3 = arr[3]
		var x_equal_approx: bool = abs(current_vertex.x - grid_vertex.x) < 0.3
		var z_equal_approx: bool = abs(current_vertex.z - grid_vertex.z) < 0.3
		if x_equal_approx and z_equal_approx:
			return grid_data.get_vertex(arr[0])
	
	print("error finding nearest vertex")
	return Vector3.ZERO


func _on_grid_mesh_grid_distorted() -> void:
	align_room_to_grid()

