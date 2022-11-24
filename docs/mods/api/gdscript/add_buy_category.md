# `AddBuyCategoriesModule`

`AddBuyCategoriesModule` is a GDScript class that makes adding categories to the buy menu easier.

## How to use

```
extends AddBuyCategoriesModule

const ParentClass := "Buy.Data"

# specify the path to the JSON definitions of all objects you'd like to add (relative to `mod.gd`)
func get_data_paths() -> Array[String]:
    return [
        "garden_sculptures.json",
        "garden_lighting.json",
    ]
```

And that's it! The provided categories will be automatically injected into the buy menu in-game.