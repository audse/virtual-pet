extends AddActionItemModule

const ParentClass := "ActionMenu.Pet"
const IsCheat := true

func get_data_path() -> String:
	return "res://mods/cheat_change_traits/action_item_data.json"


func get_menu_from_context(context: Node) -> ActionMenu:
	return context.action_menu
