class_name PaintState
extends Node

enum Action { DRAW, ERASE, LINE, RECT }
enum Shape { 
	SQUARE = 1,
	SHARP = 2, 
	ROUND = 3, 
	CONCAVE = 4, 
	CONCAVE_SHARP = 5,
	SQUARE_EDGE = 6,
	ROUND_EDGE = 7,
	CIRCLE = 8, 
	FLOWER = 9, 
	HEART = 10, 
	STAR = 11, 
	PAW_PRINT = 12,
}
enum Size { XXS, XS, SM, MD, LG, XL, XXL }
enum Ratio { ODD, EVEN }
enum Tiling { NONE, HORIZONTAL, VERTICAL, ALL }

signal action_changed(to: Action)
signal aspect_ratio_changed(to: Dictionary)
signal color_changed(to: Color)
signal precision_changed(to: float)
signal ratio_changed(to: Ratio)
signal rotation_changed(to: int)
signal shape_changed(to: Shape)
signal size_changed(to: Size)
signal tiling_changed(to: Tiling)
signal zoom_changed(to: float)
signal recenter

signal canvas_selected(canvas: SubViewport, canvas_name: String)

const CANVAS_SIZE := 800.0

const SizePx := {
	Size.XS: CANVAS_SIZE / 64.0,
	Size.SM: CANVAS_SIZE / 32.0,
	Size.MD: CANVAS_SIZE / 16.0,
	Size.LG: CANVAS_SIZE / 8.0,
	Size.XL: CANVAS_SIZE / 4.0,
	Size.XXL: CANVAS_SIZE / 2.0,
}

const OddSizePx := {
	Size.XS: CANVAS_SIZE / 81.0,
	Size.SM: CANVAS_SIZE / 27.0,
	Size.MD: CANVAS_SIZE / 18.0,
	Size.LG: CANVAS_SIZE / 9.0,
	Size.XL: CANVAS_SIZE / 3.0,
	Size.XXL: CANVAS_SIZE / 1.0,
}

const ShapeTexture := {
	Shape.SQUARE: preload("res://apps/painter/assets/shapes/square.tres"),
	Shape.SHARP: preload("res://apps/painter/assets/shapes/sharp.tres"),
	Shape.ROUND: preload("res://apps/painter/assets/shapes/round.tres"),
	Shape.CONCAVE: preload("res://apps/painter/assets/shapes/concave.tres"),
	Shape.CONCAVE_SHARP: preload("res://apps/painter/assets/shapes/concave_sharp.tres"),
	Shape.SQUARE_EDGE: preload("res://apps/painter/assets/shapes/square_edge.tres"),
	Shape.ROUND_EDGE: preload("res://apps/painter/assets/shapes/round_edge.tres"),
	Shape.CIRCLE: preload("res://apps/painter/assets/stamps/circle.tres"),
	Shape.FLOWER: preload("res://apps/painter/assets/stamps/flower.tres"),
	Shape.HEART: preload("res://apps/painter/assets/stamps/heart.tres"),
	Shape.STAR: preload("res://apps/painter/assets/stamps/star.tres"),
	Shape.PAW_PRINT: preload("res://apps/painter/assets/stamps/paw_print.tres"),
}

const ToolIcon := {
	Action.DRAW:  preload("res://apps/painter/assets/icons/pencil.tres"),
	Action.ERASE: preload("res://apps/painter/assets/icons/eraser.tres"),
	Action.LINE:  preload("res://apps/painter/assets/icons/line.tres"),
	Action.RECT:  preload("res://apps/painter/assets/icons/rectangle.tres")
}

var action := Action.DRAW:
	set(value): 
		action = value
		action_changed.emit(value)

var aspect_ratio := Vector2.ONE:
	set(value):
		aspect_ratio = value
		aspect_ratio_changed.emit(value)

var color := Color.WHITE:
	set(value):
		color = value
		color_changed.emit(value)

var line = null

var precision := -1.0:
	set(value):
		precision = value
		precision_changed.emit(value)

var precision_factor: Vector2:
	get: return Vector2(abs(precision), abs(precision))

var prev_action := Action.DRAW

var ratio := Ratio.EVEN:
	set(value):
		ratio = value
		ratio_changed.emit(value)

var rotation := 0:
	set(value):
		rotation = value
		# Keep rotation within 360 degrees
		if rotation > 360: rotation -= 360
		elif rotation < 0: rotation += 360
		rotation_changed.emit(value)

var shape := Shape.SQUARE:
	set(value):
		shape = value
		if value > Shape.CONCAVE_SHARP:
			shape = Shape.SQUARE
		elif value < Shape.SQUARE:
			shape = Shape.CONCAVE_SHARP
		shape_changed.emit(value)

var size := Size.MD:
	set(value):
		size = clamp(value, Size.XS, Size.XXL)
		size_changed.emit(value)

var size_px: Vector2:
	get: 
		var s: float = (
			SizePx[size] 
				if ratio == Ratio.EVEN 
				else OddSizePx[size]
		)
		return Vector2(s, s) * precision_factor * aspect_ratio

var tiling := Tiling.NONE:
	set(value):
		tiling = value
		tiling_changed.emit(value)

var zoom := 1.0:
	set(value):
		zoom = clamp(value, 0.1, 20.0)
		zoom_changed.emit(value)


func _ready() -> void:
	size_changed.emit()


func set_action(value: Action) -> void:
	match value:
		Action.LINE, Action.RECT:
			if action == value:
				line = null # restart line if they click the button again
		_: line = null
	
	prev_action = action
	action = value


func is_action(value: Action) -> bool:
	return action == value


func has_line() -> bool:
	return line != null


func is_zoomed() -> bool:
	return abs(1.0 - zoom) > 0.05


func is_precision_mode() -> bool:
	return precision > 0.0


func toggle_precision_mode() -> void:
	if precision < 0.0: precision = 0.25
	else: precision = -1.0
