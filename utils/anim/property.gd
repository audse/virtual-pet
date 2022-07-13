class_name AnimProperty
extends Object

enum Mode { PARALLEL, CHAIN, DEFAULT }

var prop: String
var mode: Mode
var keyframes: Dictionary

func _init(prop_val: String, keys_val: Dictionary, mode_val: Mode = Mode.CHAIN) -> void:
	prop = prop_val
	mode = mode_val
	keyframes = keys_val

func animate(tween: Tween, node: Node, to_key: String, duration: float = 0.25) -> Tween:
	match mode:
		Mode.PARALLEL: tween.parallel()
		Mode.CHAIN: tween.chain()
	tween.tween_property(node, prop, keyframes[to_key], duration)
	return tween
