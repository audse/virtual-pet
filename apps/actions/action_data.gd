class_name ActionData
extends Resource


signal actions_changed


@export var actions: Array[String] = []:
	set(value):
		actions = value
		actions_changed.emit()


func _init() -> void:
	pass
