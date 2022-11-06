class_name BuyableObjectParser
extends Object

const required_fields := {
	id = TYPE_STRING,
	display_name = TYPE_STRING,
	mesh = TYPE_STRING,
	world_layer = TYPE_STRING,
}

const optional_fields := {
	category_id = TYPE_STRING,
	description = TYPE_STRING,
	colorway_id = TYPE_STRING,
	dimensions = TYPE_DICTIONARY,
	mesh_scale = TYPE_DICTIONARY,
	rarity = TYPE_FLOAT,
	consumed_meshes = TYPE_STRING,
	collision_shape = TYPE_STRING,
	flags = TYPE_ARRAY,
	fulfills_needs = TYPE_ARRAY,
	actions = TYPE_ARRAY,
	total_uses = TYPE_FLOAT,
	# TODO script
}


static func parse(context: Node, json_file: FileAccess) -> BuyableObjectData:
	var data: Dictionary = JSON.parse_string(json_file.get_as_text())
	
	var parser := ModParser.new(context, json_file, data, required_fields)
	if not parser.are_required_fields_ok(): return null
	if not parser.are_optional_fields_ok(optional_fields): return null
	
	data = parse_required_data(context, json_file, data)
	if (data.size() == 0): return null
	
	data = parse_optional_data(context, json_file, data)
	
	return BuyableObjectData.new(data)


static func parse_required_data(_context: Node, json_file: FileAccess, data: Dictionary) -> Dictionary:
	# Convert `world_layer` param from string to enum
	# TODO: maybe this shouldn't be an enum, for more extensibility
	data.world_layer = WorldObjectData.Layer[data.world_layer.to_upper() + "_LAYER"]
	
	# Load mesh file
	if data.mesh.contains("res://"): data.mesh = load(data.mesh)
	else: data.mesh = load("res://mods/" + data.mesh)
	
	return data


static func parse_optional_data(_context: Node, json_file: FileAccess, data: Dictionary) -> Dictionary:
	# Convert dimension width & height to `Vector2i`
	var dimensions := Vector3i(1, 1, 1)
	if "width" in data.dimensions: dimensions.x = data.dimensions.width as int
	if "height" in data.dimensions: dimensions.y = data.dimensions.height as int
	if "depth" in data.dimensions: dimensions.z = data.dimensions.depth as int
	data.dimensions = dimensions
	
	# Load collision shape file
	if "collision_shape" in data:
		if data.collision_shape.contains("res://"): data.collision_shape = load(data.collision_shape)
		else: data.collision_shape = load("res://mods/" + data.collision_shape)
	
	# Parse needs
	if "fulfills_needs" in data:
		data.fulfills_needs = data.fulfills_needs.map(
			func(need: String) -> NeedsData.Need: return NeedsData.Need[need.to_upper()]
		)
	
	# Parse flags
	if "flags" in data:
		data.flags = data.flags.map(
			func(flag: String) -> BuyableObjectData.Flag: return BuyableObjectData.Flag[flag.to_upper()]
		)
	
	# Load all available meshes
	if "consumed_meshes" in data:
		var i := 0
		for mesh in data.consumed_meshes:
			if mesh.contains("res://"): data.consumed_meshes[i] = load(mesh)
			else: data.consumed_meshes[i] = load("res://mods/" + mesh)
			i += 1
	
	# Convert JSON floats to ints
	if "rarity" in data: data.rarity = int(data.rarity)
	if "total_uses" in data: data.total_uses = int(data.total_uses)
	
	# Convert scale of mesh to Vector3
	if "mesh_scale" in data: data.mesh_scale = Vector3(
		data.mesh_scale.x if "x" in data.mesh_scale else 1.0,
		data.mesh_scale.y if "y" in data.mesh_scale else 1.0,
		data.mesh_scale.z if "z" in data.mesh_scale else 1.0
	)
	
	return data
