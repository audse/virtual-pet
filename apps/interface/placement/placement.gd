class_name PlacementRect
extends CSGPolygon3D

enum Shape {
	RECT,
	ELLIPSE
}

const MATERIAL = preload("res://apps/interface/placement/assets/shaders/highlight.tres")

@export var rect: Rect2
@export var thickness := 0.1
@export var shape: Shape = Shape.RECT

var rect3: Dictionary:
	get: return Vector3Ref.to_rect3(rect)

var rect_verts: Array[Vector3]:
	get: return [
			rect3.position,
			Vector3(rect3.position.x, 0, rect3.end.z),
			rect3.end,
			Vector3(rect3.end.x, 0, rect3.position.z),
		]

var ellipse_verts: Array[Vector3]:
	get: 
		var midpoint: Vector3 = rect3.position + rect3.size / 2
		return [
			Vector3(rect3.position.x, 0, midpoint.z),
			Vector3(midpoint.x, 0, rect3.end.z),
			Vector3(rect3.end.x, 0, midpoint.z),
			Vector3(midpoint.x, 0, rect3.position.z)
		]

var verts: Array[Vector3]:
	get: match shape:
		Shape.RECT: return rect_verts
		Shape.ELLIPSE, _: return ellipse_verts

var polygon_points: Array[Vector2]:
	get: return [
		Vector2.ZERO,
		Vector2(0, thickness),
		Vector2(thickness, thickness),
		Vector2(thickness, 0)
	]

const TAN := 0.552284749831

var handles: Array[Dictionary]:
	get: match shape:
		Shape.RECT: return []
		Shape.ELLIPSE, _:
			var s: Vector3 = rect3.size * TAN / 2
			return [
				{ 
					"in": Vector3(0, 0, -s.z),
					"out": Vector3(0, 0, s.z),
				},
				{
					"in": Vector3(-s.x, 0, 0),
					"out": Vector3(s.x, 0, 0)
				},
				{ 
					"in": Vector3(0, 0, s.z),
					"out": Vector3(0, 0, -s.z),
				},
				{
					"in": Vector3(s.x, 0, 0),
					"out": Vector3(-s.x, 0, 0)
				},
			]

@onready var path := Path3D.new()


func _ready():
	mode = CSGPolygon3D.MODE_PATH
	add_child(path)
	path_node = get_path_to(path)
	
	draw_curve()


func draw_curve() -> void:
	polygon = polygon_points
	material = MATERIAL
	path.curve = Curve3D.new()
	smooth_faces = true
	
	for i in [0, 1, 2, 3, 0]:
		var vert := verts[i]
		match shape:
			Shape.RECT: path.curve.add_point(vert)
			Shape.ELLIPSE:
				var handle_points := handles[i]
				path.curve.add_point(
					vert, 
					handle_points["in"],
					handle_points["out"]
				)
