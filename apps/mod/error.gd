extends Node

const Error = {
	MISSING_REQUIRED_FIELD = 404,
	MISSING_REQUIRED_FUNCTION = 405,
	INCORRECT_FIELD_TYPE = 501,
}


func report_string(mod: FileAccess, code: int, context: String = "") -> String:
	return """
		ERROR: [{error_code}]
		- source: mod (`{mod}`)
		- Context: {context}
		""".format({
			mod = mod.get_path_absolute(),
			error_code = Error.find_key(code),
			context = context,
		})


func report_string_missing_required_field(mod: FileAccess, missing_field: String, data: Dictionary) -> String:
	return report_string(
		mod,
		Error.MISSING_REQUIRED_FIELD,
		DictRef.format({
			missing_field = missing_field,
			provided_fields = data.keys()
		})
	)

func report_string_incorrect_field_type(mod: FileAccess, field: String, expected_type: int, data: Dictionary) -> String:
	return report_string(
		mod,
		Error.INCORRECT_FIELD_TYPE,
		DictRef.format({
			incorrect_field = field,
			expected_type = expected_type, # TODO: print type string, not ints
			found_type = typeof(data[field])
		})
	)
