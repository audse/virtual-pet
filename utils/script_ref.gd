class_name ScriptRef
extends Object


static func get_enum_dict(enum_name) -> Dictionary:
	var dict := {}
	for value in enum_name.values():
		dict[value] = null
	return dict
