extends ActionItemScript


func run(_action_item: ActionItem, context: Node, args: Dictionary = {}) -> void:
	var pet_data := context.pet_data as PetData
	pet_data.personality_data.favorites_data.color = FavoritesData.FavoriteColor[args.color.to_upper()]
