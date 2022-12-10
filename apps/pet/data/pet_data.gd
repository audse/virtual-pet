class_name PetData
extends SaveableResource

signal life_happiness_changed(value: float)
signal life_happiness_increased
signal life_happiness_decreased

@export_category("Basic info")
@export var name: String = ""
@export var birthday: int = 0
@export var random: bool = false
@export_range(0.0, 1.0, 0.01) var life_happiness: float = 0.0:
	set(value):
		var prev_happiness := life_happiness
		life_happiness = clamp(value, 0.0, 1.0)
		
		if life_happiness >= prev_happiness: life_happiness_increased.emit()
		else: life_happiness_decreased.emit()
		
		life_happiness_changed.emit(life_happiness)
		emit_changed()
@export var parent: int = -1

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
	wants_data.want_fulfilled.connect(func(_want): increase_happiness())
	
	# TODO: this will eventually be replaced with a cuddle minigame thing
	# but for now clicking "cuddle" just increases your pets happiness
	interface_data.open_menu_pressed.connect(
		func(menu: PetInterfaceData.Menu) -> void:
			if menu == PetInterfaceData.Menu.CUDDLE:
				increase_happiness()
	)
	animal_data.changed.connect(emit_changed)
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


func get_relationship(pet: PetData) -> RelationshipData:
	return PetManager.get_relationship(self, pet)


func increase_fondness(pet: PetData) -> void:
	get_relationship(pet).increase_fondness()


func decrease_fondness(pet: PetData) -> void:
	get_relationship(pet).decrease_fondness()


func get_relationships() -> Array[RelationshipData]:
	return PetManager.get_relationships(self)


func get_friends() -> Array[PetData]:
	var relationships := get_relationships()
	relationships.sort_custom(
		func(a: RelationshipData, b: RelationshipData) -> bool:
			return a.fondness > b.fondness
	)
	return relationships \
		.filter(func(relationship: RelationshipData) -> bool: return relationship.fondness > 0.5) \
		.map(func(relationship: RelationshipData) -> PetData: return relationship.other(self))


func get_best_friend() -> PetData:
	return get_friends().front()


func is_friends_with(pet: PetData) -> bool:
	return get_relationship(pet).fondness > 0.5
