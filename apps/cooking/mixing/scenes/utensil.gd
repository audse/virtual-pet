extends Node3D

@export var contacts_reported := 5
@export var motion_rotation := Vector3i(10, 10, 20)

@onready var body := $Body as RigidDynamicBody3D
@onready var collider := $Collider as RigidDynamicBody3D


func _ready() -> void:
	collider.contacts_reported = contacts_reported


func _process(_delta: float) -> void:
	body.rotation.z = deg2rad(170) + deg2rad(motion_rotation.z) * body.position.x
	body.rotation.y = deg2rad(60) - deg2rad(motion_rotation.y) * body.position.z
	body.rotation.x = lerp(0, deg2rad(-motion_rotation.x), body.position.z)
	collider.position = body.position


func _on_collider_body_entered(node: Node):
	if node is RigidDynamicBody3D or node is SoftDynamicBody3D:
		node.apply_impulse(body.linear_velocity)


func move_to(pos: Vector3) -> void:
	body.move_and_collide(pos)
