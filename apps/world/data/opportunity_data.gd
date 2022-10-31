class_name OppportunityData
extends Resource
	
class Goal:
	enum GoalType {
		FULFILL_NEED,
		FULFILL_WANT,
		EXPRESS_PERSONALITY,
	}
	
	var type: GoalType
	var detail: String
	
	func _init(type_value: GoalType, detail_value := "") -> void:
		type = type_value
		detail = detail_value

var goal: Goal
var nearby_pet: PetData
var nearby_object: WorldObjectData

func _init(data: Dictionary) -> void:
	match data:
		{ "nearby_object", .. }:
			nearby_object = data.nearby_object
			continue
		{ "nearby_pet", .. }:
			nearby_pet = data.nearby_pet
			continue
		{ "goal", .. }:
			goal = data.goal
