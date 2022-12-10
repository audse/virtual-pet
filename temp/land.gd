extends StaticBody3D


@export var depth: float = 6.0

@onready var ground := $Ground as MeshInstance3D
@onready var walls := $Walls as MeshInstance3D
@onready var collision := $CollisionShape3D as CollisionShape3D

var ground_mesh := ArrayMesh.new()
var ground_surface := SurfaceTool.new()


func _ready() -> void:
	draw()


func draw() -> void:
	if WorldData.terrain:
		var shape := Vector3Ref.from_vec2_array(WorldData.terrain.shape)
		draw_ground_mesh(shape)
		draw_walls_mesh(shape)


func draw_walls_mesh(_points: Array[Vector3]) -> void:
	walls.mesh = ProcMesh.new_wall(WorldData.terrain.shape, ProcMeshParams.new({
		height = depth,
		offset = Vector3(0, -depth, 0)
	}))


func draw_ground_mesh(points: Array[Vector3]) -> void:
	ground_surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	ground_surface.set_normal(Vector3.UP)
	ground_surface.set_smooth_group(0)
	Iter.new(points).for_each(draw_ground_point)
	ground_surface.commit(ground_mesh)
	ground.mesh = ground_mesh
	collision.make_convex_from_siblings()


func draw_ground_point(point: Vector3, _i: int, iter: Iter) -> void:
	var prev: Vector3 = iter.peek(-1)
	ground_surface.add_vertex(prev)
	ground_surface.add_vertex(point)
	ground_surface.add_vertex(Vector3.ZERO)
