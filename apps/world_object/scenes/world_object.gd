class_name WorldObject
extends StaticBody3D

@export var object_data: WorldObjectData

@onready var camera := get_viewport().get_camera_3d()
@onready var action_menu := %InteractWithObjectActionMenu as Control
@onready var draggable := %Draggable3D as Draggable3D


func _ready() -> void:
	if object_data: update_object_data(object_data)


func _unhandled_input(event: InputEvent) -> void:
	if (
		Game.Mode.is_live 
		and event is InputEventMouseButton 
		and event.is_pressed()
	): 
		var event_position := Vector3Ref.project_position_to_floor_simple(camera, event.position)
		if object_data.get_rect().has_point(Vector2(event_position.x, event_position.z)):
			action_menu.open_at(event.position)
			get_viewport().set_input_as_handled()


func update_object_data(object_data_value: WorldObjectData) -> void:
	object_data = object_data_value
	
	if is_inside_tree():
		# update children with new data
		action_menu.object_data = object_data
		
		# render object scene
		object_data.buyable_object_data.render(self)
		
		# unbind drag signals
		for sig in [draggable.position_changed, draggable.rotation_changed]:
			var connections := (sig as Signal).get_connections()
			for connection in connections:
				sig.disconnect(connection)
		
		# rebind drag signals
		draggable.position_changed.connect(object_data.set_coord_from_world_position)
		draggable.rotation_changed.connect(object_data.set_rotation_from_world_rotation)
		
		# update position and rotation
		place_in_world()


func place_in_world() -> void:
	position = object_data.get_world_position()
	rotate_y(deg_to_rad(object_data.rotation))


func _on_position_changed(new_position: Vector3) -> void:
	object_data.set_coord_from_world_position(new_position)
	var world_coord: Vector3 = WorldData.to_grid(new_position)
	object_data.coord = Vector2i(int(world_coord.x), int(world_coord.z))


func _on_rotation_changed(new_rotation: Vector3) -> void:
	object_data.rotation = int(rad_to_deg(new_rotation.y))
