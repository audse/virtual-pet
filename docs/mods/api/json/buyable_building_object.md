# `BuildingObject`

`BuildingObject`s appear in the build menu. They are objects that are part of the structure of the building, such as doors and windows.

## Schema

```ts
// [1] `BuyableObject`
interface BuyableBuildingObject extends BuyableObject {
    intersection_type: IntersectionType,
    // relative to the building mesh, with { x: 0, y: 0, z: 0 } being the center
    intersection_rect: {
        position: Position, // [2] `Position`
        size: Dimensions // [3] `Dimensions`
    }
}

enum IntersectionType {
    OPEN_DOORWAY, // e.g. arches
    CLOSED_DOORWAY, // e.g. regular doors
    WINDOW,
}
```

### References
1. [`BuyableObject`](buyable_object.md)
2. [`Position`](types.md#position)
3. [`Dimensions`](types.md#dimensions)

## Example

```json
{
    "id": "hobbit_door",
    "display_name": "Hobbit Hole Door",
    "mesh": "my_mod/hobbit_door.obj",
    "world_layer": "BUILDING",
    "price": "500",
    "category_id": "door",
    "description": "A cute, round, wooden door.",
    "intersection_type": "OPEN_DOORWAY",
    "intersection_rect": {
        "position": {
            "x": -1,
            "y": 0,
            "z": -1
        },
        "size": {
            "width": 1,
            "height": 2,
            "depth": 0.5,
        }
    }
}
```