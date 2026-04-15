# Transaction

## Overview

A CKB transaction consumes existing Live Cells (inputs) and creates new Live Cells (outputs). All on-chain scripts from the transaction are executed to validate correctness. If any on-chain script fails, the entire transaction is rejected.

## Transaction Structure

```
Transaction: {
  version: Uint32;
  cell_deps: [CellDep];     // Cells referenced as dependencies (e.g., on-chain script code)
  header_deps: [H256];      // Block headers referenced by the transaction
  inputs: [CellInput];      // Live Cells to consume
  outputs: [CellOutput];    // New Cells to create
  outputs_data: [Bytes];    // Data for each output Cell
  witnesses: [Bytes];       // Signatures and other proofs
}
```

### Key Fields

| Field          | Description                                                                                               |
| -------------- | --------------------------------------------------------------------------------------------------------- |
| `cell_deps`    | References to Cells containing on-chain script code or data needed during execution. These Cells are NOT consumed. |
| `inputs`       | Live Cells to be consumed. Each references a previous transaction output.                                 |
| `outputs`      | New Cells to be created. Each specifies capacity, lock, and optional type.                                |
| `outputs_data` | Data field for each corresponding output Cell (matched by index).                                         |
| `witnesses`    | Proofs (typically signatures) used by on-chain scripts during validation.                                          |

## Transaction Flow

1. **Select inputs**: Choose Live Cells with enough capacity.
2. **Define outputs**: Specify new Cells with lock/type on-chain scripts and data.
3. **Balance capacity**: Sum of input capacities >= sum of output capacities. The difference is the transaction fee.
4. **Sign**: Place signatures in `witnesses`.
5. **Submit**: Send to a CKB node for validation and inclusion in a block.

## CKB Transaction Fee

```
fee = sum(input capacities) - sum(output capacities)
```

There is no explicit gas/fee field. The difference between total input and output capacity is the miner fee. A typical fee rate is around 1000 shannons per KB of serialized transaction size.

## cell_deps

`cell_deps` point to Cells that contain data needed during on-chain script execution but are NOT consumed:

- On-chain script code binaries (e.g., the secp256k1 lock on-chain script binary)
- Shared libraries or lookup data

```json
{
  "out_point": {
    "tx_hash": "0x...",
    "index": "0x0"
  },
  "dep_type": "code" // "code" or "dep_group"
}
```

- `dep_type: "code"` - The Cell's data is directly used.
- `dep_type: "dep_group"` - The Cell's data contains a list of out_points, all of which are loaded.

## witnesses

Witnesses provide off-chain data (usually signatures) for on-chain script validation. The witness at index `i` corresponds to the on-chain script group of input `i`.

## AI Dev Tips

- When composing transactions with CCC SDK, use `tx.completeInputsByCapacity(signer)` to auto-select inputs and `tx.completeFeeBy(signer)` to auto-calculate fees.
- Always ensure `outputs_data` array length matches `outputs` array length.
- A common mistake: forgetting to include on-chain script code Cells in `cell_deps`.
- Transaction hash is calculated over all fields except `witnesses` (similar to Bitcoin's SegWit).

## Example: Simple CKB Transfer

```typescript
// Using CCC SDK
const tx = ccc.Transaction.from({
  outputs: [{ lock: toLock, capacity: ccc.fixedPointFrom(amount) }],
});
await tx.completeInputsByCapacity(signer);
await tx.completeFeeBy(signer);
const txHash = await signer.sendTransaction(tx);
```

## References

- [Transaction - Nervos Docs](https://docs.nervos.org/docs/tech-explanation/transaction)
- [How CKB Works](https://docs.nervos.org/docs/getting-started/how-ckb-works)
- [cell_deps](https://docs.nervos.org/docs/tech-explanation/cell-deps)
- [witnesses](https://docs.nervos.org/docs/tech-explanation/witness)
