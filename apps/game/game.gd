extends Node

signal goals_changed

var Mode := GameModeState.new(
	GameModeState.Mode.LIVE, 
	GameModeState.Mode.LIVE
)


var goals: Array = []


func _ready() -> void:
	load_goals()


func is_resource_in_use(resource: Resource) -> bool:
	if resource is FateData: return resource == Fate.data
	if resource is SettingsData: return resource == Settings.data
	if resource is GoalData: return resource in Game.goals
	if resource is WorldObjectData: return resource in WorldData.objects
	if resource is PetData: return resource in WorldData.pets
	if resource is BuildingData: return resource in WorldData.buildings
	return false


func add_goal(goal_data: GoalData) -> void:
	goals.append(goal_data)
	goals_changed.emit()


func save_goals() -> void:
	for goal in goals: goal.save_data()


func load_goals() -> void:
	for goal_path in Utils.open_or_make_dir("user://goals").get_files():
		var goal_data = load("user://goals/" + goal_path)
		if goal_data is GoalData: add_goal(goal_data.setup())
