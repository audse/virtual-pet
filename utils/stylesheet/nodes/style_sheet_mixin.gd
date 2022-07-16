@tool
class_name StyleSheetMixin
extends Control


static func setup(node: Control, style_sheets: Array[StyleSheet]) -> void:
	if node and node is Control:
		for style_sheet in style_sheets:
			if style_sheet is StyleBoxStyleSheet:
				setup_stylebox(node, style_sheet)
			elif style_sheet is FontStyleSheet:
				setup_font(node, style_sheet)


static func setup_stylebox(node: Control, stylebox_style_sheet: StyleSheet) -> void:
	StyleSheetUtils.connect_to_node(node, stylebox_style_sheet)


static func setup_font(node: Control, font_style_sheet: StyleSheet) -> void:
	StyleSheetUtils.connect_to_node(node, font_style_sheet)
