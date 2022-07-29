extends Node3D

signal body_entered(body: Node)

@export var contacts_reported := 5

@onready var body := $WhiskBody as RigidDynamicBody3D
@onready var collider := $WhiskCollider as RigidDynamicBody3D

var velocity: Vector3:
	get: return body.linear_velocity


func _ready() -> void:
	collider.contacts_reported = contacts_reported


func _process(_delta: float) -> void:
	body.rotation.z = deg2rad(150) - deg2rad(10) * body.position.x
	body.rotation.y = deg2rad(60) + deg2rad(10) * body.position.z
	collider.position = body.position


func _on_whisk_collider_body_entered(node: Node):
	body_entered.emit(node)


func move_to(pos: Vector3) -> void:
	body.move_and_collide(pos)
