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

signal use_24_hour_clock_changed(value: bool)
signal font_size_changed
signal thumbnail_size_changed(value: SizeSetting)
signal limit_animations_changed
signal disabled_mods_changed
signal disable_cheat_mods_changed(value: bool)
signal hide_roofs_changed(value: bool)

@export var use_24_hour_clock: bool = false:
	set(value):
		use_24_hour_clock = value
		use_24_hour_clock_changed.emit(use_24_hour_clock)
		emit_changed()

@export_group("Accessibility")
@export var font_size: SizeSetting = SizeSetting.MEDIUM:
	set(value):
		font_size = value
		font_size_changed.emit()
		emit_changed()

@export var thumbnail_size: SizeSetting = SizeSetting.MEDIUM:
	set(value):
		thumbnail_size = value
		thumbnail_size_changed.emit(thumbnail_size)
		emit_changed()

@export var limit_animations: bool = true:
	set(value):
		limit_animations = value
		limit_animations_changed.emit()
		emit_changed()


@export_group("Mods")
@export var disabled_mods: Array[String] = ["mod_example"]
@export var disable_cheat_mods: bool = false:
	set(value):
		disable_cheat_mods = value
		disable_cheat_mods_changed.emit(value)
		emit_changed()

@export_group("View")
@export var hide_roofs: bool = false:
	set(value):
		hide_roofs = value
		hide_roofs_changed.emit(value)
		emit_changed()

func disable_mod(mod: String) -> void:
	if mod not in disabled_mods:
		disabled_mods.append(mod)
		disabled_mods_changed.emit()
		emit_changed()


func enable_mod(mod: String) -> void:
	if mod in disabled_mods:
		disabled_mods.erase(mod)
		disabled_mods_changed.emit()
		emit_changed()
