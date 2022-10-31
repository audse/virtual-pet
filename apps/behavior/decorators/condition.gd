class_name Condition
extends Decorator
@icon("../assets/condition.svg")


func run() -> void:
	if child and check():
		child.run()
	else:
		fail()


func check() -> bool:
	return true
