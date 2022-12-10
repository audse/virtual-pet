extends Node

signal category_added(BuyCategoryData)
signal object_added(BuyableItemData)

signal object_bought(BuyableItemData)
signal object_sold(WorldObjectData)


var categories: Array[BuyCategoryData] = []
var objects: Array[ItemData] = []


func _ready() -> void:
	# Load category and object mods
	Modules.accept_modules(self)


func get_objects_in_category(category: BuyCategoryData) -> Array[BuyableItemData]:
	return objects.filter(
		func(object: BuyableItemData) -> bool: return object.category_id == category.id
	)


func add_category(category: BuyCategoryData) -> void:
	categories.append(category)
	category_added.emit(category)


func add_object(object: ItemData) -> void:
	objects.append(object)
	object_added.emit(object)


func buy_object(object: BuyableItemData) -> void:
	if Fate.data.fate >= object.price:
		Fate.data.fate -= object.price
		object_bought.emit(object)


func sell_object(object: WorldObjectData) -> void:
	Fate.data.fate += object.sell_price
	WorldData.remove_object(object)
	object_sold.emit(object)
