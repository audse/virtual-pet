class_name GuideMap
extends Node

signal drag_complete(start_coord, to_coord)

const GuideTile := preload("guide_tile.gd")

@onready var cell_map := $GuideCellMap as CellMap

var disabled := true
var debounce := 0
var debounce_max := 2


var start_coord := Vector3i.ZERO
var end_coord := Vector3i.ZERO


var prev_start_coord := Vector3i.ZERO
var prev_end_coord := Vector3i.ZERO

var is_dragging: bool = false


func _ready() -> void:
	BuildData.confirm_build.connect(release)
	BuildData.confirm_destroy.connect(release)
	BuildData.state.exit_state.connect(
		func(_state: BuildModeState.BuildState) -> void:
			release()
			clear()
	)


func handle_drag(event: InputEvent, event_pos: Vector3) -> void:
	if not disabled:
		if event is InputEventScreenTouch:
			is_dragging = event.pressed
	
			end_coord = cell_map.world_to_map(event_pos)
			
			if event.pressed: start()
			else: complete()

		if event is InputEventScreenDrag:
			if debounce == debounce_max:
				end_coord = cell_map.world_to_map(event_pos)
				redraw()
			else: debounce += 1


func disable() -> void:
	disabled = true
	release()


func enable() -> void:
	disabled = false
	release()


func redraw() -> void:
	clear()
	debounce = 0
	await get_tree().process_frame
	set_cells_betweenv(start_coord, end_coord)
	prev_start_coord = start_coord
	prev_end_coord = end_coord


func start() -> void:
	is_dragging = true
	debounce = 0
	start_coord = end_coord


func release() -> void:
	is_dragging = false
	start_coord = Vector3i.ZERO
	end_coord = Vector3i.ZERO
	debounce = 0
	clear()


func clear() -> void:
	cell_map.clear()


func set_cellv(coord: Vector3i, set_many: bool = false) -> Cell:
	return cell_map.set_cellv(coord, GuideTile.new(coord), set_many)


func set_cells_betweenv(s: Vector3i, e: Vector3i) -> void:
	for coord in cell_map.get_empty_coords_betweenv(s, e):
		set_cellv(coord, true)


func set_cells(cells: Array[Vector3i]) -> void:
	for cell in cells: set_cellv(cell, true)


func complete() -> void:
	await get_tree().process_frame
	drag_complete.emit(start_coord, end_coord)
	prev_start_coord = start_coord
	prev_end_coord = end_coord
