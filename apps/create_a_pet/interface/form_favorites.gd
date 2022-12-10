extends Control

@export var favorites_data: FavoritesData:
	set(value):
		favorites_data = value
		update_data()

@onready var foods_container := %FoodsContainer as HFlowContainer
@onready var colors_container := %ColorsContainer as HFlowContainer
@onready var places_container := %PlacesContainer as HFlowContainer


var food_buttons := {}
var color_buttons := {}
var place_buttons := {}

func _ready() -> void:
	for food in FavoritesData.FavoriteFood.values():
		food_buttons[food] = Ui.tag_button(FavoritesData.get_food_name(food))
		food_buttons[food].pressed.connect(
			func() -> void: favorites_data.food = food
		)
		foods_container.add_child(food_buttons[food])
		
	for color in FavoritesData.FavoriteColor.values():
		color_buttons[color] = Ui.tag_button(FavoritesData.get_color_name(color), false, FavoritesData.FavoriteColorSwatch[color])
		color_buttons[color].pressed.connect(
			func() -> void: favorites_data.color = color
		)
		colors_container.add_child(color_buttons[color])
		
	for place in FavoritesData.FavoritePlace.values():
		place_buttons[place] = Ui.tag_button(FavoritesData.get_place_name(place))
		place_buttons[place].pressed.connect(
			func() -> void: favorites_data.place = place
		)
		places_container.add_child(place_buttons[place])


func update_data() -> void:
	%RandomButton.pressed.connect(favorites_data.generate_random)
	
	favorites_data.food_changed.connect(
		func(_val) -> void: update_buttons()
	)
	favorites_data.color_changed.connect(
		func(_val) -> void: update_buttons()
	)
	favorites_data.place_changed.connect(
		func(_val) -> void: update_buttons()
	)
	update_buttons()


func update_buttons() -> void:
	for food in food_buttons.keys():
		food_buttons[food].theme_type_variation = (
			"TagButton_Selected" if food == favorites_data.food
			else "TagButton"
		)
	for color in color_buttons.keys():
		color_buttons[color].theme_type_variation = (
			"TagButton_Selected" if color == favorites_data.color
			else "TagButton"
		)
	for place in place_buttons.keys():
		place_buttons[place].theme_type_variation = (
			"TagButton_Selected" if place == favorites_data.place
			else "TagButton"
		)


func validate() -> bool:
	return (
		favorites_data.food != -1
		and favorites_data.color != -1
		and favorites_data.place != -1
	)
