extends AddBuyCategoriesModule

const ParentClass := "Buy.Data"


func get_data_paths() -> Array[String]:
	return [
		"content_open_doorways/json/open_doorways.json"
	]
