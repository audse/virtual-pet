# `DesignCategory`

`DesignCategory`s are defined by a `JSON` file.

## Schema

```ts
interface DesignCategory {
    id: string,
    display_name: string,
    design_type: DesignType // [1] as string
    description?: string,
}
```

### References

1. [`DesignType`](design.md)

## Examples

```json
{
    "id": "wallpaper",
    "display_name": "Wallpapers",
    "design_type": "Interior_Wall",
}
```

```json
{
    "id": "hardwood_floor",
    "display_name": "Hardwoord Floors",
    "design_type": "Floor"
}
```