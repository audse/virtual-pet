class_name IsoCamera
extends Camera3D

const ROT_AMT := deg_to_rad(40)
const ROT_DELTA := deg_to_rad(90)

@export var disable_rotation: bool = false


func _ready():
	projection = Camera3D.PROJECTION_ORTHOGONAL
	rotation.x = -ROT_AMT
	rotation.y = ROT_AMT
	
	size = 22
	position.y = 16


func _input(event: InputEvent) -> void:
	if event is InputEventKey and not disable_rotation and event.is_pressed():
		match event.keycode:
			KEY_COMMA: _tween_rotate(-ROT_DELTA)
			KEY_PERIOD: _tween_rotate(ROT_DELTA)
			KEY_LEFT: _tween_translate(-5, 0, 0)
			KEY_RIGHT: _tween_translate(5, 0, 0)
			KEY_UP: _tween_translate(0, 5, 5)
			KEY_DOWN: _tween_translate(0, -5, 5)


func _tween_translate(delta_x: float, delta_y: float, delta_z: float) -> void:
	var start_pos := position
	translate(Vector3(delta_x, delta_y, delta_z))
	var target_pos := position
	position = start_pos
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", target_pos, 0.5)
	await tween.finished


func _tween_rotate(to: float) -> void:
	var start_rot := rotation
	rotate_y(to)
	var target_rot := rotation
	rotation = start_rot
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation", target_rot, 0.5)
	await tween.finished
