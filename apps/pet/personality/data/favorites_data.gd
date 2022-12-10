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

const FavoriteColorSwatch := {
	FavoriteColor.RED: Color("#fb7185"),
	FavoriteColor.ORANGE: Color("#e6926e"),
	FavoriteColor.YELLOW: Color("#fde68a"),
	FavoriteColor.GREEN: Color("#34d399"),
	FavoriteColor.AQUA: Color("#38bdf8"),
	FavoriteColor.BLUE: Color("#2577eb"),
	FavoriteColor.PINK: Color("#f589c1"),
	FavoriteColor.PURPLE: Color("#a78bfa"),
	FavoriteColor.WHITE: Color("#fafafa"),
	FavoriteColor.BLACK: Color("#3f3f46"),
	FavoriteColor.GREY: Color("#a1a1aa"),
	FavoriteColor.BROWN: Color("#8f5f53"),
}

signal color_changed(color: FavoriteColor)
signal place_changed(place: FavoritePlace)
signal food_changed(food: FavoriteFood)

@warning_ignore(int_assigned_to_enum)
@export var color: FavoriteColor = -1:
	set(value):
		color = value
		color_changed.emit(color)
		emit_changed()

@warning_ignore(int_assigned_to_enum)
@export var place: FavoritePlace = -1:
	set(value):
		place = value
		place_changed.emit(place)
		emit_changed()

@warning_ignore(int_assigned_to_enum)
@export var food: FavoriteFood = -1:
	set(value):
		food = value
		food_changed.emit(food)
		emit_changed()


# TODO
# - toy
# - best friend


func generate_random() -> void:
	color = randi_range(0, 11) as FavoriteColor
	place = randi_range(0, 3) as FavoritePlace
	food = randi_range(0, 3) as FavoriteFood


func get_fave_color_name() -> String:
	return FavoritesData.get_color_name(color)


func get_fave_food_name() -> String:
	return FavoritesData.get_food_name(food)


func get_fave_place_name() -> String:
	return FavoritesData.get_place_name(place)


static func get_color_name(i: FavoriteColor) -> String:
	var k = FavoriteColor.find_key(i)
	if k: return k.to_lower().replace("_", " ")
	else: return ""


static func get_food_name(i: FavoriteFood) -> String:
	var k = FavoriteFood.find_key(i)
	if k: return k.to_lower().replace("_", " ")
	else: return ""


static func get_place_name(i: FavoritePlace) -> String:
	var k = FavoritePlace.find_key(i)
	if k: return k.to_lower().replace("_", " ")
	else: return ""
