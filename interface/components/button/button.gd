@tool
class_name LibButton
extends Button

signal pressed_left
signal pressed_right
signal pressed_top
signal pressed_bottom
signal long_pressed

enum BlendMode {
	MIX = 1,
	ADD = 2,
	MULTIPLY = 3,
}

const DrawModeNames := {
	DRAW_DISABLED: "disabled",
	DRAW_HOVER: "hover",
	DRAW_HOVER_PRESSED: "hover_pressed",
	DRAW_NORMAL: "normal",
	DRAW_PRESSED: "pressed"
}

@export var test_press: bool:
	set(_value):
		if Engine.is_editor_hint() and get_tree():
			button_down.emit()
			await get_tree().create_timer(0.1).timeout
			button_up.emit()

@export var enable_long_press: bool = false


@export_group("Animations")

@export var circle_color := Color(1, 1, 1, 0.5):
	set(value):
		circle_color = value
		gradient.colors = _gradient_colors

## if `true`, this button will float up and down to give it a little more liveliness
@export var floating := false

@export var circle_blend_mode: BlendMode = BlendMode.MIX:
	set(value):
		circle_blend_mode = value
		match circle_blend_mode:
			BlendMode.MIX: mat.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
			BlendMode.ADD: mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			BlendMode.MULTIPLY: mat.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
		gradient.colors = _gradient_colors

@export_group("Icons")

@export var icon_left: Texture2D:
	set(value):
		icon_left = value
		queue_redraw()

@export var icon_right: Texture2D:
	set(value):
		icon_right = value
		queue_redraw()

@export var icon_top: Texture2D:
	set(value):
		icon_top = value
		queue_redraw()

@export var icon_bottom: Texture2D:
	set(value):
		icon_bottom = value
		queue_redraw()

@export var icon_modulate_left := Color.WHITE:
	set(value):
		icon_modulate_left = value
		queue_redraw()

@export var icon_modulate_right := Color.WHITE:
	set(value):
		icon_modulate_right = value
		queue_redraw()

@export var icon_modulate_top := Color.WHITE:
	set(value):
		icon_modulate_top = value
		queue_redraw()

@export var icon_modulate_bottom := Color.WHITE:
	set(value):
		icon_modulate_bottom = value
		queue_redraw()

@export var shrink_icon_left := 0.0:
	set(value):
		shrink_icon_left = value
		queue_redraw()

@export var shrink_icon_right := 0.0:
	set(value):
		shrink_icon_right = value
		queue_redraw()

@export var shrink_icon_top := 0.0:
	set(value):
		shrink_icon_top = value
		queue_redraw()

@export var shrink_icon_bottom := 0.0:
	set(value):
		shrink_icon_bottom = value
		queue_redraw()

@export_group("Gradient overlay")

@export var gradient_overlay: GradientTexture2D:
	set(value):
		gradient_overlay = value
		overlay.texture = gradient_overlay
		if is_inside_tree() or Engine.is_editor_hint():
			gradient_overlay.width = size.x
			gradient_overlay.height = size.y
		queue_redraw()

@export var gradient_blend_mode: BlendMode = BlendMode.MIX:
	set(value):
		gradient_blend_mode = value
		match gradient_blend_mode:
			BlendMode.MIX: overlay_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
			BlendMode.ADD: overlay_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			BlendMode.MULTIPLY: overlay_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
		queue_redraw()

var circle := Sprite2D.new()
var texture := GradientTexture2D.new()
var gradient := Gradient.new()
var mat := CanvasItemMaterial.new()
var overlay := Sprite2D.new()
var overlay_mat := CanvasItemMaterial.new()

var _tweens_connected := false
var _gradient_colors: PackedColorArray:
	get: return PackedColorArray([
			circle_color,
			Color(circle_color, 0.0) if circle_blend_mode != BlendMode.MULTIPLY else Color(1, 1, 1, 0.0),
		])

@onready var _start_rotation := rotation

var is_pressing := false
var time_since_press := 0.0


func _enter_tree() -> void:
	clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	
	if not button_down.is_connected(_on_button_down):
		button_down.connect(_on_button_down)
	
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	
	gradient.offsets = PackedFloat32Array([0.0, 0.0])
	gradient.colors = _gradient_colors
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1, 0.5)
	texture.width = max(size.x, size.y) * 1.25
	texture.height = texture.width
	
	circle.texture = texture
	circle.material = mat
	circle.position = size / 2
	
	overlay.position = size / 2
	overlay.material = overlay_mat


func _ready() -> void:
	if not circle.is_inside_tree(): add_child(circle)
	if not overlay.is_inside_tree(): add_child(overlay)
	
	if not _tweens_connected:
		Ui.press_scale(self)
		Ui.hover_scale(self)
		if floating and not Engine.is_editor_hint(): 
			Ui.floating(self)
		_tweens_connected = true
	
	long_pressed.connect(func() -> void: print("long pressed!"))


