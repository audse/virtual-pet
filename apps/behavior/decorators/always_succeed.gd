class_name AlwaysSucceed
extends Decorator
@icon("../assets/always_succeed.svg")


func run() -> void:
	if child: child.run()
	succeed()


func _on_subtask_failed(_subtask: Task) -> void:
	# Ignore failed subtasks
	pass
