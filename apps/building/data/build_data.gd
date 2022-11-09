extends Node

signal start_building
signal confirm_build

signal start_destroying
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


func is_area_buildable(coords: Array[Vector3i]) -> bool:
	for coord in coords:
		if not coord in WorldData.blocks: return false
		if not WorldData.blocks[coord].is_buildable: return false
	return true
