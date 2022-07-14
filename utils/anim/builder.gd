class_name AnimBuilder
extends Object

var base_node: Node

var anim := {
	setup = {},
	props = {},
	keyframes = {},
	tear_down = {},
}

var ease_override: int = -1


func _init(node: Node) -> void:
	base_node = node


func setup(value: Dictionary) -> AnimBuilder:
	anim.setup = value
	return self


func setup_prop(prop_name: String, value) -> AnimBuilder:
	anim.setup[prop_name] = value
	return self


func props(value: Dictionary) -> AnimBuilder:
	anim.props = value
	return self


func prop(prop_name: String, value: Dictionary) -> AnimBuilder:
	anim.props[prop_name] = value
	return self


func keyframes(value: Dictionary) -> AnimBuilder:
	anim.keyframes = value
	if ease_override != -1:
		for key_name in anim.keyframes: anim.keyframes[key_name].ease_type = ease_override
	return self


func keyframe(key_name: String, duration: float, ease_val: int = Tween.EASE_IN_OUT, trans_val: int = Tween.TRANS_CUBIC) -> AnimBuilder:
	anim.keyframes[key_name] = { 
		ease_type = ease_val if ease_override == -1 else ease_override,
		duration = duration,
		trans_type = trans_val
	}
	return self


func ease_type(value: int) -> AnimBuilder:
	ease_override = value
	if ease_override != -1:
		for key_name in anim.keyframes: anim.keyframes[key_name].ease_type = ease_override
	return self


func tear_down(value: Dictionary) -> AnimBuilder:
	anim.tear_down = value
	return self


func tear_down_prop(prop_name: String, value) -> AnimBuilder:
	anim.tear_down[prop_name] = value
	return self


func done() -> NodeAnim:
	return NodeAnim.new(base_node, anim)


func complete() -> void:
	var animation: NodeAnim = self.done()
	await animation.animate()
