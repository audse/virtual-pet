# `PetTrait`

`PetTrait`s are defined by `JSON` files.

## Schema

```ts
interface PetTrait {
    id: string,
    display_name: string,
    needs_effect: {
        // all values between 
        // -1.0 (less likely to seek out need fulfillment)
        // and 1.0 (more likely to seek out need fulfillment)
        [need: string]: number,
    },
}
```