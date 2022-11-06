class_name AddBuyableObjectsModule
extends Module


func get_data_paths() -> Array[String]:
	return ["res://"]


func _on_ready(context: Node) -> void:
	for path in get_data_paths():
		var full_path = path if "res://" in path else "res://mods/" + path
		var buyable_object_json := FileAccess.open(full_path, FileAccess.READ)
		if buyable_object_json:
			var buyable_object := BuyableObjectParser.parse(context, buyable_object_json)
			if buyable_object: BuyData.add_object(buyable_object)
