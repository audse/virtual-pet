class_name SaveableResource
extends Resource

@export var data_path: String

var dir_data_path: String:
	get: return "user://" + _get_dir()

var full_data_path: String:
	get: return dir_data_path + "/" + data_path + ".tres"


func _init() -> void:
	setup()


func setup():
	if not changed.is_connected(save_data):
		changed.connect(save_data)
	return self


## Override in inherited class to choose the directory that this data should save in
func _get_dir() -> String:
	return "data"


func save_data() -> void:
	if is_in_use():
		print("[", data_path, "]: Saving...")
		# Make sure this resource has a save path
		if len(data_path) < 2: data_path = str(get_instance_id())
		# Make sure the save directory exists
		if not DirAccess.dir_exists_absolute(dir_data_path):
			DirAccess.make_dir_absolute(dir_data_path)
		# Save
		ResourceSaver.save(self, full_data_path)


func delete_data() -> void:
	if FileAccess.file_exists(full_data_path):
		OS.move_to_trash(ProjectSettings.globalize_path(full_data_path))


func is_in_use() -> bool:
	if Game: return Game.is_resource_in_use(self)
	return false
