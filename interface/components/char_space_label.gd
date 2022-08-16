extends Control

enum HAlign { LEFT, CENTER, RIGHT }
enum VAlign { TOP, CENTER, BOTTOM }

@export_multiline var text := ""
@export var char_spacing: float
@export var label_settings: LabelSettings
@export var horizontal_alignment: HAlign = HAlign.LEFT
@export var vertical_alignment: VAlign = VAlign.CENTER
@export var max_lines_visible: int = -1

var font: Font
var font_size: int
var font_color: Color


func _ready() -> void:
	if label_settings:
		if label_settings.font: font = label_settings.font
		else: font = get_theme_font("font", "")
		font_size = label_settings.font_size
		font_color = label_settings.font_color
	else:
		font = get_theme_font("font", "")
		font_size = get_theme_font_size("font_size", "")
		font_color = get_theme_color("font_color", "")


func _draw() -> void:
	var string = DrawSpacedString.new(font, font_size, font_color, text, char_spacing, horizontal_alignment, size.x)
	string.draw_at(self, _get_text_pos(string))


func _get_text_pos(string: DrawSpacedString) -> Vector2:
	var pos := Vector2.ZERO
	var s := string.size
	match horizontal_alignment:
		HAlign.LEFT: pass
		HAlign.CENTER: pos.x += (size.x - s.x) / 2
		HAlign.RIGHT: pos.x += size.x - s.x
	match vertical_alignment:
		VAlign.TOP: pass
		VAlign.CENTER: pos.y += (size.y - s.y) / 2
		VAlign.BOTTOM: pos.y += size.y - s.y
	return pos
