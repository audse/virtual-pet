extends Node

const fate_data_path := "user://fate_data.tres"

var data := FateData.new()

var watched_pets: Array[PetData] = []


func _ready() -> void:
	load_data()
	
	# save every time fate changes
	data.fate_changed.connect(func(_value) -> void: save_data())
	
	connect_to_pet_list()
	WorldData.pets_changed.connect(connect_to_pet_list)


func connect_to_pet_list() -> void:
	for pet in WorldData.pets:
		if not pet in watched_pets: connect_to_pet(pet)


func connect_to_pet(pet: PetData) -> void:
	pet.command_data.receive_command.connect(
		func(_cmd) -> void: data.earn(FateData.ReasonForEarning.GAVE_COMMAND)
	)
	pet.life_happiness_increased.connect(data.earn.bind(FateData.ReasonForEarning.HAPPY_PET))
	
	# TODO this will be changed when we have an actual cuddle minigame
	pet.interface_data.open_menu_pressed.connect(
		func(menu: PetInterfaceData.Menu) -> void:
			if menu == PetInterfaceData.Menu.CUDDLE: Fate.data.earn(FateData.ReasonForEarning.CUDDLED)
	)
	
	# TODO other reasons
	
	watched_pets.append(pet)


func load_data() -> void:
	if ResourceLoader.exists(fate_data_path):
		data = ResourceLoader.load(fate_data_path)


func save_data() -> void:
	ResourceSaver.save(data, fate_data_path)
