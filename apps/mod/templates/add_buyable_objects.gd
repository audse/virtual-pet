class_name AddBuyableItemsModule
extends Module


func get_data_paths() -> Array[String]:
	return ["res://"]


func _on_ready(context: Node) -> void:
	for path in get_data_paths():
		var full_path = path if "res://" in path else "res://mods/" + path
		var item_json := FileAccess.open(full_path, FileAccess.READ)
		if item_json:
			var item := ItemParser.parse(context, item_json)
			if item and item is BuyableItemData: BuyData.add_object(item)
