class_name ActionItemParser
extends Object

const required_fields := ["id", "text"]


static func parse(context: Node, json_file: FileAccess) -> ActionItemParams:
	return parse_data(
		context,
		json_file, 
		JSON.parse_string(json_file.get_as_text())
	)


static func parse_data(context: Node, json_file: FileAccess, data: Dictionary) -> ActionItemParams:
	# Check that all required fields exist
	for field in required_fields:
		if not field in data:
			push_error(ModError.report_string_missing_required_field(json_file, field, data))
			return null
	
	# Create base param list
	var params := {
		id = data.id,
		text = data.text,
	}
	
	if "is_cheat" in data:
		params.is_cheat = data.is_cheat
	
	# If there is a submenu, create those params
	if "submenu" in data:
		params.submenu_params = parse_submenu_params(context, json_file, data)
	
	# Attach script to run when this action is selected
	if "on_pressed" in data:
		params.on_pressed = parse_on_pressed(context, json_file, data)
		if params.on_pressed == null: return null
	
	return ActionItemParams.new(params)


static func parse_submenu_params(context: Node, json_file: FileAccess, data: Dictionary) -> Array[ActionItemParams]:
	var params: Array[ActionItemParams] = []
	for param in data.submenu:
		var param_data = parse_data(context, json_file, param)
		if param_data: params.append(param_data)
	return params


static func parse_on_pressed(context: Node, json_file: FileAccess, data: Dictionary) -> Callable:
	if "run_script" in data.on_pressed:
		var script = load("res://mods/" + data.on_pressed.run_script).new()
		
		# return the `run` function within the loaded script
		if script is ActionItemScript:
			var args = data.on_pressed.arguments if "arguments" in data.on_pressed else {}
			return script.run.bind(context, args)
		
		else:
			push_error(ModError.report_string(
				json_file,
				ModError.Error.MISSING_REQUIRED_FUNCTION,
				DictRef.format({
					missing_function = "run",
					script = script,
				})
			))
			return (func(_args: Dictionary) -> void: pass)
	else:
		push_error(ModError.report_string_missing_required_field(json_file, "run_script", data))
		return (func(_args: Dictionary) -> void: pass)

