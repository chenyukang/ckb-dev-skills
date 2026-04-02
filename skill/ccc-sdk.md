# CCC SDK (CKBers' Codebase)

## Overview

CCC is the one-stop JS/TS SDK for CKB ecosystem development. It provides transaction composition, wallet connection, data analysis, and cross-chain interoperability.

- **NPM**: `@ckb-ccc/ccc` (core), `@ckb-ccc/shell` (Node.js), `@ckb-ccc/connector-react` (React)
- **Playground**: https://live.ckbccc.com/
- **Docs**: https://docs.ckbccc.com
- **API Reference**: https://api.ckbccc.com
- **GitHub**: https://github.com/ckb-devrel/ccc

## Installation

```bash
# For Node.js backend
npm install @ckb-ccc/shell

# For custom UI (core only)
npm install @ckb-ccc/ccc

# For React apps with wallet connector
npm install @ckb-ccc/connector-react
```

## Usage Pattern

All CCC exports are on the `ccc` object:

```typescript
import { ccc } from "@ckb-ccc/shell";
// or
import { ccc } from "@ckb-ccc/connector-react";
```

## Creating a Client

```typescript
// Connect to testnet
const client = new ccc.ClientPublicTestnet();

// Connect to mainnet
const client = new ccc.ClientPublicMainnet();
```

## Basic Transaction: Transfer CKB

```typescript
import { ccc } from "@ckb-ccc/shell";

// Create a signer (from private key for backend)
const signer = new ccc.SignerCkbPrivateKey(client, privateKey);

// Build transaction
const tx = ccc.Transaction.from({
  outputs: [
    {
      lock: toLock,
      capacity: ccc.fixedPointFrom(amount), // amount in CKB
    },
  ],
});

// Auto-fill inputs and calculate fee
await tx.completeInputsByCapacity(signer);
await tx.completeFeeBy(signer);

// Send
const txHash = await signer.sendTransaction(tx);
console.log("TX Hash:", txHash);
```

## Working with Addresses

```typescript
// Parse address string to Script
const lock = await ccc.Address.fromString(addressString, client);

// Get address from signer
const addresses = await signer.getAddresses();

// Create address from lock script
const address = ccc.Address.fromScript(lockScript, client);
const addressString = address.toString();
```

## Store Data on Cell

```typescript
const data = ccc.bytesFrom("Hello CKB!", "utf8");
const minCapacity = ccc.fixedPointFrom(String(61 + data.length));

const tx = ccc.Transaction.from({
  outputs: [{ lock: signer.lock, capacity: minCapacity }],
  outputsData: [data],
});

await tx.completeInputsByCapacity(signer);
await tx.completeFeeBy(signer);
const txHash = await signer.sendTransaction(tx);
```

## Query Cells

```typescript
// Collect Cells by lock script
for await (const cell of client.findCellsByLock(lockScript)) {
  console.log("Cell capacity:", cell.cellOutput.capacity);
  console.log("Cell data:", cell.outputData);
}

// Get balance (total capacity)
const balance = await signer.getBalance();
```

## Quick Start: create-ccc-app

```bash
# Bootstrap a new CCC app
npx create-ccc-app@latest my-ccc-app

# Or with pnpm
pnpm create ccc-app my-ccc-app
```

## Key Concepts

### fixedPointFrom

CCC uses fixed-point numbers for CKB amounts:

```typescript
ccc.fixedPointFrom("100"); // 100 CKB
ccc.fixedPointFrom(100); // 100 CKB
ccc.fixedPointFrom("0.5"); // 0.5 CKB
```

### Transaction Completion

CCC's killer feature is automatic transaction completion:

- `tx.completeInputsByCapacity(signer)` - Automatically selects enough input Cells.
- `tx.completeFeeBy(signer)` - Automatically calculates and adds the transaction fee.
- `tx.completeFeeChangeToOutput(signer, index)` - Adds fee change to a specific output.

### Wallet Connector (React)

```tsx
import { ccc } from "@ckb-ccc/connector-react";

function App() {
  return (
    <ccc.Provider>
      <YourApp />
    </ccc.Provider>
  );
}

function WalletButton() {
  const { open, wallet, signer } = ccc.useCcc();

  return (
    <button onClick={open}>{wallet ? wallet.name : "Connect Wallet"}</button>
  );
}
```

## AI Dev Tips

- Use `ccc.fixedPointFrom()` instead of manual shannon conversion (1 CKB = 10^8 shannons).
- Always call `completeInputsByCapacity` before `completeFeeBy` -- order matters.
- The playground (https://live.ckbccc.com/) is excellent for testing code snippets without local setup.
- For `tsconfig.json`, set `moduleResolution` to `node16`, `nodenext`, or `bundler` to enable CCC's package exports.
- For React Server Components, add `"use client"` at the top of files using `ccc.Provider`.

## Lumos Compatibility

If migrating from Lumos, CCC provides patches:

```bash
npm install @ckb-ccc/lumos-patches
```

```typescript
import { generateDefaultScriptInfos } from "@ckb-ccc/lumos-patches";
registerCustomLockScriptInfos(generateDefaultScriptInfos());
```

## CKB Wallet Ecosystem

CCC supports connecting to multiple CKB wallets via its connector. The CKB ecosystem has a rich set of wallets:

| Wallet        | Platform                 | Lock Type           | Notes                                                                     |
| ------------- | ------------------------ | ------------------- | ------------------------------------------------------------------------- |
| Neuron        | Desktop (Win/Mac/Linux)  | secp256k1           | Full node wallet                                                          |
| CKBull        | Mobile (Android/iOS)     | secp256k1           | Mobile wallet                                                             |
| JoyID         | Web                      | secp256r1 (PassKey) | Uses WebAuthn/Passkeys via [JoyID Lock](https://docs.joyid.dev/guide/sdk) |
| Portal Wallet | Web                      | Omnilock            | Web wallet                                                                |
| Rei Wallet    | Browser Extension        | secp256k1           | [Docs](https://docs.reiwallet.io), [Demo](https://demo-app.reiwallet.io/) |
| SafePal       | Hardware/Mobile          | secp256k1           | Hardware wallet                                                           |
| Ledger        | Hardware                 | secp256k1           | Hardware wallet                                                           |
| imToken       | Mobile (Android/iOS)     | secp256k1           | Multi-chain                                                               |
| OneKey        | Desktop/Mobile/Extension | secp256k1           | Multi-chain                                                               |

### Omnilock: Universal Lock for Wallet Interop

[Omnilock](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0042-omnilock/0042-omnilock.md) is a universal Lock Script that supports multiple authentication methods in a single Script:

- secp256k1 (CKB native, Bitcoin, Ethereum)
- secp256r1 (WebAuthn, passkeys)
- Multi-sig
- Time-lock and supply-lock extensions

This enables CKB DApps to accept users from any wallet ecosystem. CCC handles Omnilock integration automatically when connecting to supported wallets.

**Reference**: [Omnilock Introduction (Blog)](https://blog.cryptape.com/omnilock-a-universal-lock-that-powers-interoperability-1)

## References

- [CCC GitHub](https://github.com/ckb-devrel/ccc)
- [CCC Docs](https://docs.ckbccc.com)
- [CCC API Reference](https://api.ckbccc.com)
- [CCC Playground](https://live.ckbccc.com/)
- [SDK & Dev Tools - Nervos Docs](https://docs.nervos.org/docs/sdk-and-devtool/ccc)
- [Omnilock RFC](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0042-omnilock/0042-omnilock.md)
- [JoyID SDK](https://docs.joyid.dev/guide/sdk)
