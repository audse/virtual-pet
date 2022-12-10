class_name SellGoalData
extends GoalData

@export var one_item: String = ""
@export var any_item_in_category: String = ""


func _init() -> void:
	BuyData.object_sold.connect(
		func(object: WorldObjectData) -> void:
			if active and (
				object.item_data.id == one_item
				or object.item_data.category_id == any_item_in_category
			): progress += 1
	)
