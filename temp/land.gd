extends Node3D

@onready var mesh_instance := $MeshInstance3D

var mesh := ImmediateMesh.new()

var radius: float = 3.0
var num_points := 30
var angle := deg_to_rad(360) / num_points


func _ready() -> void:
	gen()


func gen() -> void:
	var radiuses := get_radiuses()
	
	var points: Array[Vector2] = []
	var prev_points = []
	for p in range(num_points):
		var x = cos(angle * p) * radiuses[p]
		var y = sin(angle * p) * radiuses[p]
		var point := Vector2(x, y) + Vector2Ref.randf_range(0, 1.0)
		if len(prev_points) > 0:
			point = point.lerp(prev_points[0], 0.3)
		prev_points = [point]
		points.append(point)
	
	draw_mesh(Vector3Ref.from_vec2_array(points))


func get_radiuses() -> Array:
	var get_radius := func (i: int) -> float: 
		return (radius * sin(num_points) + sin(num_points)) * randf_range(0.9, 1.1)
	
	return Iter.of_len(num_points).map(get_radius).array()


func draw_mesh(points: Array[Vector3]) -> void:
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	Iter.new(points).for_each(draw_point)
	mesh.surface_end()
	mesh_instance.mesh = mesh


func draw_point(point: Vector3, i: int, iter: Iter) -> void:
	var prev: Vector3 = iter.peek(-1)
	mesh.surface_add_vertex(prev)
	mesh.surface_add_vertex(point)
	mesh.surface_add_vertex(Vector3.ZERO)
