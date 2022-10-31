extends Button

const BUTTON_SIZE = Vector2(80, 80)
const TEXTURE_SIZE = Vector2(60, 60)

@export var shape: PaintState.Shape = PaintState.Shape.SQUARE

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED, NOTIFICATION_VISIBILITY_CHANGED:
			queue_redraw()


func _ready() -> void:
	queue_redraw()
	pressed.connect(set_shape.bind(shape))
	if not Engine.is_editor_hint():
		States.Paint.shape_changed.connect(_on_shape_changed)
		States.Paint.action_changed.connect(_on_action_changed)
		States.Paint.rotation_changed.connect(_on_rotation_changed)


func set_shape(value: int) -> void:
	States.Paint.shape = value


func get_texture() -> Texture:
	return PaintState.ShapeTexture[shape]


func _draw() -> void:
	draw_texture_rect(get_texture(), Rect2((BUTTON_SIZE - TEXTURE_SIZE) / 2, TEXTURE_SIZE), false, States.Paint.color)


func _on_shape_changed(new_shape: int) -> void:
	theme_type_variation = "" if new_shape != shape else "Selected_Button"


func _on_action_changed(new_action: int) -> void:
	disabled = new_action == PaintState.Action.ERASE


func _on_rotation_changed(value: int) -> void:
	# Stops shape from flipping 
	var texture_rect = get_child(0)
	if texture_rect:
		var curr = rad_to_deg(texture_rect.rotation)
		if curr >= 359 and value <= 91:
			texture_rect.rotation = 0
		elif curr <= 1 and value >= 269:
			texture_rect.rotation = deg_to_rad(360)
		
		var delay := 0.05 * shape
		(get_tree()
			.create_tween()
			.tween_property(texture_rect, "rotation", deg_to_rad(value), 0.1 + delay)
			.set_ease(Tween.EASE_IN_OUT)
			.set_trans(Tween.TRANS_CIRC))