func _process(delta: float) -> void:
	if enable_long_press and is_pressing:
		time_since_press += delta
		queue_redraw()


func _draw() -> void:
	draw_icons()
	if enable_long_press and is_pressing and time_since_press > 0.25:
		draw_long_press_circle((time_since_press - 0.25) * 3.0)


func _on_button_down() -> void:
	is_pressing = true
	if enable_long_press:
		get_tree().create_timer(0.5).timeout.connect(
			func() -> void:
				if is_pressing: long_pressed.emit(),
			CONNECT_ONE_SHOT
		)
	circle.position = get_local_mouse_position().clamp(size * 0.1, size * 0.9)
	
	tween_button_down()
	await button_up
	
	is_pressing = false
	time_since_press = 0.0
	await tween_button_up()
	reset_circle()


func _on_pressed() -> void:
	var pos := get_local_mouse_position()
	var side_signals := {
		left = pressed_left,
		right = pressed_right,
		bottom = pressed_bottom,
		top = pressed_top
	}
	for side in side_signals.keys():
		if is_pos_on_side(side, pos): side_signals[side].emit()


func is_pos_on_side(side: String, pos: Vector2) -> bool:
	var start := size / 3
	var end := start * 2
	match side:
		"left": return pos.x < start.x
		"right": return pos.x > end.x
		"top": return pos.y < start.y
		"bottom": return pos.y > end.y
		_: return false


func tween_button_down() -> void:
	if circle.is_inside_tree():
		var tween := circle.create_tween().set_parallel()
		tween.tween_method(tween_circle, 0.0, 0.4, Ui.time(0.15))
		tween.tween_property(self, "rotation", deg_to_rad(2.5), Ui.time(0.15))


func tween_button_up() -> void:
	if circle.is_inside_tree():
		var tween := circle.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_method(tween_circle, 0.4, 1.0, Ui.time(0.3))
		tween.parallel().tween_property(self, "rotation", deg_to_rad(-2.5), Ui.time(0.15))
		tween.set_ease(Tween.EASE_IN_OUT).tween_property(self, "rotation", 0.0, Ui.time(0.15))
		await tween.finished


func tween_circle(percent: float) -> void:
	gradient.set_offset(1, percent)
	gradient.set_color(0, Color(
		circle_color if circle_blend_mode != BlendMode.MULTIPLY else circle_color.lerp(Color.WHITE, percent),
		clampf(1.0 - percent, 0.01, 1.0) * circle_color.a
	))


func reset_circle() -> void:
	circle.modulate.a = 1.0
	gradient.set_offset(1, 0.0)
	gradient.colors = _gradient_colors


func draw_icons() -> void:
	var font_size := get_theme_font_size("font_size")
	var draw_mode := get_draw_mode()
	var stylebox := get_theme_stylebox(DrawModeNames[draw_mode], theme_type_variation)
	
	var icon_size := func(shrink: float, side: String) -> Vector2: 
		var is_on_side := is_pos_on_side(side, get_local_mouse_position())
		var val := (Vector2(font_size, font_size) - Vector2(shrink, shrink)) 
		if draw_mode == DRAW_PRESSED and is_on_side: val *= 1.75
		return val
	
	var size_left = icon_size.call(shrink_icon_left, "left")
	var size_right = icon_size.call(shrink_icon_right, "right")
	var size_top = icon_size.call(shrink_icon_top, "top")
	var size_bottom = icon_size.call(shrink_icon_bottom, "bottom")
	
	var pos_left := Vector2(
		stylebox.content_margin_left - (size_left.x / 2),
		(size.y / 2) - (size_left.y / 2)
	)
	var pos_right := Vector2(
		size.x - (size_right.x / 2) - stylebox.content_margin_right,
		(size.y / 2) - (size_right.y / 2)
	)
	var pos_top := Vector2(
		(size.x / 2) - (size_top.x / 2),
		stylebox.content_margin_top - (size_top.x / 2)
	)
	var pos_bottom := Vector2(
		(size.x / 2) - (size_bottom.x / 2),
		size.y - stylebox.content_margin_bottom - (size_bottom.x / 2)
	)
	if icon_left: draw_texture_rect(icon_left, Rect2(pos_left, size_left), false, icon_modulate_left)
	if icon_right: draw_texture_rect(icon_right, Rect2(pos_right, size_right), false, icon_modulate_right)
	if icon_top: draw_texture_rect(icon_top, Rect2(pos_top, size_top), false, icon_modulate_top)
	if icon_bottom: draw_texture_rect(icon_bottom, Rect2(pos_bottom, size_bottom), false, icon_modulate_bottom)


func draw_long_press_circle(percent: float) -> void:
	var radius := maxf(size.x, size.y) * 0.4
	draw_arc(get_local_mouse_position(), radius, deg_to_rad(-90), deg_to_rad(270) * clampf(percent, 0.0, 1.0), 180, circle_color, 20.0, true)
