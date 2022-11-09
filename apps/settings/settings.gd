extends Node

const settings_data_path := "user://settings_data.tres"

var data := SettingsData.new()

func _ready():
	load_data()
	data.use_24_hour_clock_changed.connect(func(_val): save_data())
	data.font_size_changed.connect(save_data)
	data.thumbnail_size_changed.connect(func(_val): save_data())
	data.limit_animations_changed.connect(save_data)
	data.disabled_mods_changed.connect(save_data)
	data.disable_cheat_mods_changed.connect(func(_val): save_data())


func load_data() -> void:
	if ResourceLoader.exists(settings_data_path):
		data = ResourceLoader.load(settings_data_path)


func save_data() -> void:
	ResourceSaver.save(data, settings_data_path)


func anim_duration(from: float) -> float:
	return from if not data.limit_animations else 0.0
