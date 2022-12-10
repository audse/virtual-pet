extends Button

const BUTTON_SIZE = Vector2(80, 80)
const TEXTURE_SIZE = Vector2(60, 60)
const RECT :=  Rect2((BUTTON_SIZE - TEXTURE_SIZE) / 2, TEXTURE_SIZE)

@export var shape: PaintState.Shape = PaintState.Shape.SQUARE


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED, NOTIFICATION_VISIBILITY_CHANGED: queue_redraw()


func _ready() -> void:
	queue_redraw()
	pressed.connect(set_shape.bind(shape))
	if not Engine.is_editor_hint():
		States.Paint.shape_changed.connect(_on_shape_changed)
		States.Paint.action_changed.connect(_on_action_changed)
		States.Paint.rotation_changed.connect(func(_val): queue_redraw())


func set_shape(value: int) -> void:
	States.Paint.shape = value


func get_texture() -> Texture:
	return PaintState.ShapeTexture[shape]


func get_rect_position() -> Vector2:
	return (RECT.end - RECT.size).rotated(deg_to_rad(States.Paint.rotation)) + Vector2(
		RECT.end.x + RECT.position.x if States.Paint.rotation in [90, 180] else 0.0,
		RECT.end.y + RECT.position.y if States.Paint.rotation in [180, 270] else 0.0
	)


func _draw() -> void:
	draw_set_transform(get_rect_position(), deg_to_rad(States.Paint.rotation))
	draw_texture_rect(get_texture(), Rect2(Vector2.ZERO, TEXTURE_SIZE), false, States.Paint.color)


func _on_shape_changed(new_shape: int) -> void:
	theme_type_variation = "TagButton" if new_shape != shape else "TagButton_Selected"


func _on_action_changed(new_action: int) -> void:
	disabled = new_action == PaintState.Action.ERASE
