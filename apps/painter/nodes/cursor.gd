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
	States.Paint.action_changed.connect(_on_action_changed)


func _on_action_changed(new_action: int) -> void:
	match new_action:
		Paint.Action.ERASE: self_modulate.a = 0
		_: self_modulate.a = 1


# Cursor SVG files are 500 px, so this converts to the correct scale
# e.g. a 50px grid has a scale of 0.1
func cursor_scale() -> float:
	return States.Paint.size_px().x / 500.0


func get_offset() -> Vector2:
	var start: Vector2 = States.Paint.size_px() / 2
	
	match States.Paint.get_rotation():
		270: return start * Vector2(-1, 1)
		180: return start
		90: return start * Vector2(1, -1)
	return start * -1


func into_pixel() -> Sprite2D:
	var p: Sprite2D = self.duplicate()
	var shadow = p.get_child(0)
	if shadow: shadow.queue_free()
	p.set_script(null)
	return p


func shape(tex: Texture) -> void:
	texture = tex
	for shadow in shadows:
		shadow.texture = tex


func color(c: Color) -> void:
	self_modulate = c


func resize(_to: int) -> void:
	var width: float = cursor_scale()
	var new_size = Vector2(width, width)
	(get_tree()
		.create_tween()
		.tween_property(self, "scale", new_size, 0.15)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))
