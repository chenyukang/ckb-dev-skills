# Debugging CKB on-chain scripts

## Overview

CKB on-chain scripts run in a sandboxed RISC-V VM, making debugging different from traditional programs. This skill covers debugging tools and techniques.

## Debug Logging

### Using ckb_std::debug!

```rust
ckb_std::debug!("Value: {}", some_value);
ckb_std::debug!("Hex data: {:02x?}", data_bytes);
```

- Output appears in `ckb-debugger` as `on-chain script log: ...`.
- Output appears in `ckb-testtool` as `[contract debug] ...`.
- Debug messages are **stripped in production** and incur zero overhead.

## Debugging with ckb-debugger

### Basic Execution

```bash
# Run a binary
ckb-debugger --bin build/release/my-contract

# Run with transaction file
ckb-debugger -f tx.json

# Specify which on-chain script to run (by input index)
ckb-debugger -f tx.json --cell-index 0 --cell-type input --script-group-type lock
```

### GDB Debugging

`ckb-debugger` supports GDB remote debugging:

```bash
# Start debugger in GDB mode
ckb-debugger --mode gdb --gdb-listen 127.0.0.1:9999 --bin build/release/my-contract.debug
```

In another terminal:

```bash
# Connect with GDB (need riscv64 GDB)
riscv64-unknown-elf-gdb build/release/my-contract.debug
(gdb) target remote 127.0.0.1:9999
(gdb) break program_entry
(gdb) continue
```

### Cycle Profiling

```bash
# Show cycle consumption
ckb-debugger --bin build/release/my-contract
# Output includes: All cycles: 7366(7.2K)

# Detailed cycle breakdown with pprof
ckb-debugger --mode fast --bin build/release/my-contract --pprof output.pprof
```

## Common Error Codes

| Code | Meaning                      | Common Cause                              |
| ---- | ---------------------------- | ----------------------------------------- |
| -1   | on-chain script returns -1   | Explicit validation failure in your code  |
| -2   | Exceed maximum cycles        | on-chain script computation exceeds limit |
| 1    | IndexOutOfBound              | Accessing Cell at invalid index           |
| 2    | ItemMissing                  | Expected data not found                   |
| 3    | LengthNotEnough              | Buffer too small for data                 |
| 4    | Encoding                     | Molecule deserialization error            |
| -52  | Invalid Witness              | Witness format incorrect                  |
| -31  | Signature Verification Error | Wrong signature or wrong public key       |

## Common Debugging Scenarios

### On-chain script returns non-zero

1. Add `ckb_std::debug!()` before each return statement.
2. Run with `ckb-debugger` to see which code path failed.
3. Check if the correct `args` are passed to the on-chain script.

### IndexOutOfBound Errors

```rust
// This is expected behavior -- it means "no more cells"
match load_cell_data(index, Source::GroupInput) {
    Ok(data) => { /* process */ },
    Err(SysError::IndexOutOfBound) => break, // Normal end of iteration
    Err(e) => return Err(e.into()),
}
```

### Missing cell_deps

Symptom: on-chain script code not found.
Fix: Ensure the Cell containing the on-chain script binary is included in `cell_deps`.

### Wrong hash_type

Symptom: on-chain script execution fails with unexpected code.
Fix: Verify `hash_type` matches how the on-chain script was deployed:

- `data`/`data1`/`data2`: `code_hash` = hash of on-chain script binary
- `type`: `code_hash` = hash of the deploying Cell's type on-chain script

## Debugging in Tests

```rust
#[test]
fn test_debug() {
    // ... setup ...

    // Verify and capture result
    match context.verify_tx(&tx, 10_000_000) {
        Ok(cycles) => println!("Success! Cycles: {}", cycles),
        Err(err) => {
            // The error message often includes the on-chain script's debug output
            eprintln!("Failed: {:?}", err);
            panic!("Transaction verification failed");
        }
    }
}
```

## AI Dev Tips

- Always build with `.debug` suffix for GDB debugging; use stripped binary for cycle profiling.
- When an on-chain script fails, first check `ckb_std::debug!()` output, then check error code, then use GDB if needed.
- Remember: `ckb_std::debug!()` only works in debugger/test environments; in production, these calls are no-ops.
- Use `ckb-debugger --mode fast` for performance profiling without GDB overhead.
- When debugging type on-chain scripts, remember they execute for both input and output Cells.

## References

- [Debug on-chain scripts](https://docs.nervos.org/docs/script/debug-script)
- [Rust Debug](https://docs.nervos.org/docs/script/rust/rust-debug)
- [Common Error Codes](https://docs.nervos.org/docs/script/common-script-error-code)
- [CKB Debugger](https://github.com/nervosnetwork/ckb-standalone-debugger)
