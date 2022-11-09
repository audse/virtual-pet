extends AddActionItemModule

const ParentClass := "ActionMenu.Object"
const IsCheat := true


func get_data_path() -> String:
	return "res://mods/cheat_reset_consumable/reset_consumable.json"


func get_menu_from_context(context: Node) -> ActionMenu:
	return context.action_menu


func _on_ready(context: Node) -> void:
	# only add item to menu if object does not have infinite uses
	if context.object_data and context.object_data.buyable_object_data.total_uses != -1:
		super._on_ready(context)
