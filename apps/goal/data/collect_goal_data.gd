class_name CollectGoalData
extends GoalData

@export var one_item: String = ""
@export var any_item_in_category: String = ""


func _init(args := {}) -> void:
	super._init(args)
	BuyData.object_bought.connect(
		func(object: BuyableItemData) -> void:
			if active and (
				object.id == one_item
				or object.category_id == any_item_in_category
			): progress += 1
	)
