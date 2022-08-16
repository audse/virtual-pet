@tool
class_name TitleLabel
extends Control
@icon("title_label.svg")

enum HorizontalAlignment {
	LEFT = HORIZONTAL_ALIGNMENT_LEFT,
	CENTER = HORIZONTAL_ALIGNMENT_CENTER,
	RIGHT = HORIZONTAL_ALIGNMENT_RIGHT
}

enum VerticalAlignment {
	TOP = VERTICAL_ALIGNMENT_TOP,
	CENTER = VERTICAL_ALIGNMENT_CENTER,
	BOTTOM = VERTICAL_ALIGNMENT_BOTTOM,
}

@export_category("Text")

@export var overline: String = "":
	set(value):
		overline = value
		_update_overline("string", value)

@export var title: String = "":
	set(value):
		title = value
		_update_title("string", value)

## The subtext which appears under the title.
@export_multiline var subtitle: String = "":
	set(value):
		subtitle = value
		_update_subtitle("string", value)

@export_category("Overrides")

@export_subgroup("Colors")
@export var overline_color: Color:
	set(value):
		overline_color = value
		_update_overline("color", value)

@export var title_color: Color:
	set(value):
		title_color = value
		_update_subtitle("color", subtitle_color)
		_update_title("color", value)

## By default, the subtitle color is a faded version of the 
## title color, but an override can be added.
@export var override_subtitle_color: bool = false:
	set(value):
		override_subtitle_color = value
		_update_subtitle("color", subtitle_color)

@export var subtitle_color: Color:
	get:
		if override_subtitle_color: return subtitle_color
		else: return (
			ColorRef.new(title_color)
				.and_alpha(-0.35)
				.and_saturate(0.2)
				.done()
		)
	set(value):
		subtitle_color = value
		_update_subtitle("color", subtitle_color)

@export_subgroup("Fonts")
@export var overline_font: Font:
	set(value):
		overline_font = value
		_update_overline("font", value)

@export var title_font: Font:
	set(value):
		title_font = value
		_update_title("font", value)

@export var subtitle_font: Font:
	set(value):
		subtitle_font = value
		_update_subtitle("font", value)


@export_subgroup("Sizes")
@export var override_overline_size: bool:
	set(value):
		overline_size = value
		_update_overline("font_size", overline_size)

## Defaults to 0.65 x title size
@export var overline_size: int = -1:
	get:
		if override_overline_size: return overline_size
		else: return -1
	set(value):
		if override_overline_size: 
			overline_size = value
			_update_overline("font_size", overline_size)

var _overline_size: int:
	get:
		if override_overline_size: return overline_size
		else: return int(title_size * 0.5)

## Defaults to 1.75 x theme default size
@export var title_size: int = -1:
	get:
		if title_size > 0: return title_size
		else: return int(default_size * 1.75)
	set(value):
		title_size = value
		_update_title("font_size", value)
		if not override_overline_size: _update_overline("font_size", _overline_size)
		if not override_subtitle_size: _update_subtitle("font_size", _subtitle_size)

@export var override_subtitle_size: bool:
	set(value):
		override_subtitle_size = value
		_update_title("font_size", value)

## Defaults to 0.85 x title size
@export var subtitle_size: int = -1:
	get:
		if override_subtitle_size: return subtitle_size
		else: return -1
	set(value):
		if override_subtitle_size:
			subtitle_size = value
			_update_subtitle("font_size", _subtitle_size)

var _subtitle_size: int:
	get:
		if override_overline_size: return subtitle_size
		else: return int(title_size * 0.85)

@export_subgroup("Alignment")
@export var h_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment:
	set(value):
		h_alignment = value
		if overline_string: overline_string.h_align = h_alignment
		if title_string: title_string.h_align = h_alignment
		if subtitle_string: subtitle_string.h_align = h_alignment
		if is_inside_tree(): update()

@export var v_alignment: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment:
	set(value):
		v_alignment = value
		if is_inside_tree(): update()

@export_subgroup("Line margin")
## If not set, defaults to 0.75 x font size. 
## This is the distance of the title from the subtitle.
@export var line_margin: float = -1.0:
	set(value):
		line_margin = value
		if is_inside_tree(): update()

## Defines distance of overline from title
## If not set, defaults to 0.5 x line_margin
@export var overline_line_margin: float = -1.0:
	set(value):
		overline_line_margin = value
		if is_inside_tree(): update()

