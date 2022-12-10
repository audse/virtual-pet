class_name InventoryData
extends SaveableResource

signal objects_changed
signal object_added(object: WorldObjectData)
signal object_removed(object: WorldObjectData)


@export var objects: Array[WorldObjectData] = []


func add_object(object: WorldObjectData) -> void:
	WorldData.remove_object(object)
	objects.append(object.setup())
	objects_changed.emit()
	object_added.emit(object)
	emit_changed()


func remove_object(object: WorldObjectData) -> void:
	objects.erase(object)
	objects_changed.emit()
	object_removed.emit(object)
	emit_changed()


func _get_dir() -> String:
	return "game"


func save_data() -> void:
	data_path = "inventory_data"
	super.save_data()
