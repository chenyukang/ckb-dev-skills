# CKB On-Chain Script Security Checklist

## Core Principle: Validate Everything Explicitly

CKB on-chain scripts run in an open, permissionless environment. Any transaction can invoke any on-chain script. Never assume the transaction structure is "normal" — an attacker controls every field except the on-chain script code itself.

## Critical Checks

### 1. Capacity Validation

- **Always verify**: `output.capacity >= minimum_required` for every output your on-chain script manages.
- **Minimum Cell capacity**: 61 CKBytes (for a basic Cell with no data). Typically 62+ with overhead.
- **Overflow risk**: Capacity is `u64` in shannons (1 CKB = 10^8 shannons). Check arithmetic for overflow.

```rust
// BAD: no capacity check
// GOOD:
let output = load_cell(0, Source::GroupOutput)?;
let capacity: u64 = output.capacity().unpack();
if capacity < MINIMUM_CAPACITY {
    return Err(Error::InsufficientCapacity);
}
```

### 2. Lock on-chain script vs type on-chain script Execution Context

- **lock on-chain scripts** run when a Cell is consumed (input side). They authorize spending.
- **type on-chain scripts** run on both creation (output) AND consumption (input). They enforce state rules.
- **Common mistake**: Writing a type on-chain script that only validates on consumption but not creation, allowing arbitrary initial state.

### 3. Cell Counting and Grouping

- Always use `Source::GroupInput` / `Source::GroupOutput` to iterate only Cells belonging to your on-chain script.
- **Verify the count**: If your on-chain script expects exactly 1 input and 1 output in the group, enforce it. An attacker could include extra Cells.

```rust
// Verify exactly one input and one output in the group
let input_count = QueryIter::new(load_cell, Source::GroupInput).count();
let output_count = QueryIter::new(load_cell, Source::GroupOutput).count();
if input_count != 1 || output_count != 1 {
    return Err(Error::InvalidCellCount);
}
```

### 4. Missing cell_deps

- On-chain scripts loaded via `cell_deps` must be present in the transaction. If your on-chain script references another on-chain script's code_hash, ensure the dep is included.
- **Attack vector**: Omitting a cell_dep can cause a different code path or error that an attacker exploits.

### 5. Type on-chain script Presence Checks

- If your lock on-chain script expects a type on-chain script to enforce certain rules, verify the type on-chain script is actually present on the Cell.
- `type_` field is `Option<Script>` — it can be `None`.

### 6. Data Integrity

- Always validate `outputs_data` length matches what your on-chain script expects.
- Validate data format (Molecule deserialization can fail silently with truncated data in some cases — always check).
- **Never trust data from inputs blindly** — validate it even if "your on-chain script created it" because type on-chain scripts can be absent on some Cells.

### 7. Witness Authentication

- lock on-chain scripts typically verify signatures from `witnesses`.
- **Witness layout**: The witness at the same index as the first input in the on-chain script group is used for authentication. Use `load_witness_args` to parse it.
- **Group witness**: Only the first witness in an on-chain script group carries the signature. Other inputs in the same group share it.

### 8. Since Field Validation

- The `since` field on inputs encodes time/epoch/block-number locks.
- If your on-chain script relies on time-locks, verify the `since` field is set correctly and cannot be bypassed.
- `since` uses a complex encoding (metric flag, relative/absolute flag, value). Use `ckb-std`'s `Since` helpers.

## Token/UDT-Specific Security

### 9. UDT Amount Validation

- sUDT/xUDT amounts are stored in `outputs_data` as little-endian `u128`.
- **Always verify**: `sum(input_amounts) >= sum(output_amounts)` for the token type.
- **Mint authority**: Only the owner (defined by on-chain script args) should be able to create new tokens (input_amount < output_amount).

### 10. Type ID Uniqueness

- Type ID pattern guarantees a unique type_hash. Used for upgradable on-chain scripts and unique tokens.
- **Never modify the Type ID creation logic** — it relies on the first input's `out_point` and the output index.
- Verify: Only one Cell with a given Type ID can exist at any time.

## Common Vulnerability Patterns

### 11. Reinitialization Attack

- If a type on-chain script doesn't check whether it's being created vs updated, an attacker can "reinitialize" state by creating a new Cell with arbitrary data.
- **Fix**: Check if there are group inputs. If none → creation (validate initial state). If some → update (validate state transition).

```rust
let is_creation = load_cell(0, Source::GroupInput).is_err();
if is_creation {
    // Validate initial state only
    validate_creation()?;
} else {
    // Validate state transition
    validate_update()?;
}
```

### 12. Unbounded Loops

- CKB on-chain scripts have cycle limits. Unbounded iteration over Cells or data can cause out-of-cycles failures.
- **Attack vector**: An attacker fills a transaction with many Cells to exhaust cycles.
- **Fix**: Set reasonable bounds or use the cycle limit as a natural bound (but test worst cases).

### 13. Missing Error Returns

- In Rust, if `main()` returns `0`, the on-chain script passes. Ensure all validation paths return non-zero on failure.
- **Dangerous pattern**: Using `unwrap()` — it panics and returns non-zero, which is safe but gives poor error messages. Prefer explicit error codes.

### 14. Dep Group Manipulation

- `dep_group` type cell_deps expand to multiple deps. If your on-chain script loads code from deps, verify the code_hash matches what you expect.
- An attacker could substitute a dep_group that includes malicious code alongside legitimate code.

## Pre-Deployment Checklist

- [ ] All arithmetic checked for overflow (use `checked_add`, `checked_mul`, etc.)
- [ ] lock on-chain script verifies signature/authorization correctly
- [ ] type on-chain script validates both creation and consumption paths
- [ ] Cell counts verified (no unexpected extra Cells in group)
- [ ] Capacity minimums enforced on outputs
- [ ] Data format validated (length, Molecule schema, bounds)
- [ ] Token amounts balanced (no unintended minting/burning)
- [ ] Since-based time locks tested with edge cases
- [ ] Cycle consumption profiled under adversarial conditions (max Cells, max data)
- [ ] Error codes are distinct and meaningful for debugging
- [ ] on-chain script tested with `ckb-debugger` against crafted malicious transactions
- [ ] Type ID uniqueness preserved (if using Type ID pattern)
