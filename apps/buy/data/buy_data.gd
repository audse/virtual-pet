extends Node

signal category_added(BuyCategoryData)
signal object_added(BuyableObjectData)

var categories: Array[BuyCategoryData]
var objects: Array[BuyableObjectData]


func _ready() -> void:
	# Load category and object mods
	Modules.accept_modules(self)


func get_objects_in_category(category: BuyCategoryData) -> Array[BuyableObjectData]:
	return objects.filter(
		func(object: BuyableObjectData) -> bool: return object.category_id == category.id
	)


func add_category(category: BuyCategoryData) -> void:
	categories.append(category)
	category_added.emit(category)


func add_object(object: BuyableObjectData) -> void:
	objects.append(object)
	object_added.emit(object)
