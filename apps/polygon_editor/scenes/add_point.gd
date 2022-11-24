class_name PolygonEditorAddPointButton
extends Area3D

const GROUP_NAME := "polygon_editor__add_point"


func _enter_tree() -> void:
	add_to_group(GROUP_NAME)


static func get_all(editor: Node3D) -> Array[Node]:
	return editor.get_tree().get_nodes_in_group(GROUP_NAME)
