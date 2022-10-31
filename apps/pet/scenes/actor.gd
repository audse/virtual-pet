class_name PetActor
extends CharacterBody3D

@export var pet_data: PetData:
	set(value):
		pet_data = value
		position = pet_data.world_position

@export var speed: float = 4.0
@onready var navigator := %Navigator as NavigationAgent3D

var rect: Rect2:
	get: return Rect2(
		position.x - 1.0,
		position.z - 1.0,
		2.0,
		2.0
	)

func _physics_process(_delta: float) -> void:
	if is_inside_tree() and navigator.is_target_reachable():
		set_velocity(
			(navigator.get_next_location() - global_transform.origin).normalized() * speed
		)
		move_and_slide()
		_update_world_coord()


func _update_world_coord() -> void:
	if pet_data: pet_data.world_coord = Vector2i(
		round(global_transform.origin.x / WorldData.grid_size),
		round(global_transform.origin.z / WorldData.grid_size)
	)


func go_to_location(location: Vector3) -> void:
	navigator.set_target_location(location)
	look_at_location(location)


func look_at_location(location: Vector3) -> void:	
	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation", get_target_rotation(location), 0.15)
	await tween.finished


func get_target_rotation(location: Vector3) -> Vector3:
	var start_rot: Vector3 = rotation
	look_at(Vector3(location.x, 0.5, location.z))
	var end_rot: Vector3 = rotation
	rotation = start_rot
	return end_rot
	
