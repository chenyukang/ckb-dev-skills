# Deployment and Ecosystem Tools

## Overview

This skill covers deploying Scripts to CKB networks and the key development tools in the ecosystem.

## CKB Networks

| Network          | Purpose           | RPC Endpoint                |
| ---------------- | ----------------- | --------------------------- |
| Mainnet (MIRANA) | Production        | https://mainnet.ckb.dev/rpc |
| Testnet (PUDGE)  | Testing           | https://testnet.ckb.dev/rpc |
| Devnet           | Local development | http://localhost:8114       |

The `ckb.dev` and `ckbapp.dev` RPC domains are valid aliases; this guide uses `ckb.dev` consistently.

## Testnet Faucet

Before developing, claim testnet CKB tokens:

- **Faucet**: https://faucet.nervos.org/

## OffCKB: Local Development Environment

[OffCKB](https://github.com/ckb-devrel/offckb) provides a local CKB Devnet for development.

```bash
# Install
npm install -g @offckb/cli

# Start a local devnet
offckb node
```

OffCKB comes with pre-deployed system Scripts and funded accounts for immediate development.

## Deploying Scripts

### Via CCC SDK (TypeScript)

```typescript
import { ccc } from "@ckb-ccc/shell";

async function deployScript(signer: ccc.Signer, scriptBinary: Uint8Array) {
  const scriptData = ccc.bytesFrom(scriptBinary);
  const minCapacity = ccc.fixedPointFrom(String(61 + scriptData.length));

  const tx = ccc.Transaction.from({
    outputs: [
      {
        lock: (await signer.getRecommendedAddressObj()).script,
        capacity: minCapacity,
      },
    ],
    outputsData: [scriptData],
  });

  await tx.completeInputsByCapacity(signer);
  await tx.completeFeeBy(signer);
  const txHash = await signer.sendTransaction(tx);

  // The deployed script's code_hash (data hash) is:
  // Blake2b-256 hash of the scriptBinary
  return txHash;
}
```

### Via CKB-CLI

The most reproducible way to deploy and upgrade contract binaries is `ckb-cli deploy` (deployment config + migrations).
Reference: https://github.com/nervosnetwork/ckb-cli/wiki/Deploy-contracts

```bash
# Initialize a deployment config
ckb-cli deploy init-config --deployment-config deployment.toml

# Edit deployment.toml (cells/dep_groups/lock), then generate txs
ckb-cli deploy gen-txs \
  --deployment-config deployment.toml \
  --migration-dir migrations \
  --from-address <address> \
  --info-file deploy-info.json

# If you did not use --sign-now, sign separately
ckb-cli deploy sign-txs \
  --from-account <address> \
  --info-file deploy-info.json

# Send txs to chain
ckb-cli deploy apply-txs \
  --info-file deploy-info.json \
  --migration-dir migrations

# After apply-txs, make sure the chain confirms them (on dev chains you may need to start mining)
```

Notes:

- `deployment.toml` supports both local binaries (`location = { file = "..." }`) and on-chain references (`location = { tx_hash = "0x...", index = N }`).
- Use `dep_groups` to bundle frequently-used deps (e.g. omni_lock + secp256k1_data).
- Enabling Type ID keeps the same reference identity across upgrades.

## Type ID for Upgradable Scripts

Type ID is a pattern that allows Script code to be upgraded while keeping the same `code_hash`:

1. Deploy the Script Cell with a special Type Script (Type ID).
2. Reference the Script using `hash_type: "type"` and `code_hash: <type_id_hash>`.
3. To upgrade: consume the old Cell, create a new Cell with updated code but same Type ID.

```
# Type ID Script
type: {
  code_hash: TYPE_ID_CODE_HASH,
  hash_type: "type",
  args: <unique type id>
}
```

The Type ID Script ensures only one Cell with a given type ID can exist at any time.

## ckb-script-templates: Script Project Scaffolding (recommended)

For new script projects, use [ckb-script-templates](https://github.com/cryptape/ckb-script-templates) (cargo-generate templates). It is the current recommended workflow for Rust-based on-chain scripts.

```bash
cargo install cargo-generate

# Create a workspace
cargo generate gh:cryptape/ckb-script-templates workspace --name my-ckb-contracts
cd my-ckb-contracts

# Generate a contract crate
make generate CRATE=my-contract

# Build + test
make build
make test
```

Legacy note: [Capsule](https://github.com/nervosnetwork/capsule) exists, but we do not recommend starting new projects with it.

## Running a CKB Node

For full node operation (beyond local Devnet):

- [CKB Node Running Tutorials](https://linktr.ee/nodeckb) — Guides for running your own node
- [CKB Node Probe](https://nodes.ckb.dev/) — Monitor CKB node status online
- [Find Your Node ID](https://nodes.ckb.dev/findNode)

## Public RPC Nodes

- [List of Public JSON-RPC Nodes](https://github.com/nervosnetwork/ckb/wiki/Public-JSON-RPC-nodes)

## Key Development Tools

### CKB-CLI

Command-line interface for CKB operations:

```bash
# Check balance
ckb-cli wallet get-capacity --address <address>

# Transfer CKB
ckb-cli wallet transfer \
  --from-account <from_address> \
  --to-address <to_address> \
  --capacity <amount_in_CKB>

# Generate address
ckb-cli account new
```

### CKB RPC

Common RPC calls:

```bash
# Get tip block number
curl -X POST https://testnet.ckb.dev/rpc \
  -H 'Content-Type: application/json' \
  -d '{"id": 1, "jsonrpc": "2.0", "method": "get_tip_block_number", "params": []}'

# Get live cell
curl -X POST https://testnet.ckb.dev/rpc \
  -H 'Content-Type: application/json' \
  -d '{"id": 1, "jsonrpc": "2.0", "method": "get_live_cell", "params": [{"tx_hash": "0x...", "index": "0x0"}, true]}'

# Send transaction
curl -X POST https://testnet.ckb.dev/rpc \
  -H 'Content-Type: application/json' \
  -d '{"id": 1, "jsonrpc": "2.0", "method": "send_transaction", "params": [<tx_json>, "passthrough"]}'
```

### SDKs by Language

| Language              | SDK          | Link                                          |
| --------------------- | ------------ | --------------------------------------------- |
| TypeScript/JavaScript | CCC          | https://github.com/ckb-devrel/ccc             |
| TypeScript/JavaScript | Lumos        | https://github.com/ckb-js/lumos               |
| Rust                  | ckb-sdk-rust | https://github.com/nervosnetwork/ckb-sdk-rust |
| Go                    | ckb-sdk-go   | https://github.com/nervosnetwork/ckb-sdk-go   |
| Java                  | ckb-sdk-java | https://github.com/nervosnetwork/ckb-sdk-java |

### Molecule (Serialization)

CKB uses Molecule for binary serialization (not Protobuf/JSON). Key characteristics:

- Zero-copy deserialization
- Schema-based
- Deterministic encoding

```
// Molecule schema example
table Script {
    code_hash: Byte32,
    hash_type: byte,
    args: Bytes,
}
```

## Script Upgrade Workflow

1. **Initial Deployment**: Deploy Script with Type ID.
2. **Testing**: Test thoroughly on Devnet and Testnet.
3. **Upgrade**: Consume old Cell, create new Cell with same Type ID but updated binary.
4. **Verification**: All existing references via `hash_type: "type"` automatically use the new code.

## AI Dev Tips

- Use OffCKB for local development to avoid Testnet faucet rate limits.
- Always deploy and test on Testnet before Mainnet.
- Use Type ID pattern for any Script that might need future upgrades.
- When deploying, record the `tx_hash` and `index` of the deployed Cell -- you'll need it for `cell_deps`.
- CKB capacity stored in a Script Cell is locked; budget accordingly for deployment costs.
- Use `data2` hash_type for new deployments to target the latest VM version.

## References

- [CKB Networks](https://docs.nervos.org/docs/getting-started/ckb-networks)
- [Type ID](https://docs.nervos.org/docs/script/type-id)
- [Script Upgrade Workflow](https://docs.nervos.org/docs/script/script-upgrade-workflow)
- [SDK & Dev Tools](https://docs.nervos.org/docs/sdk-and-devtool/devtool)
- [OffCKB](https://github.com/ckb-devrel/offckb)
- [Molecule Serialization](https://docs.nervos.org/docs/serialization/serialization-molecule-in-ckb)
