# `Item`

`Item`s are defined by a `JSON` file.

## Schema

```ts
interface Item {
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
    menu?: BuyMenu, // [1] defaults to `BuyMenu.BUY`
    description?: string,
    colorway_id?: string,
    dimensions?: Dimensions, // [2]
    mesh_scale?: Dimensions, // [2]
    colors?: BuyableItemColor[], // a list of other color options for this item
    rarity?: number,
    collision_shape?: string, // path to `.tres` `Shape3D` file - only applies if you are making your mod in Godot
    flags?: Flag[], // array of strings
    total_uses?: number, // only applies for consumable objects
    fulfills_needs?: string[],
    mesh_script?: string, // a script that is attached to every instance of this mesh

    // these options are for objects that appear in the build menu, such as doors and windows
    intersection_type?: IntersectionType,
    intersection_rect?: {
        x?: number, // the horizontal offset from the left of this object
        y?: number, // the vertical offset from the top of the building
        width?: number,
        height?: number, // the building's height is 4, so should be below that
    },
    stackable?: boolean, // if `true`, this item does not take up space or have collisions (e.g. more items can be placed in the same square)

}

enum WorldLayer {
    RUG_OBJECT,
    FLOOR_OBJECT,
    WALL_OBJECT,
    FOLIAGE,
    BUILDING,
}

enum Flag {
    CONSUMABLE,
    OWNABLE,
}

interface BuyableItemColor {
    name: string, // set this to `default` for one of the colors
    materials: string[] // paths to all `.mtl` files needed for the recolor (in order of surface)
}

enum IntersectionType {
    OPEN_DOORWAY, // e.g. arches
    CLOSED_DOORWAY, // e.g. regular doors
    WINDOW,
}
```

### References

1. [`BuyMenu`](buy_category.md)
2. [`Dimensions`](types.md#dimensions)


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
    "world_layer": "FLOOR_OBJECT",
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
    "world_layer": "FOLIAGE",
    "category_id": "wildflower",
    "flags": ["Consumable"],
    "total_uses": 2,
    "fulfills_needs": ["Hunger"],
    "rarity": 0,
    "script": "cute_garden_stuff/dandelion/make_a_wish.gd",
    "mesh_scale": {
        "x": 0.5,
        "y": 0.5,
        "z": 0.5
    }
}
```