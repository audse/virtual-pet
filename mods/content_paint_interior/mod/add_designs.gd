extends AddDesignsModule


const ParentClass := "Build.Data"


func get_data_paths() -> Array[String]:
	return [
		"content_paint_interior/json/paint__white.json",
		"content_paint_interior/json/paint__grey.json",
		"content_paint_interior/json/paint__black.json",
	]
