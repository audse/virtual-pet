@tool
class_name ToggleSwitch
extends Button

@export var on_color := Color("#34d399")
@export var off_color := Color("#71717a")
@export var edge_gap := 4.0

@export var on_icon: Texture2D
@export var off_icon: Texture2D

@export var animation_duration := 0.1

@onready var toggle_start_pos := Vector2(size.y / 2, size.y / 2)
@onready var toggle_size := Vector2(size.y, size.y)
@onready var radius := toggle_size.x / 2

var _is_animating: bool = false
var _elapsed_time: float = 0.0

@onready var _start_pos := toggle_start_pos
@onready var _start_color := off_color

@onready var _target_pos: Vector2:
	get: return toggle_start_pos + Vector2(size.x - size.y, 0) if button_pressed else toggle_start_pos

@onready var _target_color: Color:
	get: return on_color if button_pressed else off_color


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED, NOTIFICATION_VISIBILITY_CHANGED: queue_redraw()


func _enter_tree() -> void:
	toggle_mode = true
	toggled.connect(_on_toggled)
	theme_type_variation = "ToggleSwitch"


func _process(delta: float) -> void:
	if _is_animating:
		_elapsed_time += delta
		queue_redraw()
		if _elapsed_time > animation_duration:
			_elapsed_time = 0
			_is_animating = false
			_start_pos = _target_pos
			_start_color = _target_color


func _draw() -> void:
	if _is_animating: draw_toggle()
	else: draw_circle(_target_pos, radius - edge_gap, _target_color)


func _on_toggled(_value: bool) -> void:
	_is_animating = true
	var target_modulate = on_color if button_pressed else Color.WHITE
	(
		create_tween()
			.tween_property(self, "modulate", target_modulate.lightened(0.5), animation_duration)
	)


func draw_toggle() -> void:
	var anim_pos := _elapsed_time / animation_duration
	draw_circle(
		_start_pos.lerp(_target_pos, anim_pos), 
		radius, 
		_start_color.lerp(_target_color, anim_pos)
	)
