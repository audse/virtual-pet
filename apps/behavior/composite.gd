class_name Composite
extends Task

@onready var tasks = get_tasks()
var current_task := 0


func current() -> Task:
	return (
		tasks[current_task]
		if len(tasks) > current_task
		else null
	)


func get_tasks() -> Array[Task]:
	return (get_children()
		.filter(func(child: Node) -> bool: return child is Task and not child.disabled)
		.map(func(child: Node) -> Task: return child as Task))


func reset_tasks() -> void:
	tasks = get_tasks()
	current_task = 0
