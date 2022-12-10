class_name ItemData
extends SaveableResource

enum Flag {
	OWNABLE,
	CONSUMABLE,
}

enum Rarity {
	SUPER_COMMON = 0,
	COMMON = 1,
	UNCOMMON = 2,
	RARE = 3,
	SUPER_RARE = 4,
	ULTRA_RARE = 5
}

@export var id: String
@export var display_name: String
@export var category_id: String = ""
@export var description: String = ""
@export var colorway_id: String = ""
@export var rarity := 0
@export var flags: Array[Flag] = []

@export var use_data: ItemUseData
@export var physical_data: PhysicalItemData
@export var building_data: BuildingItemData

var is_rare: bool:
	get: return rarity >= Rarity.RARE


func _init(args := {}) -> void:
	for key in args.keys(): if key in self: self[key] = args[key]
