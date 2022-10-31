extends Control

@onready var button_map := {
	%NeedsButton: %Needs,
	%PersonalityButton: %Personality
}

@export var pet_data: PetData:
	set(value):
		pet_data = value
		update_pet_data()


func _ready():
	for button in button_map:
		button.pressed.connect(
			func():
				for other_button in button_map: 
					Themes.deselect(other_button)
					button_map[other_button].visible = false
				Themes.select(button)
				button_map[button].visible = true
		)
	
	update_pet_data()


func update_pet_data() -> void:
	if pet_data:
		%Needs.needs_data = pet_data.needs_data
		%Personality.personality_data = pet_data.personality_data
