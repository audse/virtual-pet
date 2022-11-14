class_name TraitsData
extends Resource

signal traits_changed

enum PersonalityTrait {
	FOODIE,
	LAZY,
	WILD,
	STUBBORN,
}

const num_possible_traits = 3

@export var traits: Array[PersonalityTrait]:
	set(value):
		traits = value
		traits_changed.emit()
		emit_changed()

@export var num_allowed_traits := 3


func generate_random() -> void:
	var indices := range(0, num_possible_traits)
	indices.shuffle()
	# TODO type error (GDscript bug)
#	traits = (indices
#		.slice(0, num_allowed_traits)
#		.map(func(t: int) -> PersonalityTrait: return t as PersonalityTrait))
