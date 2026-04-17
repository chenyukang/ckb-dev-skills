# Writing CKB on-chain scripts

For contract development guidance, avoid duplicating existing docs. Use the authoritative sources directly:

- RFC 0022 (Transaction Structure): https://github.com/nervosnetwork/rfcs/tree/master/rfcs/0022-transaction-structure
- Rust stdlib for on-chain scripts: https://github.com/nervosnetwork/ckb-std
- C stdlib for on-chain scripts: https://github.com/nervosnetwork/ckb-c-stdlib
- Project scaffolding (recommended): https://github.com/cryptape/ckb-script-templates

Opinionated defaults:

- Language: Rust first; C for extreme size/cycle sensitivity.
- Scaffolding: start new projects from `ckb-script-templates` (cargo-generate workspace).
