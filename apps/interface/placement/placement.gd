extends Node3D


@export var rect: Rect2
@export var thickness := 0.1

@onready var geo := ImmediateMesh.new()

var thickness_factor: Vector3:
	get: return Vector3(thickness, 0, thickness) / 2.0

var rect3: Dictionary:
	get: return Vector3Ref.to_rect3(rect)


func _ready():
	%Rect.mesh = geo
	
	geo.clear_surfaces()
	geo.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
#	draw_vert(rect3.position)
	draw_vert(Vector3(rect.position.x, 0, rect.end.y))
	draw_vert(rect3.end)
#	draw_vert(Vector3(rect.end.x, 0, rect.position.y))
#	draw_vert(rect3.position)
	
	geo.surface_end()


var _last_vert_a: Vector3
var _last_vert_b: Vector3

func draw_vert(point: Vector3) -> void:
	var vert_a := point - thickness_factor
	var vert_b := point + thickness_factor
	
	if _last_vert_a: geo.surface_add_vertex(_last_vert_a)
	if _last_vert_b: geo.surface_add_vertex(_last_vert_b)
	geo.surface_add_vertex(vert_b)
	geo.surface_add_vertex(vert_b)
	geo.surface_add_vertex(vert_a)
	
	if _last_vert_b: geo.surface_add_vertex(_last_vert_a)
	
	_last_vert_a = vert_a
	_last_vert_b = vert_b
