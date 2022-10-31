class_name WorldObjectRenderer
extends Node3D

const Interface := {
	InteractionMenu = preload("res://apps/world_object/interface/action_menus/interact_with_object.tscn")
}

var object: WorldObjectData

@onready var camera := get_viewport().get_camera_3d()
@onready var action_menu := Interface.InteractionMenu.instantiate()


func _init(object_value: WorldObjectData) -> void:
	object = object_value
	
	if not object.instance and object.scene:
		object.instance = object.scene.instantiate()


func _ready() -> void:
	action_menu.object_data = object
	add_child(action_menu)
	add_child(object.instance)
	update_placement()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed(): 
		var event_position := Vector3Ref.project_position_to_floor_simple(camera, event.position)
		if object.get_rect().has_point(Vector2(event_position.x, event_position.z)):
			action_menu.open_at(event.position)
			get_viewport().set_input_as_handled()


func update_placement() -> void:
	object.instance.position += object.get_world_position()
	object.instance.rotate_y(deg_to_rad(object.rotation))
