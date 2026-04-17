# Fiber Network (CKB Payment Channel Network)

## Overview

Fiber Network is a peer-to-peer payment and swap network built on CKB, analogous to Bitcoin's Lightning Network. It enables instant, low-cost, privacy-preserving off-chain transactions with multi-asset support.

- **Website**: https://www.fiber.world
- **Documentation**: https://docs.fiber.world
- **GitHub**: https://github.com/nervosnetwork/fiber
- **Light Paper**: https://github.com/nervosnetwork/fiber/blob/main/docs/light-paper.md
- **Latest Release**: v0.7.1

## Key Features

- **Multiple assets support**: CKB, RGB++ assets (stablecoins like RUSD), and UDT assets
- **Extremely low-cost micropayments**: e.g. 0.0001 cent payment with 0.00000001 cent fee
- **Instant swap between any asset pairs**: as long as there's available channel paths
- **Cross-network**: Interoperable with Bitcoin Lightning Network via edge nodes
- **Privacy-by-default**: Transactions are only seen by involved peers
- **Multi-hop payment**: Route payments through intermediate nodes; earn fees as a hop
- **Low latency**: Payments complete within your p2p connection latency (e.g. 20ms)
- **High throughput**: No network consensus required for off-chain transactions
- **PTLC-based**: Uses Point Time-Locked Contracts (more advanced than HTLC)
- **Composable**: Works with other CKB on-chain scripts and contracts

## How It Works

1. **Open a channel**: Two parties lock funds in an on-chain funding transaction (CKB Cell).
2. **Off-chain payments**: Unlimited instant transactions between the two parties, updating balances off-chain.
3. **Multi-hop routing**: Payments can route through multiple channels to reach any peer in the network.
4. **Close the channel**: Final balance is settled on-chain; all intermediate payments are consolidated into one L1 transaction.

## Architecture

Fiber Network Node (FNN) is the reference node implementation:

```
┌────────────────────────────────────┐
│  Fiber Network Node (fnn binary)   │
│                                    │
│  ┌──────────┐  ┌────────────────┐  │
│  │ P2P Layer│  │  RPC (JSON-RPC)│  │
│  │ (libp2p) │  │  Port: 8227    │  │
│  └──────────┘  └────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │  Channel State Machine       │  │
│  │  (funding, commitment, PTLC) │  │
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │  CKB Integration Layer       │  │
│  │  (wallet, L1 monitoring)     │  │
│  └──────────────────────────────┘  │
└────────────────────────────────────┘
```

## Running a Fiber Node

### Prerequisites

