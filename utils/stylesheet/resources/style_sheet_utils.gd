@tool
class_name StyleSheetUtils
extends Resource

const signal_names := {
	stylebox = "stylebox_changed",
	font = "font_changed",
	color = "color_changed"
}

const func_names := {
	stylebox = "change_stylebox",
	font = "change_font",
	color = "change_color"
}


static func connect_to_node(node: Control, style_sheet: StyleSheet) -> void:
	if not node or not node is Control: return
	var _success: bool
	_success = connect_stylebox(node, style_sheet)
	_success = connect_font(node, style_sheet)
	_success = connect_color(node, style_sheet)


static func connect_stylebox(node: Control, style_sheet: StyleSheet) -> bool:
	if not style_sheet or not style_sheet.has_signal("stylebox_changed"): return false
	if not style_sheet.is_connected("stylebox_changed", StyleSheetSetter, "change_stylebox"):
		var _connect = style_sheet.stylebox_changed.connect(StyleSheetSetter.change_stylebox.bind(node))
		return true
	return false


static func connect_font(node: Control, style_sheet: StyleSheet) -> bool:
	if not style_sheet or not style_sheet.has_signal("font_changed"): return false
	if not style_sheet.is_connected("font_changed", StyleSheetSetter, "change_font"):
		var _connect = style_sheet.font_changed.connect(StyleSheetSetter.change_font)
		return true
	return false


static func connect_color(node: Control, style_sheet: StyleSheet) -> bool:
	if not style_sheet or not style_sheet.has_signal("color_changed"): return false
	if not style_sheet.is_connected("color_changed", StyleSheetSetter, "change_color"):
		var _connect = style_sheet.color_changed.connect(StyleSheetSetter.change_color)
		return true
	return false
