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
@export var category_id: DesignType
@export var price: int

@export_subgroup("Optional identity data")
@export var description: String = ""
@export var tags: Array[String] = []
@export var rarity := 0

@export_group("World data")
@export var albedo_texture: Resource
@export var normal_texture: Resource
