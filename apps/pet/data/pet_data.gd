class_name PetData
extends SaveableResource

signal life_happiness_changed(value: float)
signal life_happiness_increased
signal life_happiness_decreased

@export_category("Basic info")
@export var name: String = ""
@export var birthday: String = ""
@export var random: bool = false
@export_range(0.0, 1.0, 0.01) var life_happiness: float = 0.0:
	set(value):
		var prev_happiness := life_happiness
		life_happiness = clamp(value, 0.0, 1.0)
		
		if life_happiness >= prev_happiness: life_happiness_increased.emit()
		else: life_happiness_decreased.emit()
		
		life_happiness_changed.emit(life_happiness)
		emit_changed()

@export_category("Data")
@export var animal_data :=  AnimalData.new()
@export var needs_data := NeedsData.new()
@export var wants_data := WantsData.new()
@export var personality_data := PersonalityData.new()
@export var command_data := CommandData.new()
@export var interface_data := PetInterfaceData.new()

@export_category("World info")
@export var world_coord := Vector2i.ZERO
var world_position: Vector3:
	get: return Vector3(
		world_coord.x as float * WorldData.grid_size as float,
		0,
		world_coord.y as float * WorldData.grid_size as float
	)


func _init(args: Dictionary = {}) -> void:
	for key in args.keys():
		if key in self: self[key] = args[key]
	
	if random:
		needs_data.generate_random()
		personality_data.generate_random()
	
	setup()


func _get_dir() -> String:
	return "pets"


func setup():
	wants_data.select_wants(self)
	wants_data.want_fulfilled.connect(increase_happiness)
	
	# TODO: this will eventually be replaced with a cuddle minigame thing
	# but for now clicking "cuddle" just increases your pets happiness
	interface_data.open_menu_pressed.connect(
		func(menu: PetInterfaceData.Menu) -> void:
			if menu == PetInterfaceData.Menu.CUDDLE:
				increase_happiness()
	)
	
	needs_data.changed.connect(emit_changed)
	wants_data.changed.connect(emit_changed)
	personality_data.changed.connect(emit_changed)
	personality_data.traits_data.changed.connect(emit_changed)
	personality_data.favorites_data.changed.connect(emit_changed)
	interface_data.changed.connect(emit_changed)
	
	# If loading a saved pet that was recently cuddled, the timer won't exist.
	# We need to make it now
	if interface_data.is_recently_cuddled:
		# TODO not sure if this is working
		Datetime.data.hour_changed.connect(
			func(_hr) -> void: interface_data.is_recently_cuddled = false,
			CONNECT_ONE_SHOT
		)
	
	super.setup()
	return self


func increase_happiness() -> void:
	life_happiness += randf_range(0.01, 0.05)


func decrease_happiness() -> void:
	life_happiness -= randf_range(0.005, 0.025)
