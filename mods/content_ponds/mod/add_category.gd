extends AddBuyCategoriesModule

const ParentClass := "Buy.Data"


func get_data_paths() -> Array[String]:
	return [
		"content_ponds/json/ponds.json"
	]
