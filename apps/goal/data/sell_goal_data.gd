class_name SellGoalData
extends GoalData

@export var one_object: BuyableObjectData
@export var any_object_in_category: String


func _init() -> void:
	BuyData.object_sold.connect(
		func(object: WorldObjectData) -> void:
			if active and (
				(one_object and object.buyable_object_data == one_object) 
				or object.buyable_object_data.category_id == any_object_in_category
			): progress += 1
	)
