extends AddActionItemModule

## This is an example of a complete mod

## This mod adds a button to  every pet's context menu that allows you to change its
## favorite color.

## `mod.gd` defines where the mod should be loaded, parses the JSON, and creates the nodes
## `action_item_data.json` defines how the action item will look and act
## `on_pressed.gd` contains a function `run` that is run when the action item is pressed


const parent_class := "res://apps/pet/interface/action_menu.gd"


func get_data_path() -> String:
	return "res://mods/mod_example/action_item_data.json"


func get_menu_from_context(context: Node) -> ActionMenu:
	return context.action_menu
