class_name WorldRenderer
extends Node3D
@icon("assets/icons/world_renderer.svg")

const BuildScene := preload("res://apps/building/scenes/build.tscn")
const PetScene = preload("res://apps/pet/scenes/pet.tscn")
const ObjectScene = preload("res://apps/world_object/scenes/world_object.tscn")


func _ready() -> void:
	for object in WorldData.objects:
		render_object(object)
	
	for pet in WorldData.pets:
		render_pet(pet)
	
	BuyData.object_bought.connect(_on_object_bought)
	
	BuildData.state.enter_state.connect(
		func(mode: BuildModeState.BuildState) -> void:
			match mode:
				BuildModeState.BuildState.CREATING, BuildModeState.BuildState.EDITING:
					render_building(BuildData.state.current_building)
	)


func render_object(object_data: WorldObjectData) -> WorldObject:
	var renderer := ObjectScene.instantiate()
	add_child(renderer)
	renderer.update_object_data(object_data)
	return renderer


func render_pet(pet_data: PetData) -> void:
	var pet := PetScene.instantiate()
	pet.pet_data = pet_data
	add_child(pet)


func _on_object_bought(object_data: BuyableObjectData) -> void:
	var world_object := WorldObjectData.new({
		buyable_object_data = object_data,
		coord = Vector2(4, 0)
	})
	WorldData.add_object(world_object)
	render_object(world_object)


func render_building(building_data: BuildingData) -> void:
	if not building_data.instance:
		building_data.instance = BuildScene.instantiate()
		add_child(building_data.instance)
		building_data.instance.building_data = building_data
