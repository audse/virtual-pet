class_name UsePetData
extends Object

var pet_data: PetData


## `obedience` is the likelihood your pet will respond to your command.
## As your pet becomes happier, their obedience will grow.
var obedience: float:
	get: return lerp(pet_data.life_happiness, UseNeedsData.new(pet_data).overall_state, 0.25)


var happiness: float:
	get: return lerp(pet_data.life_happiness, UseNeedsData.new(pet_data).overall_state, 0.75)


func _init(pet_data_value: PetData) -> void:
	pet_data = pet_data_value


func will_obey_command() -> bool:
	return randf_range(0, obedience + 0.25) > 0.25
