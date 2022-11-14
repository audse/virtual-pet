class_name BuyableObjectThumbnail
extends Button


const EnvironmentScene := preload("res://environment/scenes/environment.tscn")

@export var object_data: BuyableObjectData

var container: SubViewportContainer
var viewport: SubViewport
var camera: Camera3D

var camera_size: float:
	get: return {
		1: 3.0,
		2: 5.0,
		3: 8.0,
		4: 12.0,
		# TODO
	}[max(object_data.dimensions.x, object_data.dimensions.y)]


var camera_position: Vector3:
	get: return {
		1: Vector3(4.0, 6.0, 5.0),
		# TODO
	}[max(object_data.dimensions.x, object_data.dimensions.y)]


func _init(object_data_value: BuyableObjectData) -> void:
	object_data = object_data_value


func _ready() -> void:
	make_sub_viewport()
	make_camera()
	make_label()
	
	if object_data and viewport:
		var object_mesh := object_data.render_mesh(viewport)
		object_mesh.name = object_data.display_name
	
	pressed.connect(func() -> void: BuyData.buy_object(object_data))


func make_sub_viewport() -> void:
	container = SubViewportContainer.new()
	add_child(container)
	container.stretch = true
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	viewport = SubViewport.new()
	container.add_child(viewport)
	viewport.size = container.size
	viewport.gui_disable_input = true
	viewport.transparent_bg = true
	viewport.add_child(EnvironmentScene.instantiate())
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE


func make_camera() -> void:
	camera = Camera3D.new()
	viewport.add_child(camera)
	camera.position = camera_position
	camera.rotation = Vector3(deg_to_rad(-40.0), deg_to_rad(40.0), 0.0)
	camera.set_orthogonal(camera_size, 0.05, 4000.0)


func make_label() -> void:
	var l := Label.new()
	add_child(l)
	l.text = str(object_data.price)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var s := StyleBoxFlat.new()
	s.bg_color = Color("#27272a")
	s.set_corner_radius_all(24)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 3
	s.content_margin_right = 3
	l.add_theme_stylebox_override("normal", s)
	l.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
