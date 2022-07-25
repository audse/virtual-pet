class_name QuickSpatialGrid
extends Node3D
@icon("quick_spatial_grid.svg")

@export var origin := Vector3(0, 0, 0)
@export var bounds := Vector3(10, 1, 10)
@export var size := Vector3(1, 1, 1)
@export var mesh: Mesh

var grid_points: Array[Vector3]:
	get:
		var points := []
		for x in range(origin.x, origin.x + bounds.x):
			for y in range(origin.y, origin.y + bounds.y):
				for z in range(origin.z, origin.z + bounds.z):
					points.append(Vector3(x, y, z) * size)
		return points


func _ready():	
	for point in grid_points:
		var marker := MeshInstance3D.new()
		marker.mesh = mesh
		marker.position = point
		add_child(marker)
