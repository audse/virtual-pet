@tool
class_name DropMenu
extends Control
@icon("drop_menu.svg")

signal opening
signal opened
signal closing
signal closed

enum Origin {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	LEFT_TOP,
	LEFT_CENTER,
	LEFT_BOTTOM,
	RIGHT_TOP,
	RIGHT_CENTER,
	RIGHT_BOTTOM,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT,
}

const TRIANGLE_PATH := "DropMenuTriangle"
const TRIANGLE_OUTLINE_PATH := "DropMenuTriangleOutline"

@export var origin: Origin = Origin.TOP_LEFT:
	set(value):
		origin = value
		_reset()

@export var container: NodePath:
	set(value):
		container = value
		_reset()

@export var triangle_size := Vector2(50, 25):
	set(value):
		triangle_size = value
		_reset_triangle()

@export var triangle_outline_width := {
		left   = 0,
		top    = 0,
		right  = 0,
		bottom = 0
	}:
	set(value):
		triangle_outline_width = value
		_reset_triangle()

@export var right_angle: bool = false:
	set(value):
		right_angle = value
		_reset_triangle()

@export var margin := Vector2.ZERO:
	set(value):
		margin = value
		_reset_triangle()


@export var triangle_color: Color:
	set(value):
		triangle_color = value
		_reset_triangle()

@export var triangle_outline_color: Color:
	set(value):
		triangle_outline_color = value
		_reset_triangle()

@export var remake: bool:
	set(_value): 
		triangle_node = _remake_triangle()
		triangle_outline_node = _remake_triangle_outline()
		_reset()

@export var test_open: bool:
	set(_value): open()

@export var test_close: bool:
	set(_value): close()

var triangle_points: Array[Vector2]:
	get: 
		var top_point = triangle_size.x / 2
		if right_angle: match origin:
			Origin.TOP_LEFT, Origin.RIGHT_TOP, Origin.BOTTOM_RIGHT, Origin.LEFT_BOTTOM:
				top_point = 0
			_: top_point = triangle_size.x
		
		return [
			Vector2(top_point, 0),
			Vector2(triangle_size.x, triangle_size.y),
			Vector2(0, triangle_size.y)
		]

var triangle_outline_points: Array[Vector2]:
	get:
		var width := triangle_outline_width
		var widths: Array[float] = [
			max(width.left, width.top, width.right),
			max(width.right, width.bottom),
			max(width.left, width.bottom),
		]
		
		var num_points := len(triangle_points)
		var new_points: Array[Vector2] = []

		for i in range(num_points):
			var curr := triangle_points[i]
			var prev := triangle_points[(i + num_points - 1) % num_points]
			var next := triangle_points[(i + 1) % num_points]
			var offset := widths[i]
			
			var next_neighbor := (next - curr).normalized()
			var nnn := Vector2(next_neighbor.y, -next_neighbor.x)
			
			var prev_neighbor = (curr - prev).normalized()
			var npn = Vector2(prev_neighbor.y, -prev_neighbor.x)
			
			var bisector = Vector2(nnn.x + npn.x, nnn.y + npn.y)
			var bisn = bisector.normalized()
			
			var bislen = offset / sqrt(1 + nnn.x * npn.x + nnn.y * npn.y)

			new_points.append(curr + bislen * bisn)
		
		# remove the inner fill
		new_points.append(new_points[0])
		new_points.append(triangle_points[0])
		new_points.append(triangle_points[2])
		new_points.append(triangle_points[1])
		new_points.append(triangle_points[0])
		new_points.append(new_points[0])
		
		return new_points

var triangle_position: Vector2:
	get: 		
		var tri_size = (
			triangle_size 
			if abs(triangle_rotation) != 90 
			else Vector2(triangle_size.y, triangle_size.x)
		)
		var top_left_pos := Vector2.ZERO + margin
		var bottom_right_pos := size - margin - tri_size
		var center_pos := (bottom_right_pos - top_left_pos) / 2 + margin / 2
		center_pos += tri_size / 2
		
		var pos := top_left_pos
		match origin:
			Origin.TOP_CENTER, Origin.BOTTOM_CENTER: 
				pos.x = center_pos.x
				continue
			Origin.TOP_RIGHT, Origin.RIGHT_CENTER, Origin.BOTTOM_RIGHT, Origin.RIGHT_TOP, Origin.RIGHT_BOTTOM:
				pos.x = bottom_right_pos.x
				continue
			Origin.LEFT_CENTER, Origin.RIGHT_CENTER:
				pos.y = center_pos.y
			Origin.BOTTOM_LEFT, Origin.BOTTOM_CENTER, Origin.BOTTOM_RIGHT, Origin.RIGHT_BOTTOM, Origin.LEFT_BOTTOM:
				pos.y = bottom_right_pos.y
		
		return pos

