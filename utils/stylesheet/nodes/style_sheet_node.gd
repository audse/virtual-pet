@tool
class_name StyleSheetSetter
extends Control

@export var target_node_path: NodePath = "..":
	set(value):
		target_node_path = value
		var node: Control = get_node_or_null(target_node_path)
		if node and node.is_inside_tree() and node is Control:
			target_node = node
	
@export var stylebox_style_sheet: Resource:
	set(value):
		stylebox_style_sheet = value
		if (
			stylebox_style_sheet
			and stylebox_style_sheet is StyleBoxStyleSheet
			and not stylebox_style_sheet.stylebox_changed.is_connected(change_stylebox)
		):
			_connect = stylebox_style_sheet.stylebox_changed.connect(change_stylebox.bind(target_node))

@export var font_style_sheet: Resource:
	set(value):
		font_style_sheet = value
		if (
			font_style_sheet
			and font_style_sheet is FontStyleSheet
		):
			if not font_style_sheet.font_changed.is_connected(change_font):
				_connect = font_style_sheet.font_changed.connect(change_font.bind(target_node))
			if not font_style_sheet.color_changed.is_connected(change_color):
				_connect = font_style_sheet.color_changed.connect(change_color.bind(target_node))

var target_node: Control
var _connect


func _ready() -> void:
	set("target_node_path", target_node_path)


static func change_stylebox(stylebox: StyleBoxFlat, which: String, node: Control) -> void:
	if node and node is Control and node.has_method("add_stylebox_override"):
		node.add_stylebox_override(which, stylebox)


static func change_font(font: Font, which: String, node: Control) -> void:
	if node and node is Control and node.has_method("add_font_override"):
		node.add_font_override(which, font)


static func change_color(color: Color, which: String, node: Control) -> void:
	if node and node is Control and node.has_method("add_color_override"):
		node.add_color_override(which, color)
