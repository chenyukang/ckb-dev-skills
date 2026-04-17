# CKB Development Skill for AI

A comprehensive vibe-coding skill and best-practices guide for Nervos CKB development (CKB2023 MIRANA, current through March 2026).

## Overview

This skill provides deep knowledge of the CKB development ecosystem:

- **Cell Model**: Generalized UTXO model — Cells, capacity, Live/Dead state
- **On-chain scripts**: CKB smart-contract-style programs (lock on-chain scripts and type on-chain scripts) running on CKB-VM (RISC-V)
- **On-chain script language**: Rust with `ckb-std` (default), C with `ckb-c-stdlib`, JS via `ckb-js-vm`
- **DApp SDK**: CCC (`@ckb-ccc/*`) for transaction building, signing, wallet connection
- **Tokens**: sUDT, xUDT, Spore DOB, RGB++ protocol
- **Testing**: `ckb-testtool` (Rust) + `ckb-debugger` (CLI, GDB)
- **Deployment**: OffCKB (local Devnet), Type ID for upgradable on-chain scripts
- **Security**: Capacity validation, Cell counting, reinitialization prevention
- **Fiber Network**: Payment channels, off-chain payments, cross-chain Lightning interop

## Installation

### Manual Install

```bash
git clone https://github.com/nervosnetwork/ckb-dev-skills
cd ckb-dev-skills
./install.sh
```

### Install to Project

```bash
./install.sh --project
```

## Skill Structure

```
skill/
├── SKILL.md                 # Main skill definition (required)
├── cell-model.md            # Cell Model basics
├── script.md                # On-chain script structure & types
├── transaction.md           # Transaction structure
├── ckb-vm.md                # CKB-VM, cycles, syscalls
├── rust-setup.md            # Rust environment setup
├── writing-scripts.md       # Writing on-chain scripts (authoritative links)
├── ccc-sdk.md               # CCC SDK for DApp development
├── transaction-patterns.md  # Transaction composition patterns
├── token-standards.md       # sUDT, xUDT, RGB++
├── testing.md               # Testing on-chain scripts
├── debugging.md             # Debugging on-chain scripts
├── deployment.md            # Deployment & tools
├── ecosystem-scripts.md     # System/ecosystem on-chain scripts
├── security.md              # Security checklist
├── fiber-network.md         # Fiber Network (payment channels)
└── resources.md             # Curated reference links
```

## Usage

Once installed, Claude Code will automatically use this skill when you ask about:

- CKB on-chain script (smart contract) development
- Cell Model and UTXO-style state management
- Transaction building, signing, and sending on CKB
- DApp development with CCC SDK (TypeScript/JavaScript)
- Token creation and management (sUDT, xUDT, Spore DOB, RGB++)
- Wallet integration for CKB
- Testing and debugging CKB on-chain scripts
- Deploying on-chain scripts to Devnet/Testnet/Mainnet
- CKB-VM, cycles, and performance optimization
- Molecule serialization format
- Fiber Network payment channels, invoices, and cross-chain swaps

### Example Prompts

```
"Help me set up a new CKB on-chain script project in Rust"
"Create a lock on-chain script that requires 2-of-3 multisig"
"Build a transaction that transfers CKB using CCC SDK"
"Write tests for my type on-chain script using ckb-testtool"
"How do I deploy an on-chain script to CKB Testnet?"
"Create a simple UDT token with mint and transfer"
"Debug my on-chain script — it's returning error code 5"
"What's the minimum capacity for a Cell with 32 bytes of data?"
"Help me integrate CKB wallet connection in my React app"
"Review this on-chain script for security issues"
"How do I run a Fiber node and open a payment channel?"
"Send a payment over Fiber Network using invoices"
"Set up a two-node Fiber testnet for local development"
```

## Stack Decisions

This skill encodes opinionated best practices:

| Layer                    | Default Choice         | Alternative                            |
| ------------------------ | ---------------------- | -------------------------------------- |
| On-chain script language | Rust + `ckb-std`       | C (`ckb-c-stdlib`), JS (`ckb-js-vm`)   |
| DApp SDK                 | CCC (`@ckb-ccc/shell`) | CCC React (`@ckb-ccc/connector-react`) |
| Project Scaffolding      | `ckb-script-templates` | Manual setup                           |
| Unit Testing             | `ckb-testtool`         | `ckb-debugger` CLI                     |
| Debugging                | `ckb-debugger` + GDB   | Debug print via `ckb_debug!`           |
| Local Development        | OffCKB                 | Manual CKB node                        |
| Deployment               | Type ID (upgradable)   | Direct data deployment                 |
| Serialization            | Molecule               | —                                      |
| Payment Channels         | Fiber Network (fnn)    | —                                      |

## Content Sources

This skill incorporates best practices from:

- [Nervos CKB Documentation](https://docs.nervos.org/) — Official documentation
- [CCC SDK](https://github.com/ckb-devrel/ccc) — Primary JS/TS SDK
- [ckb-std](https://github.com/nervosnetwork/ckb-std) — Rust standard library for on-chain scripts
- [CKB RFCs](https://github.com/nervosnetwork/rfcs) — Protocol specifications
- [CKB Academy](https://academy.ckb.dev/) — Learning platform
- [Fiber Network](https://github.com/nervosnetwork/fiber) — Payment channel network
- [Fiber Docs](https://docs.fiber.world) — Fiber Network documentation

## Progressive Disclosure

The skill uses Claude Code's progressive disclosure pattern. The main `SKILL.md` provides core guidance and operating procedures. Claude reads the specialized markdown files only when needed for specific tasks, keeping context usage efficient.

## Quality Checks

The repository includes a docs-focused CI workflow that checks:

- Markdown links with Lychee
- Spelling with CSpell
- Markdown formatting with Prettier

You can run the same checks locally with:

```bash
make docs-check
```

Useful shortcuts:

- `make docs-format` — rewrite Markdown files with Prettier
- `make docs-format-check` — verify Markdown formatting only
- `make docs-spell` — run spelling checks only
- `make docs-links` — run link checks only

## Contributing

Contributions are welcome! Please ensure any updates reflect current CKB ecosystem best practices.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License
