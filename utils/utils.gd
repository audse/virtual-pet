extends Node

var Random = RandomNumberGenerator.new()

func _ready() -> void:
	Random.randomize()


static func add_child_at(to: Node, child: Node, index: int) -> void:
	to.add_child(child)
	to.move_child(child, index)


static func transfer_child(from: Node, to: Node, child: Node, index: int = -1) -> void:
	from.remove_child(child)
	if index >= 0:
		add_child_at(to, child, index)
	else:
		to.add_child(child)
