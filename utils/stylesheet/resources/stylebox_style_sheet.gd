@tool
class_name StyleBoxStyleSheet
extends StyleSheet

signal stylebox_changed(new_stylebox: StyleBoxFlat, which: String)

const SIDES := [
	"top", 
	"left", 
	"right", 
	"bottom",
]

const CORNERS := [
	"top_left", 
	"top_right", 
	"bottom_left", 
	"bottom_right"
]

const PROPERTY_GROUPS := {
	border_width = [
		"border_width_left", 
		"border_width_right", 
		"border_width_top", 
		"border_width_bottom"
	],
	corner_radius = [
		"corner_radius_bottom_left",
		"corner_radius_bottom_right",
		"corner_radius_top_left",
		"corner_radius_top_right"
	],
	expand_margin = [
		"expand_margin_left", 
		"expand_margin_right", 
		"expand_margin_top", 
		"expand_margin_bottom"
	],
}

@export var preset: StyleSheetConstants.StyleBoxPresets:
	set(value):
		preset = value
		if "STYLEBOX_PRESETS" in StyleSheetConstants and StyleSheetConstants.STYLEBOX_PRESETS[preset]:
			apply_styles = StyleSheetConstants.STYLEBOX_PRESETS[preset]
			send_update()

@export var base_stylebox: StyleBoxFlat

var base_node: Control


func send_update() -> void:
	var new_styleboxes := get_styleboxes()
	for name in new_styleboxes:
		stylebox_changed.emit(new_styleboxes[name], name)


func get_base_styleboxes() -> Dictionary:
	var styles: Dictionary = {}
	for default_name in get_default_style_names():
		styles[default_name] = get_base_stylebox(default_name)
	return styles


func get_base_stylebox(default_name: String) -> StyleBoxFlat:
	if base_stylebox != null: return base_stylebox
	elif base_node and base_node is Control:
		var style := _get_stylebox_from_theme(default_name)
		return style if style else new_reset_stylebox()
	else: return new_reset_stylebox()


func _get_stylebox_from_theme(style: String) -> StyleBoxFlat:
	if base_node and base_node is Control:
		if base_node.has_theme_stylebox_override(style):
			base_node.remove_theme_stylebox_override(style)
		return base_node.get_theme_stylebox(style)
	return null


func get_styleboxes() -> Dictionary:
	# key/value pairs of style names and their new styleboxes
	var styleboxes = get_base_styleboxes()
	
	# list of styles that are applied to all styleboxes
	var default_styles := []

	# key/value pairs of style names and styles to apply
	var styles: Dictionary = {}

	# add key for every default style name
	var default_name_list := get_default_style_names()
	for default_name in default_name_list:
		styles[default_name] = []
	
	for style_string in apply_styles.split(" "):
		# parse the style string into style name (e.g. "pressed") and value (e.g. "bg_red_500")
		var style_info := parse_style_name(style_string)
		var name: String = style_info.name
		var string: String = style_info.string

		if name == default_style_names:
			default_styles.append(string)

		else:
			# add a key to the styles dictionary for the current value, if it doesn't exist
			if not styles.has(name): styles[name] = []
			
			# add this style to the list according to its name
			styles[name].append(style_string)
	
	for name in styles:
		if not name in styleboxes: styleboxes[name] = get_base_stylebox(name)
		
		# apply default styles to all styleboxes
		styleboxes[name] = apply_styles_from(styleboxes[name].duplicate(), default_styles + styles[name])
	
	return styleboxes


