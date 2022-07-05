class_name GuideMap
extends CellMap

signal drag_complete(start_coord, to_coord)

const GuideTile = preload("guide_tile.gd")

var debounce := 0
var debounce_max := 4
var start_coord := Vector3i.ZERO
var is_dragging: bool = false


func handle_drag(event: InputEvent, event_pos: Vector3) -> void:
	if event is InputEventScreenTouch:
		is_dragging = event.pressed
		
		if is_dragging:
			start_coord = world_to_map(event_pos)
		else:
			_on_complete(event_pos)

	if event is InputEventScreenDrag:
		if debounce == debounce_max:
			redraw(event_pos)
			debounce = 0
		else: debounce += 1


func set_cellv(coord: Vector3i, _tile: MeshInstance3D = null, set_many: bool = false) -> Cell:
	return super.set_cellv(coord, GuideTile.new(), set_many)


func redraw(event_pos: Vector3) -> void:
	clear()
	debounce = 0
	await get_tree().process_frame
	set_cells_betweenv(start_coord, world_to_map(event_pos), null)


func _on_complete(event_pos: Vector3) -> void:
	await get_tree().process_frame
	clear()
	emit_signal("drag_complete", start_coord, world_to_map(event_pos))
	start_coord = Vector3i.ZERO

