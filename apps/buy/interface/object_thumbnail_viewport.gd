class_name BuyableObjectThumbnailViewport
extends SubViewportContainer

const EnvironmentScene := preload("res://environment/scenes/environment.tscn")

@export var object_data: BuyableObjectData


func _init(object_data_value: BuyableObjectData) -> void:
	object_data = object_data_value


func _ready() -> void:
	stretch = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var viewport := make_sub_viewport()
	var _camera := make_camera(viewport)
	
	if object_data and viewport:
		var object_mesh := object_data.render_mesh(viewport)
		object_mesh.name = object_data.display_name


func make_sub_viewport() -> SubViewport:
	var viewport := SubViewport.new()
	add_child(viewport)
	viewport.gui_disable_input = true
	viewport.transparent_bg = true
	viewport.add_child(EnvironmentScene.instantiate())
	viewport.own_world_3d = true
	return viewport


func make_camera(viewport: SubViewport) -> Camera3D:
	var camera := Camera3D.new()
	viewport.add_child(camera)
	camera.position = Vector3(4.0, 6.0, 5.0)
	camera.rotation = Vector3(deg_to_rad(-40.0), deg_to_rad(40.0), 0.0)
	camera.set_orthogonal(5, 0.05, 4000.0)
	return camera
	
