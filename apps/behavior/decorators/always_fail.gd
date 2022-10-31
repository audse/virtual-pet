class_name AlwaysFail
extends Decorator
@icon("../assets/always_fail.svg")


func run() -> void:
	if child: child.run()
	fail()


func _on_subtask_succeeded(_subtask: Task) -> void:
	# Ignore succeeded subtasks
	pass
