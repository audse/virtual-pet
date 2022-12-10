class_name NeedsData
extends Resource

enum Need {
	ACTIVITY,
	COMFORT,
	HUNGER,
	HYGIENE,
	SLEEPY
}

const need_list := [
	Need.ACTIVITY,
	Need.COMFORT, 
	Need.HUNGER,
	Need.HYGIENE, 
	Need.SLEEPY
]

signal need_changed(need: NeedsData.Need, val: float)
signal activity_changed(val: float)
signal comfort_changed(val: float)
signal hunger_changed(val: float)
signal hygiene_changed(val: float)
signal sleepy_changed(val: float)

## 0 = very bored, 1 = fully played with
@export_range(0.0, 1.0, 0.05) var activity := 0.0:
	set(value):
		activity = NeedsData.clamp_need(value)
		activity_changed.emit(activity)
		need_changed.emit(Need.ACTIVITY, activity)
		emit_changed()

## 0 = very uncomfy, 1 = fully comfy
@export_range(0.0, 1.0, 0.05) var comfort := 0.0:
	set(value):
		comfort = NeedsData.clamp_need(value)
		comfort_changed.emit(comfort)
		need_changed.emit(Need.COMFORT, comfort)
		emit_changed()

## 0 = very hungry, 1 = full
@export_range(0.0, 1.0, 0.05) var hunger := 0.0:
	set(value):
		hunger = NeedsData.clamp_need(value)
		hunger_changed.emit(hunger)
		need_changed.emit(Need.HUNGER, hunger)
		emit_changed()

## 0 = very dirty, 1 = fully clean
@export_range(0.0, 1.0, 0.05) var hygiene := 0.0:
	set(value):
		hygiene = NeedsData.clamp_need(value)
		hygiene_changed.emit(hygiene)
		need_changed.emit(Need.HYGIENE, hygiene)
		emit_changed()

## 0 = very sleepy, 1 = fully rested
@export_range(0.0, 1.0, 0.05) var sleepy := 0.0:
	set(value):
		sleepy = NeedsData.clamp_need(value)
		sleepy_changed.emit(sleepy)
		need_changed.emit(Need.SLEEPY, sleepy)
		emit_changed()

func _init(
	activity_value := activity,
	comfort_value := comfort,
	hunger_value := hunger,
	hygiene_value := hygiene,
	sleepy_value := sleepy
) -> void:
	activity = activity_value
	comfort = comfort_value
	hunger = hunger_value
	hygiene = hygiene_value
	sleepy = sleepy_value


func generate_random() -> void:
	activity = Auto.Random.randf_range(0.4, 0.8)
	comfort = Auto.Random.randf_range(0.4, 0.8)
	hunger = Auto.Random.randf_range(0.4, 0.8)
	hygiene = Auto.Random.randf_range(0.4, 0.8)
	sleepy = Auto.Random.randf_range(0.4, 0.8)


func get_need(need: Need) -> float:
	match need:
		Need.ACTIVITY: return activity
		Need.COMFORT: return comfort
		Need.HUNGER: return hunger
		Need.HYGIENE: return hygiene
		Need.SLEEPY: return sleepy
		_: return 0.0


func play(is_boosted := false) -> void:
	activity += randf_range(0.2, 0.4) * (1.25 if is_boosted else 1.0)
	sleepy -= randf_range(0.05, 0.1)


func lounge(is_boosted := false) -> void:
	comfort += randf_range(0.2, 0.4) * (1.25 if is_boosted else 1.0)
	activity -= randf_range(0.05, 0.1)
	sleepy += randf_range(0.01, 0.05) * (1.25 if is_boosted else 1.0)


func eat(is_boosted := false) -> void:
	hunger += randf_range(0.3, 0.6) * (1.25 if is_boosted else 1.0)
	sleepy -= randf_range(0.05, 0.1)


func sleep(is_boosted := false) -> void:
	sleepy += randf_range(0.2, 0.4) * (1.25 if is_boosted else 1.0)
	comfort += randf_range(0.05, 0.1) * (1.25 if is_boosted else 1.0)


func wash(is_boosted := false) -> void:
	hygiene += randf_range(0.4, 0.6) * (1.25 if is_boosted else 1.0)
	comfort -= randf_range(0.01, 0.05)


static func clamp_need(val: float) -> float:
	return snapped(clampf(val, 0, 1), 0.01)


func decrease_needs() -> void:
	activity -= randf_range(0.01, 0.03)
	comfort  -= randf_range(0.01, 0.03)
	hunger   -= randf_range(0.01, 0.03)
	hygiene  -= randf_range(0.01, 0.03) / 2.0
	sleepy   -= randf_range(0.01, 0.03) / 2.0
