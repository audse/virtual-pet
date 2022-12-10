class_name ItemParser
extends Object

const required_fields := {
	id = TYPE_STRING,
	display_name = TYPE_STRING,
}

const optional_fields := {
	mesh = TYPE_STRING,
	world_layer = TYPE_STRING,
	price = TYPE_FLOAT,
	category_id = TYPE_STRING,
	menu = TYPE_STRING,
	description = TYPE_STRING,
	colorway_id = TYPE_STRING,
	dimensions = TYPE_DICTIONARY,
	mesh_scale = TYPE_DICTIONARY,
	rarity = TYPE_FLOAT,
	collision_shape = TYPE_STRING,
	flags = TYPE_ARRAY,
	fulfills_needs = TYPE_ARRAY,
	total_uses = TYPE_FLOAT,
	mesh_script = TYPE_STRING,
	intersection_type = TYPE_STRING,
	intersection_rect = TYPE_DICTIONARY,
	stackable = TYPE_BOOL,
	walkable = TYPE_BOOL,
}


static func parse(context: Node, json_file: FileAccess) -> ItemData:
	var data: Dictionary = JSON.parse_string(json_file.get_as_text())
	
	var parser := ModParser.new(context, json_file, data, required_fields)
	if not parser.are_required_fields_ok(): return null
	if not parser.are_optional_fields_ok(optional_fields): return null
	
	data = parse_optional_data(context, json_file, data, parser)
	data = parse_buyable_item_data(json_file, parser, data)
	data.physical_data = parse_physical_item_data(json_file, parser, data)
	data.building_data = parse_building_item_data(json_file, parser, data)
	data.use_data = parse_use_data(json_file, parser, data)
	
	if "price" in data: return BuyableItemData.new(data)
	else: return ItemData.new(data)


static func parse_optional_data(_context: Node, _json_file: FileAccess, data: Dictionary, _parser: ModParser) -> Dictionary:
	
	# Parse flags
	if "flags" in data: data.flags = data.flags.map(
		func(flag: String) -> BuyableItemData.Flag: return BuyableItemData.Flag[flag.to_upper()]
	)
	
	# Convert JSON floats to ints
	if "rarity" in data: data.rarity = int(data.rarity)
	
	return data


static func check_layer_name(json_file: FileAccess, layer: String) -> void:
	assert((layer.to_upper() + "_LAYER") in WorldObjectData.Layer.keys(), ModError.report_string(
		json_file,
		ModError.Error.UNKNOWN_ENUM_KEY,
		"{0} is not a valid `world_layer` value. (`world_layer` must be one of [`BUILDING`, `FLOOR_OBJECT`, `WALL_OBJECT`, `FOLIAGE`])".format([layer])
	))


static func parse_buyable_item_data(_json_file: FileAccess, _parser: ModParser, data: Dictionary) -> Dictionary:
	if "menu" in data and data.menu in BuyCategoryData.Menu: data.menu = BuyCategoryData.Menu[data.menu.to_upper()]
	data.price = int(data.price)
	return data

	
static func parse_physical_item_data(json_file: FileAccess, parser: ModParser, data: Dictionary) -> PhysicalItemData:
	if not "world_layer" in data or not "mesh" in data: return null
	
	# Convert `world_layer` param from string to enum
	ItemParser.check_layer_name(json_file, data.world_layer)
	data.world_layer = WorldObjectData.Layer[data.world_layer.to_upper() + "_LAYER"]
	
	# Load mesh file
	if data.mesh.contains("res://"): data.mesh = load(data.mesh)
	else: data.mesh = load("res://mods/" + data.mesh)
	
	# Convert dimension width, height, and depth to `Vector3i`
	if "dimensions" in data: data.dimensions = Vector3i(parser.parse_dimensions(data.dimensions))
	else: data.dimensions = Vector3i.ONE
	
	# Load collision shape file
	if "collision_shape" in data:
		if data.collision_shape.contains("res://"): data.collision_shape = load(data.collision_shape)
		else: data.collision_shape = load("res://mods/" + data.collision_shape)
	
	# Convert scale of mesh to Vector3
	if "mesh_scale" in data: data.mesh_scale = parser.parse_position(data.mesh_scale, Vector3.ONE)
	
	# Load the script for the `MeshInstance3D`
	if "mesh_script" in data: data.mesh_script = parser.get_as_script(data.mesh_script)
	
	return PhysicalItemData.new(data)


static func parse_building_item_data(_json_file: FileAccess, _parser: ModParser, data: Dictionary) -> BuildingItemData:
	if not "intersection_type" in data and not "intersection_rect" in data: return null
	
	if "intersection_type" in data: data.intersection_type = BuildingItemData.BuildingIntersectionType[data.intersection_type.to_upper()]
	if "intersection_rect" in data:
		data.intersection_rect = Rect2(
			data.intersection_rect.x if "x" in data.intersection_rect else 0,
			data.intersection_rect.y if "y" in data.intersection_rect else 0,
			data.intersection_rect.width if "width" in data.intersection_rect else 0,
			data.intersection_rect.height if "height" in data.intersection_rect else 0,
		)
	return BuildingItemData.new(data)


static func parse_use_data(_json_file: FileAccess, _parser: ModParser, data: Dictionary) -> ItemUseData:
	if not "fulfills_needs" in data or not "total_uses" in data: return null
	
	# Parse needs
	if "fulfills_needs" in data: data.fulfills_needs = data.fulfills_needs.map(
		func(need: String) -> NeedsData.Need: return NeedsData.Need[need.to_upper()]
	)
	if "total_uses" in data: data.total_uses = int(data.total_uses)
	return ItemUseData.new(data)
