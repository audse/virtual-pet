class_name Chance
extends Decorator
@icon("../assets/chance.svg")


@export_range(0, 100, 0.1) var percent_chance := 50.0


func run() -> void:
	var success: bool = randf_range(0, 100) <= percent_chance
	
	logs("{0}% chance of task success".format([percent_chance]))
	
	if success: child.run()
	else: fail()
