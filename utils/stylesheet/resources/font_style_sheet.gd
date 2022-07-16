@tool
class_name FontStyleSheet
extends StyleSheet

signal font_changed(new_font: FontData, which: String)
signal color_changed(new_color: Color, which: String)

@export var preset: StyleSheetConstants.FontPresets:
	set(value):
		preset = value
		if "FONT_PRESETS" in StyleSheetConstants and StyleSheetConstants.FONT_PRESETS[preset]:
			self.apply_styles = StyleSheetConstants.FONT_PRESETS[preset]

@export var base_color := Color.WHITE:
	set(value):
		base_color = value
		send_update()

@export var base_font: FontData = StyleSheetConstants.FONTS.regular:
	set(value):
		base_font = value
		send_update()


func set_apply_styles(apply_styles_value: String) -> void:
	apply_styles = apply_styles_value
	send_update()


func send_update() -> void:
	var new_fonts := get_font()
	for key in new_fonts.keys():
		font_changed.emit(new_fonts[key], key)


func get_font() -> Dictionary:
	
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

	
	# key/value pairs of style_names and their final font values
	var FONTS := {}
	var font_template := new_reset_font()

	for name in styles.keys():
		var new_font := apply_styles_from(font_template.duplicate(), default_styles + styles[name])
		FONTS[name] = new_font.font
		set_color(new_font.color, name)
	
	return FONTS


func new_reset_font() -> Font:
	var font := Font.new()
	font.font_data = base_font
	font = set_size(font, "size_md")
	return font


func apply_styles_from(font: Font, styles: Array[String]) -> Dictionary:
	var color: Color = base_color
	
	for style_string in styles:
		# set font data
		if "FONTS" in StyleSheetConstants.FONTS[style_string]:
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

	if "FONT_SIZES" in StyleSheetConstants and StyleSheetConstants.FONT_SIZES[values[1]]:
		new_size = StyleSheetConstants.FONT_SIZES[values[1]]
	
	font.size = new_size if new_size > 1 else font.size
	return font


func set_color(color: Color, style_name: String) -> void:
	color_changed.emit(color, style_name)
