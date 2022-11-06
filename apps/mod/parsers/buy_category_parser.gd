class_name BuyCategoryParser
extends Object

const required_fields := {
	id = TYPE_STRING,
	display_name = TYPE_STRING,
}

const optional_fields := {
	description = TYPE_STRING,
}


static func parse(context: Node, json_file: FileAccess) -> BuyCategoryData:
	var data: Dictionary = JSON.parse_string(json_file.get_as_text())
	
	var parser := ModParser.new(context, json_file, data, required_fields)
	if not parser.are_required_fields_ok(): return null
	if not parser.are_optional_fields_ok(optional_fields): return null
	
	return BuyCategoryData.new(data)
