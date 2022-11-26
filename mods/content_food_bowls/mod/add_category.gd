class_name AddCategoryFoodBowl
extends AddBuyCategoriesModule

const ParentClass := "Buy.Data"


func get_data_paths() -> Array[String]:
	return [
		"content_food_bowls/json/food_bowls.json"
	]