func apply_styles_from(new_stylebox: StyleBoxFlat, styles: Array) -> StyleBoxFlat:
		for style_string in styles:
			if "bg_" in style_string:
				new_stylebox = set_bg_color(new_stylebox, style_string)
			elif "border_" in style_string:
				new_stylebox = set_border_color(new_stylebox, style_string)
			elif "bg-opacity_" in style_string:
				new_stylebox = set_bg_opacity(new_stylebox, style_string)
			elif "border-opacity_" in style_string:
				new_stylebox = set_border_opacity(new_stylebox, style_string)
			elif "radius_" in style_string:
				new_stylebox = set_radius(new_stylebox, style_string)
			elif "border-width_" in style_string:
				new_stylebox = set_border_width(new_stylebox, style_string)
			elif "content-margin_" in style_string:
				new_stylebox = set_content_margin(new_stylebox, style_string)
			elif "expand-margin_" in style_string:
				new_stylebox = set_expand_margin(new_stylebox, style_string)
			elif "shadow_" in style_string:
				new_stylebox = set_shadow_color(new_stylebox, style_string)
			elif "shadow-opacity_" in style_string:
				new_stylebox = set_shadow_opacity(new_stylebox, style_string)
			elif "shadow-offset_" in style_string:
				new_stylebox = set_shadow_offset(new_stylebox, style_string)
			elif "shadow-size_" in style_string:
				new_stylebox = set_shadow_size(new_stylebox, style_string)
			elif "corner-detail_" in style_string:
				new_stylebox = set_corner_detail(new_stylebox, style_string)
			elif "border-blend_" in style_string:
				new_stylebox = set_border_blend(new_stylebox, style_string)
			elif "draw-center_" in style_string:
				new_stylebox = set_draw_center(new_stylebox, style_string)
			elif "antialiasing_" in style_string:
				new_stylebox = set_antialiasing(new_stylebox, style_string)
			elif "antialiasing-size_" in style_string:
				new_stylebox = set_antialiasing_size(new_stylebox, style_string)
		
		return new_stylebox



func new_reset_stylebox() -> StyleBoxFlat:
	var reset_stylebox := StyleBoxFlat.new()
	reset_stylebox.bg_color = Color("#00FFFFFF")
	reset_stylebox.border_color = Color("#00FFFFFF")
	
	for border_width in PROPERTY_GROUPS.border_width:
		reset_stylebox.set(border_width, 0)
	
	for corner_radius in PROPERTY_GROUPS.corner_radius:
		reset_stylebox.set(corner_radius, 0)
	
	return reset_stylebox


func parse_size_string(size_string: String) -> int:
	var size := size_string.strip_edges()
	if "SIZES" in StyleSheetConstants and size in StyleSheetConstants.SIZES:
		return StyleSheetConstants.SIZES[size]
	else:
		return size.to_int()


