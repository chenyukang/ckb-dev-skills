# Testing CKB on-chain scripts

## Overview

CKB on-chain scripts can be tested using two primary methods:

1. **ckb-testtool**: Simulates a complete CKB environment in Rust unit tests.
2. **ckb-debugger**: Runs on-chain scripts from the command line with transaction data.

## Testing with ckb-testtool

`ckb-testtool` provides a simulated CKB environment that shares the same underlying code as the actual CKB node.

### Setup

In `tests/Cargo.toml`:

```toml
[dependencies]
ckb-testtool = "0.13"
serde_json = "1.0"
```

### Basic Test Structure

```rust
use ckb_testtool::builtin::ALWAYS_SUCCESS;
use ckb_testtool::context::Context;
use ckb_types::{bytes::Bytes, core::TransactionBuilder, packed::*, prelude::*};

#[test]
fn test_my_script() {
    // 1. Create a test context
    let mut context = Context::default();

    // 2. Deploy the on-chain script binary
    let contract_bin: Bytes = std::fs::read("../build/release/my-contract")
        .expect("read contract")
        .into();
    let out_point = context.deploy_cell(contract_bin);

    // 3. Build an on-chain script referencing the deployed code
    let lock_script = context
        .build_script(&out_point, Bytes::from(vec![42u8]))
        .expect("build script");
    let lock_script_dep = CellDep::new_builder()
        .out_point(out_point)
        .build();

    // 4. Create input Cells
    let input_out_point = context.create_cell(
        CellOutput::new_builder()
            .capacity(1000u64.pack())
            .lock(lock_script.clone())
            .build(),
        Bytes::new(),
    );
    let input = CellInput::new_builder()
        .previous_output(input_out_point)
        .build();

    // 5. Define output Cells
    let outputs = vec![
        CellOutput::new_builder()
            .capacity(500u64.pack())
            .lock(lock_script.clone())
            .build(),
        CellOutput::new_builder()
            .capacity(500u64.pack())
            .lock(lock_script)
            .build(),
    ];
    let outputs_data = vec![Bytes::new(); 2];

    // 6. Build the transaction
    let tx = TransactionBuilder::default()
        .input(input)
        .outputs(outputs)
        .outputs_data(outputs_data.pack())
        .cell_dep(lock_script_dep)
        .build();

    // 7. Verify
    let cycles = context
        .verify_tx(&tx, 10_000_000)
        .expect("pass verification");
    println!("Consumed cycles: {}", cycles);
}
```

### Testing with Witnesses (Signatures)

```rust
// Add witness data
let witness = WitnessArgs::new_builder()
    .lock(Some(signature_bytes).pack())
    .build();

let tx = TransactionBuilder::default()
    .input(input)
    .outputs(outputs)
    .outputs_data(outputs_data.pack())
    .cell_dep(lock_script_dep)
    .witness(witness.as_bytes().pack())
    .build();
```

### Expecting Failure

```rust
let result = context.verify_tx(&tx, 10_000_000);
assert!(result.is_err(), "Transaction should fail");
// Check specific error code if needed
```

### Dump Transaction for ckb-debugger

```rust
let dump = context.dump_tx(&tx).expect("dump tx");
let json = serde_json::to_string_pretty(&dump).expect("serialize");
std::fs::write("test-vectors/my_test.json", json).unwrap();
```

### Run Tests

```bash
# Run all tests
make test

# Run specific test with output
cargo test -- tests::test_my_script --nocapture

# Or via make
make test CARGO_ARGS="-- tests::test_my_script --nocapture"
```

## Testing with ckb-debugger

### Run a Binary Directly

```bash
ckb-debugger --bin build/release/my-contract
```

### Run with Transaction File

```bash
ckb-debugger -f tests/test-vectors/my_test.json
```

### Transaction File Format

```json
{
  "mock_info": {
    "inputs": [
      {
        "input": {
          "since": "0x0",
          "previous_output": { "tx_hash": "0x...", "index": "0x0" }
        },
        "output": {
          "capacity": "0x3e8",
          "lock": {
            "code_hash": "0x...",
            "hash_type": "type",
            "args": "0x..."
          },
          "type": null
        },
        "data": "0x",
        "header": null
      }
    ],
    "cell_deps": [
      {
        "cell_dep": {
          "out_point": { "tx_hash": "0x...", "index": "0x0" },
          "dep_type": "code"
        },
        "output": {
          "capacity": "0x...",
          "lock": { "code_hash": "0x...", "hash_type": "data", "args": "0x" },
          "type": null
        },
        "data": "0x<on-chain script binary hex>",
        "header": null
      }
    ],
    "header_deps": [],
    "extensions": []
  },
  "tx": {
    "version": "0x0",
    "cell_deps": [
      {
        "out_point": { "tx_hash": "0x...", "index": "0x0" },
        "dep_type": "code"
      }
    ],
    "header_deps": [],
    "inputs": [
      {
        "since": "0x0",
        "previous_output": { "tx_hash": "0x...", "index": "0x0" }
      }
    ],
    "outputs": [
      {
        "capacity": "0x1f4",
        "lock": { "code_hash": "0x...", "hash_type": "type", "args": "0x" },
        "type": null
      }
    ],
    "outputs_data": ["0x"],
    "witnesses": []
  }
}
```

### Transaction File Macros

Use macros to auto-fill on-chain script binary data:

```json
"data": "0x{{ data ../../build/release/my-contract }}",
"type": "{{ def_type my-contract }}",
"code_hash": "0x{{ ref_type my-contract }}"
```

## AI Dev Tips

- **Recommended workflow**: Use `ckb-testtool` for regular testing; use `ckb-debugger` for debugging issues.
- `ckb-testtool` shares CKB core code, so it closely resembles actual on-chain behavior.
- Always test both success and failure cases for your on-chain scripts.
- Use `context.dump_tx()` to generate transaction files for `ckb-debugger` instead of creating them manually.
- Cycle consumption in tests matches real on-chain costs.

## References

- [On-chain script Testing Guide](https://docs.nervos.org/docs/script/script-testing-guide)
- [Rust Quick Start](https://docs.nervos.org/docs/script/rust/rust-quick-start)
- [Rust Test](https://docs.nervos.org/docs/script/rust/rust-test)
- [ckb-testtool](https://docs.rs/ckb-testtool/latest/ckb_testtool)
