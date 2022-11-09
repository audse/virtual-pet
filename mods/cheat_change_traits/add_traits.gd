extends ActionItemScript


func run(action_item: ActionItem, context: Node, extra_args := {}) -> void:
	var pet_data := context.pet_data as PetData
	# Add all traits
	if "all_traits" in extra_args and extra_args.all_traits:
		pet_data.personality_data.traits_data.traits = TraitsData.PersonalityTrait.values()
	# Add single trait
	else: pet_data.personality_data.traits_data.traits.append(action_item.id as TraitsData.PersonalityTrait)
