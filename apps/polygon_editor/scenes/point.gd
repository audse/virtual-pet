class_name PolygonEditorPoint
extends RigidBody3D

signal position_changed(position: Vector3, node: RigidBody3D)

const GROUP_NAME := "polygon_editor__point"

@onready var drag := %Draggable3D as Draggable3D
@onready var mesh := %MeshInstance3D as MeshInstance3D
@onready var light := %OmniLight3D as OmniLight3D

@onready var radius: float = (mesh.mesh as SphereMesh).radius
@onready var focused_radius: float = radius * 1.25


func _enter_tree() -> void:
	add_to_group(GROUP_NAME)


func _ready():
	light.light_energy = 0.0
	light.light_indirect_energy = 0.0
	
	drag.position_changed.connect(
		func(pos) -> void: position_changed.emit(pos, self)
	)
	
	drag.drag_started.connect(_on_drag_started)
	drag.drag_finished.connect(_on_drag_finished)


static func get_all(editor: Node3D) -> Array[Node]:
	return editor.get_tree().get_nodes_in_group(GROUP_NAME)


func _on_drag_started() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK).set_parallel()
	tween.tween_property(mesh, "mesh:radius", focused_radius, 0.15)
	tween.tween_property(mesh, "mesh:height", focused_radius, 0.15)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(light, "light_energy", 0.5, 0.15)
	tween.tween_property(light, "light_indirect_energy", 0.5, 0.15)


func _on_drag_finished() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK).set_parallel()
	tween.tween_property(mesh, "mesh:radius", radius, 0.25)
	tween.tween_property(mesh, "mesh:height", radius, 0.25)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(light, "light_energy", 0.0, 0.15)
	tween.tween_property(light, "light_indirect_energy", 0.0, 0.15)
