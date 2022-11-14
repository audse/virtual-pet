class_name WorldObject
extends StaticBody3D

@export var object_data: WorldObjectData

@onready var viewport := get_viewport()
@onready var camera := viewport.get_camera_3d()
@onready var action_menu := %InteractWithObjectActionMenu as Control
@onready var draggable := %Draggable3D as Draggable3D

var mesh: MeshInstance3D:
	set(value):
		mesh = value
		if mesh and "context" in mesh:
			mesh.context = self

var collision: CollisionShape3D

var is_consumable: bool:
	get: return mesh and "consume" in mesh


func _ready() -> void:
	if object_data: update_object_data(object_data)
	action_menu.sell_pressed.connect(queue_free)


func _unhandled_input(event: InputEvent) -> void:
	if (
		Game.Mode.is_live 
		and event is InputEventMouseButton 
		and event.is_pressed()
	): 
		var event_position := Vector3Ref.project_position_to_floor_simple(camera, event.position)
		if object_data.get_rect().has_point(Vector2(event_position.x, event_position.z)):
			action_menu.open_at(viewport.get_mouse_position())
			viewport.set_input_as_handled()


func update_object_data(object_data_value: WorldObjectData) -> void:
	object_data = object_data_value
	
	if is_inside_tree():
		draggable.fallback_position = Vector3(object_data.coord.x, 0, object_data.coord.y)
		
		# update children with new data
		action_menu.object_data = object_data
		
		# render object scene
		var nodes = object_data.buyable_object_data.render(self)
		mesh = nodes.mesh_instance
		collision = nodes.collision_instance
		
		# unbind drag signals
		for sig in [draggable.position_changed, draggable.rotation_changed]:
			var connections := (sig as Signal).get_connections()
			for connection in connections:
				sig.disconnect(connection)
		
		# rebind drag signals
		draggable.position_changed.connect(_on_position_changed)
		draggable.rotation_changed.connect(object_data.set_rotation_from_world_rotation)
		
		# update position and rotation
		place_in_world()


func place_in_world() -> void:
	position = object_data.get_world_position()
	rotate_y(deg_to_rad(object_data.rotation))


func _on_position_changed(new_position: Vector3) -> void:
	var world_coord: Vector3i = WorldData.to_grid(new_position) * Vector3i(1, 0, 1)
	
	# Only adjust the coord if it is occupiable
	if world_coord in WorldData.blocks and WorldData.blocks[world_coord].is_occupiable_by_object(object_data):
		object_data.coord = Vector2i(world_coord.x, world_coord.z)
		
		# Update the fallback position so that if the object can't be dragged any further, 
		# it will return to the most recent spot
		draggable.fallback_position = Vector3(world_coord)


func consume() -> void:
	if is_consumable: mesh.consume()


func reset() -> void:
	print("resetting...")
	if is_consumable: mesh.reset()
