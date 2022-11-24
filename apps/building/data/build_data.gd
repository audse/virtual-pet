extends Node

signal confirm_build
signal confirm_destroy

signal cancel

var state := BuildModeState.new()


var designs := {
	DesignData.DesignType.INTERIOR_WALL: [],
	DesignData.DesignType.EXTERIOR_WALL: [],
	DesignData.DesignType.FLOOR: [],
	DesignData.DesignType.ROOF: [],
}

var design_categories: Array[DesignCategoryData] = []


func _ready() -> void:
	Modules.accept_modules(self)
	
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
		if not WorldData.blocks[coord].is_buildable_by_building(state.current_building): return false
	return true


func add_design(design: DesignData) -> void:
	designs[design.design_type].append(design)


func add_design_category(category: DesignCategoryData) -> void:
	design_categories.append(category)
