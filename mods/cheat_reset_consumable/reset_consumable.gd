extends ActionItemScript


func run(_action_item: ActionItem, context: Node, _args: Dictionary = {}) -> void:
	context.object_data.reset_uses()
