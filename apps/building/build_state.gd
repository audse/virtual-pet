class_name BuildModeState
extends State

enum BuildState {
	READY,
	CREATING,
	EDITING,
	BUILDING_WALLS,
	DESTROYING_WALLS,
}

var current_building: BuildingData 


func _init() -> void:
	super._init(BuildState.READY, BuildState.READY)


func enter(next_state: int) -> void:
	match next_state:
		BuildState.CREATING: current_building = BuildingData.new()
		BuildState.BUILDING_WALLS: BuildData.start_building.emit()
		BuildState.DESTROYING_WALLS: BuildData.start_destroying.emit()
		_: current_building = null
	super.enter(next_state)


func cancel() -> void:
	match state:
		BuildState.BUILDING_WALLS, BuildState.DESTROYING_WALLS:
			set_to(prev_state)
		_:  set_to(BuildState.READY)
	BuildData.cancel.emit()
