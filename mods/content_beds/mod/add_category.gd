extends AddBuyCategoriesModule

const ParentClass := "Buy.Data"


func get_data_paths() -> Array[String]:
	return [
		"content_beds/json/beds.json"
	]
