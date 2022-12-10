class_name Ui
extends Node


static func time(from: float) -> float:
	if Settings.is_inside_tree(): return Settings.anim_duration(from)
	else: return from


static func is_pressed(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.is_pressed()


static func tweener(node: Node) -> Tween:
	return node.create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


static func bouncer(node: Node) -> Tween:
	return  node.create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)


static func scale_in(node: Control, delay := 0.0) -> void:
	node.pivot_offset = node.size / 2.0
	node.rotation = deg_to_rad(-45.0)
	node.scale = Vector2.ZERO
	await RenderingServer.frame_post_draw
#	node.visible = true
	var tween := Ui.bouncer(node)
	tween.tween_property(node, "scale", Vector2.ONE, Ui.time(0.25)).set_delay(delay)
	tween.tween_property(node, "rotation", 0.0, Ui.time(0.25)).set_delay(delay)
	await tween.finished


static func scale_out(node: Control, delay := 0.0) -> void:
	node.pivot_offset = node.size / 2.0
	node.scale = Vector2.ONE
	var tween := Ui.bouncer(node)
	tween.tween_property(node, "scale", Vector2.ZERO, Ui.time(0.25)).set_delay(delay)
	tween.tween_property(node, "rotation", deg_to_rad(45.0), Ui.time(0.25)).set_delay(delay)
	await tween.finished
#	node.visible = false


static func hover_scale(node: Control) -> void:
	node.mouse_entered.connect(
		func() -> void:
			node.pivot_offset = node.size / 2.0
			node.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).tween_property(node, "scale", Vector2(1.05, 1.05), Ui.time(0.15))
	)
	node.mouse_exited.connect(
		func() -> void:
			node.pivot_offset = node.size / 2.0
			node.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).tween_property(node, "scale", Vector2(1.0, 1.0), Ui.time(0.15))
	)


static func pulse(node: Control) -> void:
	pass


static func floating(node: Control, delta := 10.0) -> void:
	var _start_position = node.position
	var tween := node.create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_method(
		func(pos: float) -> void:
			node.position.y = _start_position.y + pos,
		-delta / 2, delta / 2, 1.0
	)
	tween.tween_method(
		func(pos: float) -> void:
			node.position.y = _start_position.y + pos,
		delta / 2, -delta / 2, 1.0
	)


static func press_scale(node: Button) -> void:
	node.button_down.connect(
		func() -> void:
			node.pivot_offset = node.size / 2.0
			var tween := node.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween.tween_property(node, "scale", Vector2(1.1, 1.1), Ui.time(0.05))
			tween.tween_property(node, "scale", Vector2(0.9, 0.9), Ui.time(0.05))
	)
	node.button_up.connect(
		func() -> void:
			node.pivot_offset = node.size / 2.0
			var tween := node.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween.tween_property(node, "scale", Vector2(1.05, 1.05), Ui.time(0.1))
			tween.tween_property(node, "scale", Vector2.ONE, Ui.time(0.1))
	)


static func pop(node: Control) -> void:
	node.pivot_offset = node.size / 2.0
	var tween := node.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "scale", Vector2(1.1, 1.1), Ui.time(0.25))
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), Ui.time(0.25))
	await tween.finished


static func tag(text: String, color := Color.WHITE) -> Label:
	var label := Label.new()
	label.text = text
	label.modulate = color
	label.theme_type_variation = "Tag"
	return label


static func tag_button(text: String, selected := false, color := Color.WHITE) -> Button:
	var button := Button.new()
	button.text = text
	button.modulate = color
	button.theme_type_variation = "TagButton" if not selected else "TagButton_Selected"
	return button
