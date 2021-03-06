class_name Anim
extends Object


static func fade_in(node: Node, duration: float = 0.25) -> void:
	await (
		AnimBuilder
			.new(node)
			.keyframe("fade", duration, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
			.fade_in()
			.complete()
	)


static func fade_out(node: Node, duration: float = 0.25) -> void:
	await (
		AnimBuilder
			.new(node)
			.keyframe("fade", duration, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
			.fade_out()
			.complete()
	)


static func pop_enter_base(node: Node) -> AnimBuilder:
	return (
		AnimBuilder
			.new(node)
			.setup({
				pivot_offset = node.size / 2,
				scale        = Vector2.ZERO,
				visible      = true,
			})
			.keyframe("enter", 0.15, Tween.EASE_OUT, Tween.TRANS_CIRC)
			.keyframe("settle", 0.25)
			.prop("scale", {
				enter  = node.scale * 1.1,
				settle = node.scale,
			})
	)


static func pop_toggle(node: Node) -> void:
	if node.visible: await pop_enter(node)
	else: await pop_exit(node)


static func pop_enter(node: Node) -> void:
	if node.visible: return
	await pop_enter_base(node).done().animate()


static func pop_exit_base(node: Node) -> AnimBuilder:
	return (
		AnimBuilder
			.new(node)
			.setup({ pivot_offset = node.size / 2 })
			.keyframe("anticipation", 0.15)
			.keyframe("exit", 0.15, Tween.EASE_IN, Tween.TRANS_CIRC)
			.prop("scale", {
				anticipation = node.scale * 1.1,
				exit = Vector2.ZERO
			})
			.tear_down({
				visible = false,
				scale   = Vector2.ONE,
			})
	)


static func pop_exit(node: Node) -> void:
	if not node.visible: return	
	await pop_exit_base(node).done().animate()


static func pop_spin_toggle(node: Node, direction: int = 1) -> void:
	if not node.visible: await pop_spin_enter(node, direction)
	else: await pop_spin_exit(node, direction * -1)


static func pop_spin_enter(node: Node, direction: int = 1) -> void:
	if node.visible: return
	await (
		pop_enter_base(node)
			.setup_prop("rotation", deg2rad(node.rotation + 100 * direction))
			.prop("rotation", {
				enter = deg2rad(node.rotation - 20 * direction),
				settle = node.rotation
			})
			.done()
			.animate()
	)


static func pop_spin_exit(node: Node, direction: int = -1) -> void:
	if not node.visible: return
	await (
		pop_exit_base(node)
			.prop("rotation", {
				anticipation = deg2rad(node.rotation - 20 * direction),
				exit = deg2rad(node.rotation + 100 * direction),
			})
			.done()
			.animate()
	)
