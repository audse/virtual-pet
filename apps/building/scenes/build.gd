extends Node3D

@onready var map: CellMap = $CellMap
@onready var guide_map: GuideMap = $GuideMap
@onready var grid_plane: MeshInstance3D = %GridPlane

var building_data := BuildingData.new():
	set(value):
		building_data = value
		if is_inside_tree(): update_from_data()

var center := Vector3i.ZERO
var coords := {
	start = Vector3i.ZERO,
	end = Vector3i.ZERO,
}

var enabled: bool = false:
	set(value):
		enabled = value
		guide_map.clear()
		if enabled: guide_map.enable()
		else: guide_map.disable()
		set_coords()

var is_current: bool:
	get: return BuildData.state.current_building == building_data


func _ready() -> void:
	guide_map.drag_complete.connect(await_confirmation)
	
	BuildData.confirm_build.connect(_on_built)
	BuildData.confirm_destroy.connect(_on_destroyed)
	BuildData.cancel.connect(_on_cancelled)
	BuildData.start_building.connect(_on_start)
	BuildData.start_destroying.connect(_on_start)


func update_from_data() -> void:
	map.clear()
	map.set_cells(building_data.coords)
#	if len(building_data.coords) == 0: center_around(
#		WorldData.to_grid(Vector3Ref.project_position_to_floor_simple(
#			get_viewport().get_camera_3d(),
#			Utils.get_display_area(self).size / 2.0,
#		))
#	)
#	else:
#		building_data.coords.sort()
#		center_around(building_data.coords[len(building_data.coords) / 2])


#func center_around(coord: Vector3i) -> void:
#	center = coord
#	$DrawArea.position = Vector3(coord)


func set_coords(start := Vector3i.ZERO, end := Vector3i.ZERO):
	coords.start = start
	coords.end = end


func await_confirmation(start_coord: Vector3i, end_coord: Vector3i) -> void:
	if is_current:
		set_coords(start_coord, end_coord)
		
		# redraw guide map cells (as they are automatically deleted when drag is finished)
		guide_map.set_cells_betweenv(start_coord, end_coord)


func _on_start() -> void:
	if is_current:
		await get_tree().create_timer(0.1).timeout
		grid_plane.visible = true
		enabled = true


func _on_built() -> void:
	if is_current:
		var empty_coords := map.get_empty_coords_betweenv(coords.start, coords.end)
		if BuildData.is_area_buildable(CellMap.from_2x2_to_1x1_coords(empty_coords)):
			building_data.add_area(empty_coords)
			map.set_cells_betweenv(coords.start, coords.end)


func _on_destroyed() -> void:
	if is_current:
		var empty_coords := map.get_filled_coords_betweenv(coords.start, coords.end)
		map.erase_cells_betweenv(coords.start, coords.end)
		building_data.remove_area(empty_coords)


func _on_cancelled() -> void:
	grid_plane.visible = false
	enabled = false


func _on_area_3d_input_event(_camera: Node, event: InputEvent, event_pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if is_current: guide_map.handle_drag(event, event_pos)
