extends ColorRect

var pet_data := PetData.new()


@onready var controller := $ModalController as ModalController

@onready var grid := %Grid as GridContainer

@onready var form_identity := %FormIdentity as Control
@onready var form_animal := %FormAnimal as Control
@onready var form_personality_attributes := %FormPersonalityAttributes as Control
@onready var form_traits := %FormTraits as Control
@onready var form_favorites := %FormFavorites as Control
@onready var forms := [form_identity, form_animal, form_personality_attributes, form_traits, form_favorites]

@onready var adopt_button := %AdoptButton as Button


func _ready():
	resize()
	
	pet_data.birthday = Datetime.data.now
	form_identity.pet_data = pet_data
	form_animal.animal_data = pet_data.animal_data
	form_personality_attributes.personality_data = pet_data.personality_data
	form_traits.traits_data = pet_data.personality_data.traits_data
	form_favorites.favorites_data = pet_data.personality_data.favorites_data
	
	adopt_button.pressed.connect(
		func() -> void:
			var is_ok: bool = forms.all(func(form) -> bool: return form.validate())
			if is_ok: 
				WorldData.add_pet(pet_data)
				close()
	)
	
	%BackButton.pressed.connect(close)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED: resize()


func resize() -> void:
	if not is_inside_tree() or not grid: return
	var area := Utils.get_display_area(self)
	var is_wide: bool = area.size.x > 1366
	grid.columns = 3 if is_wide else 1


func open() -> void:
	visible = true
	Datetime.data.paused = true
	controller.open()


func close() -> void:
	controller.close()
	await controller.closed
	visible = false
	Datetime.data.paused = Datetime.data.prev_pause_state
	
