class_name TraitsData
extends Resource

signal traits_changed

enum PersonalityTrait {
	FOODIE,
	LAZY,
	WILD,
	STUBBORN,
}

const NUM_TRAITS := 4

@export var traits: Array:
	set(value):
		traits = value
		traits_changed.emit()
		emit_changed()

@export var num_allowed_traits := 3


func generate_random() -> void:
	var indices := range(0, NUM_TRAITS)
	indices.shuffle()
	traits = (indices.slice(0, num_allowed_traits))


func add_trait(t: PersonalityTrait) -> void:
	if traits.size() < num_allowed_traits:
		traits.append(t)
		traits_changed.emit()


func remove_trait(t: PersonalityTrait) -> void:
	if t in traits: 
		traits.erase(t)
		traits_changed.emit()


func toggle_trait(t: PersonalityTrait) -> void:
	if t in traits: remove_trait(t)
	else: add_trait(t)


static func get_trait_name(i: int) -> String:
	return PersonalityTrait.find_key(i).to_lower().replace("_", " ")
