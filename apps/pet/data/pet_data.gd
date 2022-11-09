class_name PetData
extends Resource

signal life_happiness_changed(value: float)
signal life_happiness_increased
signal life_happiness_decreased

@export_category("Basic info")
@export var name: String
@export var birthday: String
@export var random: bool
@export_range(0.0, 1.0, 0.01) var life_happiness: float = 0.0:
	set(value):
		var prev_happiness := life_happiness
		life_happiness = clamp(value, 0.0, 1.0)
		
		if life_happiness >= prev_happiness: life_happiness_increased.emit()
		else: life_happiness_decreased.emit()
		
		life_happiness_changed.emit(life_happiness)
		save_data()

@export_category("Data")
@export var animal_data: AnimalData
@export var needs_data: NeedsData:
	set(value):
		needs_data = value
		needs_data.need_changed.connect(func(_need, _val): save_data())

@export var wants_data: WantsData:
	set(value):
		wants_data = value
		wants_data.wants_changed.connect(func(_val): save_data())

@export var personality_data: PersonalityData:
	set(value):
		personality_data = value
		personality_data.attribute_changed.connect(func(_attr, _val): save_data())
		personality_data.traits_data.traits_changed.connect(save_data)
		personality_data.favorites_data.color_changed.connect(func(_val): save_data())
		personality_data.favorites_data.place_changed.connect(func(_val): save_data())
		personality_data.favorites_data.food_changed.connect(func(_val): save_data())

@export var command_data: CommandData
@export var interface_data: PetInterfaceData:
	set(value):
		interface_data = value
		interface_data.recently_cuddled_changed.connect(func(_val): save_data())

@export_category("World info")
@export var world_coord := Vector2i.ZERO
var world_position: Vector3:
	get: return Vector3(
		world_coord.x as float * WorldData.grid_size as float,
		0,
		world_coord.y as float * WorldData.grid_size as float
	)

var defaults = {
	name = "",
	birthday = "",
	random = false,
	life_happiness = 0.0,
	animal_data = AnimalData.new(),
	needs_data = NeedsData.new(),
	wants_data = WantsData.new(),
	personality_data = PersonalityData.new(),
	command_data = CommandData.new(),
	interface_data = PetInterfaceData.new()
}

var data_path: String:
	get: return "user://pets/" + name + ".tres"


func _init(args: Dictionary = {}) -> void:
	for key in defaults.keys():
		if key in args: self[key] = args[key]
		elif self[key] == null: self[key] = defaults[key]
	
	if random:
		needs_data.generate_random()
		personality_data.generate_random()
	
	wants_data.select_wants(self)
	wants_data.want_fulfilled.connect(increase_happiness)
	
	# TODO: this will eventually be replaced with a cuddle minigame thing
	# but for now clicking "cuddle" just increases your pets happiness
	interface_data.open_menu_pressed.connect(
		func(menu: PetInterfaceData.Menu) -> void:
			if menu == PetInterfaceData.Menu.CUDDLE:
				increase_happiness()
	)


func increase_happiness() -> void:
	life_happiness += randf_range(0.01, 0.05)


func decrease_happiness() -> void:
	life_happiness -= randf_range(0.005, 0.025)


func save_data() -> void:
	print("[Pet: " + name + "] Saving...")
	ResourceSaver.save(self, data_path)
