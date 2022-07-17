@tool
class_name StyleSheetSetter
extends Node
@icon("res://utils/stylesheet/icons/wand-magic-sparkles-solid.svg")

@export var target_node_path: NodePath = "..":
	set(value):
		target_node_path = value
		update_base_node = true

@export var stylebox_style_sheet: Resource:
	set(value):
		stylebox_style_sheet = value
		_connect_stylebox_stylesheet()

@export var font_style_sheet: Resource:
	set(value):
		font_style_sheet = value
		_connect_font_stylesheet()

@export var update_base_node: bool:
	set(_value):
		var node: Control = get_node_or_null(target_node_path)
		if node and node is Control:
			target_node = node
			_connect_stylebox_stylesheet()
			_connect_font_stylesheet()

var target_node: Control


func _connect_stylebox_stylesheet() -> void:
	if stylebox_style_sheet and stylebox_style_sheet is StyleBoxStyleSheet:
		stylebox_style_sheet.base_node = target_node
		
		if stylebox_style_sheet.stylebox_changed.is_connected(change_stylebox):
			stylebox_style_sheet.stylebox_changed.disconnect(change_stylebox)
		else:
			stylebox_style_sheet.stylebox_changed.connect(change_stylebox.bind(target_node))


func _connect_font_stylesheet() -> void:
	if font_style_sheet and font_style_sheet is FontStyleSheet: 
		font_style_sheet.base_node = target_node
		
		if font_style_sheet.font_changed.is_connected(change_font):
			font_style_sheet.font_changed.disconnect(change_font)
		else:
			font_style_sheet.font_changed.connect(change_font.bind(target_node))
		
		if font_style_sheet.color_changed.is_connected(change_color):
			font_style_sheet.color_changed.disconnect(change_color)
		else:
			font_style_sheet.color_changed.connect(change_color.bind(target_node))


static func change_stylebox(stylebox: StyleBoxFlat, which: String, node: Control) -> void:
	if node and node is Control:
		node.add_theme_stylebox_override(which, stylebox)


static func change_font(font: Font, which: String, node: Control) -> void:
	if node and node is Control:
		node.add_theme_font_override(which, font)


static func change_color(color: Color, which: String, node: Control) -> void:
	if node and node is Control:
		node.add_theme_color_override(which, color)
