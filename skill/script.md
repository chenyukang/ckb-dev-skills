# On-Chain Script

## Overview

An on-chain script in CKB is a binary executable that runs on-chain in the CKB-VM (a RISC-V based virtual machine). on-chain scripts are CKB's equivalent of smart contracts. They are Turing-complete and can perform arbitrary logic to guard and protect on-chain assets.

## On-Chain Script Structure

```rust
pub struct Script {
    pub code_hash: H256,         // Identifies the on-chain script code
    pub hash_type: ScriptHashType, // How to locate the on-chain script code
    pub args: JsonBytes,          // Parameters passed to the on-chain script
}
```

### Fields Explained

| Field       | Description                                                   |
| ----------- | ------------------------------------------------------------- |
| `code_hash` | Identifies which on-chain script code to load and execute              |
| `hash_type` | Defines how to interpret `code_hash` when locating code       |
| `args`      | Custom arguments passed to the on-chain script (e.g., public key hash) |

### hash_type Values

| Value                    | Name      | Description                                  |
| ------------------------ | --------- | -------------------------------------------- |
| `data`, `data1`, `data2` | Data Hash | Match the hash of the on-chain script binary directly |
| `type`                   | Type Hash | Match the hash of a Cell's type on-chain script       |

## Two Types of on-chain scripts

### Lock on-chain script (Required)

- Controls **ownership and access** to a Cell.
- Executes only on **input** Cells (not output Cells).
- If the lock on-chain script returns non-zero, the Cell cannot be consumed.
- Common use: signature verification (e.g., `secp256k1_blake160_sighash_all`).

### Type on-chain script (Optional)

- Controls **how a Cell can be used** in a transaction.
- Executes on both **input** and **output** Cells.
- Common use: enforcing token rules (e.g., UDT issuance/transfer logic).

## On-Chain Script Execution Rules

In a transaction:

- Input Cells' **lock on-chain scripts** are executed.
- Input Cells' **type on-chain scripts** are executed (if present).
- Output Cells' **type on-chain scripts** are executed (if present).
- Output Cells' **lock on-chain scripts** are **NOT** executed.

Return code `0` = success. Any non-zero = failure (transaction rejected).

## Default lock on-chain script: secp256k1_blake160_sighash_all

The most common lock on-chain script on CKB:

1. Extracts the public key from the transaction witness.
2. Hashes the public key with Blake2b to get a Blake160 hash.
3. Compares with the hash stored in `args`.
4. Verifies the secp256k1 signature.

```
code_hash: 0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8
hash_type: type
args: <20-byte blake160 hash of public key>
```

## AI Dev Tips

- On-chain scripts share code via `code_hash` + `hash_type`; they differ by `args`. Multiple users share the same lock on-chain script code but each has a unique `args` (their public key hash).
- Use `type` hash_type for upgradable on-chain scripts (via Type ID pattern); use `data`/`data1`/`data2` for immutable on-chain scripts.
- When building transactions, always include the Cell containing the on-chain script code in `cell_deps`.

## References

- [Intro to on-chain script](https://docs.nervos.org/docs/script/intro-to-script)
- [On-chain script structure](https://docs.nervos.org/docs/tech-explanation/script)
- [Lock on-chain script vs type on-chain script](https://docs.nervos.org/docs/tech-explanation/lock-type-diff)
- [Data Hash vs Type Hash](https://docs.nervos.org/docs/tech-explanation/data-type-diff)
