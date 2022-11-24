class_name DesignCategoryParser
extends Object

const required_fields := {
	id = TYPE_STRING,
	display_name = TYPE_STRING,
	design_type = TYPE_STRING,
}

const optional_fields := {
	description = TYPE_STRING,
}


static func parse(context: Node, json_file: FileAccess) -> DesignCategoryData:
	var data: Dictionary = JSON.parse_string(json_file.get_as_text())
	
	var parser := ModParser.new(context, json_file, data, required_fields)
	if not parser.are_required_fields_ok(): return null
	if not parser.are_optional_fields_ok(optional_fields): return null
	
	DesignParser.check_design_type_name(json_file, data.design_type)
	data.design_type = DesignData.DesignType[data.design_type.to_upper()]

	return DesignCategoryData.new(data)
