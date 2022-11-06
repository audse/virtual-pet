extends ActionItemScript

const Colors = {
	red = FavoritesData.FavoriteColor.RED,
	orange = FavoritesData.FavoriteColor.ORANGE,
	yellow = FavoritesData.FavoriteColor.YELLOW,
	green = FavoritesData.FavoriteColor.GREEN,
	aqua = FavoritesData.FavoriteColor.AQUA,
	blue = FavoritesData.FavoriteColor.BLUE,
	pink = FavoritesData.FavoriteColor.PINK,
	purple = FavoritesData.FavoriteColor.PURPLE,
	white = FavoritesData.FavoriteColor.WHITE,
	black = FavoritesData.FavoriteColor.BLACK,
	grey = FavoritesData.FavoriteColor.GREY,
	brown = FavoritesData.FavoriteColor.BROWN,
}


func run(action_item: ActionItem, context: Node, args: Dictionary = {}) -> void:
	var pet_data := context.pet_data as PetData
	pet_data.personality_data.favorites_data.color = Colors[args.color]
