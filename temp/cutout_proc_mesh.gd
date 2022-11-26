extends Node3D

@onready var interior_wall := $MeshInstance3D as MeshInstance3D
@onready var exterior_wall := $MeshInstance3D2 as MeshInstance3D
@onready var top := $MeshInstance3D3 as MeshInstance3D


var polygon := Polygon.sort(PackedVector2Array([
	Vector2.ZERO,
	Vector2(4, 1),
	Vector2(4, 4),
	Vector2(0, 4),
]))

var cutouts: Array[Array] = [
	[Rect2(0.5, 0.5, 1, 1), Rect2(2.0, 0.5, 1.5, 1.5)],
	[Rect2(0.5, 0.5, 1, 1)],
	[Rect2(0.5, 0.5, 3, 0.5)],
	[Rect2(0.5, 0.5, 1, 1)],
]

func _ready():
	make_walls(interior_wall, polygon, -0.1, true)
	make_walls(exterior_wall, polygon, 0.0)
	
	top.mesh = ProcMesh.new_outline_polygon(polygon, ProcMeshParams.new({ 
		offset = Vector3(0, 2.0, 0), 
		thickness = 0.1 
	}))


func make_walls(mesh: MeshInstance3D, p: PackedVector2Array, offset := 0.0, flip_normal := false) -> void:
	var edges := Polygon.get_edges(Polygon.grow(p, offset))
	
	var i := 0
	for edge in edges:
		var facing := Polygon3.get_facing(edge[0], edge[1], flip_normal)
		var c: Array[Rect2] = cutouts[i]
		mesh.mesh = ProcMesh.new_wall_with_rect_cutouts(edge[0], edge[1], c,
			ProcMeshParams.new({ mesh = mesh.mesh, height = 2.0, facing = facing })
		)
		i += 1
