class_name BehaviorTree
extends Task
@icon("assets/behavior_tree.svg")

@export var log: bool = false

@onready var child: Task = (
	get_children()
		.filter(func(child: Node) -> bool: return child is Task and not child.disabled)[0]
	if get_child_count() > 0
	else null
)


func start():
	tree = self
	super.start()


func run():
	super.run()
	if child: child.run()


func _on_subtask_succeeded(_subtask: Task) -> void:
	succeed()


func _on_subtask_failed(_subtask: Task) -> void:
	fail()
