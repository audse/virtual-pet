class_name TraitsData
extends Resource


enum PersonalityTrait {
	FOODIE,
	LAZY,
	WILD,
	STUBBORN,
}

const num_possible_traits = 3

@export var traits: Array[PersonalityTrait]
@export var num_allowed_traits := 3


func generate_random() -> void:
	var indices := range(0, num_possible_traits)
	indices.shuffle()
	traits = (indices
		.slice(0, num_allowed_traits)
		.map(func(t: int) -> PersonalityTrait: return t as PersonalityTrait))
