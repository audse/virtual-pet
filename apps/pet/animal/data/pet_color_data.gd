class_name PetColorData
extends Resource

const DefaultBodyMaterial := preload("res://apps/pet/assets/materials/default_body_material.tres")
const DefaultDetailMaterial := preload("res://apps/pet/assets/materials/default_detail_material.tres")

@export var id: String = "grey"
@export var display_name: String = "Grey"
@export var animals: Array[AnimalData.Animal] = [
	AnimalData.Animal.DOG
]

@export_group("Materials")
@export var body_material: BaseMaterial3D = DefaultBodyMaterial
@export var detail_material: BaseMaterial3D = DefaultDetailMaterial


func _init(args := {}) -> void:
	for arg in args.keys(): if arg in self: self[arg] = args[arg]
