class_name CollectGoalData
extends GoalData

@export var one_object: BuyableObjectData
@export var any_object_in_category: String


func _init(args := {}) -> void:
	super._init(args)
	BuyData.object_bought.connect(
		func(object: BuyableObjectData) -> void:
			if active and (
				(one_object and object == one_object) 
				or object.category_id == any_object_in_category
			): progress += 1
	)
