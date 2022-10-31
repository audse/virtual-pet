class_name WorldRenderer
extends Node3D
@icon("assets/icons/world_renderer.svg")

const PetScene = preload("res://apps/pet/scenes/pet.tscn")


func _ready() -> void:
	for object in WorldData.objects:
		render_object(object)
	
	for pet in WorldData.pets:
		render_pet(pet)


func render_object(object: WorldObjectData) -> void:
	add_child(WorldObjectRenderer.new(object))


func render_pet(pet_data: PetData) -> void:
	var pet := PetScene.instantiate()
	pet.pet_data = pet_data
	add_child(pet)
