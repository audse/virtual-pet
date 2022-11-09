class_name State
extends Object


signal exit_state(prev_state)
signal enter_state(next_state)

var reset_state: int = -1
var prev_state: int = reset_state
var state: int = reset_state

var target_node: Node = null


func _init(state_value: int = 0, reset_state_value = null) -> void:
	state = state_value
	if reset_state_value != null:
		reset_state = reset_state_value
	else:
		reset_state = state_value


func reset() -> void:
	if state != reset_state:
		set_to(reset_state)


func enter(next_state: int) -> void:
	prev_state = state
	state = next_state
	enter_state.emit(next_state)


func exit() -> void:
	exit_state.emit(state)


func set_to(next_state: int) -> void:
	if state != next_state:
		exit()
		enter(next_state)
