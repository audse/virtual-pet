@tool
class_name PillRange
extends Range
@icon("pill_range.svg")

signal pressed
signal filled(index: int)
signal emptied(index: int)

enum Direction { HORIZONTAL, VERTICAL }

@export var direction: Direction = Direction.HORIZONTAL
@export var inverted := false
@export var disabled := false

@export_group("Theme Overrides")

@export_subgroup("Progress modulate", "const_override_")
@export var high_modulate := Color.WHITE
@export var medium_modulate := Color.WHITE
@export var low_modulate := Color.WHITE

@export_subgroup("Constants", "const_override_")
@export var const_override_h_separation: int = -1
@export var const_override_v_separation: int = -1

@export_subgroup("Styleboxes", "stylebox_override_")
@export var stylebox_override_empty: StyleBox
@export var stylebox_override_empty_hover: StyleBox
@export var stylebox_override_empty_pressed: StyleBox
@export var stylebox_override_filled: StyleBox
@export var stylebox_override_filled_hover: StyleBox
@export var stylebox_override_filled_pressed: StyleBox

# TODO styleboxes / modulate based on num_filled
# TODO array of styleboxes for each pill ?

@onready var empty_stylebox: StyleBox = get_theme_stylebox("empty", "PillRange")
@onready var empty_hover_stylebox: StyleBox = get_theme_stylebox("empty_hover", "PillRange")
@onready var empty_pressed_stylebox: StyleBox = get_theme_stylebox("empty_pressed", "PillRange")

@onready var fill_stylebox: StyleBox = get_theme_stylebox("filled", "PillRange")
@onready var fill_hover_stylebox: StyleBox = get_theme_stylebox("filled_hover", "PillRange")
@onready var fill_pressed_stylebox: StyleBox = get_theme_stylebox("filled_pressed", "PillRange")

@onready var h_separation: int = get_theme_constant("h_separation", "PillRange")
@onready var v_separation: int = get_theme_constant("v_separation", "PillRange")

@onready var pill_size: Vector2:
	get: match direction:
			Direction.HORIZONTAL : return Vector2(size.x / num_pills - margin.x, size.y)
			Direction.VERTICAL, _: return Vector2(size.x, size.y / num_pills - margin.y)

@onready var margin: 
	get: match direction:
			Direction.HORIZONTAL : return Vector2(h_separation, 0)
			Direction.VERTICAL, _: return Vector2(0, v_separation)

var num_pills: int:
	get: return round((max_value - min_value) / step) as int

var num_filled: int:
	get: return floor(value / max_value * num_pills) as int

var pill_rects: Array[Rect2]:
	get:
		var rects := []
		for index in range(num_pills):
			var pos := Vector2.ZERO
			match direction:
				Direction.HORIZONTAL: pos.x = pill_size.x * index + index * margin.x
				Direction.VERTICAL: pos.y = pill_size.y * index + index * margin.y
			rects.append(Rect2(pos, pill_size))
		return rects

var _hovered_pill: int = -1
var _pressed_pill: int = -1


func _draw() -> void:
	for pill in range(num_pills):
		draw_pill(pill)
	
	var percent = (value - min_value) / (max_value - min_value)
	
	if percent < 0.5:
		modulate = low_modulate.lerp(medium_modulate, percent * 2.0)
	else:
		modulate = medium_modulate.lerp(high_modulate, (percent - 0.5) * 2.0)


func get_stylebox(index: int) -> StyleBox:
	var is_filled: bool = (
		(index < num_filled and not inverted) 
		or (index >= (num_pills - num_filled) and inverted)
	)
	var is_pressed: bool = _pressed_pill == index
	var is_hovered: bool = _hovered_pill == index
	
	if is_filled:
		if is_pressed: return Utils.first_non_null([
			stylebox_override_filled_pressed,
			fill_pressed_stylebox,
			stylebox_override_filled,
			fill_stylebox
		])
		elif is_hovered: return Utils.first_non_null([
			stylebox_override_filled_hover,
			fill_hover_stylebox,
			stylebox_override_filled,
			fill_stylebox,
		])
		else: return Utils.first_non_null([
			stylebox_override_filled,
			fill_stylebox,
		])
	else:
		if is_pressed: return Utils.first_non_null([
			stylebox_override_empty_pressed,
			empty_pressed_stylebox,
			stylebox_override_empty,
			empty_stylebox
		])
		elif is_hovered: return Utils.first_non_null([
			stylebox_override_empty_hover,
			empty_hover_stylebox,
			stylebox_override_empty,
			empty_stylebox
		])
		else: return Utils.first_non_null([
			stylebox_override_empty,
			empty_stylebox
		])


func draw_pill(index: int) -> void:
	var rect := pill_rects[index]
	var stylebox := get_stylebox(index)
	if stylebox: draw_style_box(stylebox, rect)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not disabled:
		_hovered_pill = _find_pill_at_pos(event.position)
		
		queue_redraw()
	
	if event is InputEventScreenTouch and not disabled:
		if event.is_pressed(): pressed.emit()
		
		if event.pressed:
			var prev_amt: int = num_filled
			
			_pressed_pill = _find_pill_at_pos(event.position)
			var _pill_index = _pressed_pill + 1 if not inverted else  _pressed_pill
			if _pill_index != num_filled and _pressed_pill >= 0:
				value = step * (_pill_index)
			
			# pressing a filled pill empties it
			elif _pill_index == num_filled:
				value -= step
			
			if prev_amt > num_filled:
				emptied.emit(num_filled + 1)
			elif prev_amt < num_filled:
				filled.emit(num_filled)
			
			queue_redraw()
		else:
			_pressed_pill = -1


func _find_pill_at_pos(pos: Vector2) -> int:
		for index in range(num_pills):
			var r := (
				pill_rects[index]
					.grow_individual(margin.x / 2, margin.y / 2, margin.x / 2, margin.y / 2)
			)
			if r.has_point(pos):
				return index
		return -1
