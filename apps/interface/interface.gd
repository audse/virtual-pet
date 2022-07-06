extends Control

signal entered
signal exited
signal button_pressed(which: String)


func enable_center_actions() -> void:
	%CenterActions.mouse_filter = MOUSE_FILTER_PASS


func disable_center_actions() -> void:
	%CenterActions.mouse_filter = MOUSE_FILTER_IGNORE


func _on_button_pressed(which: String) -> void:
	button_pressed.emit(which)


func _on_mouse_entered() -> void:
	entered.emit()


func _on_mouse_exited() -> void:
	exited.emit()
