class_name Chopping
extends Node3D
@icon("chopping.svg")

const MOUSE_OFFSET_IN_WORLD := Vector2(-75, 250) # pixels
const MIN_CHOP_LENGTH := 150 # pixels

@export var choppable_path: NodePath
@export var utensil_path: NodePath

@onready var choppable := get_node(choppable_path) as Choppable
@onready var utensil := get_node(utensil_path) as Utensil
@onready var _camera = get_viewport().get_camera_3d()

@onready var _utensil_start_pos := utensil.body.position
@onready var _utensil_start_speed := utensil.speed

var _is_pressed := false

var _press_start_pos: Vector2
var _press_end_pos: Vector2


func _physics_process(delta: float) -> void:
	# move utensil really slowly if pressed so that we get that "chop" feeling
	if _is_pressed: utensil.speed = _utensil_start_speed / 4.0
	else: utensil.speed = _utensil_start_speed
	
	var y_pos: float = _utensil_start_pos.y - (1.0 if _is_pressed else 0.0)
	utensil.body.position.y = move_toward(utensil.body.position.y, y_pos, delta * 7.5)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			var world_pos := Vector3Ref.project_position_to_floor(_camera, event.position + MOUSE_OFFSET_IN_WORLD)
			if choppable.bounds.has_point(world_pos):
				_is_pressed = true
				_press_start_pos = event.position
		else: 
			_is_pressed = false
			_press_end_pos = event.position
			_chop()


func _chop() -> void:
	if _press_start_pos.distance_to(_press_end_pos) > MIN_CHOP_LENGTH:
		choppable.chop()
