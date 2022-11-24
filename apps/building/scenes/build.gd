extends Node3D

@onready var viewport := get_viewport()
@onready var camera := viewport.get_camera_3d()

@onready var map: CellMap = $CellMap
@onready var guide_map: GuideMap = $GuideMap
@onready var grid_plane: MeshInstance3D = %GridPlane
@onready var roof_map: CellMap = $RoofMap
@onready var roof_mesh: MeshInstance3D = $RoofContainer/RoofMesh

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
	BuildData.confirm_build.connect(_on_built)
	BuildData.confirm_destroy.connect(_on_destroyed)
	
	BuildData.state.enter_state.connect(
		func(state: BuildModeState.BuildState) -> void:
			if is_current:
				match state:
					BuildModeState.BuildState.BUILDING_WALLS, BuildModeState.BuildState.DESTROYING_WALLS:
						_on_start()
					BuildModeState.BuildState.READY, BuildModeState.BuildState.EDIT:
						_on_cancelled()
	)
	
	Settings.data.hide_roofs_changed.connect(
		func(hide_roofs: bool) -> void: roof_map.visible = not hide_roofs
	)
	
	Game.Mode.enter_state.connect(
		func(_state) -> void: edit_button.visible = Game.Mode.is_build
	)
	
	edit_button.pressed.connect(
		func() -> void: BuildData.state.edit(building_data)
	)
	
	editor.polygon_changed.connect(renderer.draw_building)


func _physics_process(_delta: float) -> void:
	edit_button.visible = (
		Game.Mode.is_build
		and BuildData.state.current_building == null
		and building_data
		and not building_data.is_empty
	)
	if edit_button.visible:
		edit_button.position = camera.unproject_position(building_data.center_coord)


func update_from_data() -> void:
	renderer.update_from_data(building_data)
	
	# Render objects
	for object_data in building_data.objects:
		get_parent().render_object_to(self, object_data)
	
	if not building_data.object_added.is_connected(_on_object_added):
		building_data.object_added.connect(_on_object_added)


func enable() -> void:
	grid_plane.visible = true
	guide_map.visible = true
	guide_map.release()
	guide_map.enable()


func disable() -> void:
	grid_plane.visible = false
	guide_map.visible = false
	guide_map.release()
	guide_map.disable()


func _on_start() -> void:
	await get_tree().create_timer(0.1).timeout
	grid_plane.visible = true
	enable()


func _on_built() -> void:
	var empty_coords := map.get_empty_coords_betweenv(guide_map.prev_start_coord, guide_map.prev_end_coord)
	if BuildData.is_area_buildable(empty_coords):
		building_data.add_area(empty_coords)


func _on_destroyed() -> void:
	if is_current:
		var filled_coords := map.get_filled_coords_betweenv(guide_map.prev_start_coord, guide_map.prev_end_coord)
		building_data.remove_area(filled_coords)


func _on_object_added(object: BuildingObjectData) -> void:
	get_parent().render_object_to(self, object)


func _on_cancelled() -> void:
	disable()


func _on_area_3d_input_event(_camera: Node, event: InputEvent, event_pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if is_current: guide_map.handle_drag(event, event_pos)
