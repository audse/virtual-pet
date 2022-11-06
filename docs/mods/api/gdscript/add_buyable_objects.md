# `AddBuyableObjectsModule`

`AddBuyableObjectsModule` is a GDScript class that makes adding objects to the buy menu easier.

## How to use

```
extends AddBuyableObjectsModule

const parent_class := "res://apps/buy/data/buy_data.gd"

# specify the path to the JSON definitions of all objects you'd like to add (relative to `mod.gd`)
func get_data_paths() -> String:
    return [
        "dog_sculpture.json",
        "rabbit_sculpture.json",
        "lizard_sculpture.json",
    ]
```

And that's it! The provided objects will be automatically injected into the buy menu in-game.