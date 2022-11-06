class_name PetActor
extends CharacterBody3D


@export var pet_data: PetData:
	set(value):
		pet_data = value
		position = pet_data.world_position

@export var speed: float = 6.0
@onready var navigator := %Navigator as NavigationAgent3D
@onready var animation_player := %Model.get_node("AnimationPlayer") as AnimationPlayer
@onready var timer := %Timer as Timer

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
	change_animation("Idle")
	timer.timeout.connect(_on_timer_timeout)
	
	Datetime.data.time_paused.connect(pause)
	Datetime.data.time_unpaused.connect(unpause)


func _physics_process(_delta: float) -> void:
	if is_inside_tree() and navigator.is_target_reachable() and not Datetime.data.paused:
		var next := navigator.get_next_location() - global_transform.origin
		set_velocity(next.normalized() * speed)
		if abs(next.x) > 0.05 or abs(next.y) > 0.05 or abs(next.z) > 0.05:
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
	look_at_location(location)
	
	await navigator.navigation_finished
	change_animation("Idle")


func look_at_location(location: Vector3) -> void:	
	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation:y", get_target_rotation(location).y, animation_durations["Turn"])
	await tween.finished


func get_target_rotation(location: Vector3) -> Vector3:
	var start_rot: Vector3 = rotation
	look_at(Vector3(location.x, 0.5, location.z))
	var end_rot: Vector3 = rotation
	rotation = start_rot
	return end_rot


func change_animation(anim_name: String, one_shot := false) -> void:
	timer.stop()
	timer.wait_time = animation_durations[anim_name]
	
	if Datetime.data.paused:
		await Datetime.data.time_unpaused
	
	animation_player.play(anim_name, (
		0.5 if animation_player.assigned_animation != anim_name else -1.0
	))
	if not one_shot:
		timer.start()
	else:
		await get_tree().create_timer(timer.wait_time).timeout
		change_animation("Idle")


func _on_timer_timeout() -> void:
	animation_player.stop(true)
	animation_player.play(animation_player.current_animation, 0.0)


func pause() -> void:
	timer.stop()
	animation_player.stop(false)


func unpause() -> void:
	timer.start()
	animation_player.play()
