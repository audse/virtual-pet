# `BuyableObject`

`BuyableObject`s are defined by a `JSON` file.

## Schema

```ts
enum WorldLayer {
    FloorObject,
    WallObject,
    Foliage,
    Building,
}

enum Flag {
    Consumable,
    Ownable,
}

interface BuyableObject {
    /*
     * Required properties
     */
    id: string,
    display_name: string,
    mesh: string, // path to 3D model, e.g. `.obj` file
    world_layer: WorldLayer, // as string

    /*
     * Optional properties
     */
    category_id?: string,
    description?: string,
    colorway_id?: string,
    dimensions?: {
        width?: int,  // defaults to 1
        height?: int,  // defaults to 1
        depth?: int, // defaults to 1
    },
    mesh_scale?: {
        width?: number, // defaults to 1
        height?: number, // defaults to 1
        depth?: number, // defaults to 1
    },
    rarity?: number,
    collision_shape?: string, // path to `.tres` `Shape3D` file- only applies if you are making your mod in Godot
    flags?: Flag[], // array of strings
    actions?: string,
    total_uses?: number, // only applies for consumable objects
    fulfills_needs?: string[],
    consumed_meshes?: string[], // path to 3D models of the mesh's appearance after being consumed. the order is important; the first path should be the item with 1 use left (almost all the way gone), the next with 2 uses left, and so on. consumable objects without this set will use the default mesh for all states.
    script?: string, // a script that is run whenever this object enters the scene. should include the function `_on_placed_in_world`
}
```

## Examples

```json
{
    "id": "lava_lamp",
    "display_name": "Lava Lamp",
    "mesh": "cool_home_stuff/lava_lamp/lava_lamp_blue.obj",
    "dimensions": {
        "width": 1,
        "height": 1,
    },
    "world_layer": "FloorObject",
    "category_id": "lighting",
    "description": "The coolest way to light your room!",
    "flags": ["Ownable"],
    "colorway_id": "blue",
}
```

```json
{
    "id": "dandelion",
    "display_name": "Dandelion",
    "mesh": "cute_garden_stuff/dandelion/dandelion.obj",
    "dimensions": {
        "width": 1,
        "height": 1,
        "depth": 1
    },
    "world_layer": "Foliage",
    "category_id": "wildflower",
    "flags": ["Consumable"],
    "total_uses": 2,
    "fulfills_needs": ["Hunger"],
    "consumed_meshes": [
        "cute_garden_stuff/dandelion/dandelion_with_no_seeds.obj",
    ],
    "actions": ["make a wish"],
    "rarity": 0,
    "script": "cute_garden_stuff/dandelion/make_a_wish.gd",
    "mesh_scale": {
        "x": 0.5,
        "y": 0.5,
        "z": 0.5
    }
}
```