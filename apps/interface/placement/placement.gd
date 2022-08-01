class_name PlacementRect
extends CSGPolygon3D


signal move_finished
signal scale_finished

enum Shape {
	RECT,
	ELLIPSE
}

const MATERIAL = preload("res://apps/interface/placement/assets/shaders/highlight.tres")

@export var rect: Rect2:
	set(value):
		rect = value
		if is_inside_tree():
			draw_curve()

@export var thickness := 0.1:
	set(value):
		thickness = value
		if is_inside_tree():
			draw_curve()

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
	smooth_faces = true
	path_joined = true
	path_interval_type = CSGPolygon3D.PATH_INTERVAL_DISTANCE
	path_interval = 0.01
	path_simplify_angle = deg2rad(1)
	draw_curve()


func draw_curve() -> void:
	polygon = polygon_points
	material = MATERIAL
	path.curve = Curve3D.new()
	
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
				path.curve.set_point_tilt(i, deg2rad(i * 10))
	
	path.curve = Vector3Ref.smooth_curve(path.curve)


func scale_to(size: Vector2) -> void:
	var tween := _tween(Tween.EASE_OUT)
	tween.tween_property(self, "rect:size", size, 0.25)
	await tween.finished
	scale_finished.emit()

var is_moving: bool = false
var _move_to_stack: Array[Vector2] = []


func move_to(target: Vector2) -> void:
	is_moving = true
	var tween := _tween()
	tween.tween_property(self, "rect:position", target, 0.15)
	await tween.finished
	is_moving = false
	move_finished.emit()



func thickness_to(target: float) -> void:
	var tween := _tween()
	tween.tween_property(self, "thickness", target, 0.2)
	await tween.finished


func queue_move_to(target: Vector2, skip_inbetweens: bool = true) -> void:
	if skip_inbetweens: _move_to_stack = [target]
	else: _move_to_stack.append(target)
	if is_moving:
		move_finished.connect(
			func () -> void: 
				if len(_move_to_stack) > 0:
					await move_to(_move_to_stack.pop_back())
					if len(_move_to_stack) > 0 and not skip_inbetweens: 
						move_to(_move_to_stack.pop_back()),
			CONNECT_ONESHOT
		)
	else: move_to(target)


func _tween(easing := Tween.EASE_IN_OUT) -> Tween:
	return create_tween().set_ease(easing).set_trans(Tween.TRANS_SINE).set_parallel()
