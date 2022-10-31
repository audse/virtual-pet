class_name FavoritesData
extends Resource

enum FavoriteColor {
	RED,
	ORANGE,
	YELLOW,
	GREEN,
	AQUA,
	BLUE,
	PINK,
	PURPLE,
	WHITE,
	BLACK,
	GREY,
	BROWN,
}

enum FavoritePlace {
	HOME,
	FOREST,
	BEACH,
	FRIENDS,
}

enum FavoriteFood {
	VEGETABLE,
	FRUIT,
	MEAT,
	DESSERT
}

@export var color: FavoriteColor
@export var place: FavoritePlace
@export var food: FavoriteFood


# TODO
# - toy
# - best friend


func generate_random() -> void:
	color = randi_range(0, 11) as FavoriteColor
	place = randi_range(0, 3) as FavoritePlace
	food = randi_range(0, 3) as FavoriteFood
