class_name ModHooks
extends Object

const Paths := {
	"ActionMenu": {
		"Pet": "res://apps/pet/interface/action_menu.gd",
		"Object": "res://apps/world_object/interface/action_menus/interact_with_object.gd",
	},
	"Buy": {
		"Data": "res://apps/buy/data/buy_data.gd",
	},
	"Build": {
		"Data": "res://apps/building/data/build_data.gd",
	},
	"Game": {
		"Data": "res://apps/game/game.gd",
	},
}

## Converts `parent_class = "ActionMenu.Pet"` to full path, e.g. `res://apps/pet/...`
static func get_class_path(hook: String) -> String:
	var parts: Array[String] = hook.split(".") as Array[String]
	var result = Paths
	for part in parts:
		result = result[part]
	return str(result)
