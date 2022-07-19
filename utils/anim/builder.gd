class_name AnimBuilder
extends Object

var logging_enabled: bool = false
var base_node: Node

var anim := {
	setup = {},
	props = {},
	keyframes = {},
	tear_down = {},
}

# keyframes: { duration = 0.25, ease_type = Tween.EASE_IN, trans_type = Tween.TRANS_SINE }

var ease_override: int = -1


func _init(node: Node) -> void:
	base_node = node


func logging() -> AnimBuilder:
	logging_enabled = true
	return self

func setup(value: Dictionary) -> AnimBuilder:
	for prop_name in value:
		anim.setup[prop_name] = value[prop_name]
	return self


func setup_prop(prop_name: String, value) -> AnimBuilder:
	anim.setup[prop_name] = value
	return self


func props(value: Dictionary) -> AnimBuilder:
	for prop_name in value:
		anim.props[prop_name] = value[prop_name]
	return self


func prop(prop_name: String, value: Dictionary) -> AnimBuilder:
	anim.props[prop_name] = value
	return self


## Changes alpha smoothly throughout entire animation.
## Add this method after all keyframes to be faded have been defined.
func fade(from: float, to: float, self_only: bool = false) -> AnimBuilder:
	var mod_prop := {}
	var num_keys := len(anim.keyframes.keys())
	var mod = base_node.modulate
	var i := 0
	for key in anim.keyframes:
		var weight := float(i + 1) / float(num_keys)
		var a := ease(lerp(from, to, weight), 0.3)
		mod_prop[key] = Color(mod.r, mod.g, mod.b, a)
		i += 1
	var key_name := "modulate" if not self_only else "self_modulate"
	anim.props[key_name] = mod_prop
	anim.setup[key_name] = Color(mod.r, mod.g, mod.b, from)
	return self


## Increases alpha smoothly throughout entire animation.
## Add this method after all keyframes to be faded have been defined.
func fade_in() -> AnimBuilder:
	return fade(0.0, 1.0)

## Increases alpha smoothly throughout entire animation.
## Add this method after all keyframes to be faded have been defined.
func self_fade_in() -> AnimBuilder:
	return fade(0.0, 1.0, true)


## Decreases alpha smoothly throughout entire animation.
## Add this method after all keyframes to be faded have been defined.
func fade_out() -> AnimBuilder:
	return fade(base_node.modulate.a, 0.0)


## Decreases alpha smoothly throughout entire animation.
## Add this method after all keyframes to be faded have been defined.
func self_fade_out() -> AnimBuilder:
	return fade(base_node.modulate.a, 0.0, true)


func keyframes(value: Dictionary) -> AnimBuilder:
	for key_name in value:
		if not "ease_type" in value[key_name]:
			value[key_name].ease_type = Tween.EASE_IN_OUT
		if not "trans_type" in value[key_name]:
			value[key_name].trans_type = Tween.TRANS_SINE
		
		anim.keyframes[key_name] = value[key_name]
		
	if ease_override != -1:
		for key_name in anim.keyframes: anim.keyframes[key_name].ease_type = ease_override
	return self


func keyframe(key_name: String, duration: float, ease_val: int = Tween.EASE_IN_OUT, trans_val: int = Tween.TRANS_SINE) -> AnimBuilder:
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
	for prop_name in value:
		anim.tear_down[prop_name] = value[prop_name]
	return self


func tear_down_prop(prop_name: String, value) -> AnimBuilder:
	anim.tear_down[prop_name] = value
	return self


func then_hide() -> AnimBuilder:
	anim.tear_down.visible = false
	return self


func done() -> NodeAnim:
	for prop_name in anim.props:
		print("[", base_node.name, "]: antimating ", prop_name)
	return NodeAnim.make(base_node, anim, logging_enabled)


func complete() -> void:
	var animation: NodeAnim = self.done()
	await animation.animate()
