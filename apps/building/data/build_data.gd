extends Node

signal confirm_build
signal confirm_destroy

signal cancel

var state := BuildModeState.new()


func _ready() -> void:
	Game.Mode.enter_state.connect(
		func(_mode: GameModeState.Mode) -> void:
			state.set_to(BuildModeState.BuildState.READY)
	)
	Game.Mode.exit_state.connect(
		func(_mode: GameModeState.Mode) -> void:
			state.set_to(BuildModeState.BuildState.READY)
	)


func is_area_buildable(coords_2x2: Array[Vector3i]) -> bool:
	var coords_1x1 := CellMap.from_2x2_to_1x1_coords(coords_2x2)
	for coord in coords_1x1:
		if not coord in WorldData.blocks: return false
		if not WorldData.blocks[coord].is_buildable_by_building(state.current_building): return false
	return true
