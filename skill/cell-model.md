# Cell Model

## Overview

A Cell is the smallest fundamental unit in CKB, analogous to a UTXO in Bitcoin but more generalized. Every piece of state on CKB is stored in a Cell.

## Cell Structure

```
Cell: {
  capacity: HexString;   // Size in shannons (1 CKB = 10^8 shannons)
  lock: Script;           // Controls ownership and access
  type: Script | null;    // Optional. Controls how the Cell can be used in transactions
  data: HexString;        // Arbitrary state storage
}
```

## Key Concepts

### Live Cells vs Dead Cells

- **Live Cell**: A Cell that has not been consumed. Available for use in future transactions.
- **Dead Cell**: A Cell that has been consumed by a transaction. No longer usable.

### Capacity

- `capacity` serves a dual purpose: it represents both the CKB token amount and the storage limit of the Cell.
- A Cell's total size (including `capacity`, `lock`, `type`, and `data` fields) must not exceed its `capacity` value.
- Minimum capacity: **61 CKBytes** (for a Cell with no type on-chain script and no data). Recommended: **62+ CKBytes** to cover transaction fees.

### Type on-chain script

- `type` is optional. Plain CKB Cells usually use `type: null`.
- Add a type on-chain script only when the Cell needs custom validation logic (for example, UDTs or application state transitions).

### Immutability

Cells on-chain are immutable. To "update" a Cell:

1. Consume the existing Cell as a transaction input.
2. Create a new Cell as a transaction output with the updated data.

## AI Dev Tips

- When constructing transactions, always verify that each output Cell's total serialized size does not exceed its `capacity` field.
- Size `capacity` from the Cell's serialized contents; `62` CKBytes is only a simple rule of thumb for lock-only Cells with little or no data.
- Remember: querying "balance" on CKB means summing the `capacity` of all Live Cells owned by an address.

## Example

```json
{
  "capacity": "0x19995d0ccf",
  "lock": {
    "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
    "args": "0x0a486fb8f6fe60f76f001d6372da41be91172259",
    "hash_type": "type"
  },
  "type": null
}
```

## References

- [Cell - Nervos Docs](https://docs.nervos.org/docs/tech-explanation/cell)
- [Capacity - Nervos Docs](https://docs.nervos.org/docs/tech-explanation/capacity)
- [Cell Model - Nervos Docs](https://docs.nervos.org/docs/ckb-fundamentals/cell-model)
