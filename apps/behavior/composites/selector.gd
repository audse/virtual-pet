class_name Selector
extends Composite
@icon("../assets/selector.svg")

signal subtask_selected(Task)


func run() -> void:
	super.run()
	var task := current()
	if task: task.run()


func _on_subtask_succeeded(subtask: Task) -> void:
	subtask_selected.emit(subtask)
	reset_tasks()
	succeed()


func _on_subtask_failed(_subtask: Task) -> void:
	current_task += 1
	if current_task >= len(tasks):
		reset_tasks()
		fail()
	else: run()
