class_name NeedsData
extends Resource

signal activity_changed(val: float)
signal comfort_changed(val: float)
signal hunger_changed(val: float)
signal hygiene_changed(val: float)
signal sleep_changed(val: float)

@export_range(0.0, 1.0, 0.05) var activity := 0.0:
	set(value):
		activity = value
		activity_changed.emit(activity)

@export_range(0.0, 1.0, 0.05) var comfort := 0.0:
	set(value):
		comfort = value
		comfort_changed.emit(comfort)

@export_range(0.0, 1.0, 0.05) var hunger := 0.0:
	set(value):
		hunger = value
		hunger_changed.emit(hunger)

@export_range(0.0, 1.0, 0.05) var hygiene := 0.0:
	set(value):
		hygiene = value
		hygiene_changed.emit(hygiene)

@export_range(0.0, 1.0, 0.05) var sleep := 0.0:
	set(value):
		sleep = value
		sleep_changed.emit(sleep)


func _init(
	activity_value := activity,
	comfort_value := comfort,
	hunger_value := hunger,
	hygiene_value := hygiene,
	sleep_value := sleep
) -> void:
	activity = activity_value
	comfort = comfort_value
	hunger = hunger_value
	hygiene = hygiene_value
	sleep = sleep_value


func generate_random() -> void:
	activity = Auto.Random.randf_range(0.4, 0.8)
	comfort = Auto.Random.randf_range(0.4, 0.8)
	hunger = Auto.Random.randf_range(0.4, 0.8)
	hygiene = Auto.Random.randf_range(0.4, 0.8)
	sleep = Auto.Random.randf_range(0.4, 0.8)
	
