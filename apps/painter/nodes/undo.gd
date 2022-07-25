extends Node

signal updated

class Action:
	var pixels: Array[Sprite2D]
	var action: PaintState.Action
	
	func _init(t: PaintState.Action, p: Array[Sprite2D]) -> void:
		action = t
		pixels = p


var undo_stack: Array[Action] = []
var redo_stack: Array[Action] = []


func _ready() -> void:
	updated.emit()


func add(type: PaintState.Action, pixels: Array[Sprite2D]) -> void:
	undo_stack.append(Action.new(type, pixels))
	redo_stack = []
	updated.emit()


func prev() -> Action:
	return undo_stack.back()


func undo() -> Action:
	var action: Action = undo_stack.pop_back()
	redo_stack.append(action)
	updated.emit()
	return action


func redo() -> Action:
	var action: Action = redo_stack.pop_back()
	undo_stack.append(action)
	updated.emit()
	return action
	

func can_undo() -> bool:
	return len(undo_stack) > 0


func can_redo() -> bool:
	return len(redo_stack) > 0