func parse_style_string(style_string: String) -> Dictionary:
	var _c = """ parse_style_string
	
		:param style_string: String
		accepts a string indicating the direction and size of a style
		
		formats:
			{property}_{size} 
				left, right, top, bottom
				
			{property}_{x|y}_{size} 
				left, right or top, bottom
				
			{property}_{size_y}_{size_x} 
				(SIDES) top, bottom --> left, right
				(CORNERS) top left, top right --> bottom left, bottom right
				
			{property}_{size_top}_{size_right}_{size_bottom}_{size_left} 
				(SIDES) top --> right --> bottom --> left
				(CORNERS) top left --> top right --> bottom right --> bottom left
			
			{property}_{t|b|l|r}_{size}
				top or bottom or left or right
			
			{property}_{tl|tr|bl|br}_{size}
				top left or top right or bottom left or bottom right
		
		property can be one of:
			border
			radius
			expand-margin
			content-margin
		
		size can be a key in SIZES dict, or an int value
	"""
	
	var style_values := {}
	var style_string_parts: Array = style_string.split("_")
	
	# early return for invalid style string
	if len(style_string_parts) <= 1: return style_values
	
	# e.g. "border_sm"
	if len(style_string_parts) == 2:
		var size := parse_size_string(style_string_parts.back())
		
		for property in SIDES + CORNERS: style_values[property] = size
		
		return style_values
	
	# e.g. "border_sm_md"
	if len(style_string_parts) == 3:
		var y_size = parse_size_string(style_string_parts[1])
		var x_size = parse_size_string(style_string_parts[2])
		for property in ["top", "bottom", "top_left", "top_right"]:
			style_values[property] = y_size
		for property in ["left", "right", "bottom_left", "bottom_right"]:
			style_values[property] = x_size
		return style_values
		
	# e.g. "border_sm_md_lg_xl"
	if len(style_string_parts) == 5:
		var top := parse_size_string(style_string_parts[1])
		var right := parse_size_string(style_string_parts[2])
		var bottom := parse_size_string(style_string_parts[3])
		var left := parse_size_string(style_string_parts[4])
		style_values.top = top
		style_values.top_left = top
		style_values.right = right
		style_values.top_right = right
		style_values.bottom = bottom
		style_values.bottom_right = bottom
		style_values.left = left
		style_values.bottom_left = left
		return style_values
	
	var size := parse_size_string(style_string_parts.back())
	
	match style_string_parts:
		["x", ..]: 
			style_values.left = size
			style_values.right = size
		["y", ..]: 
			style_values.top = size
			style_values.bottom = size
		["l", ..]: style_values.left = size
		["r", ..]: style_values.right = size
		["t", ..]: style_values.top = size
		["b", ..]: style_values.bottom = size
		["tl", ..]: style_values.top_left = size
		["tr", ..]: style_values.top_right = size
		["bl", ..]: style_values.bottom_left = size
		["br", ..]: style_values.bottom_right = size
	
	return style_values


func set_bg_color(new_stylebox: StyleBoxFlat, color_string: String) -> StyleBoxFlat:
	new_stylebox.bg_color = StyleBoxStyleSheet.parse_color_string(color_string)
	return new_stylebox


func set_border_color(new_stylebox: StyleBoxFlat, color_string: String) -> StyleBoxFlat:
	new_stylebox.border_color = StyleBoxStyleSheet.parse_color_string(color_string)
	return new_stylebox


func set_shadow_color(new_stylebox: StyleBoxFlat, color_string: String) -> StyleBoxFlat:
	new_stylebox.shadow_color = StyleBoxStyleSheet.parse_color_string(color_string)
	return new_stylebox


# OPACITY

func set_bg_opacity(new_stylebox: StyleBoxFlat, opacity_string: String) -> StyleBoxFlat:
	var values := opacity_string.split("_")
	if len(values) <= 1: return new_stylebox
	new_stylebox.bg_color.a = values[1].to_float() / 100
	return new_stylebox


func set_border_opacity(new_stylebox: StyleBoxFlat, opacity_string: String) -> StyleBoxFlat:
	var values := opacity_string.split("_")
	if len(values) <= 1: return new_stylebox
	new_stylebox.border_color.a = values[1].to_float() / 100
	return new_stylebox


func set_shadow_opacity(new_stylebox: StyleBoxFlat, opacity_string: String) -> StyleBoxFlat:
	var values := opacity_string.split("_")
	if len(values) <= 1: return new_stylebox
	new_stylebox.shadow_color.a = values[1].to_float() / 100
	return new_stylebox


# CORNER_RADIUS

func set_radius(new_stylebox: StyleBoxFlat, radius_string: String) -> StyleBoxFlat:
	var values = parse_style_string(radius_string)
	
	match values:
		{ "top_left", ..}:
			new_stylebox.corner_radius_top_left = values.top_left
			continue
		{ "top_right", ..}:
			new_stylebox.corner_radius_top_right = values.top_right
			continue
		{ "bottom_left", ..}:
			new_stylebox.corner_radius_bottom_left = values.bottom_left
			continue
		{ "bottom_right", ..}:
			new_stylebox.corner_radius_bottom_right = values.bottom_right
			continue
	
	return new_stylebox


# BORDER_WIDTH