- Rust and Cargo (if building from source)
- `ckb-cli` for key management
- CKB testnet tokens from [faucet](https://faucet.nervos.org/)

### Quick Setup

```bash
# Option 1: Download pre-built binary from releases
# https://github.com/nervosnetwork/fiber/releases

# Option 2: Build from source
git clone https://github.com/nervosnetwork/fiber.git
cd fiber
cargo build --release

# Set up node directory
mkdir /path/to/my-fnn
cp target/release/fnn /path/to/my-fnn
cp config/testnet/config.yml /path/to/my-fnn
cd /path/to/my-fnn

# Create wallet key
mkdir ckb
ckb-cli account new
ckb-cli account export --lock-arg <lock_arg> --extended-privkey-path ./ckb/exported-key
head -n 1 ./ckb/exported-key > ./ckb/key
rm ./ckb/exported-key

# Start the node
FIBER_SECRET_KEY_PASSWORD='your_password' RUST_LOG=info ./fnn -c config.yml -d .
```

### Detailed Guide

- [Run a Fiber Node](https://docs.fiber.world/docs/quick-start/run-a-node) — Full setup walkthrough

## Basic Payment Flow

### 1. Connect to a Peer

```bash
curl -s -X POST http://localhost:8227 \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42", "jsonrpc": "2.0",
    "method": "connect_peer",
    "params": [{"address": "/ip4/127.0.0.1/tcp/8238/p2p/<PEER_ID>"}]
  }'
```

### 2. Open a Payment Channel

```bash
curl -s -X POST http://localhost:8227 \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42", "jsonrpc": "2.0",
    "method": "open_channel",
    "params": [{
      "peer_id": "<PEER_ID>",
      "funding_amount": "0xba43b7400",
      "public": true
    }]
  }'
# funding_amount 0xba43b7400 = 500 CKB (in shannons)
```

### 3. Generate an Invoice (Receiver Side)

```bash
curl -s -X POST http://localhost:8237 \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42", "jsonrpc": "2.0",
    "method": "new_invoice",
    "params": [{
      "amount": "0x2540be400",
      "currency": "Fibt",
      "description": "Payment for service",
      "expiry": "0xe10",
      "payment_preimage": "0x'$(openssl rand -hex 32)'",
      "hash_algorithm": "sha256"
    }]
  }'
# amount 0x2540be400 = 100 CKB
# currency: "Fibt" (testnet), "Fibb" (mainnet)
```

### 4. Send Payment (Sender Side)

```bash
curl -s -X POST http://localhost:8227 \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42", "jsonrpc": "2.0",
    "method": "send_payment",
    "params": [{"invoice": "fibt100000000001p..."}]
  }'
```

### 5. Check Channel Balance

```bash
curl -s -X POST http://localhost:8227 \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42", "jsonrpc": "2.0",
    "method": "list_channels",
    "params": [{"peer_id": "<PEER_ID>"}]
  }'
# state_name: "CHANNEL_READY" when channel is open
```

### 6. Close the Channel

```bash
curl -s -X POST http://localhost:8227 \
  -H "Content-Type: application/json" \
  -d '{
    "id": "42", "jsonrpc": "2.0",
    "method": "shutdown_channel",
    "params": [{
      "channel_id": "<CHANNEL_ID>",
      "close_script": {
        "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
        "hash_type": "type",
        "args": "<YOUR_LOCK_ARGS>"
      },
      "fee_rate": "0x3FC"
    }]
  }'
```

## Key RPC Methods

| Method             | Description                                     |
| ------------------ | ----------------------------------------------- |
| `connect_peer`     | Connect to another Fiber node                   |
| `disconnect_peer`  | Disconnect from a peer                          |
| `open_channel`     | Open a payment channel with funding             |
| `accept_channel`   | Accept a channel open request (auto by default) |
| `list_channels`    | List all channels and their states              |
| `shutdown_channel` | Cooperatively close a channel                   |
| `new_invoice`      | Create a payment invoice (receiver)             |
| `parse_invoice`    | Decode an invoice string                        |
| `send_payment`     | Send payment using an invoice                   |
| `get_payment`      | Check payment status                            |

Full RPC reference: https://github.com/nervosnetwork/fiber/blob/v0.7.1/crates/fiber-lib/src/rpc/README.md

## Stablecoin Support

Fiber supports UDT tokens (like RUSD stablecoin) through the `udt_whitelist` config:

```yaml
ckb:
  udt_whitelist:
    - name: RUSD
      script:
        code_hash: 0x1142755a...
        hash_type: type
        args: 0x878fcc6f...
      cell_deps:
        - type_id: ...
      auto_accept_amount: 1000000000
```

When opening a channel with UDT, specify `funding_udt_type_script` in the `open_channel` params.

Guide: [Transfer Stablecoins](https://docs.fiber.world/docs/quick-start/transfer-stablecoin)

## Cross-Network Interoperability

Fiber Network can interoperate with Bitcoin Lightning Network:

- **Edge nodes** bridge the two networks, enabling cross-chain atomic swaps
- Users can pay from Lightning to Fiber and vice versa
- RGB++ stablecoins can enter the "Hybrid Lightning Network"

## fiber-pay CLI Tool

[fiber-pay](https://github.com/RetricSu/fiber-pay) is an AI-friendly CLI layer over Fiber Network that simplifies node operations:

```bash
# Install
git clone https://github.com/RetricSu/fiber-pay.git
cd fiber-pay
pnpm install && pnpm build && pnpm link --global

# Usage (progressive discovery)
fiber-pay -h                    # Discover command groups
fiber-pay node -h               # Node lifecycle commands
fiber-pay channel -h            # Channel management
fiber-pay invoice -h            # Invoice operations
fiber-pay payment -h            # Payment operations
```

Features: node lifecycle management, channel management, invoice/payment flows, multi-node orchestration, job-based runtime for complex operations.

## Testnet Information

- **Testnet Public Nodes**: See [testnet nodes manual](https://github.com/nervosnetwork/fiber/blob/develop/docs/testnet-nodes.md)
- **Bootnode addresses** are pre-configured in `config/testnet/config.yml`
- **Faucet**: https://faucet.nervos.org/ (fund your node's CKB address)

## Version Upgrade Notes

FNN is under active development. Protocol and storage format may change between versions.

**Safe upgrade process:**

1. Close all channels via `shutdown_channel` RPC
2. Stop the node
3. Remove storage: `rm -rf /path/to/my-fnn/fiber/store`
4. Replace binary and restart

**With state migration** (optional):

```bash
# Backup first
cp -r /path/to/my-fnn/fiber/store /path/to/my-fnn/fiber/store.backup
# Run migration
fnn-migrate -p /path/to/my-fnn/fiber/store
# Replace binary and restart
```

## AI Dev Tips

- Fiber operates at the **application layer** above CKB L1. You don't write CKB on-chain scripts for Fiber — you interact with FNN via JSON-RPC.
- All amounts in Fiber RPC are in **shannons** (1 CKB = 10^8 shannons) encoded as hex strings.
- `funding_amount` determines the maximum one-directional transfer capacity of a channel.
- Invoice `payment_preimage` must be a unique 32-byte random hex for each invoice.
- Use `fiber-pay` CLI when orchestrating multi-node setups or automating payment flows.
- Channel state must be `CHANNEL_READY` before sending payments.
- Always close channels before upgrading FNN versions to avoid fund loss.
- For integration, use Fiber JSON-RPC directly. There is also an official `fiber-js/` package in the Fiber repo for JS/TS clients, but many flows still map 1:1 to RPC calls.

## References

- [Fiber Network Documentation](https://docs.fiber.world)
- [What is Payment Channel Network](https://docs.fiber.world/docs/tech-explanation/payment-channel)
- [Fiber Light Paper](https://docs.fiber.world/docs/tech-explanation/light-paper)
- [Fiber Architecture & Modules](https://docs.fiber.world/docs/tech-explanation/high-level)
- [Fiber Invoice Protocol](https://docs.fiber.world/docs/tech-explanation/invoice-protocol)
- [Fiber P2P Message Protocol](https://docs.fiber.world/docs/tech-explanation/p2p-message)
- [RPC Documentation](https://github.com/nervosnetwork/fiber/blob/v0.7.1/crates/fiber-lib/src/rpc/README.md)
- [Basic Transfer Tutorial](https://docs.fiber.world/docs/quick-start/basic-transfer)
- [Transfer Stablecoins Tutorial](https://docs.fiber.world/docs/quick-start/transfer-stablecoin)
- [Connect Public Nodes](https://docs.fiber.world/docs/quick-start/connect-nodes)
- [Build a Game with Fiber](https://docs.fiber.world/docs/tutorial/simple-game)
- [Fiber Node Backup Guide](https://docs.fiber.world/docs/guide/backup)
- [fiber-pay CLI](https://github.com/RetricSu/fiber-pay)
