# `AddActionItemModule`

`AddActionItemModule` is a GDScript class that makes adding items to action menus easier.

## How to use

```
extends AddActionItemModule

# specify the menu that will contain this item
const parent_class = "res://apps/pet/interface/action_menu.gd"

# specify the path to the JSON definition of this action item (relative to `mod.gd`)
func get_data_path() -> String:
    return "my_action_item_data.json"

# find the action menu within the context node (could be the context itself)
func get_menu_from_context(context: Node) -> ActionMenu:
    return context.get_node("ActionMenu")
```

And that's it! The provided action item will be automatically injected into the action menu in-game.