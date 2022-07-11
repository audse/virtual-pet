@tool
extends Button

const Paint = States.PaintState
const Shape = Paint.Shape

const BUTTON_SIZE = Vector2(75, 75)
const TEXTURE_SIZE = Vector2(60, 60)

@export var shape: States.PaintState.Shape = Shape.SQUARE
@export var reload: bool = false:
	get: return false
	set(_value): remake_texture()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED, NOTIFICATION_VISIBILITY_CHANGED:
			remake_texture()


func _ready() -> void:
	remake_texture()
	pressed.connect(set_shape.bind(shape))
	States.Paint.shape_changed.connect(_on_shape_changed)
	States.Paint.action_changed.connect(_on_action_changed)
	States.Paint.rotation_changed.connect(_on_rotation_changed)


func set_shape(value: int) -> void:
	States.Paint.shape = value


func get_texture() -> Texture:
	return States.PaintState.ShapeTexture[shape]


func remake_texture() -> void:
	var texture_rect
	if get_child_count() > 0:
		texture_rect = get_child(0)
		if texture_rect:
			remove_child(texture_rect)
	texture_rect = TextureRect.new()
	add_child(texture_rect)
	
	texture_rect.texture = get_texture()
	texture_rect.ignore_texture_size = true
	texture_rect.pivot_offset = TEXTURE_SIZE / 2
	texture_rect.size = TEXTURE_SIZE
	texture_rect.position = (BUTTON_SIZE - TEXTURE_SIZE) / 2
	texture_rect.set_anchors_preset(Control.PRESET_CENTER)
	custom_minimum_size = BUTTON_SIZE
	size = BUTTON_SIZE
	modulate = States.Paint.color


func _on_shape_changed(new_shape: int) -> void:
	theme_type_variation = "" if new_shape != shape else "SuccessButton"


func _on_action_changed(new_action: int) -> void:
	disabled = new_action == Paint.Action.ERASE


func _on_rotation_changed(value: int) -> void:
	# Stops shape from flipping 
	var texture_rect = get_child(0)
	if texture_rect:
		var curr = rad2deg(texture_rect.rotation)
		if curr >= 359 and value <= 91:
			texture_rect.rotation = 0
		elif curr <= 1 and value >= 269:
			texture_rect.rotation = deg2rad(360)
		
		var delay := 0.05 * shape
		(get_tree()
			.create_tween()
			.tween_property(texture_rect, "rotation", deg2rad(value), 0.1 + delay)
			.set_ease(Tween.EASE_IN_OUT)
			.set_trans(Tween.TRANS_CIRC))
