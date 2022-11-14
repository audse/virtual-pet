class_name ConsumableObject
extends WorldObjectMeshInstance


func _ready() -> void:
	_update_mesh()
	super._ready()


func consume() -> void:
	# alter the mesh to reflect being consumed
	_update_mesh()


func reset() -> void:
	# alter the mesh to reflect being unconsumed
	_update_mesh()


func _get_mesh(_uses_left: int) -> Mesh:
	return mesh


func _update_mesh() -> void:
	if context and context.object_data:
		mesh = _get_mesh(context.object_data.uses_left)
