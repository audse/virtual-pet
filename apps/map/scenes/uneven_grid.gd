extends Node3D

signal awaiting_confirmation
signal build_complete

@onready var map: CellMap = $CellMap
@onready var guide_map: GuideMap = $GuideMap
@onready var actions_container: HBoxContainer = $MarginContainer/HBoxContainer
@onready var build_button: Button = %BuildButton
@onready var cancel_button: Button = %CancelButton

var coords := {
	start = Vector3i.ZERO,
	end = Vector3i.ZERO,
}

func _ready() -> void:
	guide_map.drag_complete.connect(await_confirmation)
	build_button.pressed.connect(complete_build)
	cancel_button.pressed.connect(guide_map.clear)


func _on_area_3d_input_event(_camera: Node, event: InputEvent, event_pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not actions_container.get_rect().has_point(event.position):
		guide_map.handle_drag(event, event_pos)


func await_confirmation(start_coord: Vector3i, end_coord: Vector3i) -> void:
	coords.start = start_coord
	coords.end = end_coord
	
	# draw guide map cells (as they are automatically deleted when drag is finished)
	guide_map.set_cells_betweenv(start_coord, end_coord)
	awaiting_confirmation.emit()


func complete_build() -> void:
	map.set_cells_betweenv(coords.start, coords.end)
	guide_map.clear()
	build_complete.emit()
