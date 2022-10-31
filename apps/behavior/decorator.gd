class_name Decorator
extends Task


@onready var child: Task = (
	get_children()
		.filter(func(child: Node) -> bool: return child is Task and not child.disabled)[0]
	if get_child_count() > 0
	else null
)


func run():
	if child: child.run()
	super.run()


func _on_subtask_succeeded(_subtask: Task):
	succeed()


func _on_subtask_failed(_subtask: Task):
	fail()


func _on_subtask_cancelled(_subtask: Task):
	cancel()
