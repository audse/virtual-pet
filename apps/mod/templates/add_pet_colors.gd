class_name AddPetColorsModule
extends Module


func get_data_paths() -> Array[String]:
	return []


func _on_ready(context: Node) -> void:
	for path in get_data_paths():
		var full_path = path if "res://" in path else "res://mods/" + path
		if ".tres" in full_path or ".res" in full_path:
			var color: PetColorData = load(full_path)
			if color: Game.pet_colors[color.id] = color
		else:
			var json := FileAccess.open(full_path, FileAccess.READ)
			if not json: continue
			var color := PetColorParser.parse(context, json)
			if color: Game.pet_colors[color.id] = color

