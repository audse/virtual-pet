class_name Task
extends Node
@icon("assets/task.svg")

signal running(Task)
signal failed(Task)
signal succeeded(Task)
signal cancelled(Task)
signal finished(Task)

enum Status {
	FRESH,
	RUNNING,
	SUCCEEDED,
	FAILED,
	CANCELLED
}

@export var disabled: bool = false
@export var log_this_task: bool = true

var tree: BehaviorTree
var status: Status = Status.FRESH
var depth := 0


func start() -> void:
	status = Status.FRESH
	
	for child in get_children():
		if child is Task:
			child.tree = tree
			child.depth = depth + 1
			child.running.connect(_on_subtask_running)
			child.succeeded.connect(_on_subtask_succeeded)
			child.failed.connect(_on_subtask_failed)
			child.cancelled.connect(_on_subtask_cancelled)
			
			child.start()


func reset() -> void:
	cancel()
	status = Status.FRESH


func run() -> void:
	logs("running...", false)
	
	status = Status.RUNNING
	running.emit(self)


func succeed() -> void:
	logs("succeeded!", true)
	
	status = Status.SUCCEEDED
	succeeded.emit(self)
	finished.emit(self)


func fail() -> void:
	logs("failed.", true)
	
	status = Status.FAILED
	failed.emit(self)
	finished.emit(self)


func cancel() -> void:
	logs("cancelled.", true)
	
	if status == Status.RUNNING:
		status = Status.CANCELLED
		
		for child in get_children():
			if child is Task: child.cancel()
		
		cancelled.emit(self)
		finished.emit(self)


func is_running() -> bool:
	return status == Status.RUNNING


func _on_subtask_running(_subtask: Task) -> void:
	pass


func _on_subtask_succeeded(_subtask: Task) -> void:
	pass


func _on_subtask_failed(_subtask: Task) -> void:
	pass


func _on_subtask_cancelled(_subtask: Task) -> void:
	pass


func logs(s: String, last_in_tree: bool = false) -> void:
	if tree and tree.logging_enabled and log_this_task:
		var indentations: Array[String] = []
		indentations.resize(depth)
		indentations.fill("│ ")
		var indent: String = indentations.reduce(
			func(accum, p): return accum + p, 
			""
		)
		
		var has_subtask = (
			(not last_in_tree)
			and (len(get_children().filter(
				func(child: Node): return child is Task and child.log_this_task
			)) > 0)
		)
		
		var line_1 = "╰" if last_in_tree else "├"
		var line_2 = "───" if not has_subtask else "─┬─"
		
		print(indent, line_1, line_2, "[", self.name, "]: ", s)
