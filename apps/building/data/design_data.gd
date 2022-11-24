class_name DesignData
extends Resource

enum DesignType {
	INTERIOR_WALL,
	EXTERIOR_WALL,
	FLOOR,
	ROOF,
}


@export_group("Object identity")
@export var id: String
@export var display_name: String
@export var design_type: DesignType
@export var price: int

@export_subgroup("Optional")
@export var category_id: String = ""
@export var description: String = ""
@export var rarity := 0

@export_group("World data")
@export var albedo_texture: Resource

@export_subgroup("Optional")
@export var normal_texture: Resource
@export var texture_scale := Vector3.ONE


func _init(args: Dictionary = {}) -> void:
	for arg in args.keys():
		if arg in self: self[arg] = args[arg]
