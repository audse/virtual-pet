extends Node

@export var pets: Array[PetData] = []
@export var relationships: Array[RelationshipData] = []

@onready var pet_nodes: Array[Node]:
	get: return get_tree().get_nodes_in_group("pet")


func _ready() -> void:	
	RelationshipData.load_relationships()


func get_by_name(pet_name: String) -> PetData:
	return WorldData.pets \
		.filter(func(pet: PetData) -> bool: return pet.name.to_lower() == pet_name.to_lower()) \
		.pop_front()


func get_relationships(pet: PetData) -> Array[RelationshipData]:
	return relationships.filter(
		func(relationship: RelationshipData) -> bool: relationship.involves(pet)
	)


func get_relationship(pet_a: PetData, pet_b: PetData) -> RelationshipData:
	var relationship: RelationshipData = relationships \
		.filter(func(relationship: RelationshipData) -> bool: return relationship.involves(pet_a, pet_b)) \
		.front()
	if relationship: return relationship
	relationship = RelationshipData.new(pet_a, pet_b).setup()
	relationships.append(relationship)
	return relationship


func get_pet_node(pet: PetData) -> Node:
	return pet_nodes.filter(func(node: Node) -> bool: return node.pet_data == pet).pop_front()
