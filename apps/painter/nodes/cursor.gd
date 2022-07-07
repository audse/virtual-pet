extends Sprite2D

# Cursor SVG files are 500 px, so this converts to the correct scale
# e.g. a 50px grid has a scale of 0.1
const cursor_scale := {
	States.PaintState.Size.Xxs: 0.025,
	States.PaintState.Size.Xs: 0.05,
	States.PaintState.Size.Sm: 0.1,
	States.PaintState.Size.Md: 0.2,
	States.PaintState.Size.Lg: 0.4,
	States.PaintState.Size.Xl: 0.8,
}


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
	return p


func shape(tex: Texture) -> void:
	texture = tex


func color(c: Color) -> void:
	self_modulate = c


func resize(size: int) -> void:
	var width: float = cursor_scale[size]
	var new_size = Vector2(width, width)
	(get_tree()
		.create_tween()
		.tween_property(self, "scale", new_size, 0.15)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_CIRC))
