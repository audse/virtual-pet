# `AddDesignCategoriesModule`

`AddDesignCategoriesModule` is a GDScript class that makes adding categories to the buy menu easier.

## How to use

```
extends AddDesignCategoriesModule

const ParentClass := "Build.Data"

# specify the path to the JSON definitions of all objects you'd like to add (relative to `mod.gd`)
func get_data_paths() -> Array[String]:
    return [
        "wallpapers.json",
    ]
```

And that's it! The provided categories will be automatically injected into the build menu in-game.