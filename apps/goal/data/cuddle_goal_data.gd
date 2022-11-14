class_name CuddleGoalData
extends GoalData


func _init(args := {}) -> void:
	super._init(args)
	connect_pets()
	WorldData.pets_changed.connect(connect_pets)


func connect_pets() -> void:
	for pet in WorldData.pets:
		if not pet.interface_data.recently_cuddled_changed.is_connected(_on_recently_cuddled):
			pet.interface_data.recently_cuddled_changed.connect(_on_recently_cuddled)


func _on_recently_cuddled(_val) -> void:
	if active: progress += 1
