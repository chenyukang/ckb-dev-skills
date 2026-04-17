# Curated Resources

## Core Documentation

- [Nervos CKB Documentation](https://docs.nervos.org/) — Official docs (architecture, on-chain script dev, guides)
- [CKB RFCs](https://github.com/nervosnetwork/rfcs) — Protocol specifications and design decisions
- [CKB Academy](https://academy.ckb.dev/) — Interactive learning platform with courses:
  - [CKB Fundamentals](https://academy.ckb.dev/courses) — Foundational theory
  - [CKB Operations](https://academy.ckb.dev/courses) — Practical transaction execution
- [CKB Glossary](https://docs.nervos.org/docs/tech-explanation/glossary) — Terminology reference
- [CKB Developer Resource Hub](https://github.com/ckb-devrel/CKB-Developer-Resource) — Comprehensive developer link collection
- [Nervos Talk Developer Resources Hub](https://talk.nervos.org/t/nervos-network-developers-resources-hub/7261) — Community-curated resource list

## Tutorials & Learning

- [CookCKB](https://github.com/CKBFansDAO/cookckb/tree/master) — Example code collection and development framework
- [Construct and Send Your First CKB Transaction](https://blog.cryptape.com/construct-and-send-your-first-ckb-transaction) — Step-by-step tutorial
- [Cryptape Blog](https://blog.cryptape.com/) — Insights and research on CKB design and development

## On-Chain Script Development

### Rust

- [ckb-std](https://github.com/nervosnetwork/ckb-std) — Rust standard library for CKB on-chain scripts (no_std)
- [ckb-script-templates](https://github.com/cryptape/ckb-script-templates) — Cargo-generate templates for on-chain script projects
- [ckb-testtool](https://github.com/nervosnetwork/ckb-testtool) — Rust testing framework for CKB on-chain scripts
- [Simple UDT Example](https://github.com/xcshuan/simple-udt) — Sample sUDT on-chain script implementation in Rust

### C

- [ckb-c-stdlib](https://github.com/nervosnetwork/ckb-c-stdlib) — C standard library for CKB on-chain scripts

### JavaScript

- [ckb-js-vm](https://github.com/nervosnetwork/ckb-js-vm) — JavaScript VM running on CKB-VM

### Lua

- [ckb-lua](https://github.com/nervosnetwork/ckb-lua) — Lua support for CKB on-chain scripts

### Frameworks

- [ckb-script-templates](https://github.com/cryptape/ckb-script-templates) — Recommended project scaffolding (cargo-generate)
- [Capsule](https://github.com/nervosnetwork/capsule) — Legacy framework (not recommended for new projects)

## DApp Development

- [CCC SDK](https://github.com/ckb-devrel/ccc) — CKBers' Codebase, the primary JS/TS SDK
- [CCC Playground](https://live.ckbccc.com/) — Interactive playground for CCC SDK
- [CCC API Docs](https://api.ckbccc.com) — TypeScript API reference
- [Lumos](https://github.com/ckb-js/lumos) — Full-featured JS/TS framework (legacy, CCC recommended for new projects)
- [Spore SDK](https://github.com/sporeprotocol/spore-sdk) — SDK for Spore DOB protocol

### SDKs by Language

| Language              | SDK               | Link                                          |
| --------------------- | ----------------- | --------------------------------------------- |
| TypeScript/JavaScript | CCC (recommended) | https://github.com/ckb-devrel/ccc             |
| TypeScript/JavaScript | Lumos (legacy)    | https://github.com/ckb-js/lumos               |
| Rust                  | ckb-sdk-rust      | https://github.com/nervosnetwork/ckb-sdk-rust |
| Go                    | ckb-sdk-go        | https://github.com/nervosnetwork/ckb-sdk-go   |
| Java                  | ckb-sdk-java      | https://github.com/nervosnetwork/ckb-sdk-java |

## Token Standards & Protocols

- [sUDT RFC](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0025-simple-udt/0025-simple-udt.md) — Simple User Defined Token
- [xUDT RFC](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0052-extensible-udt/0052-extensible-udt.md) — Extensible User Defined Token
- [Spore Protocol Docs](https://docs.spore.pro/) — Digital Object (DOB) standard
- [DOB/0 Protocol](https://docs.spore.pro/dob/dob0-protocol) — DOB/0 protocol spec
- [Spore Demo](https://github.com/sporeprotocol/spore-demo) — Spore demo source code
- [Philosopher's Stone](https://github.com/SpectreMercury/PhilosopherStone) — Spore application example
- [RGB++ Design](https://github.com/utxostack/RGBPlusPlus-design) — RGB++ protocol early design docs
- [RGB++ SDK](https://github.com/RGBPlusPlus/rgbpp-sdk) — RGB++ SDK (actively maintained fork)
- [RGB++ Code Examples](https://github.com/RGBPlusPlus/rgbpp-sdk/tree/develop/examples) — SDK examples
- [RGB++ Light Paper (CN)](https://github.com/utxostack/RGBPlusPlus-design/blob/main/docs/light-paper-cn.md) — RGB++ protocol whitepaper draft

## Wallets

- [Omnilock RFC](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0042-omnilock/0042-omnilock.md) — Universal lock powering wallet interoperability
- [Omnilock Introduction](https://blog.cryptape.com/omnilock-a-universal-lock-that-powers-interoperability-1) — Blog post explaining Omnilock
- [JoyID SDK](https://docs.joyid.dev/guide/sdk) — JoyID (PassKey) wallet integration
- [Rei Wallet Docs](https://docs.reiwallet.io) — Rei browser extension wallet
- [Rei Wallet Demo](https://demo-app.reiwallet.io/) — Interactive Rei demo

### Supported Wallets

| Wallet           | Platform                        | Type             |
| ---------------- | ------------------------------- | ---------------- |
| Neuron           | Desktop (Windows, macOS, Linux) | Full node wallet |
| CKBull           | Mobile (Android, iOS)           | Mobile wallet    |
| JoyID            | Web                             | PassKey-based    |
| Portal Wallet    | Web                             | Web wallet       |
| Rei Wallet       | Browser Extension               | Extension        |
| SafePal          | Hardware, Mobile                | Hardware wallet  |
| Ledger           | Hardware                        | Hardware wallet  |
| Opera Wallet     | Mobile (Android)                | Built-in         |
| imToken          | Mobile (Android, iOS)           | Multi-chain      |
| Gate Web3 Wallet | Mobile, Extension               | Multi-chain      |
| OneKey           | Desktop, Mobile, Extension      | Multi-chain      |

## Fiber Network (Payment Channels)

- [Fiber Network Website](https://www.fiber.world) — Official site
- [Fiber Documentation](https://docs.fiber.world) — Docs, tutorials, tech explanations
- [Fiber GitHub](https://github.com/nervosnetwork/fiber) — FNN node source code (Rust)
- [Fiber Light Paper](https://github.com/nervosnetwork/fiber/blob/main/docs/light-paper.md) — Protocol design overview
- [Fiber RPC Reference](https://github.com/nervosnetwork/fiber/blob/v0.7.1/crates/fiber-lib/src/rpc/README.md) — Full JSON-RPC API
- [Run a Fiber Node](https://docs.fiber.world/docs/quick-start/run-a-node) — Node setup guide
- [Basic Transfer Tutorial](https://docs.fiber.world/docs/quick-start/basic-transfer) — End-to-end payment example
- [Transfer Stablecoins](https://docs.fiber.world/docs/quick-start/transfer-stablecoin) — UDT (RUSD) payments
- [Connect Public Nodes](https://docs.fiber.world/docs/quick-start/connect-nodes) — Join the testnet
- [Build a Game with Fiber](https://docs.fiber.world/docs/tutorial/simple-game) — Game tutorial
- [fiber-pay CLI](https://github.com/RetricSu/fiber-pay) — AI-friendly CLI for Fiber node operations

## Testing & Debugging

- [ckb-debugger](https://github.com/nervosnetwork/ckb-standalone-debugger) — CLI tool for executing and debugging on-chain scripts
- [ckb-testtool](https://github.com/nervosnetwork/ckb-testtool) — Simulates CKB environment for Rust tests

## Local Development & Infrastructure

- [OffCKB](https://github.com/ckb-devrel/offckb) — Local Devnet with pre-deployed system on-chain scripts
- [CKB-CLI](https://github.com/nervosnetwork/ckb-cli) — Command-line interface for CKB node interaction
- [Testnet Faucet](https://faucet.nervos.org/) — Claim testnet CKB tokens for development
- [Public JSON-RPC Nodes](https://github.com/nervosnetwork/ckb/wiki/Public-JSON-RPC-nodes) — List of public RPC endpoints
- [CKB Node Running Tutorials](https://linktr.ee/nodeckb) — Guides for running your own CKB node
- [CKB Node Probe](https://nodes.ckb.dev/) — Monitor CKB node status online

## Serialization

- [Molecule](https://github.com/nervosnetwork/molecule) — CKB's on-chain serialization format
- [Molecule Encoding Spec](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0008-serialization/0008-serialization.md)

## Explorers & Tools

- [CKB Explorer (Mainnet)](https://explorer.nervos.org/) — Block explorer
- [CKB Testnet Explorer](https://pudge.explorer.nervos.org/) — Testnet block explorer
- [CKB RPC Docs](https://github.com/nervosnetwork/ckb/tree/develop/rpc) — JSON-RPC API reference
- [CKB GraphQL Layer](https://talk.nervos.org/t/a-graphql-layer-for-ckb/7476) — Retrieving Cells and transactions via GraphQL
- [xUDT Logos](https://xudtlogos.cc/faq) — Display xUDT logos on DApps
- [CKB DApps](https://ckbdapps.com/) — Collection of CKB DApp tools
- [CKB Tools](https://ckb.tools/) — Address generation and utility tools

## Network Information

- **Mainnet (MIRANA)**: `https://mainnet.ckb.dev/rpc`
- **Testnet (PUDGE)**: `https://testnet.ckb.dev/rpc`
- **Devnet**: Use OffCKB (`offckb node`) → `http://localhost:8114`

## Community

- [Nervos Talk](https://talk.nervos.org/) — Community forum (technical discussions archive since 2017)
- [Nervos Discord](https://discord.gg/nervos) — Developer chat
  - [English Dev Channel](https://discord.com/channels/657799690070523914/671647247024521217)
  - [Chinese Dev Channel](https://discord.com/channels/657799690070523914/1242826741777432667)
- [CKB Dev Telegram](https://t.me/ckbdev) — Developer and enthusiast community group
- [CKB GitHub](https://github.com/nervosnetwork/ckb) — CKB node source code

## Videos

- [Cryptape Vanguard YouTube](https://www.youtube.com/@cryptape) — Technical talks and tutorials
- [Nervos Network YouTube](https://www.youtube.com/@NervosNetwork/videos) — Official Nervos channel

## Grants & Funding

- [CKB Community Fund DAO](https://talk.nervos.org/c/ckb-community-fund-dao/65) — Apply for CKB-related grants
- [Fund DAO Guidelines](https://talk.nervos.org/t/ckb-community-fund-dao/6873) — Rules and procedures
