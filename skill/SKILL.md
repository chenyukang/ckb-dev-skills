---
name: ckb-dev
description: End-to-end Nervos CKB development playbook. Covers Cell Model, on-chain script (smart contract) development in Rust/C/JS, CCC SDK for DApp building, transaction composition, token standards (sUDT/xUDT/RGB++), Fiber Network (payment channels), testing with ckb-testtool and ckb-debugger, deployment with Type ID, and ecosystem tooling. Targets CKB2023 (MIRANA) best practices.
user-invocable: true
---

# CKB Development Skill

## What this Skill is for

Use this Skill when the user asks for:

- CKB on-chain script (smart contract) development
- Cell Model and UTXO-style state management
- Transaction building, signing, and sending on CKB
- DApp development with CCC SDK (TypeScript/JavaScript)
- Token creation and management (sUDT, xUDT, Spore DOB, RGB++)
- Wallet integration for CKB (Omnilock, JoyID, multi-wallet support)
- Testing and debugging CKB on-chain scripts
- Deploying on-chain scripts to Devnet/Testnet/Mainnet
- CKB-VM (RISC-V), cycles, and performance optimization
- Toolchain setup, version issues, build errors
- Molecule serialization format
- Running CKB nodes and RPC interaction
- Fiber Network (payment channels, invoices, multi-hop payments, cross-chain swaps)

## Terminology

- **script**: A script in the conventional software sense, such as an install script, shell script, or automation script.
- **on-chain script**: A CKB on-chain executable that runs in CKB-VM. Use this term for CKB smart-contract-style validation logic, including lock on-chain scripts and type on-chain scripts.
- **`Script`**: The CKB data structure name used by APIs, schemas, and code. Keep this exact spelling when referring to the type or serialized field shape.

## Default stack decisions (opinionated)

1. **On-chain script language: Rust first**

- Prefer Rust with `ckb-std` for all new on-chain scripts.
- Use C with `ckb-c-stdlib` only for extremely size/cycle-sensitive on-chain scripts.
- Use JavaScript (ckb-js-vm) for prototyping or educational demos.

2. **DApp SDK: CCC first**

- Use `@ckb-ccc/shell` for Node.js backends.
- Use `@ckb-ccc/connector-react` for React frontends with wallet connection.
- Use `@ckb-ccc/ccc` for custom UI without built-in connector.

3. **On-chain script project scaffolding**

- Use `cargo generate gh:cryptape/ckb-script-templates workspace` for new projects.
- Use `make generate CRATE=<name>` to add contracts within a project.

4. **Testing**

- Default: `ckb-testtool` for Rust unit tests (simulates full CKB environment).
- Use `ckb-debugger` for command-line execution, cycle profiling, and GDB debugging.
- Use `ckb-debugger --mode gdb` when you need step-through debugging.

5. **Deployment**

- Use OffCKB for local Devnet development.
- Use Type ID pattern for upgradable on-chain scripts.
- Use `data2` hash_type for new on-chain scripts (targets latest VM version).

6. **Serialization**

- CKB uses Molecule (not Protobuf/JSON) for on-chain data serialization.
- Use `@ckb-ccc/ccc` codecs for TypeScript, `molecule` crate for Rust.

## Operating procedure (how to execute tasks)

When solving a CKB task:

### 1. Classify the task layer

- Core concepts (Cell Model, on-chain script, Transaction structure)
- On-chain script development (Rust/C/JS)
- DApp / client-side development (CCC SDK, wallet)
- Payment channels and off-chain payments (Fiber Network)
- Testing and debugging
- Deployment and infrastructure

### 2. Pick the right building blocks

- On-chain script development: Rust + ckb-std + ckb-script-templates
- DApp client: CCC SDK (@ckb-ccc/shell or @ckb-ccc/connector-react)
- Testing: ckb-testtool (Rust) + ckb-debugger (CLI)
- Local dev: OffCKB
- Payment channels: Fiber Network (fnn node + JSON-RPC)

### 3. Implement with CKB-specific correctness

Always be explicit about:

- Cell capacity requirements (minimum 61 CKBytes, recommend 62+)
- Lock on-chain script vs type on-chain script distinction and execution rules
- `cell_deps` inclusion for referenced on-chain script code
- `outputs_data` array matching `outputs` array length
- hash_type selection (`data2` for new, `type` for upgradable via Type ID)
- Transaction fee = sum(input capacities) - sum(output capacities)

### 4. Design the on-chain contract before tests or implementation

When producing a solution design, test plan, or implementation plan for a CKB contract, first write a detailed contract design document. Do not jump directly to test cases or code. The contract is the fixed interface that all later transaction construction, tests, client code, and deployment work must follow.

The contract design document must include:

