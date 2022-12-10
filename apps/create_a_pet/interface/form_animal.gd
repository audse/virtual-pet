extends VBoxContainer

@export var animal_data: AnimalData:
	set(value):
		animal_data = value
		update_data()

@onready var dog_button := %DogButton as Button
@onready var animal_buttons := {
	AnimalData.Animal.DOG: dog_button
}

@onready var white_button := %WhiteButton as Button
@onready var grey_button := %GreyButton as Button
@onready var black_button := %BlackButton as Button
@onready var color_buttons := {
	white = white_button,
	grey = grey_button,
	black = black_button
}

func _ready() -> void:
	update_data()


func update_data() -> void:
	if not is_inside_tree() or not animal_data: return
	
	for animal in animal_buttons.keys():
		animal_buttons[animal].pressed.connect(
			func() -> void: animal_data.animal = animal
		)
	for color in color_buttons.keys():
		color_buttons[color].pressed.connect(
			func() -> void: animal_data.color = color
		)
	
	animal_data.animal_changed.connect(func(_val) -> void: update_buttons())
	animal_data.color_changed.connect(func(_val) -> void: update_buttons())
	
	update_buttons()
	
	
func update_buttons() -> void:
	for animal in animal_buttons.keys():
		animal_buttons[animal].button_pressed = animal == animal_data.animal 
	
#	for color in color_buttons.keys():
#		color_buttons[color].theme_type_variation = (
#			"TagButton_Selected" if color == animal_data.color
#			else "TagButton"
#		)


func validate() -> bool:
	return animal_data.animal != -1 and animal_data.color.length() > 0
