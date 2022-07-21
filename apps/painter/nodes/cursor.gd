extends Sprite2D

const Paint = States.PaintState
const Size = Paint.Size

@onready var shadows = [
	%Cursor/Shadow, 
	%Cursor/Shadow/Shadow2, 
	%Cursor/Shadow/Shadow3, 
	%Cursor/Shadow/Shadow4,
]


func _ready() -> void:
	States.Paint.size_changed.connect(resize)
	States.Paint.ratio_changed.connect(resize)
	States.Paint.action_changed.connect(_on_change_action)
	States.Paint.color_changed.connect(_on_color_changed)
	States.Paint.shape_changed.connect(_on_change_shape)
	States.Paint.rotation_changed.connect(_on_rotation_changed)
	modulate = Color("#a3a3a3")


func move_by_unit(keycode: int) -> void:
	var unit: Vector2 = States.Paint.size_px
	var target: Vector2 = position
	match keycode:
		KEY_W: target.y -= unit.y
		KEY_A: target.x -= unit.x
		KEY_S: target.y += unit.y
		KEY_D: target.x += unit.x
	move_to(target)


func move_to(pos: Vector2) -> void:
	(get_tree()
		.create_tween()
		.tween_property(self, "position", pos, 0.05)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))


func _on_change_shape(new_shape: int) -> void:
	shape(States.PaintState.ShapeTexture[new_shape])


func _on_change_action(new_action: int) -> void:
	match new_action:
		Paint.Action.ERASE: self_modulate.a = 0
		_: self_modulate.a = 1


func _on_color_changed(new_color: Color) -> void:
	self_modulate = new_color


func _on_rotation_changed(value: int) -> void:
	(get_tree()
		.create_tween()
		.tween_property(self, "rotation", deg2rad(value), 0.15)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))


# Cursor SVG files are 500 px, so this converts to the correct scale
# e.g. a 50px grid has a scale of 0.1
func cursor_scale() -> float:
	return States.Paint.size_px.x / 500.0


func get_offset() -> Vector2:
	var start: Vector2 = States.Paint.size_px / 2.0
	
	match States.Paint.rotation:
		270: return start * Vector2(-1, 1)
		180: return start
		90:  return start * Vector2(1, -1)
	return start * -1


func into_pixel() -> Sprite2D:
	var p: Sprite2D = self.duplicate()
	var shadow = p.get_child(0)
	if shadow: shadow.queue_free()
	p.set_script(null)
	p.modulate.a = 1.0
	p.self_modulate.a = 1.0
	return p


func shape(tex: Texture) -> void:
	texture = tex
	for shadow in shadows:
		shadow.texture = tex


func resize(_to: int) -> void:
	var width: float = cursor_scale()
	var new_size = Vector2(width, width)
	(get_tree()
		.create_tween()
		.tween_property(self, "scale", new_size, 0.15)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))
