# `BuyCategory`

`BuyCategory`s are defined by a `JSON` file.

## Schema

```ts
interface BuyCategory {
    id: string,
    display_name: string,
    description?: string,
    menu?: BuyMenu // as string
}

interface BuyMenu {
    BUY,
    BUILD
}
```

## Examples

```json
{
    "id": "garden_statues",
    "display_name": "Garden statues",
    "description": "Lions and tigers and bear statues- oh my!"
}
```

```json
{
    "id": "art_deco_building_stuff",
    "display_name": "Art Deco building stuff",
    "description": "Art Deco & 1920s style doors and windows.",
    "menu": "BUILD"
}
```