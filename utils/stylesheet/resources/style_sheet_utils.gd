@tool
class_name StyleSheetUtils
extends Resource


static func connect_to_node(node: Control, style_sheet: StyleSheet) -> void:
	if not node or not node is Control: return
	connect_stylebox(node, style_sheet)
	connect_font(node, style_sheet)
	connect_color(node, style_sheet)


static func connect_stylebox(node: Control, style_sheet: StyleSheet) -> void:
	if node.is_inside_tree():
		if not style_sheet or not style_sheet.has_signal("stylebox_changed"): return
		if not style_sheet.stylebox_changed.is_connected(StyleSheetSetter.change_stylebox):
			style_sheet.stylebox_changed.connect(StyleSheetSetter.change_stylebox.bind(node))


static func connect_font(node: Control, style_sheet: StyleSheet) -> void:
	if node.is_inside_tree():
		if not style_sheet or not style_sheet.has_signal("font_changed"): return
		if not style_sheet.font_changed.is_connected(StyleSheetSetter.change_font):
			style_sheet.font_changed.connect(StyleSheetSetter.change_font)


static func connect_color(node: Control, style_sheet: StyleSheet) -> void:
	if node.is_inside_tree():
		if not style_sheet or not style_sheet.has_signal("color_changed"): return
		if not style_sheet.color_changed.is_connected(StyleSheetSetter.change_color):
			style_sheet.color_changed.connect(StyleSheetSetter.change_color)
