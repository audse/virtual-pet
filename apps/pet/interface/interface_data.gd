class_name PetInterfaceData
extends Resource

signal recently_cuddled_changed(value: bool)

enum Menu {
	ABOUT,
	CUDDLE,
	GIVE_OBJECT,
	RENAME,
}

signal open_menu_pressed(menu: Menu)

## The amount of time before this pet can be cuddled again
const cuddle_cooldown_time := 60.0

@export var is_recently_cuddled: bool = false:
	set(value):
		is_recently_cuddled = value
		recently_cuddled_changed.emit(value)
		emit_changed()
