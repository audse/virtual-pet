# `BuyCategory`

`BuyCategory`s are defined by a `JSON` file.

## Schema

```ts
interface BuyCategory {
    id: string,
    display_name: string,
    description?: string,
}
```

## Examples

```json
{
    "id": "garden_statues",
    "display_name": "Garden Statues",
    "description": "Lions and tigers and bear statues- oh my!"
}
```