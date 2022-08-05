class_name Utensil
extends Node3D
@icon("utensil.svg")


@export var motion_rotation := Vector3i(10, 10, 20)
@export var start_rotation := Vector3(0, 60, 170)

@onready var body := $Body as RigidDynamicBody3D
@onready var collider := $Collider as Area3D
@onready var collider_shape := $Collider/ItemCollision as CollisionShape3D

var _world: World3D
var _delta: Vector3


func _ready() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera: _world = camera.get_world_3d()


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
	
