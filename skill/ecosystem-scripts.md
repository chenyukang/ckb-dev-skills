# Ecosystem On-Chain Scripts

## Overview

CKB has a set of well-audited, production-ready on-chain scripts deployed on both Mainnet and Testnet. Understanding these on-chain scripts is essential for building on CKB.

## System on-chain scripts

### secp256k1_blake160_sighash_all (Default Lock)

The most commonly used lock on-chain script. Verifies secp256k1 signature with Blake2b-160 hash.

```
code_hash: 0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8
hash_type: type
args: <20-byte blake160 of public key>
```

**How it works:**

1. Extracts public key from witness signature.
2. Hashes public key with Blake2b-256, takes first 20 bytes (Blake160).
3. Compares with `args`.
4. Verifies secp256k1 signature.

### secp256k1_blake160_multisig_all (Multi-Sig Lock)

Multi-signature lock on-chain script supporting M-of-N signing.

```
code_hash: 0x5c5069eb0857efc65e1bca0c07df34c31663b3622fd3876c876320fc9634e2a8
hash_type: type
args: <20-byte blake160 of multi-sig config>
```

### anyone_can_pay (ACP Lock)

Allows anyone to deposit CKB/UDT to the Cell without consuming it. Useful for receiving payments.

```
code_hash: 0xd369597ff47f29fbc0d47d5f40857c3cc6b7c4244c16e4df2eb3a204e3d8e75c
hash_type: type
args: <20-byte lock_args> [minimum_ckb_amount] [minimum_udt_amount]
```

## Token on-chain scripts

### sUDT (Simple UDT) type on-chain script

```
code_hash: 0x5e7a36a77e68eecc013dfa2fe6a23f3b6c344b04005808694ae6dd45eea4cfd5
hash_type: type
args: <32-byte owner lock hash>
```

### xUDT (Extensible UDT) type on-chain script

Extended UDT with pluggable extensions for features like supply control and pausability.

## Omnilock (Universal Lock)

A universal lock on-chain script that supports multiple authentication methods and features in a single on-chain script.

```
code_hash: 0xf329effd1c475a2978453c8600e1eaf0bc2087ee093c3ee64cc96ec6847752cb
hash_type: type
args: <auth content (21 bytes)> [omnilock args flags and fields]
```

**Supported auth methods:**

- **secp256k1** (CKB native, Bitcoin, Ethereum addresses)
- **secp256r1** (WebAuthn, passkeys — used by JoyID)
- **Multi-sig** (M-of-N threshold)
- **exec/dl** (dynamic loading of custom auth)
- **ckb-auth** integration (any algorithm ckb-auth supports)

**Optional features** (via flags in args):

- **Supply lock**: Limit token supply
- **Time lock**: Cells cannot be spent until after a certain time
- **ACP (Anyone-Can-Pay)**: Accept deposits from anyone

**Why Omnilock matters**: It enables CKB DApps to accept users from virtually any wallet ecosystem (Ethereum, Bitcoin, WebAuthn, etc.) through a single lock on-chain script, rather than deploying separate on-chain scripts for each auth method.

**References:**

- [Omnilock RFC](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0042-omnilock/0042-omnilock.md)
- [Omnilock Introduction (Blog)](https://blog.cryptape.com/omnilock-a-universal-lock-that-powers-interoperability-1)

## JoyID Lock

A specialized lock on-chain script for [JoyID](https://docs.joyid.dev/guide/sdk) wallet, using WebAuthn/Passkeys (secp256r1) for passwordless authentication.

- JoyID uses on-device biometric authentication (fingerprint, Face ID) to sign CKB transactions.
- Internally relies on secp256r1 signature verification.
- CCC SDK supports JoyID connection out of the box via `@ckb-ccc/connector-react`.

**Practical example**: [Philosopher's Stone - JoyID integration](https://github.com/SpectreMercury/PhilosopherStone/blob/main/src/utils/joyid.ts)

## Library on-chain scripts

### ckb-auth

A universal authentication library on-chain script that supports multiple signature algorithms:

- secp256k1 (Bitcoin, Ethereum)
- secp256r1 (WebAuthn, passkeys)
- Schnorr (Bitcoin Taproot)
- RSA
- Ed25519
- And more

This enables CKB to verify signatures from virtually any blockchain ecosystem.

## Using ecosystem on-chain scripts in Transactions

When using these on-chain scripts, you need to:

1. **Reference the on-chain script code** via `code_hash` and `hash_type`.
2. **Include the code Cell** in `cell_deps`.

Example with CCC:

```typescript
// The lock on-chain script auto-uses secp256k1_blake160_sighash_all
const signer = new ccc.SignerCkbPrivateKey(client, privateKey);

// CCC automatically adds the required cell_deps
const tx = ccc.Transaction.from({
  outputs: [{ lock: recipientLock, capacity: ccc.fixedPointFrom("100") }],
});
await tx.completeInputsByCapacity(signer);
await tx.completeFeeBy(signer);
```

## AI Dev Tips

- CCC SDK automatically handles `cell_deps` for common system on-chain scripts -- you rarely need to add them manually.
- The `secp256k1_blake160_sighash_all` on-chain script is what most CKB addresses use by default.
- When building custom lock on-chain scripts, consider using `ckb-auth` as a dependency to support multiple signature algorithms.
- ecosystem on-chain scripts are deployed at well-known addresses; check the Nervos docs for the latest addresses on each network.
- `anyone_can_pay` is powerful for DApps that need to receive arbitrary deposits.

## References

- [Ecosystem on-chain scripts Introduction](https://docs.nervos.org/docs/ecosystem-scripts/introduction)
- [secp256k1_blake160_sighash_all](https://docs.nervos.org/docs/ecosystem-scripts/secp256k1_blake160_sighash_all)
- [Omnilock RFC](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0042-omnilock/0042-omnilock.md)
- [Omnilock Introduction (Blog)](https://blog.cryptape.com/omnilock-a-universal-lock-that-powers-interoperability-1)
- [ckb-auth](https://docs.nervos.org/docs/ecosystem-scripts/ckb-auth)
- [JoyID SDK](https://docs.joyid.dev/guide/sdk)
- [sUDT](https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0025-simple-udt/0025-simple-udt.md)
