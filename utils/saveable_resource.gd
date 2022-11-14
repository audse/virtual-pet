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
	_has_set_is_in_use = false
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


# We don't want to save editor-only objects, so we want to make sure
# each saved resource is part of the world in some way before saving.
# We cache this because no point calculating more than once.
var _is_in_use: bool = false
var _has_set_is_in_use: bool = false

func is_in_use() -> bool:
	if not _has_set_is_in_use and Game and WorldData:
		_is_in_use = Game.is_resource_in_use(self)
		_has_set_is_in_use = true
	return _is_in_use
