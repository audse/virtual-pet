class_name AddActionItemModule
extends Module


func get_data_path() -> String:
	return "res://"


func get_menu_from_context(context: Node) -> ActionMenu:
	return context as ActionMenu


func _on_ready(context: Node) -> void:
	var action_item_json := FileAccess.open(get_data_path(), FileAccess.READ)
	if action_item_json:
		var action_item := ActionItemParser.parse(context, action_item_json)
		if action_item: get_menu_from_context(context).append_action(action_item)
