@tool
class_name ThoughtBubble
extends PanelContainer
@icon("thought_bubble.svg")

const panel: StyleBoxFlat = preload("thought_bubble_panel.tres")
const mat: ShaderMaterial = preload("thought_bubble.tres")

enum DotPosition {
	TOP_LEFT,
	TOP,
	TOP_RIGHT,
	LEFT,
	RIGHT,
	BOTTOM_LEFT,
	BOTTOM,
	BOTTOM_RIGHT
}

@export var start_open: bool = false
@export var animation_duration: float = 0.35

var _animation_duration := (
	animation_duration if Engine.is_editor_hint()
	else animation_duration if not Settings.data.limit_animations 
	else 0.0
)

@export var test_open: bool = false:
	set(value):
		test_open = value
		if test_open: open()
		else: close()

@export var reload_material: bool = false:
	set(_value):
		_update_material()

@export var reload_panel: bool = false:
	set(_value):
		_update_panel()

@export_category("Dots")
@export var show_dots: bool = true:
	set(value):
		show_dots = value
		_update_dots()

@export var dots_position: DotPosition = DotPosition.BOTTOM_RIGHT:
	set(value):
		dots_position = value
		_update_dots_position()

@export_category("Styles")
@export var bg_color: Color = Color("#18181b"):
	set(value):
		bg_color = value
		_update_bg_color()
			
@export var content_margin_top: float = 0.0:
	set(value):
		content_margin_top = value
		_update_margins()

@export var content_margin_left: float = 0.0:
	set(value):
		content_margin_left = value
		_update_margins()

@export var content_margin_bottom: float = 0.0:
	set(value):
		content_margin_bottom = value
		_update_margins()

@export var content_margin_right: float = 0.0:
	set(value):
		content_margin_right = value
		_update_margins()
		
var dots_pos: Vector2:
	get: return {
			DotPosition.TOP_LEFT: Vector2(0.2, 0.2),
			DotPosition.TOP: Vector2(0.5, 0.2),
			DotPosition.TOP_RIGHT: Vector2(0.8, 0.2),
			DotPosition.LEFT: Vector2(0.2, 0.5),
			DotPosition.RIGHT: Vector2(0.8, 0.5),
			DotPosition.BOTTOM_LEFT: Vector2(0.2, 0.8),
			DotPosition.BOTTOM: Vector2(0.5, 0.8),
			DotPosition.BOTTOM_RIGHT: Vector2(0.8, 0.8)
		}[dots_position]

var new_panel := panel


func _enter_tree() -> void:
	_update_material()
	_update_panel()
	
	if start_open: _reset_opened()
	else: _reset_closed()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or is_inside_tree():
		size.x = max(size.x, size.y)
		size.y = max(size.x, size.y)


func open() -> void:
	if Engine.is_editor_hint() or is_inside_tree():
		rotation = deg_to_rad(-25)
		pivot_offset = size * dots_pos
		var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", 1.0, _animation_duration)
		tween.set_trans(Tween.TRANS_CUBIC).tween_method(
			func(offset: float) -> void: 
				material.set_shader_parameter("center_offset", Vector2(0, offset)),
			0.2,
			0.0,
			_animation_duration
		)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), _animation_duration)
		tween.tween_property(self, "rotation", 0.0, _animation_duration)
		await tween.finished


func close() -> void:
	if Engine.is_editor_hint() or is_inside_tree():
		pivot_offset = size * dots_pos
		var tween := create_tween().set_parallel().set_ease(Tween.EASE_IN)
		tween.tween_property(self, "modulate:a", 0.0, _animation_duration)
		tween.set_trans(Tween.TRANS_CUBIC).tween_method(
			func(offset: float) -> void: 
				material.set_shader_parameter("center_offset", Vector2(0, offset)),
			0.0,
			0.2,
			_animation_duration
		)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(self, "scale", Vector2(0.25, 0.25), _animation_duration)
		tween.tween_property(self, "rotation", deg_to_rad(-15), _animation_duration)
		await tween.finished


func _reset_opened() -> void:
	modulate.a = 1.0
	scale = Vector2.ONE
	rotation = 0.0


func _reset_closed() -> void:
	modulate.a = 0.0
	scale = Vector2(0.25, 0.25)
	rotation = deg_to_rad(-15.0)


func _update_panel() -> void:
	new_panel = panel.duplicate()
	add_theme_stylebox_override("panel", new_panel)
	_update_margins()


func _update_material() -> void:
	material = mat.duplicate(true)
	_update_dots()
	_update_bg_color()
	_update_seed()
	_update_dots_position()


func _update_dots() -> void:
	if is_inside_tree() or Engine.is_editor_hint():
		material.set_shader_parameter("show_dots", show_dots)


func _update_bg_color() -> void:
	if is_inside_tree() or Engine.is_editor_hint():
		material.set_shader_parameter("blob_color", bg_color)


func _update_seed() -> void:
	if is_inside_tree() or Engine.is_editor_hint():
		((material.get_shader_parameter("noise") as NoiseTexture2D).noise as FastNoiseLite).seed = randi()


func _update_dots_position() -> void:
	if is_inside_tree() or Engine.is_editor_hint():		
		(material as ShaderMaterial).set_shader_parameter("dots_position", dots_pos)


func _update_margins() -> void:
	for margin in ["top", "right", "bottom", "left"]:
		var m_name: String = "content_margin_" + margin
		new_panel[m_name] = panel[m_name] + self[m_name]
