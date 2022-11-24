class_name DesignParser
extends Object

const required_fields := {
	id = TYPE_STRING,
	display_name = TYPE_STRING,
	albedo_texture = TYPE_STRING,
	design_type = TYPE_STRING,
	price = TYPE_FLOAT,
}

const optional_fields := {
	normal_texture = TYPE_STRING,
	texture_scale = TYPE_DICTIONARY,
	category_id = TYPE_STRING,
	description = TYPE_STRING,
	rarity = TYPE_FLOAT,
}


static func parse(context: Node, json_file: FileAccess) -> DesignData:
	var data: Dictionary = JSON.parse_string(json_file.get_as_text())
	
	var parser := ModParser.new(context, json_file, data, required_fields)
	if not parser.are_required_fields_ok(): return null
	if not parser.are_optional_fields_ok(optional_fields): return null
	
	data = parse_required_data(context, json_file, data)
	if (data.size() == 0): return null
	
	data = parse_optional_data(context, json_file, data, parser)
	return DesignData.new(data)


static func parse_required_data(_context: Node, json_file: FileAccess, data: Dictionary) -> Dictionary:
	# Convert `world_layer` param from string to enum
	DesignParser.check_design_type_name(json_file, data.design_type)
	data.design_type = DesignData.DesignType[data.design_type.to_upper()]
	
	# Load albedo texture
	if "albedo_texture" in data:
		if data.albedo_texture.contains("res://"): data.albedo_texture = load(data.albedo_texture)
		else: data.albedo_texture = load("res://mods/" + data.albedo_texture)
	
	data.price = int(data.price)
	
	return data


static func parse_optional_data(_context: Node, _json_file: FileAccess, data: Dictionary, parser: ModParser) -> Dictionary:
	# Load normal texture
	if "normal_texture" in data:
		if data.normal_texture.contains("res://"): data.normal_texture = load(data.normal_texture)
		else: data.normal_texture = load("res://mods/" + data.normal_texture)
	
	# Convert JSON floats to ints
	if "rarity" in data: data.rarity = int(data.rarity)
	
	# Convert dimensions Dictionary to Vector3
	if "texture_scale" in data: data.texture_scale = parser.parse_dimensions(data.texture_scale)
	
	return data


static func check_design_type_name(json_file: FileAccess, design_type: String) -> void:
	assert(design_type.to_upper() in DesignData.DesignType.keys(), ModError.report_string(
		json_file,
		ModError.Error.UNKNOWN_ENUM_KEY,
		"{provided} is not a valid `design_type` value. (`design_type` must be one of {options})".format({
			provided = design_type, 
			options = DesignData.DesignType.values()
		})
	))

	
