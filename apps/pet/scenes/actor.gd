class_name PetActor
extends CharacterBody3D


@export var pet_data: PetData:
	set(value):
		pet_data = value
		position = pet_data.world_position
		if is_inside_tree(): 
			go_to_location(pet_data.world_position)
			renderer.pet_data = pet_data

@export var speed: float = 6.0
@onready var navigator := %Navigator as NavigationAgent3D
@onready var animation_player := %Model.get_node("AnimationPlayer") as AnimationPlayer
@onready var renderer := %Renderer as PetRenderer

const animation_durations := {
	"Idle": 1.5,
	"WalkCycle": 1.05,
	"Turn": 0.25,
	"Eat": 54.0 / 24.0
}

var rect: Rect2:
	get: return Rect2(
		position.x - 1.0,
		position.z - 1.0,
		2.0,
		2.0
	)


func _ready() -> void:
	Datetime.data.time_paused.connect(pause)
	Datetime.data.time_unpaused.connect(unpause)
	renderer.pet_data = pet_data


func _physics_process(_delta: float) -> void:
	if is_inside_tree() and navigator.is_target_reachable() and not Datetime.data.paused:
		var next := navigator.get_next_location() - global_transform.origin
		set_velocity(next.normalized() * speed)
		if abs(next.x) > 0.05 or abs(next.y) > 0.05 or abs(next.z) > 0.05:
			rotation = rotation.lerp(get_target_rotation(position + next * Vector3(1, 0, 1)), 0.1)
			move_and_slide()
		_update_world_coord()


func _update_world_coord() -> void:
	if pet_data: pet_data.world_coord = Vector2i(
		round(global_transform.origin.x / WorldData.grid_size),
		round(global_transform.origin.z / WorldData.grid_size)
	)


func go_to_location(location: Vector3) -> void:
	change_animation("WalkCycle")
	
	navigator.set_target_location(location)
	
	await navigator.navigation_finished
	change_animation("Idle")


func get_target_rotation(location: Vector3) -> Vector3:
	var start_rot: Vector3 = rotation
	look_at(location)
	var end_rot: Vector3 = rotation
	rotation = start_rot
	return end_rot


func change_animation(anim_name: String, one_shot := false) -> void:
	var current := animation_player.current_animation
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name, 0.5)
	if one_shot: animation_player.queue(current)


func pause() -> void:
	animation_player.stop(false)


func unpause() -> void:
	animation_player.play()
