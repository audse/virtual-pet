class_name ModParser
extends Object

var context: Node
var json_file: FileAccess
var data: Dictionary = {}
var required_fields: Dictionary = {}


func _init(
	context_value: Node,
	json_file_value: FileAccess,
	data_value: Dictionary,
	required_fields_value: Dictionary
) -> void:
	context = context_value
	json_file = json_file_value
	data = data_value
	required_fields = required_fields_value


func are_required_fields_ok() -> bool:
	for field in required_fields.keys():
		# check that fields exist
		assert(field in data, ModError.report_string_missing_required_field(json_file, field, data))
		
		# check that provided values are of the correct type
		var expected_type: int = required_fields[field]
		assert(typeof(data[field]) == expected_type, ModError.report_string_incorrect_field_type(json_file, field, expected_type, data))
	
	return true


func are_optional_fields_ok(optional_fields: Dictionary) -> bool:
	for field in optional_fields.keys():
		if field in data:
			var expected_type: int = optional_fields[field]
			assert(typeof(data[field]) == expected_type, ModError.report_string_incorrect_field_type(json_file, field, expected_type, data))
	return true


func get_as_script(path: String) -> Script:
	var script = load("res://mods/" + path)
	is_script(script)
	return script as Script


func parse_dimensions(dimensions: Dictionary, default := Vector3.ONE) -> Vector3:
	return Vector3(
		float(dimensions.width) if "width" in dimensions else default.x,
		float(dimensions.height) if "height" in dimensions else default.y,
		float(dimensions.depth) if "depth" in dimensions else default.z
	)


func is_script(script) -> void:
	assert(script is Script, ModError.report_string(
		json_file,
		ModError.Error.INCORRECT_FILE_TYPE,
		DictRef.format({
			expected_file_type = "Script",
			found_file_type = typeof(script),
		})
	))