var triangle_rotation: int:
	get: match origin:
		Origin.TOP_LEFT, Origin.TOP_CENTER, Origin.TOP_RIGHT: return 0
		Origin.LEFT_TOP, Origin.LEFT_CENTER, Origin.LEFT_BOTTOM: return -90
		Origin.RIGHT_TOP, Origin.RIGHT_CENTER, Origin.RIGHT_BOTTOM: return 90
		Origin.BOTTOM_LEFT, Origin.BOTTOM_CENTER, Origin.BOTTOM_RIGHT, _: return 180

var triangle_offset: Vector2:
	get: match triangle_rotation:
			+90: return Vector2(0, -triangle_size.y)
			-90: return Vector2(-triangle_size.x, 0)
			180: return -triangle_size
			_  : return Vector2.ZERO

var triangle_node: Polygon2D = null:
	get:
		if triangle_node: return triangle_node
		if get_child_count() > 0: return get_child(0)
		if triangle_node: return triangle_node
		triangle_node = _remake_triangle()
		return triangle_node

var triangle_outline_node: Polygon2D = null:
	get:
		if triangle_outline_node: return triangle_outline_node
		if triangle_node and triangle_node.get_child_count() > 0:
			triangle_outline_node = triangle_node.get_child(0)
			if triangle_outline_node: return triangle_outline_node
		triangle_outline_node = _remake_triangle_outline()
		return triangle_outline_node

var container_node: Container = null:
	get:
		if container_node: return container_node
		container_node = get_node_or_null(container)
		return container_node


func _reset_triangle() -> void:
	if triangle_node:
		triangle_node.polygon = triangle_points
		triangle_node.rotation = deg_to_rad(triangle_rotation)
		triangle_node.color = triangle_color
		triangle_node.position = triangle_position
		triangle_node.offset = triangle_offset
		triangle_node.antialiased = true
		
		if triangle_outline_node:
			triangle_outline_node.polygon = triangle_outline_points
			triangle_outline_node.color = triangle_outline_color
			triangle_outline_node.offset = triangle_offset
			triangle_outline_node.antialiased = true
	
	if container_node:
		container_node.global_position = container_rect.position
		await RenderingServer.frame_post_draw
		container_node.set_deferred("size", container_rect.size)


var triangle_bound_rect: Rect2:
	get:
		var tri_size: Vector2 = (
			Vector2(triangle_size.y, triangle_size.x) 
				if abs(triangle_rotation) == 90 
				else triangle_size
		)
		var tri: Polygon2D = get_child(0)
		if tri and tri is Polygon2D:
			return Rect2(tri.global_position, tri_size)
		else:
			print("no triangle found!")
			return Rect2(
				triangle_position + global_position + triangle_offset,
				tri_size
			)


func _get_container_rect(max_size := Vector2.ZERO) -> Rect2:
	var has_max_size: bool = max_size.distance_to(Vector2.ZERO) > 1.0
	var triangle := triangle_bound_rect
	
	# If not provided, the max size defaults to the screen size
	if not has_max_size:
		max_size = Utils.get_display_area(self).size
	
	var min_x_pos: float = (
		max(0, triangle.position.x)
		if origin in [
			Origin.TOP_LEFT,
			Origin.LEFT_TOP,
			Origin.LEFT_CENTER,
			Origin.LEFT_BOTTOM,
			Origin.BOTTOM_LEFT,
		]
		else 0
	)
	
	var max_x_pos: float = (
		min(max_size.x, triangle.end.x)
		if origin in [
			Origin.TOP_RIGHT,
			Origin.RIGHT_TOP, 
			Origin.RIGHT_CENTER, 
			Origin.RIGHT_BOTTOM, 
			Origin.BOTTOM_RIGHT
		] 
		else max_size.x
	)
	
	var min_y_pos: float = (
		max(0, triangle.position.y)
		if origin in [
			Origin.LEFT_TOP,
			Origin.TOP_LEFT,
			Origin.TOP_CENTER,
			Origin.TOP_RIGHT,
			Origin.RIGHT_TOP,
		]
		else 0
	)
	
	var max_y_pos: float = (
		min(max_size.y, triangle.end.y)
		if origin in [
			Origin.LEFT_BOTTOM,
			Origin.BOTTOM_LEFT,
			Origin.BOTTOM_CENTER,
			Origin.BOTTOM_RIGHT,
			Origin.RIGHT_BOTTOM,
		]
		else max_size.y
	)
	
	return Rect2(min_x_pos, min_y_pos, max_x_pos - min_x_pos, max_y_pos - min_y_pos)


var container_rect: Rect2:
	get: return _get_container_rect()

func _remake_triangle() -> Polygon2D:
	if get_child_count() > 0:
		var prev := get_child(0)
		if prev is Polygon2D: prev.queue_free()
	
	var triangle := Polygon2D.new()
	add_child(triangle)
	move_child(triangle, 0)
	return triangle


func _remake_triangle_outline() -> Polygon2D:
	if triangle_node:
		if triangle_node.get_child_count() > 0:
			triangle_node.get_child(0).queue_free()
		
		var outline := Polygon2D.new()
		triangle_node.add_child(outline)
		return outline
	return null


