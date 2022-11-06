class_name Draggable
extends Node
@icon("draggable.svg")

signal tapped
signal drag_started
signal drag_ended
signal dragging

@export var node_path: NodePath
@export var disabled: bool = false
@export var collide: bool = true

@export_category("Offset position")
@export var offset_from_mouse: Vector2
@export var offset_in_world: Vector3

@export_category("Axis lock")
@export var lock_x: bool = false
@export var lock_y: bool = false
@export var lock_z: bool = false


@onready var node: Node = get_node(node_path)
@onready var _node_collision_3ds: Array[Node] = node.find_children("", "CollisionShape3D", true)
@onready var _node_collision_3d: CollisionShape3D:
	get: return _node_collision_3ds[0] as CollisionShape3D if len(_node_collision_3ds) > 0 else null


@onready var viewport: Viewport = node.get_viewport() if node else null
@onready var camera_2d: Camera2D = viewport.get_camera_2d() if viewport else null
@onready var camera_3d: Camera3D = viewport.get_camera_3d() if viewport else null
@onready var camera_distance: float = (
	camera_3d.position.distance_to(Vector3.ZERO) if camera_3d 
		else camera_2d.position.distance_to(Vector2.ZERO) if camera_2d 
		else 0.0
)
@onready var _start_node_position_3d: Vector3 = node.position if node and node is Node3D else Vector3.ZERO

var is_dragging := false:
	set(value):
		if is_dragging != value:
			is_dragging = value
			if value: start_drag()
			else: end_drag()
		
		if is_dragging: dragging.emit()

var _drag_elapsed_frames := 0
var _start_pos: Vector2

var _offset_in_world: Vector3 = offset_in_world

var _last_pos: Vector2:
	set(value):
		_last_pos = value
		if node and (node is Node2D or node is Control):
			if lock_x: _last_pos.x = node.position.x
			if lock_y: _last_pos.y = node.position.y


func _ready() -> void:
	if node and node is PhysicsBody3D:
		node.input_event.connect(
			func (_cam, event: InputEvent, pos, _normal, _idx) -> void:
				_area_input(event, pos)
		)
	if node and node is Control:
		node.gui_input.connect(_area_input)


func _unhandled_input(event: InputEvent) -> void:
	if is_dragging and event.is_action_released("tap"):
		is_dragging = false


func _area_input(event: InputEvent, pos: Vector3 = Vector3.ZERO):
	if disabled: return
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if event.is_pressed() or event is InputEventScreenDrag:
			is_dragging = true
			_drag_elapsed_frames += 1
			
			_offset_in_world = offset_in_world + (node.global_position - pos)
			
		else:
			is_dragging = false


func _physics_process(_delta: float) -> void:
	if is_dragging and viewport:
		_last_pos = viewport.get_mouse_position()
		
		if node is Node3D and camera_3d:
			var target_position: Vector3
			if not lock_y:
				target_position = camera_3d.project_position(
					_last_pos + offset_from_mouse, 
					camera_distance
				)
			else:
				target_position = Vector3Ref.project_position_to_floor(
					camera_3d, 
					_last_pos + offset_from_mouse,
					[_node_collision_3d]
				)
				if lock_x: target_position.x = _start_node_position_3d.x
				if lock_y: target_position.y = _start_node_position_3d.y
				if lock_z: target_position.z = _start_node_position_3d.z
			
			if node is PhysicsBody3D and collide:
				node.move_and_collide(target_position - node.global_position + _offset_in_world)
				
			else: node.position = target_position
		
		elif node is Control or node is Node2D:
			# TODO
			pass


func start_drag() -> void:
	drag_started.emit()
	_start_pos = _last_pos
	_drag_elapsed_frames = 0


func end_drag() -> void:
	drag_ended.emit()
	_start_pos = Vector2.ZERO
	_last_pos = Vector2.ZERO
	if _drag_elapsed_frames < 2: tapped.emit()


func get_pos() -> Vector2:
	return _last_pos + offset_from_mouse


func get_3d_pos() -> Vector3:
	if node is Node3D and camera_3d:
		return camera_3d.project_position(_last_pos + offset_from_mouse, 0.0)
	else: return Vector3.ZERO


func get_start_pos() -> Vector2:
	return _start_pos


func get_3d_start_pos() -> Vector3:
	if node is Node3D and camera_3d:
		return camera_3d.project_position(_start_pos, 0.0)
	else: return Vector3.ZERO
