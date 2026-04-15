# Rust On-Chain Script Development: Environment Setup

## Overview

Rust is the recommended language for CKB on-chain script development due to its performance, memory safety, and mature toolchain support for RISC-V targets.

## Prerequisites

| Tool                                  | Minimum Version | Purpose                        |
| ------------------------------------- | --------------- | ------------------------------ |
| Rust                                  | >= 1.71.1       | Language and compiler          |
| `riscv64imac-unknown-none-elf` target | -               | RISC-V cross-compilation       |
| Clang                                 | >= 18           | C compiler for dependencies    |
| Make                                  | >= 4.3          | Build automation               |
| cargo-generate                        | >= 0.17.0       | Project scaffolding            |
| ckb-debugger                          | >= 0.117.0      | on-chain script execution and debugging |

## Installation Steps

### 1. Install Rust and RISC-V Target

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add RISC-V target
rustup target add riscv64imac-unknown-none-elf
```

### 2. Install Clang

```bash
# macOS
brew install llvm@18

# Ubuntu/Debian
sudo apt install clang-18
```

### 3. Install cargo-generate

```bash
cargo install cargo-generate
```

### 4. Install CKB Debugger

```bash
cargo install ckb-debugger
```

## Create a New On-Chain Script Project

```bash
# Generate project from template
cargo generate gh:cryptape/ckb-script-templates workspace --name my-ckb-project

# Enter project directory
cd my-ckb-project

# Generate a contract
make generate CRATE=my-contract

# Build all contracts
make build
```

## Project Structure

```
my-ckb-project/
├── Makefile                    # Build commands
├── contracts/
│   └── my-contract/
│       ├── Cargo.toml
│       └── src/
│           └── main.rs         # Contract entry point (program_entry)
├── tests/
│   └── src/
│       └── tests.rs            # Test cases using ckb-testtool
├── build/
│   └── release/                # Compiled binaries
│       ├── my-contract         # Production binary
│       └── my-contract.debug   # Debug binary
└── scripts/                    # Utility scripts
```

## Key Libraries

| Library                                                                  | Purpose                                                      |
| ------------------------------------------------------------------------ | ------------------------------------------------------------ |
| [ckb-std](https://github.com/nervosnetwork/ckb-std)                      | Standard library for CKB on-chain scripts (syscalls, high-level APIs) |
| [ckb-testtool](https://docs.rs/ckb-testtool/latest/ckb_testtool)         | Testing framework that simulates CKB environment             |
| [ckb-script-templates](https://github.com/cryptape/ckb-script-templates) | Project templates for cargo-generate                         |

## Important: no_std Requirement

CKB on-chain scripts must use `#![no_std]` because there is no operating system in CKB-VM. The `ckb-std` crate provides replacements for common functionality:

```rust
#![no_std]
#![cfg_attr(not(test), no_main)]

#[cfg(test)]
extern crate alloc;

// Entry point
#[no_mangle]
pub fn program_entry() -> i8 {
    // Your on-chain script logic here
    0 // Return 0 for success
}
```

## AI Dev Tips

- Always use `#![no_std]` -- CKB-VM has no OS and no standard library.
- The `program_entry` function is the equivalent of `main()`. Return `0` for success, non-zero for failure.
- Use `ckb_std::debug!()` for logging (similar to `println!`); these are stripped in production builds.
- Compile with `--release` and strip debug symbols for production to minimize binary size and cycle consumption.
- The RISC-V target is `riscv64imac-unknown-none-elf` (64-bit, integer, multiply, atomic, compressed).

## References

- [Rust Quick Start](https://docs.nervos.org/docs/script/rust/rust-quick-start)
- [Rust Build](https://docs.nervos.org/docs/script/rust/rust-build)
- [Program Languages for on-chain script](https://docs.nervos.org/docs/script/program-language-for-script)
- [ckb-std GitHub](https://github.com/nervosnetwork/ckb-std)
