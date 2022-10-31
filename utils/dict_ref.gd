class_name DictRef
extends Object


static func format(dict: Dictionary, depth := 1) -> String:
	var lines := ["{"]
	
	for key in dict.keys():
		var value = dict[key]
		if value is Dictionary:
			value = DictRef.format(value, depth + 1)
		lines.append("{0}: {1},".format([key, value]))
	
	lines.append("}")
	
	var indents = []
	indents.resize(depth)
	indents.fill("  ")
	var indent: String = indents.reduce(
		func(accum, i) -> String: return accum + i, 
		""
	)
	
	lines[0] = indent + lines[0]
	for i in range(1, len(lines) - 1):
		lines[i] = indent + indent + lines[i]
	lines[len(lines) - 1] = indent + lines[len(lines) - 1]
	
	return lines.reduce(
		func(accum: String, line: String) -> String: return accum + "\n" + line,
		""
	)
