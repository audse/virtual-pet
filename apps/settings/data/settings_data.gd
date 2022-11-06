class_name SettingsData
extends Resource

enum SizeSetting {
	SMALLEST = 0,
	SMALL = 1,
	MEDIUM = 2,
	BIG = 3,
	BIGGER = 4,
	BIGGEST = 5
}

signal use_24_hour_clock_changed(bool)
signal font_size_changed
signal thumbnail_size_changed(SizeSetting)
signal limit_animations_changed
signal disabled_mods_changed

@export var use_24_hour_clock: bool = false:
	set(value):
		use_24_hour_clock = value
		use_24_hour_clock_changed.emit(use_24_hour_clock)

@export_group("Accessibility")
@export var font_size: SizeSetting = SizeSetting.MEDIUM:
	set(value):
		font_size = value
		font_size_changed.emit()

@export var thumbnail_size: SizeSetting = SizeSetting.MEDIUM:
	set(value):
		thumbnail_size = value
		thumbnail_size_changed.emit(thumbnail_size)

@export var limit_animations: bool = true:
	set(value):
		limit_animations = value
		limit_animations_changed.emit()


@export_group("Mods")
@export var disabled_mods: Array[String] = ["mod_example"]


func disable_mod(mod: String) -> void:
	if mod not in disabled_mods:
		disabled_mods.append(mod)
		disabled_mods_changed.emit()


func enable_mod(mod: String) -> void:
	if mod in disabled_mods:
		disabled_mods.erase(mod)
		disabled_mods_changed.emit()
