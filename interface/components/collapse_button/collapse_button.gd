class_name CollapseButton
extends Button

const Icon := preload("res://static/icons/caret_down_28x28.svg")

enum { LEFT, RIGHT }

@export_enum(LEFT, RIGHT) var icon_side := LEFT
@export var icon_modulate := Color.WHITE

var icon_margin := 24
var icon_size := Icon.get_size()

var _icon_offset: Vector2:
	get: match icon_side:
		LEFT: return Vector2(icon_margin, -2)
		_:    return Vector2(-icon_margin, 2)

var icon_position: Vector2:
	get: 
		var pos := _icon_offset
		match icon_side:
			LEFT: pos += size * Vector2(0, 0.5) - icon_size * Vector2(0, 0.5)
			_:    pos += size * Vector2(1, 0.5) - icon_size * Vector2(1, 0.5)
		if button_pressed: pos.y = icon_size.y + _icon_offset.y
		return pos

var font: Font = get_theme_font("font", theme_type_variation)
var font_size: int = get_theme_font_size("font_size", theme_type_variation)
var pressed_font_color: Color = get_theme_color("font_pressed_color", theme_type_variation)
var pressed_stylebox: StyleBoxFlat = get_theme_stylebox("pressed", theme_type_variation)

@onready var target: Control = get_child(0) if get_child_count() > 0 else null

var _start_text: String = text
var _start_text_size: Vector2 = font.get_string_size(_start_text, alignment, -1, font_size)
var _start_size: Vector2 = size
var _pressed_text_position: Vector2:
	get: return _start_size / 2 - _start_text_size * Vector2(0.5, 0) + Vector2(0, pressed_stylebox.content_margin_top / 2.0)


func _enter_tree() -> void:
	clip_children = CanvasItem.CLIP_CHILDREN_MAX
	clip_contents = true
	toggle_mode = true
	
	if not pressed.is_connected(_on_toggled):
		pressed.connect(_on_toggled)


func _ready() -> void:
	if target: 
		target.visible = false
		target.show_behind_parent = true


func _draw() -> void:
	if button_pressed: 
		draw_string(font, _pressed_text_position, _start_text, alignment, -1, font_size, pressed_font_color)
		draw_set_transform(icon_position + icon_size, deg_to_rad(180))
	else: draw_set_transform(icon_position)
	draw_texture_rect(Icon, Rect2(Vector2.ZERO, icon_size), false, icon_modulate)


func _on_toggled() -> void:
	if target:
		if button_pressed: 
			target.visible = true
			size = target.size + target.position + Vector2(0, _start_size.y)
			target.offset_top = _start_size.y
			text = ""
		else:
			target.visible = false
			size = _start_size
			target.offset_top = 0
			text = _start_text
