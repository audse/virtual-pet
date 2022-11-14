class_name BuildingRenderer
extends Node3D

const WALL_HEIGHT := 4.0
const WALL_THICKNESS := 0.1
const FLOOR_THICKNESS := 0.2

@export var building_data: BuildingData

@onready var floor_mesh := %Floor as MeshInstance3D
@onready var exterior_mesh := %ExteriorWalls as MeshInstance3D
@onready var interior_mesh := %InteriorWalls as MeshInstance3D

@export var points: PackedVector2Array


func _ready() -> void:
	var offset_polygon := Geometry2D.offset_polygon(points, -WALL_THICKNESS, Geometry2D.JOIN_MITER)[0]
	render_walls(exterior_mesh.mesh, points)
	render_walls(interior_mesh.mesh, offset_polygon)
	floor_mesh.mesh = create_floor_box_mesh()
	render_walls(floor_mesh.mesh, offset_polygon, FLOOR_THICKNESS * 0.99)


func render_walls(target_mesh: ArrayMesh, polygon: PackedVector2Array, height := WALL_HEIGHT) -> void:
	for point in polygon.size():
		target_mesh.add_surface_from_arrays(
			Mesh.PRIMITIVE_TRIANGLES, 
			create_wall_box_mesh(point, polygon, height)
		)


func create_wall_box_mesh(point_index: int, polygon: PackedVector2Array, height := WALL_HEIGHT) -> Array:
	var point := polygon[point_index]
	var prev := polygon[point_index - 1]
	
	var box := BoxMesh.new()
	var box_size := get_wall_box_size(point, prev, height)
	box.size = abs(box_size)
	
	# Corners need additional help lining up
	if is_equal_approx(box_size.x, WALL_THICKNESS):
		box.size.z += WALL_THICKNESS * 0.99
	if is_equal_approx(box_size.z, WALL_THICKNESS):
		box.size.x += WALL_THICKNESS * 0.99
	
	var arrays := box.get_mesh_arrays()
	for i in arrays[Mesh.ARRAY_VERTEX].size():
		var offset := Vector3(prev.x, height, prev.y) - (box_size / 2)
		
		if is_equal_approx(box_size.x, WALL_THICKNESS):
			offset.z -= WALL_THICKNESS / 2.0
		if is_equal_approx(box_size.z, WALL_THICKNESS):
			offset.x -= WALL_THICKNESS / 2.0
		
		arrays[Mesh.ARRAY_VERTEX][i] += offset
	return arrays


func get_wall_box_size(a: Vector2, b: Vector2, height := WALL_HEIGHT) -> Vector3:
	var s := Vector3(WALL_THICKNESS, height, WALL_THICKNESS)
	s.x = b.x - a.x
	s.z = b.y - a.y
	if is_zero_approx(b.x - a.x):
		s.x = WALL_THICKNESS
	if is_zero_approx(b.y - a.y):
		s.z = WALL_THICKNESS
	return s


func create_floor_box_mesh() -> ArrayMesh:
	var verts := Geometry2D.triangulate_polygon(points)
	var mesh := ArrayMesh.new()
	
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3(0, 1, 0))
	
	for i in verts:
		surface.add_vertex(Vector3(points[i].x, 0, points[i].y))
	
	for i in verts:
		surface.add_vertex(Vector3(points[i].x, FLOOR_THICKNESS, points[i].y))
	
	return surface.commit()
