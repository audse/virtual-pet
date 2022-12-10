class_name PetColorParser
extends Object

const required_fields := {
	id = TYPE_STRING,
	display_name = TYPE_STRING,
	animals = TYPE_ARRAY,
}

const optional_fields := {
	body_material = TYPE_STRING,
	detail_material = TYPE_STRING,
}


static func parse(context: Node, json_file: FileAccess) -> PetColorData:
	var data: Dictionary = JSON.parse_string(json_file.get_as_text())
	
	var parser := ModParser.new(context, json_file, data, required_fields)
	if not parser.are_required_fields_ok(): return null
	if not parser.are_optional_fields_ok(optional_fields): return null
	
	data = parse_required_data(context, json_file, data)
	data = parse_optional_data(context, json_file, data)
	
	return PetColorData.new(data)


static func parse_required_data(_context: Node, _json_file: FileAccess, data: Dictionary) -> Dictionary:
	data.animals = data.animals.map(
		func(animal: String) -> AnimalData.Animal: return AnimalData.Animal[animal.to_upper()]
	)
	return data


static func parse_optional_data(_context: Node, _json_file: FileAccess, data: Dictionary) -> Dictionary:
	# Load materials
	if "body_material" in data:
		if data.body_material.contains("res://"): data.body_material = load(data.body_material)
		else: data.body_material = load("res://mods/" + data.body_material)
	if "detail_material" in data:
		if data.detail_material.contains("res://"): data.detail_material = load(data.detail_material)
		else: data.detail_material = load("res://mods/" + data.detail_material)
	return data
