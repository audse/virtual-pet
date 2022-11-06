class_name PetInterfaceData
extends Resource

enum Menu {
	ABOUT,
	CUDDLE,
	GIVE_OBJECT,
	RENAME,
}

signal open_menu_pressed(menu: Menu)

## The amount of time before this pet can be cuddled again
const cuddle_cooldown_time := 60.0

@export var is_recently_cuddled: bool = false
