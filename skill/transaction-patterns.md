# Transaction Composition Patterns

## Overview

Composing transactions on CKB follows the Cell model: consume input Cells, produce output Cells. This skill covers common transaction patterns using the CCC SDK.

## Basic Pattern

```typescript
import { ccc } from "@ckb-ccc/shell";

// 1. Define outputs (what you want to create)
const tx = ccc.Transaction.from({
  outputs: [{ lock: recipientLock, capacity: ccc.fixedPointFrom("100") }],
});

// 2. Auto-fill inputs
await tx.completeInputsByCapacity(signer);

// 3. Auto-calculate fee
await tx.completeFeeBy(signer);

// 4. Send
const txHash = await signer.sendTransaction(tx);
```

## Transfer CKB

```typescript
async function transferCKB(
  signer: ccc.Signer,
  toAddress: string,
  amountCKB: string,
) {
  const client = signer.client;
  const toLock = (await ccc.Address.fromString(toAddress, client)).script;

  const tx = ccc.Transaction.from({
    outputs: [{ lock: toLock, capacity: ccc.fixedPointFrom(amountCKB) }],
  });

  await tx.completeInputsByCapacity(signer);
  await tx.completeFeeBy(signer);
  return await signer.sendTransaction(tx);
}
```

## Store Data on Cell

```typescript
async function storeData(signer: ccc.Signer, data: string) {
  const dataBytes = ccc.bytesFrom(data, "utf8");
  const minCapacity = ccc.fixedPointFrom(String(61 + dataBytes.length));

  const tx = ccc.Transaction.from({
    outputs: [
      {
        lock: (await signer.getRecommendedAddressObj()).script,
        capacity: minCapacity,
      },
    ],
    outputsData: [dataBytes],
  });

  await tx.completeInputsByCapacity(signer);
  await tx.completeFeeBy(signer);
  return await signer.sendTransaction(tx);
}
```

## Deploy On-Chain Script Code

To deploy an on-chain script binary on-chain, store it in a Cell's data field:

```typescript
async function deployScript(signer: ccc.Signer, scriptBinary: Uint8Array) {
  const scriptData = ccc.bytesFrom(scriptBinary);
  const minCapacity = ccc.fixedPointFrom(String(61 + scriptData.length));

  const tx = ccc.Transaction.from({
    outputs: [
      {
        lock: (await signer.getRecommendedAddressObj()).script,
        capacity: minCapacity,
        // Optional: add a type on-chain script (e.g., Type ID) for upgradability
      },
    ],
    outputsData: [scriptData],
  });

  await tx.completeInputsByCapacity(signer);
  await tx.completeFeeBy(signer);
  return await signer.sendTransaction(tx);
}
```

## Multi-Output Transaction

```typescript
const tx = ccc.Transaction.from({
  outputs: [
    { lock: aliceLock, capacity: ccc.fixedPointFrom("100") },
    { lock: bobLock, capacity: ccc.fixedPointFrom("200") },
    { lock: charlieLock, capacity: ccc.fixedPointFrom("50") },
  ],
});

await tx.completeInputsByCapacity(signer);
await tx.completeFeeBy(signer);
const txHash = await signer.sendTransaction(tx);
```

## Transaction with Type On-Chain Script (UDT Transfer)

```typescript
const tx = ccc.Transaction.from({
  outputs: [
    {
      lock: recipientLock,
      type: udtTypeScript, // The UDT type on-chain script
      capacity: ccc.fixedPointFrom("142"), // Enough for Cell overhead
    },
  ],
  outputsData: [
    // UDT amount encoded as little-endian u128
    ccc.numLeToBytes(transferAmount, 16),
  ],
});

// Add cell_deps for the UDT type on-chain script code
tx.addCellDeps(udtCellDep);

await tx.completeInputsByCapacity(signer);
await tx.completeFeeBy(signer);
const txHash = await signer.sendTransaction(tx);
```

## Adding cell_deps

```typescript
// Add a single cell_dep
tx.addCellDeps({
  outPoint: { txHash: "0x...", index: 0 },
  depType: "code",
});

// Add a dep_group
tx.addCellDeps({
  outPoint: { txHash: "0x...", index: 0 },
  depType: "depGroup",
});
```

## Transaction Capacity Calculation

```
Total Input Capacity  >= Total Output Capacity + Transaction Fee
```

CCC handles this automatically with `completeInputsByCapacity` and `completeFeeBy`, but understanding the math helps with debugging.

## AI Dev Tips

- **Order matters**: Always call `completeInputsByCapacity` before `completeFeeBy`.
- **Minimum Cell capacity**: Each output Cell needs at least 61 CKBytes. The actual minimum depends on the Cell's content (lock on-chain script size + type on-chain script size + data size + 8 bytes for capacity field).
- **outputs_data alignment**: `outputsData[i]` corresponds to `outputs[i]`. If an output has no data, use `"0x"` (empty bytes).
- CCC automatically handles change Cells -- you don't need to manually create them.
- For complex transactions, build incrementally: define outputs first, then add cell_deps, then complete inputs and fees.

## References

- [Transfer CKB - Nervos Docs](https://docs.nervos.org/docs/dapp/transfer-ckb)
- [Store Data on Cell](https://docs.nervos.org/docs/dapp/store-data-on-cell)
- [CCC Transaction Composing](https://github.com/ckb-devrel/ccc#transaction-composing)
