# `ActionItem`

`ActionItem`s are defined by a `JSON` file.

## Schema

```ts
interface ActionItem {
    // a unique (within the containing action menu) identifier for this action item
    id: string,

    // the display text for the button
    text: string,

    // if the action item is a cheat or not (cheats have a special appearance in-game)
    is_cheat?: boolean,

    // if provided, a list of actions that will appear after clicking this action button
    submenu?: Array<ActionItem>,

    // if provided, a script to run when this action button is pressed
    on_pressed?: {

        // a path to the script. assumes that it will be in the mods folder and that the script contains a `run` function
        run_script: string,

        // the arguments that will be provided to the `run` function
        arguments?: {
            [key: string]: any,
        }
    }
}
```

## Example

```json
{
    "id": "change_favorite_color",
    "text": "change fave color...",
    "submenu": [
        {
            "id": "red",
            "text": "red",
            "on_pressed": {
                "run_script": "my_mod/change_favorite_color.gd",
                "arguments": {
                    "color": "red"
                }
            }
        }
    ]
}
```