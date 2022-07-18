@tool
class_name FontStyleSheet
extends StyleSheet

signal font_changed(new_font: FontFile, which: String)
signal color_changed(new_color: Color, which: String)

@export var preset: StyleSheetConstants.FontPresets:
	set(value):
		preset = value
		if "FONT_PRESETS" in StyleSheetConstants and preset in StyleSheetConstants.FONT_PRESETS:
			apply_styles = StyleSheetConstants.FONT_PRESETS[preset]
			send_update()

@export var base_color := Color.WHITE:
	set(value):
		base_color = value
		send_update()

@export var base_font: FontFile = StyleSheetConstants.FONTS.regular:
	set(value):
		base_font = value
		send_update()


var base_node: Control


func send_update() -> void:
	var new_fonts := get_font()
	for key in new_fonts:
		font_changed.emit(new_fonts[key].font, key)
		color_changed.emit(new_fonts[key].color, key)


func get_base_fonts() -> Dictionary:
	var fonts := {}
	for default_name in get_default_style_names():
		if base_node and base_node is Control:
			fonts[default_name] = _get_font_from_theme(default_name)
		else:
			fonts[default_name] = new_reset_font()
	return fonts


func _get_font_from_theme(style: String) -> Font:
	if base_node and base_node is Control:
		if base_node.has_theme_font_override(style):
			base_node.remove_theme_font_override(style)
		return base_node.get_theme_font(style)
	return null


func get_font() -> Dictionary:
	# key/value pairs of style_names and their final font values
	var fonts := get_base_fonts()
	
	# list of styles that are applied to all FONTS
	var default_styles := []

	# key/value pairs of style_names and their associated styles
	var styles := {}

	# add key for every default style name
	var default_name_list := get_default_style_names()
	for default_name in default_name_list:
		styles[default_name] = []
	
	for style in apply_styles.split(" "):
		
		var style_info := parse_style_name(style)
		var name: String = style_info.name
		var string: String = style_info.string
		
		# if the style applies to ALL of the defaults (e.g. has no "style:" prefix)
		if name == default_style_names:
			default_styles.append(string)
		
		# if the style applies to only one name (e.g. has "style:" prefix)
		else:
			if not name in styles: styles[name] = []
			styles[name].append(string)
	
	for name in styles:
		fonts[name] = apply_styles_from(fonts[name].duplicate(), default_styles + styles[name])
	
	return fonts


func new_reset_font() -> Font:
	var font := Font.new()
	font.font_data = base_font
	font = set_size(font, "size_md")
	return font


func apply_styles_from(font: Font, styles: Array) -> Dictionary:
	var color: Color = base_color
	
	for style_string in styles:
		# set font data
		if (
			"FONTS" in StyleSheetConstants
			and style_string in StyleSheetConstants.FONTS
		):
			font.font_data = StyleSheetConstants.FONTS[style_string]
		
		# set font size
		if "size" in style_string: font = set_size(font, style_string)
		elif "color" in style_string: color = parse_color_string(style_string)
	return {
		font = font,
		color = color
	}


func set_size(font: Font, size_string: String) -> Font:
	var values := size_string.split("_")
	if len(values) != 2: return font
	var new_size: int = values[1].to_int()

	if (
		"FONT_SIZES" in StyleSheetConstants 
		and values[1] in StyleSheetConstants.FONT_SIZES
	):
		new_size = StyleSheetConstants.FONT_SIZES[values[1]]
	
	font.size = new_size if new_size > 1 else font.size
	return font
