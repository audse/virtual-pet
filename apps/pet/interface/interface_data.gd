class_name PetInterfaceData
extends Resource

enum Menu {
	ABOUT,
	CUDDLE,
	GIVE_OBJECT,
	RENAME,
}

signal open_menu_pressed(menu: Menu)
