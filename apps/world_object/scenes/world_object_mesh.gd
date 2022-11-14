class_name WorldObjectMeshInstance
extends MeshInstance3D

signal context_changed


var context: WorldObject:
	set(value):
		context = value
		context_changed.emit()
		_on_context_changed()


func _ready() -> void:
	pass


func _on_context_changed() -> void:
	pass
