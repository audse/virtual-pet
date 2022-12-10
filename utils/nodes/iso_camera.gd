class_name IsoCamera
extends Marker3D

const SPEED := 4.0
const ROT_AMT := deg_to_rad(40)
const ROT_DELTA := deg_to_rad(30)

@export var disabled: bool = false
@export var clamp_to_world: bool = true

@onready var camera := $Camera3D as Camera3D
@onready var target_rotation: float = rotation.y
@onready var target_position: Vector3 = position:
	set(value):
		if clamp_to_world:
			var max_size = Vector3(WorldData.size.x, 100, WorldData.size.y) if WorldData else Vector3(100, 100, 100)
			target_position = value.clamp(-max_size, max_size)
		else: target_position = value
	
@onready var target_size: float = camera.size


func _input(event: InputEvent) -> void:
	if event is InputEventKey and not disabled and event.is_pressed():
		var zoom_ease := ease(camera.size / 24.0, 1.6)
		match event.keycode:
			KEY_COMMA: target_rotation = rotation.y - ROT_DELTA
			KEY_PERIOD: target_rotation = rotation.y + ROT_DELTA
			KEY_LEFT: target_position = position + Vector3(-5, 0, 5).rotated(Vector3(0, 1, 0), rotation.y) * zoom_ease
			KEY_RIGHT: target_position = position + Vector3(5, 0, -5).rotated(Vector3(0, 1, 0), rotation.y) * zoom_ease
			KEY_UP: target_position = position + Vector3(-5, 0, -5).rotated(Vector3(0, 1, 0), rotation.y) * zoom_ease
			KEY_DOWN: target_position = position + Vector3(5, 0, 5).rotated(Vector3(0, 1, 0), rotation.y) * zoom_ease
			KEY_EQUAL: target_size = camera.size - zoom_ease * 10.0
			KEY_MINUS: target_size = camera.size + zoom_ease * 15.0


func _physics_process(delta: float) -> void:
	if position.distance_to(target_position) > 0.1:
		position = position.slerp(target_position, delta * SPEED)
	if abs(target_size - camera.size) > 0.1:
		camera.size = lerpf(camera.size, target_size, delta * SPEED)
	if abs(target_rotation - rotation.y) > 0.1:
		rotation.y = lerpf(rotation.y, target_rotation, delta * SPEED)


func _tween_rotate(to: float) -> void:
	var start_rot := rotation
	rotate_y(to)
	var target_rot := rotation
	rotation = start_rot
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation", target_rot, 0.5)
	await tween.finished
