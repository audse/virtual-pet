extends Node3D

const SPEED := Vector3(20, 0.5, 20)
const MOUSE_OFFSET_IN_WORLD := Vector2(-50, 250) # pixels
const MIN_CHOP_LENGTH := 150 # pixels

@onready var mushroom := $Mushroom as Choppable
@onready var knife := $Knife as Utensil
@onready var _camera := $Camera3D as Camera3D

@onready var _knife_start_pos := knife.position
var _target_pos: Vector3
var _is_pressed := false

var _press_start_pos: Vector2
var _press_end_pos: Vector2

func _physics_process(delta: float) -> void:
	if abs(knife.body.position.distance_to(_target_pos)) > 0.01:
		var curr_pos: Vector3 = knife.body.position.direction_to(_target_pos)
		if _is_pressed: 
			knife.position.y = move_toward(knife.position.y, _knife_start_pos.y - 1.0, delta * 10)
		else: 
			knife.position.y = move_toward(knife.position.y, _knife_start_pos.y, delta * 3)
			# only move knife if not pressed so that we get that "chop" feeling
			knife.move_to(curr_pos* SPEED * delta, delta)


func _on_input_area_event(_camera, event: InputEvent, pos: Vector3, _normal, _shape_idx):
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		_target_pos = pos


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			var world_pos := Vector3Ref.project_position_to_floor_simple(_camera, event.position + MOUSE_OFFSET_IN_WORLD)
			if mushroom.bounds.has_point(world_pos):
				_is_pressed = true
				_press_start_pos = event.position
		else: 
			_is_pressed = false
			_press_end_pos = event.position
			_chop()


func _chop() -> void:
	if _press_start_pos.distance_to(_press_end_pos) > MIN_CHOP_LENGTH:
		mushroom.chop()
