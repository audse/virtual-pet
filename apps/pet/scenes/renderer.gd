class_name PetRenderer
extends Node3D

@export var pet_data: PetData:
	set(value):
		pet_data = value
		update()

var DogWalkAnim := preload("res://apps/pet/assets/animations/dog_walk_cycle.res")

@onready var model := get_child(0)
@onready var animation_player: AnimationPlayer = Utils.first_child_of_type(model, "AnimationPlayer")
@onready var meshes: Array[Node] = model.find_children("", "MeshInstance3D")


func _ready() -> void:
	DogWalkAnim.length = 1.05
	update()
	

func update() -> void:
	if is_inside_tree() and pet_data:
		pet_data.animal_data.color_changed.connect(
			func(_color) -> void: update_materials()
		)
		update_materials()


func update_materials() -> void:
	if pet_data.animal_data.color:
		var body_surface_name: String = {
			AnimalData.Animal.DOG: "Dog"
		}[pet_data.animal_data.animal]

		var detail_surface_name: String = {
			AnimalData.Animal.DOG: "Eyelids"
		}[pet_data.animal_data.animal]
		
		for mesh in meshes:
			var body_surface := (mesh.mesh as ArrayMesh).surface_find_by_name(body_surface_name)
			if body_surface != -1: mesh.set_surface_override_material(body_surface, pet_data.animal_data.color.body_material)
			
			var detail_surface := (mesh.mesh as ArrayMesh).surface_find_by_name(detail_surface_name)
			if detail_surface != -1: mesh.set_surface_override_material(detail_surface, pet_data.animal_data.color.detail_material)
	else:
		pet_data.animal_data.color = PetColorData.new()
