extends Node3D

@onready var map: CellMap = $CellMap
@onready var guide_map: GuideMap = $GuideMap

var coords := {
	start = Vector3i.ZERO,
	end = Vector3i.ZERO,
}


func _ready() -> void:
	guide_map.drag_complete.connect(await_confirmation)


func set_coords(start := Vector3i.ZERO, end := Vector3i.ZERO):
	coords.start = start
	coords.end = end


func await_confirmation(start_coord: Vector3i, end_coord: Vector3i) -> void:
	set_coords(start_coord, end_coord)
	
	# draw guide map cells (as they are automatically deleted when drag is finished)
	guide_map.set_cells_betweenv(start_coord, end_coord)


func complete_build() -> void:
	map.set_cells_betweenv(coords.start, coords.end)
	guide_map.clear()
	set_coords()


func _on_area_3d_input_event(_camera: Node, event: InputEvent, event_pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	guide_map.handle_drag(event, event_pos)


func _on_interface_button_pressed(which: String) -> void:
	match which:
		"CancelButton": guide_map.clear()
		"BuildButton": complete_build()


func _on_interface_entered() -> void:
	guide_map.disable()


func _on_interface_exited() -> void:
	guide_map.enable()
