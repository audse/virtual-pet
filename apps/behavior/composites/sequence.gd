class_name Sequence
extends Composite
@icon("../assets/sequence.svg")


func run():
	super.run()
	var task: Task = current()
	if task: task.run()


func _on_subtask_succeeded(_subtask: Task):
	current_task += 1
	if current_task >= len(tasks): succeed()
	else: run()


func _on_subtask_failed(_subtask: Task):
	current_task = 0
	fail()
