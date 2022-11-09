class_name Ui
extends Node


static func bouncer(node: Control) -> Tween:
	return  node.create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)



static func scale_in(node: Control, delay := 0.0) -> void:
	node.pivot_offset = node.size / 2.0
	node.rotation = deg_to_rad(-45.0)
	node.scale = Vector2.ZERO
	await RenderingServer.frame_post_draw
#	node.visible = true
	var tween := Ui.bouncer(node)
	tween.tween_property(node, "scale", Vector2.ONE, Settings.anim_duration(0.25)).set_delay(delay)
	tween.tween_property(node, "rotation", 0.0, Settings.anim_duration(0.25)).set_delay(delay)
	await tween.finished


static func scale_out(node: Control, delay := 0.0) -> void:
	node.pivot_offset = node.size / 2.0
	node.scale = Vector2.ONE
	var tween := Ui.bouncer(node)
	tween.tween_property(node, "scale", Vector2.ZERO, Settings.anim_duration(0.25)).set_delay(delay)
	tween.tween_property(node, "rotation", deg_to_rad(45.0), Settings.anim_duration(0.25)).set_delay(delay)
	await tween.finished
#	node.visible = false
