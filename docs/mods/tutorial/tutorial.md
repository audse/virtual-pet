# How to create and load a mod

## Setup
1. Inside the `mods` folder, create a directory `hello_world`
2. In `mods/hello_world`, create a file `mod.gd`
3. In `mod.gd`, enter the following code:
```
extends Module
var ParentClass = "res://main.gd"

func _on_ready(context: Node) -> void:
    print("Hello, world!")
```

That's it! The game will print "Hello, world" when it's run.