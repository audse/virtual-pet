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
	
	for building in WorldData.buildings:
		render_building(building)
	
	BuyData.object_bought.connect(_on_object_bought)
	Inventory.data.object_removed.connect(_on_object_removed_from_inventory)
	
	BuildData.state.enter_state.connect(
		func(mode: BuildModeState.BuildState) -> void:
			match mode:
				BuildModeState.BuildState.EDIT: render_building(BuildData.state.current_building)
	)
	
	WorldData.pet_added.connect(render_pet)


func render_object(object_data: WorldObjectData) -> WorldObject:
	return WorldRenderer.render_object_to(self, object_data)


static func render_object_to(parent: Node, object_data: WorldObjectData) -> WorldObject:
	object_data.instance = ObjectScene.instantiate()
	parent.add_child(object_data.instance)
	object_data.instance.update_object_data(object_data)
	return object_data.instance


func render_pet(pet_data: PetData) -> void:
	var pet := PetScene.instantiate()
	pet.pet_data = pet_data
	add_child(pet)


func render_building(building_data: BuildingData) -> void:
	if building_data and not building_data.instance:
		building_data.instance = BuildScene.instantiate()
		add_child(building_data.instance)
		building_data.instance.building_data = building_data


func _on_object_bought(object_data: BuyableItemData) -> void:
	var coord := WorldData.to_grid(Auto.get_screen_center_in_world())
	match object_data.menu:
		BuyCategoryData.Menu.BUY:
			var world_object := WorldObjectData.new({
				item_data = object_data,
				coord = WorldData.get_nearest_occupiable_coord(Vector2i(coord.x, coord.z))
			})
			WorldData.add_object(world_object)
			render_object(world_object)
		BuyCategoryData.Menu.BUILD:
			if BuildData.state.current_building:
				var building_object := WorldObjectData.new({
					item_data = object_data,
					coord = WorldData.get_nearest_occupiable_coord(Vector2i(coord.x, coord.z))
				})
				BuildData.state.current_building.add_object(building_object)


func _on_object_removed_from_inventory(object_data: WorldObjectData) -> void:
	WorldData.add_object(object_data)
	render_object(object_data)
