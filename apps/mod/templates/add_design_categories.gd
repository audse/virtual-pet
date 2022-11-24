class_name AddDesignCategoriesModule
extends Module


func get_data_paths() -> Array[String]:
	return ["res://"]


func _on_ready(context: Node) -> void:
	for path in get_data_paths():
		var full_path = path if "res://" in path else "res://mods/" + path
		var design_category_json := FileAccess.open(full_path, FileAccess.READ)
		if design_category_json:
			var design_category := DesignCategoryParser.parse(context, design_category_json)
			if design_category: BuildData.add_design_category(design_category)
