extends Control

const GoalScene := preload("goal.tscn")

@onready var controller := %ModalController
@onready var goals_container := %GoalsContainer as VBoxContainer

var goals := {}

func _ready() -> void:	
	update_goals()
	Game.goals_changed.connect(update_goals)


func update_goals() -> void:
	for goal in Game.goals:
		var id = goal.get_instance_id()
		if not id in goals:
			goals[id] = GoalScene.instantiate()
			goals_container.add_child(goals[id])
			goals[id].goal_data = goal
		goals[id].update_goal_data()


func open() -> void:
	visible = true
	Datetime.data.paused = true
	sort_goals()
	await controller.open()


func close() -> void:
	await controller.close()
	Datetime.data.paused = Datetime.data.prev_pause_state
	visible = true


func sort_goals() -> void:
	update_goals()
	Game.goals.sort_custom(
		func(a: GoalData, b: GoalData) -> bool:
			# TODO not sorting properly, should be ready-to-claim -> unfinished -> claimed
			if a.complete and not a.reward.is_claimed: return true
			else: return not a.complete
	)
	for goal_data in Game.goals:
		var id = goal_data.get_instance_id()
		goals[id].move_to_front()
	