func set_border_width(new_stylebox: StyleBoxFlat, border_width_string: String) -> StyleBoxFlat:
	var values = parse_style_string(border_width_string)
	
	match values:
		{ "top", ..}:
			new_stylebox.border_width_top = values.top
			continue
		{ "bottom", ..}:
			new_stylebox.border_width_bottom = values.bottom
			continue
		{ "left", ..}:
			new_stylebox.border_width_left = values.left
			continue
		{ "right", ..}:
			new_stylebox.border_width_right = values.right
			continue
		
	return new_stylebox


# CONTENT_MARGIN

func set_content_margin(new_stylebox: StyleBoxFlat, content_margin_string: String) -> StyleBoxFlat:
	var values = parse_style_string(content_margin_string)
	
	match values:
		{ "top", ..}:
			new_stylebox.content_margin_top = values.top
			continue
		{ "bottom", ..}:
			new_stylebox.content_margin_bottom = values.bottom
			continue
		{ "left", ..}:
			new_stylebox.content_margin_left = values.left
			continue
		{ "right", ..}:
			new_stylebox.content_margin_right = values.right
			continue
	
	return new_stylebox


# EXPAND_MARGIN

func set_expand_margin(new_stylebox: StyleBoxFlat, expand_margin_string: String) -> StyleBoxFlat:
	var values = parse_style_string(expand_margin_string)
	
	match values:
		{ "top", ..}:
			new_stylebox.expand_margin_top = values.top
			continue
		{ "bottom", ..}:
			new_stylebox.expand_margin_bottom = values.bottom
			continue
		{ "left", ..}:
			new_stylebox.expand_margin_left = values.left
			continue
		{ "right", ..}:
			new_stylebox.expand_margin_right = values.right
			continue
	
	return new_stylebox


# SHADOW

func set_shadow_offset(new_stylebox: StyleBoxFlat, shadow_offset_string: String) -> StyleBoxFlat:
	var values = parse_style_string(shadow_offset_string)
	
	match values:
		{ "top", "bottom", ..}:
			new_stylebox.shadow_offset.y = values.top
			continue
		{ "left", "right", ..}:
			new_stylebox.shadow_offset.x = values.left
			continue
	
	return new_stylebox


func set_shadow_size(new_stylebox: StyleBoxFlat, shadow_offset_string: String) -> StyleBoxFlat:
	var values = parse_style_string(shadow_offset_string)
	new_stylebox.shadow_size = values.top
	return new_stylebox


func set_corner_detail(new_stylebox: StyleBoxFlat, corner_detail_string: String) -> StyleBoxFlat:
	var values = parse_style_string(corner_detail_string)
	new_stylebox.corner_detail = values.top
	return new_stylebox


func set_border_blend(new_stylebox: StyleBoxFlat, border_blend_string: String) -> StyleBoxFlat:
	if "on" in border_blend_string:
		new_stylebox.border_blend = true
	elif "off" in border_blend_string:
		new_stylebox.border_blend = false
	return new_stylebox


func set_draw_center(new_stylebox: StyleBoxFlat, draw_center_string: String) -> StyleBoxFlat:
	if "on" in draw_center_string:
		new_stylebox.draw_center = true
	elif "off" in draw_center_string:
		new_stylebox.draw_center = false
	return new_stylebox


func set_antialiasing(new_stylebox: StyleBoxFlat, antialiasing_string: String) -> StyleBoxFlat:
	if "on" in antialiasing_string:
		new_stylebox.anti_aliasing = true
	elif "off" in antialiasing_string:
		new_stylebox.anti_aliasing = false
	return new_stylebox


func set_antialiasing_size(new_stylebox: StyleBoxFlat, antialiasing_size_string: String) -> StyleBoxFlat:
	var values: Array = antialiasing_size_string.split("_")
	if len(values) < 2: return new_stylebox
	new_stylebox.anti_aliasing_size = float(values[1])
	return new_stylebox
