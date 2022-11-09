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

signal color_changed(color: FavoriteColor)
signal place_changed(place: FavoritePlace)
signal food_changed(food: FavoriteFood)

@export var color: FavoriteColor:
	set(value):
		color = value
		color_changed.emit(color)

@export var place: FavoritePlace:
	set(value):
		place = value
		place_changed.emit(place)

@export var food: FavoriteFood:
	set(value):
		food = value
		food_changed.emit(food)


# TODO
# - toy
# - best friend


func generate_random() -> void:
	color = randi_range(0, 11) as FavoriteColor
	place = randi_range(0, 3) as FavoritePlace
	food = randi_range(0, 3) as FavoriteFood
