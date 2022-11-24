extends AddDesignsModule


const ParentClass := "Build.Data"


func get_data_paths() -> Array[String]:
	return [
		"content_siding_exterior/json/vertical_siding__white.json",
		"content_siding_exterior/json/vertical_siding__black.json",
	]
