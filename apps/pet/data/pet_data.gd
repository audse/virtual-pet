class_name PetData
extends Resource

@export var name: String
@export var birthday: String

@export var animal_data: Resource
@export var needs_data: Resource
@export var personality_data: Resource


func _init(
	random := false,
	name_value := name,
	birthday_value := birthday,
	animal_data_value := AnimalData.new(),
	needs_data_value := NeedsData.new(),
	personality_data_value := PersonalityData.new()
) -> void:
	name = name_value
	birthday = birthday_value
	animal_data = animal_data_value
	needs_data = needs_data_value
	personality_data = personality_data_value
	
	if random:
		needs_data.generate_random()
		personality_data.generate_random()
