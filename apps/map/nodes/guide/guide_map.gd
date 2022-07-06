class_name GuideMap
extends Node

signal drag_complete(start_coord, to_coord)

const GuideTile = preload("guide_tile.gd")

@onready var cell_map = $GuideCellMap

var disabled := false
var debounce := 0
var debounce_max := 4
var start_coord := Vector3i.ZERO
var is_dragging: bool = false


func handle_drag(event: InputEvent, event_pos: Vector3) -> void:
	if event is InputEventScreenTouch and not disabled:
		is_dragging = event.pressed
		
		if is_dragging:
			start_coord = cell_map.world_to_map(event_pos)
		else:
			_on_complete(event_pos)

	if event is InputEventScreenDrag and not disabled:
		if debounce == debounce_max:
			redraw(event_pos)
			debounce = 0
		else: debounce += 1


func disable() -> void:
	disabled = true


func enable() -> void:
	disabled = false


func redraw(event_pos: Vector3) -> void:
	clear()
	debounce = 0
	await get_tree().process_frame
	set_cells_betweenv(start_coord, cell_map.world_to_map(event_pos))


func clear() -> void:
	cell_map.clear()


func set_cellv(coord: Vector3i, set_many: bool = false) -> Cell:
	return cell_map.set_cellv(coord, GuideTile.new(), set_many)


func set_cells_betweenv(start: Vector3i, end: Vector3i) -> void:
	for coord in cell_map.get_empty_coords_betweenv(start, end):
		set_cellv(coord, true)


func _on_complete(event_pos: Vector3) -> void:
	await get_tree().process_frame
	clear()
	drag_complete.emit(start_coord, cell_map.world_to_map(event_pos))
	start_coord = Vector3i.ZERO
