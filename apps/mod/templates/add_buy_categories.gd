class_name AddBuyCategoriesModule
extends Module


func get_data_paths() -> Array[String]:
	return ["res://"]


func _on_ready(context: Node) -> void:
	for path in get_data_paths():
		var full_path = path if "res://" in path else "res://mods/" + path
		var buy_category_json := FileAccess.open(full_path, FileAccess.READ)
		if buy_category_json:
			var buy_category := BuyCategoryParser.parse(context, buy_category_json)
			if buy_category: BuyData.add_category(buy_category)
