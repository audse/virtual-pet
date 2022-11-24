# `Design`

`Design`s are defined by a `JSON` file.

## Schema

```ts
interface Design {
    /*
     * Required properties
     */
    id: string,
    display_name: string,
    design_type: DesignType,
    price: int, // price is per building
    albedo_texture: string, // path to an image

    /*
     * Optional properties
     */
    normal_texture?: string, // path to an image
    category_id?: string,
    description?: string,
    rarity?: int,
    texture_scale?: Dimensions // [1]
}

enum DesignType {
    EXTERIOR_WALL,
    INTERIOR_WALL,
	FLOOR,
	ROOF,
}
```

### References

1. [`Dimensions`](types.md#dimensions)


## Examples

```json
{
    "id": "striped_wallpaper",
    "display_name": "Striped Wallpaper",
    "design_type": "Interior_Wall",
    "price": 1000,
    "albedo_texture": "my_mod/images/striped_wallpaper.png",
    "category_id": "wallpaper"
}
```

```json
{
    "id": "brick_wall",
    "display_name": "Brick Wall",
    "design_type": "Exterior_Wall",
    "price": 1000,
    "albedo_texture": "my_mod/images/brick_wall.png",
    "normal_texture": "my_mod/images/brick_wall_normal.png",
    "category_id": "stone",
    "texture_scale": {
        "width": 2,
        "height": 2,
        "depth": 2,
    }
}
```