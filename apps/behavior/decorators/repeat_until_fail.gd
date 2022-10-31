class_name RepeatUntilFail
extends Decorator
@icon("../assets/repeat_until_fail.svg")

@export var limit := -1

var count := 0
var repeating := false


func run() -> void:
	if not repeating and child:
		repeating = true
		child.run()


func _on_subtask_succeeded(_subtask: Task) -> void:
	count += 1
	
	if limit > 0 and count >= limit:
		count = 0
		repeating = false
		succeed()
	
	if repeating and child:
		child.run()


func _on_subtask_failed(_subtask: Task) -> void:
	repeating = false
	fail()