func v(x, y = null) -> Vector2:
	return Vector2(x, y if y != null else x)


var origin_point: Vector2:
	get:
		match origin:
			Origin.TOP_LEFT, Origin.LEFT_TOP: return v(0)
			Origin.TOP_CENTER: return v(0.5, 0)
			Origin.TOP_RIGHT, Origin.RIGHT_TOP: return v(1, 0)
			Origin.LEFT_CENTER: return v(0, 0.5)
			Origin.LEFT_BOTTOM, Origin.BOTTOM_LEFT: return v(0, 1)
			Origin.BOTTOM_CENTER: return v(0.5, 1)
			Origin.BOTTOM_RIGHT, Origin.RIGHT_BOTTOM: return v(1)
			Origin.RIGHT_CENTER: return v(1, 0.5)
			_: return v(1)

var origin_point_centered: Vector2:
	get:
		var eq := func(a: float, b: float) -> bool:
			return Math.is_float_equal_approx(a, b)
		var point := origin_point
		if eq.call(point.x, 0): point.x = -1
		if eq.call(point.y, 0): point.y = -1
		if eq.call(point.x, 0.5): point.x = 0
		if eq.call(point.y, 0.5): point.y = 0
		return point

@export var is_open: bool = false:
	set(value):
		is_open = value
		_reset()


func _reset() -> void:
	scale = v(1)
	modulate.a = 1.0
	visible = true
	
	if triangle_node:
		triangle_node.scale = v(1)
		triangle_node.modulate.a = 1.0
		triangle_node.rotation = 0
	if container_node:
		container_node.scale = v(1)
		container_node.modulate.a = 1.0
		container_node.rotation = 0
	
	_reset_triangle()
	
	if is_open:
		if triangle_node: triangle_node.visible = true
		if container_node: container_node.visible = true
	else:
		if triangle_node: triangle_node.visible = false
		if container_node: container_node.visible = false


func _ready() -> void:
	triangle_node = _remake_triangle()
	triangle_outline_node = _remake_triangle_outline()
	_reset()


var _is_animating := false

func queue_open() -> void:
	if _is_animating and not is_open:
		closed.connect(open, CONNECT_ONE_SHOT)
	elif not _is_animating:
		open()


func queue_close() -> void:
	if _is_animating and is_open:
		opened.connect(close, CONNECT_ONE_SHOT)
	elif not _is_animating:
		close()


func open() -> void:
	if not is_inside_tree(): return
	opening.emit()
	_is_animating = true
	_reset()
	
	if triangle_node: (
		AnimBuilder.new(triangle_node)
			.setup({
				"scale": v(0, 1),
				"visible": true,
			})
			.keyframe("open", 0.15, Tween.EASE_OUT)
			.fade_in()
			.keyframe("settle", 0.25, Tween.EASE_OUT)
			.prop("scale", { open = v(1.2), settle = v(1) })
			.complete()
	)
	if container_node: (
		AnimBuilder.new(container_node)
			.setup({
				"scale": v(0.25),
				"pivot_offset": container_node.size * origin_point,
				"visible": true,
				"rotation": 0,
			})
			.keyframe("open", 0.15, Tween.EASE_OUT, Tween.TRANS_SINE)
			.fade_in()
			.keyframe("settle", 0.25, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
			.prop("scale", { 
				open = v(1.05, 1.1),
				settle = Vector2.ONE 
			})
			.complete()
	)
	await get_tree().create_timer(0.5).timeout
	is_open = true
	_is_animating = false
	opened.emit()


func close() -> void:
	if not is_inside_tree(): return
	closing.emit()
	_is_animating = true
	_reset()
	if triangle_node: (
		AnimBuilder.new(triangle_node)
			.setup({
				"visible": true,
				"scale": v(1),
			})
			.keyframe("anticipation", 0.125)
			.keyframe("close", 0.125, Tween.EASE_IN)
			.fade_out()
			.prop("scale", {
				anticipation = v(1.2),
				close = v(0, 1),
			})
			.tear_down({
				"visible": false,
				"scale": v(1),
				"position": triangle_position
			})
			.complete()
	)
	if container_node: (
		AnimBuilder.new(container_node)
			.setup({
				"pivot_offset": container_node.size * origin_point,
				"visible": true,
				"scale": v(1),
				"rotation": 0.0,
			})
			.keyframe("anticipation", 0.125, Tween.EASE_IN_OUT)
			.keyframe("close", 0.125, Tween.EASE_IN, Tween.TRANS_SINE)
			.fade_out()
			.props({
				"scale": { 
					anticipation = v(1, 1.1),
					close = v(0.75, 0.25),
				},
				"rotation": { 
					anticipation = deg_to_rad(-1) * origin_point_centered.y,
					close = deg_to_rad(2) * origin_point_centered.y,
				}
			})
			.tear_down({
				"scale": v(1),
				"visible": false,
				"rotation": 0
			})
			.complete()
	)
	await get_tree().create_timer(0.35).timeout
	is_open = false
	_is_animating = false
	closed.emit()
