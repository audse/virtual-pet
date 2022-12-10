class_name BuildModeState
extends State

signal current_building_changed(BuildingData)

enum BuildState {
	READY,
	EDIT,
	BUILDING_WALLS,
	DESTROYING_WALLS,
}

var current_building: BuildingData :
	set(value):
		current_building = value
		current_building_changed.emit(current_building)


func _init() -> void:
	super._init(BuildState.READY, BuildState.READY)


func enter(next_state: int) -> void:
	match next_state:
		BuildState.READY: current_building = null
	super.enter(next_state)


func cancel() -> void:
	match state:
		BuildState.BUILDING_WALLS, BuildState.DESTROYING_WALLS:
			edit(current_building)
		_:  set_to(BuildState.READY)
	BuildData.cancel.emit()


func start_new() -> void:
	edit(BuildingData.new().setup())


func edit(data: BuildingData) -> void:
	print("[", data.data_path if data else "null", "]: Editing...")
	current_building = data
	WorldData.add_building(current_building)
	set_to(BuildState.EDIT)
