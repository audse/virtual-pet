class_name UsePersonalityData
extends Object

var pet_data: PetData

var active: int:
	get: return pet_data.personality_data.active
var clean: int:
	get: return pet_data.personality_data.clean
var playful: int:
	get: return pet_data.personality_data.playful
var smart: int:
	get: return pet_data.personality_data.smart
var social: int:
	get: return pet_data.personality_data.social


func _init(pet_data_value: PetData) -> void:
	pet_data = pet_data_value


func debug_string() -> String:
	return DictRef.format({
		active = active,
		clean = clean,
		playful = playful,
		smart = smart,
		social = social,
	})


func is_foodie() -> bool:
	return TraitsData.PersonalityTrait.FOODIE in pet_data.personality_data.traits_data.traits


func is_lazy() -> bool:
	return TraitsData.PersonalityTrait.LAZY in pet_data.personality_data.traits_data.traits


func is_wild() -> bool:
	return TraitsData.PersonalityTrait.WILD in pet_data.personality_data.traits_data.traits


func is_stubborn() -> bool:
	return TraitsData.PersonalityTrait.STUBBORN in pet_data.personality_data.traits_data.traits
