@tool
class_name StyleSheet
extends Resource

#StyleSheet
#
# #TODO stylebox
#- [x] Shadow size
#- [x] Shadow color
#- [x] Shadow opacity
#- [x] Border blend
#- [x] Draw center
#- [x] Corner detail
#- [x] Antialiasing bool
#- [x] Antialising size
#
# #TODO font
#- [ ] Outline size
#- [ ] Outline color
#- [ ] Spacing
#  - [ ] Top
#  - [ ] Bottom
#  - [ ] Char
#  - [ ] Space
#- [ ] Color opacity
#- [ ] Outline opacity
#
# #TODO other constants
#- [ ] Button h separation


@export_multiline var apply_styles := "":
	set(value):
		apply_styles = value
		send_update()

@export var default_style_names := "normal":
	set(value):
		default_style_names = value
		send_update()


func send_update() -> void:
	pass


func parse_style_name(style_string: String) -> Dictionary:
	var value := {
		name = default_style_names,
		string = style_string
	}
	var colon_position: int = style_string.find(":")
	if colon_position != -1 and colon_position < len(style_string):
		value.name = style_string.split(":")[0].strip_edges()
		value.string = style_string.right(colon_position + 1).strip_edges()
	return value


static func parse_color_string(color_string: String) -> Color:
	var values := color_string.split("_")
	if len(values) <= 2: return Color.WHITE
	var color_name: String = values[1].strip_edges()
	var color_number := values[2].strip_edges().to_int()
	if (
		"PALETTE" in StyleSheetConstants 
		and color_name in StyleSheetConstants.PALETTE
		and color_number in StyleSheetConstants.PALETTE[color_name]
	):
		return StyleSheetConstants.PALETTE[color_name][color_number]
	
	return Color.WHITE


func get_default_style_names() -> Array[String]:
	var style_names: Array = default_style_names.split(" ")
	var clean_style_names := []
	for style_name in style_names:
		clean_style_names.append(style_name.strip_edges())
	return clean_style_names
