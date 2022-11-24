# `AddDesignsModule`

`AddDesignsModule` is a GDScript class that makes adding objects to the buy menu easier.

## How to use

```
extends AddDesignsModule

const ParentClass := "Build.Data"

# specify the path to the JSON definitions of all objects you'd like to add (relative to `mod.gd`)
func get_data_paths() -> Array[String]:
    return [
        "striped_wallpaper.json",
        "polka_dot_wallpaper.json",
    ]
```

And that's it! The provided designs will be automatically injected into the build menu in-game.