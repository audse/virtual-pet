class_name NodeAnim
extends Object

signal animation_finished

var node: Node
var keyframes: Dictionary


func _init(node_val: Node, keys_val: Dictionary) -> void:
	node = node_val
	keyframes = keys_val


func setup() -> void:
	for prop in keyframes.setup:
		if prop in node: node.set(prop, keyframes.setup[prop])
	await node.get_tree().process_frame


func get_props() -> Array:
	var props: Array[AnimProperty] = []
	for prop in keyframes.props:
		if prop in node: props.append(AnimProperty.new(prop, keyframes.props[prop]))
	return props


func tear_down() -> void:
	for prop in keyframes.tear_down:
		if prop in node: node.set(prop, keyframes.tear_down[prop])


func animate() -> void:
	setup()
	
	var props := get_props()
	
	for key in keyframes.keyframes:
		var key_data: Dictionary = keyframes.keyframes[key]
		var tween := (
			node.create_tween()
				.set_trans(Tween.TRANS_CUBIC)
				.set_ease(key_data.ease_type)
		)
		for prop in props:
			prop.animate(tween, node, key, key_data.duration)
		await tween.finished
	
	tear_down()
	self.animation_finished.emit()
