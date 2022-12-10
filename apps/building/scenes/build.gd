extends Node3D

@onready var viewport := get_viewport()
@onready var camera := viewport.get_camera_3d()
@onready var grid_plane: MeshInstance3D = %GridPlane
@onready var editor := %PolygonEditor as PolygonEditor
@onready var renderer: BuildingRenderer = %BuildingRenderer
@onready var edit_button: Button = %EditButton

var building_data := BuildingData.new():
	set(value):
		building_data = value
		if is_inside_tree(): update_from_data()

var is_current: bool:
	get: return BuildData.state.current_building == building_data


func _ready() -> void:
	BuildData.state.enter_state.connect(
		func(state: BuildModeState.BuildState) -> void:
			if is_current:
				match state:
					BuildModeState.BuildState.BUILDING_WALLS, BuildModeState.BuildState.DESTROYING_WALLS:
						_on_start()
					BuildModeState.BuildState.READY, BuildModeState.BuildState.EDIT:
						_on_cancelled()
	)
	
	Game.Mode.enter_state.connect(
		func(_state) -> void: edit_button.visible = Game.Mode.is_build
	)
	
	edit_button.pressed.connect(
		func() -> void: BuildData.state.edit(building_data)
	)
	
	editor.polygon_changed.connect(
		func(polygon) -> void:
			if is_current: 
				building_data.shape = editor.polygon
				renderer.draw_building(polygon)
	)


func _physics_process(_delta: float) -> void:
	edit_button.visible = (
		Game.Mode.is_build
		and BuildData.state.current_building == null
		and building_data
		and not building_data.is_empty
	)
	if edit_button.visible:
		var center := Polygon.get_center(building_data.shape)
		edit_button.position = camera.unproject_position(Vector3(center.x, 2.0, center.y))


func update_from_data() -> void:
	renderer.update_from_data(building_data)
	
	# Render objects
	for object_data in building_data.objects:
		get_parent().render_object_to(self, object_data)
	
	if not building_data.object_added.is_connected(_on_object_added):
		building_data.object_added.connect(_on_object_added)


func enable() -> void:
	if is_current:
		editor.enable()
		grid_plane.visible = true


func disable() -> void:
	editor.disable()
	grid_plane.visible = false


func _on_start() -> void:
	if is_current:
		await get_tree().create_timer(0.1).timeout
		editor.polygon = building_data.shape
		enable()


func _on_object_added(object: WorldObjectData) -> void:
	get_parent().render_object_to(self, object)


func _on_cancelled() -> void:
	disable()