@export_subgroup("Misc settings")
@export var overline_char_spacing: float = 0.5:
	set(value):
		overline_char_spacing = value
		_update_overline("spacing", value)

@export var title_char_spacing: float = -1.0:
	set(value):
		title_char_spacing = value
		_update_title("spacing", value)

@export var subtitle_char_spacing: float = -1.0:
	set(value):
		subtitle_char_spacing = value
		_update_subtitle("spacing", value)

var default_font: Font = get_theme_default_font()
var default_size: float = get_theme_default_font_size()

var full_height: float:
	get: 
		var h = 0.0
		if len(overline) > 0: 
			h += overline_string.size.y
			if len(title) > 0: h += overline_line_margin
		if len(title) > 0: 
			h += title_string.size.y
			if len(subtitle) > 0: h += line_margin
		if len(subtitle) > 0: h += subtitle_string.size.y
		return h

var _start_y_pos: float:
	get: match v_alignment:
		VERTICAL_ALIGNMENT_TOP: return 0.0
		VERTICAL_ALIGNMENT_CENTER: return (size.y - full_height) / 2
		VERTICAL_ALIGNMENT_BOTTOM, _: return size.y - full_height
	

var _overline_position: Vector2:
	get:	
		var pos := Vector2(0, _start_y_pos)
		match h_alignment:
			HORIZONTAL_ALIGNMENT_CENTER: pos.x = (size.x - overline_string.size.x) / 2
			HORIZONTAL_ALIGNMENT_RIGHT: pos.x = size.x - overline_string.size.x
		return pos

var _title_position: Vector2:
	get:
		var pos := Vector2(0, _start_y_pos)
		if len(title) > 0: pos.y = _overline_position.y + overline_string.size.y + overline_line_margin
		match h_alignment:
			HORIZONTAL_ALIGNMENT_CENTER: pos.x = (size.x - title_string.size.x) / 2
			HORIZONTAL_ALIGNMENT_RIGHT: pos.x = size.x - title_string.size.x
		return pos

var _subtitle_position: Vector2:
	get:
		var pos := Vector2(0, _start_y_pos)
		if len(subtitle) > 0: pos.y = _title_position.y + title_string.size.y + line_margin
		match h_alignment:
			HORIZONTAL_ALIGNMENT_CENTER: pos.x = (size.x - subtitle_string.size.x) / 2
			HORIZONTAL_ALIGNMENT_RIGHT: pos.x = size.x - subtitle_string.size.x
		return pos

var overline_string: DrawSpacedString
var title_string: DrawSpacedString
var subtitle_string: DrawSpacedString


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			if overline_string: overline_string.max_width = size.x
			if title_string: title_string.max_width = size.x
			if subtitle_string: subtitle_string.max_width = size.x
		
		NOTIFICATION_ENTER_TREE, NOTIFICATION_VISIBILITY_CHANGED:
			# set unset fonts
			if not overline_font: overline_font = default_font
			if not title_font: title_font = default_font
			if not subtitle_font: subtitle_font = default_font
			
			# set unset font sizes
			if title_size < 0: title_size = (default_size * 1.75) as int
			
			if line_margin < 0: line_margin = default_size * 0.75
			if overline_line_margin < 0: overline_line_margin = line_margin * 0.5

			if not overline_string: overline_string = DrawSpacedString.new(overline_font, overline_size, overline_color, overline, overline_char_spacing, h_alignment, size.x)
			if not title_string: title_string = DrawSpacedString.new(title_font, title_size, title_color, title, title_char_spacing, h_alignment, size.x)
			if not subtitle_string: subtitle_string = DrawSpacedString.new(subtitle_font, subtitle_size, subtitle_color, subtitle, subtitle_char_spacing, h_alignment, size.x)


func _draw() -> void:
	overline_string.draw_at(self, _overline_position)
	title_string.draw_at(self, _title_position)
	subtitle_string.draw_at(self, _subtitle_position)


func _update_overline(prop: String, value) -> void:
	if overline_string: overline_string.set(prop, value)
	if is_inside_tree(): update()


func _update_title(prop: String, value) -> void:
	if title_string: title_string.set(prop, value)
	if is_inside_tree(): update()


func _update_subtitle(prop: String, value) -> void:
	if subtitle_string: subtitle_string.set(prop, value)
	if is_inside_tree(): update()
