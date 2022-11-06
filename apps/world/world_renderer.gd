class_name WorldRenderer
extends Node3D
@icon("assets/icons/world_renderer.svg")

const PetScene = preload("res://apps/pet/scenes/pet.tscn")
const ObjectScene = preload("res://apps/world_object/scenes/world_object.tscn")

func _ready() -> void:
	for object in WorldData.objects:
		render_object(object)
	
	for pet in WorldData.pets:
		render_pet(pet)
	
	await get_tree().create_timer(1.5).timeout
	var new_obj := WorldObjectData.new({
		buyable_object_data = BuyData.objects[0],
		coord = Vector2i(-3, 3),
	})
	render_object(new_obj)


func render_object(object_data: WorldObjectData) -> void:
	var renderer := ObjectScene.instantiate()
	add_child(renderer)
	renderer.update_object_data(object_data)


func render_pet(pet_data: PetData) -> void:
	var pet := PetScene.instantiate()
	pet.pet_data = pet_data
	add_child(pet)
