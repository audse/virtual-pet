# `BuyableObject`

`BuyableObject`s are defined by a `JSON` file.

## Schema

```ts
interface BuyableObject {
    /*
     * Required properties
     */
    id: string,
    display_name: string,
    mesh: string, // path to 3D model, e.g. `.obj` file
    world_layer: WorldLayer, // as string
    price: number,

    /*
     * Optional properties
     */
    category_id?: string,
    description?: string,
    colorway_id?: string,
    dimensions?: BuyableObjectDimensions,
    mesh_scale?: BuyableObjectDimensions,
    colors?: BuyableObjectColor[], // a list of other color options for this item
    rarity?: number,
    collision_shape?: string, // path to `.tres` `Shape3D` file - only applies if you are making your mod in Godot
    flags?: Flag[], // array of strings
    actions?: string,
    total_uses?: number, // only applies for consumable objects
    fulfills_needs?: string[],
    consumed_meshes?: string[], // path to 3D models of the mesh's appearance after being consumed. the order is important; the first path should be the item with 1 use left (almost all the way gone), the next with 2 uses left, and so on. consumable objects without this set will use the default mesh for all states.
    script?: string, // a script that is run whenever this object enters the scene. should include the function `_on_placed_in_world`
}

enum WorldLayer {
    Floor_Object,
    Wall_Object,
    Foliage,
    Building,
}

enum Flag {
    Consumable,
    Ownable,
}

interface BuyableObjectDimensions {
    width?: number, // default = 1
    height?: number, // default = 1
    depth?: number, // default = 1
}

interface BuyableObjectColor {
    name: string, // set this to `default` for one of the colors
    materials: string[] // paths to all `.mtl` files needed for the recolor (in order of surface)
}
```

## Examples

```json
{
    "id": "lava_lamp",
    "display_name": "Lava Lamp",
    "mesh": "cool_home_stuff/lava_lamp/lava_lamp.obj",
    "dimensions": {
        "width": 1,
        "height": 1,
    },
    "world_layer": "FloorObject",
    "category_id": "lighting",
    "description": "The coolest way to light your room!",
    "flags": ["Ownable"],
    "colors": [
        {
            "name": "default",
            "materials": [
                "cool_home_stuff/lava_lamp/lava_lamp_base.mtl",
                "cool_home_stuff/lava_lamp/lava_lamp_blue.mtl",
            ]
        },
        {
            "name": "green",
            "materials": [
                "cool_home_stuff/lava_lamp/lava_lamp_base.mtl",
                "cool_home_stuff/lava_lamp/lava_lamp_green.mtl",
            ]
        }
    ]
}
```

```json
{
    "id": "dandelion",
    "display_name": "Dandelion",
    "mesh": "cute_garden_stuff/dandelion/dandelion.obj",
    "colors": [
        {
            "name": "default",
            "materials": ["cute_garden_stuff/dandelion/dandelion.mtl"],
        }
    ],
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