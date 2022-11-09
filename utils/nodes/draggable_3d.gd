class_name Draggable3D
extends Node
@icon("draggable.gd")

signal position_changed(Vector3)
signal rotation_changed(Vector3)

@export var object: Node3D
@export var distance_from_ground_while_dragging: float = 0.0

@onready var viewport: Viewport = get_viewport()
@onready var camera: Camera3D = viewport.get_camera_3d()

@onready var start_distance_from_ground := object.position.y
@export var enable_fallback_position: bool = false

var is_dragging: bool = false:
	set(value):
		is_dragging = value
		if not is_dragging: elapsed_frames = 0

var elapsed_frames: int = 0:
	set(value):
		elapsed_frames = value

## The distance between the center of the object and the mouse event position
var mouse_offset := Vector3.ZERO

var enabled: bool:
	get: return Game.Mode.state == GameModeState.Mode.BUY

var fallback_position: Vector3


func _ready() -> void:
	object.input_event.connect(_on_input_event)


func _unhandled_input(event: InputEvent) -> void:
	if is_dragging and event.is_action_released("tap"):
		is_dragging = false


func _on_input_event(
	_camera: Camera3D,
	event: InputEvent,
	position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if event is InputEventScreenDrag:
		is_dragging = true
		elapsed_frames += 1
	
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		is_dragging = true
		elapsed_frames += 1
		
		if (
			"double_click" in event and event.double_click
			or "double_tap" in event and event.double_tap
		):
			is_dragging = false
			_on_tapped()
		
		elif "is_pressed" in event and event.is_pressed():
			mouse_offset = position - object.position
	
	if is_dragging and event.is_action_released("tap"):
		is_dragging = false


func _physics_process(_delta: float) -> void:
	if enabled:
		# move towards the nearest grid square
		var target: Vector3 = (
			object.position.lerp(object.position.snapped(WorldData.grid_size_vector), 0.1)
			if not enable_fallback_position
			else fallback_position
		)
		
		if is_dragging and elapsed_frames > 5:
			target = Vector3Ref.project_position_to_floor_simple(
				camera,
				# This is what makes the item under your mouse, instead of floating above it
				# TODO: Will probably need to be adjusted for camera zoom
				viewport.get_mouse_position() + Vector2(0, 250)
			) - mouse_offset
			# Float upwards while dragging
			target.y = lerp(object.position.y, distance_from_ground_while_dragging, 0.1)
			position_changed.emit(target)
			
		else:
			# Move back towards original ground position
			target.y = lerp(target.y, start_distance_from_ground, 0.1)
		
		if object is PhysicsBody3D: object.move_and_collide(target - object.position)
		else: object.position = target


func _on_tapped() -> void:
	if enabled:
		var tween := object.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(object, "position:y", start_distance_from_ground + distance_from_ground_while_dragging * 0.75, 0.15)
		tween.tween_property(object, "rotation:y", object.rotation.y + deg_to_rad(45.0), 0.15)
		tween.tween_property(object, "position:y", start_distance_from_ground, 0.15)
		await tween.finished
		
		rotation_changed.emit(object.rotation)


