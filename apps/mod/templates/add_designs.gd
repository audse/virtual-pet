class_name AddDesignsModule
extends Module


func get_data_paths() -> Array[String]:
	return ["res://"]


func _on_ready(context: Node) -> void:
	for path in get_data_paths():
		var full_path = path if "res://" in path else "res://mods/" + path
		var design_json := FileAccess.open(full_path, FileAccess.READ)
		if design_json:
			var design := DesignParser.parse(context, design_json)
			if design: BuildData.add_design(design)
