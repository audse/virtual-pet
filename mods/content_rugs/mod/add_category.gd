extends AddBuyCategoriesModule

const ParentClass := "Buy.Data"


func get_data_paths() -> Array[String]:
	return [
		"content_rugs/json/rugs.json"
	]