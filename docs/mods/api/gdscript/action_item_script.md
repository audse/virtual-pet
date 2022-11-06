# `ActionItemScript`

# Class methods

#### `run(action_item: ActionItem, context: Node, extra_args: Dictionary)`
`run` is called when the action item is selected.

`action_item` is the `ActionItem` that was pressed, causing this event.
`context` is the `Node` from which this `ActionItem` is spawned. For example, this might be the pet's interaction menu.
`extra_args` is anything passed to `on_pressed.arguments` in the `JSON`.

## Example
```
extends ActionItemScript

func run(action_item: ActionItem, context: Node, extra_args: Dictionary) -> void:
    print(
        """
        The action item `{id}` was pressed from within the menu {menu_name}.
        The arguments supplied were: {arguments}
        """.format({ 
            id = action_item.id,
            menu_name = context.name,
            arguments = DictRef.format(extra_args)
        })
    )

```