extends Node3D

const SPEED := Vector3(15, 0.5, 15)

@export var utensil_path: NodePath
@export var container_path: NodePath

@onready var utensil := get_node(utensil_path)
@onready var container := get_node(container_path)

@onready var _target_pos: Vector3 = utensil.body.position


func _physics_process(delta: float) -> void:
	if abs(utensil.body.position.distance_to(_target_pos)) > 0.01:
		var curr_pos: Vector3 = utensil.body.position.direction_to(_target_pos) * SPEED * delta
		utensil.move_to(curr_pos)


func _on_input_area_event(_camera, event: InputEvent, pos: Vector3, _normal, _shape_idx):
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		_target_pos = pos
