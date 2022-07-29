extends Node3D

const SPEED := Vector3(15, 0.5, 15)

enum Tool { WHISK, SPOON, }
enum Bowl { MIXING_BOWL, POT, }

const Whisk = preload("res://apps/cooking/mixing/scenes/whisk.tscn")
const MixingBowl = preload("res://apps/cooking/mixing/scenes/mixing_bowl.tscn")

@export var tool: Tool = Tool.WHISK
@export var bowl: Bowl = Bowl.MIXING_BOWL

@onready var whisk := $Whisk as Node3D
@onready var _target_pos: Vector3 = whisk.body.position
@onready var fill := $Fill as MeshInstance3D
@onready var items = [%Rice, %Rice1, %Rice2]


func _physics_process(delta: float) -> void:
	if abs(whisk.body.position.distance_to(_target_pos)) > 0.01:
		var curr_pos: Vector3 = whisk.body.position.direction_to(_target_pos) * SPEED * delta
		whisk.move_to(curr_pos)


func _on_input_area_event(_camera, event: InputEvent, pos: Vector3, _normal, _shape_idx):
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		_target_pos = pos


func _on_whisk_body_entered(body: Node) -> void:
	if body is RigidDynamicBody3D:
		body.apply_impulse(whisk.velocity)