- **Contract type list**: list every custom on-chain script and state whether it is used as a **lock on-chain script** or **type on-chain script**. If it is a lock on-chain script, explicitly define what type on-chain script(s) it requires, allows, or forbids on the protected cells. If it is a type on-chain script, explicitly define what lock on-chain script(s) it requires, allows, or forbids on the protected cells. If there is no restriction on the other script position, say so explicitly. These lock/type pairing rules are part of the contract interface because they determine authorization boundaries, witness layout, and transaction construction.
- **Protected cell model**: for each relevant cell kind, define its `lock`, optional `type`, `data` layout, capacity requirements, whether the cell is an input, output, or both, and which script validates it.
- **Args schema**: for every custom on-chain script, specify exact `args` bytes, length, encoding, field order, semantic meaning, allowed values, and examples. Include how `args` are derived and which fields are immutable after deployment or cell creation.
- **Witness schema**: for every custom on-chain script and every required or allowed lock on-chain script, specify exact witness format and location. Prefer `WitnessArgs` by default, and explicitly state whether payloads live in `WitnessArgs.lock`, `WitnessArgs.input_type`, `WitnessArgs.output_type`, or raw witness bytes. Include byte layout, Molecule schema if used, field order, signing preimage rules, and examples. State which transaction input/output group each witness belongs to.
- **Execution group rules**: state how CKB groups scripts by `Script` hash, which cells are in each group, and which indexes the script must inspect with syscalls.
- **Strict execution flow**: step-by-step validation logic in the order the on-chain script executes, including data loading, parsing, signature/hash checks, state transition checks, capacity/token conservation checks, error codes, and failure behavior.
- **Transaction invariants**: exact requirements on `inputs`, `outputs`, `outputs_data`, `cell_deps`, `header_deps`, `since`, fees, change cells, and script dependencies.
- **State transition table**: every allowed scenario, required inputs, required outputs, required witnesses, expected success result, and representative failure cases.
- **Serialization and hashing**: Molecule schemas or fixed binary layouts, endian choices, hash functions, domain separators, and examples of encoded values.
- **Security notes**: replay protection, authorization boundary, malleability risks, dependency pinning, upgrade assumptions, capacity leakage, and cycle limits.

For each typical scenario, provide a concrete CKB transaction sample. Each sample must include:

- Human-readable purpose and preconditions.
- `cell_deps` with script code dependencies and `dep_type`.
- `inputs` grouped by cell kind and script group.
- `outputs` with `lock`, `type`, capacity, and data.
- `outputs_data` aligned one-to-one with `outputs`.
- Witnesses with exact fields and encoded payloads.
- Fee/change handling.
- Expected on-chain scripts executed: input locks, input types, output types.
- Expected result and at least one negative variant for tests.

Typical scenario sets should cover, when relevant: create/issue, update/transfer, consume/destroy, merge/split, authorization failure, malformed args/witness/data, missing `cell_deps`, wrong script group, insufficient capacity, invalid state transition, and replay or duplicate-use attempts.

### 5. Add tests

- On-chain script tests: ckb-testtool with both success and failure cases.
- Transaction tests: verify cycle consumption is reasonable.
- Use `context.dump_tx()` to generate ckb-debugger transaction files.

### 6. Deliverables expectations

When you implement changes, provide:

- Exact files changed
- Commands to build (`make build`) and test (`make test`)
- Cycle consumption estimates where relevant
- Risk notes for anything touching signatures, token transfers, or capacity management

When you provide a design or test plan, provide:

- Detailed contract design document before implementation details.
- Explicit lock/type classification for every custom on-chain script.
- Exact `args` and witness schemas for every custom on-chain script.
- Strict on-chain execution flow and error/failure behavior.
- A complete transaction sample set covering every typical scenario.
- Test matrix derived from the state transition table and transaction samples.

## Progressive disclosure (read when needed)

- Cell Model basics: [cell-model.md](cell-model.md)
- On-chain script structure & types: [script.md](script.md)
- Transaction structure: [transaction.md](transaction.md)
- CKB-VM, cycles, syscalls: [ckb-vm.md](ckb-vm.md)
- Rust environment setup: [rust-setup.md](rust-setup.md)
- Writing on-chain scripts (authoritative links): [writing-scripts.md](writing-scripts.md)
- CCC SDK (DApp development): [ccc-sdk.md](ccc-sdk.md)
- Transaction composition patterns: [transaction-patterns.md](transaction-patterns.md)
- Token standards (sUDT, xUDT, RGB++): [token-standards.md](token-standards.md)
- Testing on-chain scripts: [testing.md](testing.md)
- Debugging on-chain scripts: [debugging.md](debugging.md)
- Deployment & tools: [deployment.md](deployment.md)
- Ecosystem on-chain scripts: [ecosystem-scripts.md](ecosystem-scripts.md)
- Security checklist: [security.md](security.md)
- Fiber Network (payment channels): [fiber-network.md](fiber-network.md)
- Curated resources: [resources.md](resources.md)
