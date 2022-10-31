extends VBoxContainer


@onready var temp_button := %TempButton as Button

var buttons := {}

var bg_color := Color("#52525b")
var happy_color := Color("#d4d4d8")
var medium_color := Color("#a1a1aa")
var upset_color := Color("#71717a")


func _ready() -> void:
	if temp_button: temp_button.visible = false
	WorldData.pets_changed.connect(_render_buttons)
	_render_buttons()


func _render_buttons() -> void:
	for pet in WorldData.pets:
		if not pet.name in buttons:
			buttons[pet] = _make_pet_button(pet)
			add_child(buttons[pet])
			queue_redraw()
			
			buttons[pet].pressed.connect(
				func() -> void: _on_pet_button_pressed(pet)
			)
			pet.needs_data.need_changed.connect(
				func(_need: NeedsData.Need, _value: float) -> void:
					_update_state(buttons[pet], pet)
					queue_redraw()
			)


func _draw() -> void:
	for button in buttons.values():
		var state: float = button.get_meta("state")
		var arc_length := 360 * state
		var arc_position: Vector2 = button.position + button.size / 2
		var color := (
			happy_color if state > 0.7 
			else medium_color if state > 0.35 
			else upset_color
		)
		var arc_radius: float = max(button.size.x, button.size.y) / 2 + 4.0
		draw_arc(arc_position, arc_radius, deg_to_rad(180 - arc_length), deg_to_rad(-180), arc_length as int, bg_color, 8.0, true)
		draw_arc(arc_position, arc_radius + 4.0, deg_to_rad(180), deg_to_rad(180 - arc_length), arc_length as int, color, 12.0, true)


func _make_pet_button(pet_data: PetData) -> Button:
	var button := Button.new()
	button.disabled = true
	button.text = pet_data.name.substr(0, 2)
	button.set_meta("pet_data", pet_data)
	button.theme_type_variation = "CircleButton_PaddingSm"
	_update_state(button, pet_data)
	return button


func _update_state(button: Button, pet_data: PetData) -> void:
	var state := UseNeedsData.new(pet_data).overall_state
	button.set_meta("state", state)


func _on_pet_button_pressed(_pet_data: PetData) -> void:
	# TODO move camera to pet or bring up options or something
	pass
