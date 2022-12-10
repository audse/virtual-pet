extends Node

signal goals_changed
signal goal_complete(goal: GoalData)

var Mode := GameModeState.new(
	GameModeState.Mode.LIVE, 
	GameModeState.Mode.LIVE
)

var goals: Array = []
var pet_colors := {}


func _enter_tree() -> void:
	Modules.accept_modules(self)


func _ready() -> void:
	load_goals()
	
	await get_tree().create_timer(2.0).timeout
	WorldData.pets[0].animal_data.color = Game.pet_colors.knitted__grey


func is_resource_in_use(resource: Resource) -> bool:
	if resource is InventoryData: return resource == Inventory.data
	if resource is FateData: return resource == Fate.data
	if resource is SettingsData: return resource == Settings.data
	if resource is GoalData: return resource in Game.goals
	if resource is WorldObjectData: return (
		resource in WorldData.objects
		or resource in Inventory.data.objects
	)
	if resource is PetData: return resource in WorldData.pets
	if resource is BuildingData: return resource in WorldData.buildings
	if resource is RelationshipData: return true # todo
	return false


func add_goal(goal_data: GoalData) -> void:
	goals.append(goal_data)
	goals_changed.emit()
	goal_data.completed.connect(func() -> void: goal_complete.emit(goal_data))


func save_goals() -> void:
	for goal in goals: goal.save_data()


func load_goals() -> void:
	for goal_path in Utils.open_or_make_dir("user://goals").get_files():
		var goal_data = load("user://goals/" + goal_path)
		if goal_data is GoalData: add_goal(goal_data.setup())
