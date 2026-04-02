# CKB-VM

## Overview

CKB-VM is the virtual machine that executes Scripts on CKB. It is based on the RISC-V instruction set, an open-source CPU architecture. This design means CKB Scripts are essentially standard RISC-V binaries -- you can write them in any language that compiles to RISC-V.

## Key Properties

- **RISC-V based**: Uses the open-standard RISC-V ISA, providing low-level CPU access and high efficiency.
- **Turing-complete**: Supports loops, branches, and arbitrary computation.
- **Deterministic**: Same input always produces same output across all nodes.
- **Multi-language support**: Any language with a RISC-V compiler backend can be used (Rust, C, JavaScript via interpreter, etc.).

## Cycles

Cycles measure the computational cost of executing a Script. Each VM instruction or syscall consumes a specific number of cycles.

- **Block cycle limit** (`max_block_cycles`): The total cycles for all Scripts in a block cannot exceed this limit.
- **CKB Mainnet MIRANA**: `max_block_cycles = 3,500,000,000`
- **Transaction verification ceiling** (`tx_pool.max_tx_verify_cycles`): Nodes can still reject or refuse to relay transactions whose verification cost is too high, even though consensus itself only caps cycles per block.

## VM Versions

CKB-VM has evolved through multiple versions:

| Version | hash_type       | Description                               |
| ------- | --------------- | ----------------------------------------- |
| VM 0    | `data`          | Original VM                               |
| VM 1    | `data1`         | Added VM version 1 features               |
| VM 2    | `data2`, `type` | Added Spawn syscall, improved performance |

Use `data2` or `type` hash_type to target the latest VM version (VM 2).

## Syscalls

Scripts interact with the blockchain through syscalls -- special functions that read transaction data, Cell data, and more.

Common syscalls:

- `ckb_load_script()` - Load the current Script
- `ckb_load_cell_data()` - Load data from a Cell
- `ckb_load_witness()` - Load witness data
- `ckb_load_input()` / `ckb_load_output()` - Load input/output Cells
- `ckb_load_cell_by_field()` - Load specific Cell fields
- `ckb_debug()` - Print debug messages (stripped in production)

## Spawn (Cross-Script Calls)

VM 2 introduced the `Spawn` syscall, allowing one Script to directly call another Script binary. This enables modular Script composition:

```
spawn(code_hash, hash_type, args, bounds, ...) -> exit_code
```

## AI Dev Tips

- Target VM 2 (`data2` hash_type) for new Scripts to leverage all features including Spawn.
- Monitor cycle consumption during development; use `ckb-debugger` to profile cycle costs.
- The cycle cost model differs from Ethereum's gas -- consensus caps total cycles per block, and nodes may additionally enforce `tx_pool.max_tx_verify_cycles` for individual transactions.
- Rust scripts compiled with `--release` and `strip` can significantly reduce both binary size and cycle consumption.

## References

- [CKB-VM - Nervos Docs](https://docs.nervos.org/docs/ckb-fundamentals/ckb-vm)
- [VM Cycle Limits](https://docs.nervos.org/docs/script/vm-cycle-limits)
- [VM Version History](https://docs.nervos.org/docs/script/vm-version)
- [VM Selection](https://docs.nervos.org/docs/script/vm-selection)
- [Spawn: Cross-Script Calls](https://docs.nervos.org/docs/script/spawn-cross-script-calling)
