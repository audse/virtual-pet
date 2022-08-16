class_name Utensil
extends Node3D
@icon("utensil.svg")


@export var motion_rotation := Vector3i(10, 10, 20)
@export var start_rotation := Vector3(0, 60, 170)
@export_flags_3d_physics var input_area_layers = 1
@export var speed := Vector3(15, 0.5, 15)

@onready var body := $Body as RigidDynamicBody3D
@onready var collider := $Collider as Area3D
@onready var collider_shape := $Collider/ItemCollision as CollisionShape3D
@onready var input_area := $InputArea as Area3D

var _target: Vector3
var _world: World3D
var _delta: Vector3


func _ready() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera: _world = camera.get_world_3d()
	if input_area:
		input_area.collision_layer = input_area_layers
		input_area.collision_mask = input_area_layers
		input_area.input_event.connect(_on_input_area_event)


func _physics_process(delta: float) -> void:
	if abs(body.position.distance_to(_target)) > 0.01:
		var curr_pos: Vector3 = body.position.direction_to(_target) * speed * delta
		move_to(curr_pos, delta)


func _process(_d: float) -> void:
	body.rotation.z = deg2rad(start_rotation.z) + deg2rad(motion_rotation.z) * body.position.x
	body.rotation.y = deg2rad(start_rotation.y) - deg2rad(motion_rotation.y) * body.position.z
	body.rotation.x = deg2rad(start_rotation.x) + lerp(0, deg2rad(-motion_rotation.x), body.position.z)
	
	collider.position = body.position


func _on_collider_body_entered(node: Node):
	if node is RigidDynamicBody3D or node is SoftDynamicBody3D:
		var added_velocity := Vector3Ref.sign_no_zeros(_delta) as Vector3 * Vector3(0.025, 0.05, 0.025)
		node.apply_impulse(_delta * 1.5 + added_velocity)


func move_to(pos: Vector3, time_delta: float = 1.0) -> void:
	body.move_and_collide(pos)
	_delta = pos - body.position * Vector3(1, 0, 1) * time_delta


func _on_input_area_event(_camera, event: InputEvent, pos: Vector3, _normal, _shape_idx):
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		_target = pos
