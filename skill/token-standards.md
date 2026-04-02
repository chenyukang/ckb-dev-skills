# Token Standards on CKB

## Overview

CKB supports various token standards built on the Cell model. Unlike account-based blockchains, tokens on CKB are stored in Cell data and governed by Type Scripts.

## sUDT (Simple User Defined Token)

The basic fungible token standard on CKB ([RFC 0025](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0025-simple-udt/0025-simple-udt.md)).

### Structure

Each sUDT Cell stores the token amount as a 128-bit little-endian unsigned integer in the first 16 bytes of `data`:

```
Cell.data = <amount: u128 (16 bytes)> [optional extra data]
```

### Type Script

```
type: {
  code_hash: <sUDT code hash>,
  hash_type: "type",
  args: <owner lock hash (32 bytes)>
}
```

The `args` field contains the owner's lock script hash. Only the owner can issue (mint) new tokens. Anyone can transfer existing tokens.

### Rules

- **Mint**: Only the owner (whose lock script hash matches `args`) can create new sUDT Cells.
- **Transfer**: Total input sUDT amount >= Total output sUDT amount (for the same type script).

## xUDT (Extensible UDT)

An extension of sUDT with additional features like supply control, pausability, and custom logic ([RFC 0052](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0052-extensible-udt/0052-extensible-udt.md)).

## Spore DOB (Digital Object)

A protocol for creating unique digital objects on CKB. Part of the [DOB Protocol Family](https://docs.spore.pro/category/dob-digital-object).

- **Documentation**: https://docs.spore.pro/
- **Spore SDK**: https://github.com/sporeprotocol/spore-sdk
- **DOB/0 Protocol Spec**: https://docs.spore.pro/dob/dob0-protocol

### Features

- On-chain content storage (not just a URI like ERC-721)
- Content type detection
- Immutable or mutable (with cluster ownership)
- Built-in royalty and ownership

### Getting Started

- [Getting Started with Spore](https://docs.spore.pro/category/get-started)
- [Create Your First Spore](https://docs.spore.pro/tutorials/create-first-spore/)
- [Creating an On-Chain Blog Using Spore](https://docs.spore.pro/tutorials/create-on-chain-blog/)
- [Managing Spore Operations](https://docs.spore.pro/category/how-to-recipes) — Creation, transfer, melting, data handling
- [Spore Glossary](https://docs.spore.pro/category/glossary)

### Examples

- [Spore Demo](https://github.com/sporeprotocol/spore-demo) — Demo source code
- [Philosopher's Stone](https://github.com/SpectreMercury/PhilosopherStone) — Full Spore application example

## RGB++ Protocol

An extended RGB protocol that uses CKB as a verification layer for Bitcoin L1 assets.

- **Design**: https://github.com/utxostack/RGBPlusPlus-design
- **SDK**: https://github.com/RGBPlusPlus/rgbpp-sdk
- **Code Examples**: https://github.com/RGBPlusPlus/rgbpp-sdk/tree/develop/examples
- **Light Paper (CN)**: https://github.com/utxostack/RGBPlusPlus-design/blob/main/docs/light-paper-cn.md
- **Contract Specs (CN)**: https://github.com/utxostack/RGBPlusPlus-design/blob/main/docs/lockscript-design-prd-cn.md

### How It Works

1. Assets are issued on Bitcoin.
2. State changes are verified on CKB.
3. CKB's Turing-complete VM enables complex logic for Bitcoin-native assets.

## AI Dev Tips

- When creating UDT transfer transactions, always ensure the total input token amount >= total output token amount for each token type.
- UDT amounts are stored as 128-bit little-endian integers. Use `ccc.numLeToBytes(amount, 16)` to encode.
- Each UDT Cell still requires CKB capacity for storage. A typical sUDT Cell needs ~142 CKBytes (lock script + type script + 16 bytes data + capacity field).
- The sUDT type script's `args` (owner lock hash) determines who can mint. This is a 32-byte Blake2b-256 hash of the owner's lock script.

## References

- [Assets & Token Standards](https://docs.nervos.org/docs/assets-token-standards/assets-overview)
- [sUDT RFC](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0025-simple-udt/0025-simple-udt.md)
- [xUDT RFC](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0052-extensible-udt/0052-extensible-udt.md)
- [Create a Fungible Token](https://docs.nervos.org/docs/dapp/create-token)
- [Spore Protocol](https://docs.spore.pro/)
- [Spore SDK](https://github.com/sporeprotocol/spore-sdk)
- [DOB/0 Protocol](https://docs.spore.pro/dob/dob0-protocol)
- [RGB++ Design](https://github.com/utxostack/RGBPlusPlus-design)
- [RGB++ SDK](https://github.com/RGBPlusPlus/rgbpp-sdk)
- [xUDT Logos](https://xudtlogos.cc/faq) — Display xUDT logos on DApps
