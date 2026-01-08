# Solana SDK Crate to Zig Module Mapping

Complete mapping of Rust crates to Zig modules.

## Core Types

| Zig Module | Rust Crate | Description |
|------------|------------|-------------|
| `public_key.zig` | `pubkey` | Ed25519 public key (32 bytes) |
| `hash.zig` | `hash` | SHA-256 hash (32 bytes) |
| `signature.zig` | `signature` | Ed25519 signature (64 bytes) |
| `keypair.zig` | `keypair` | Ed25519 key pair |
| `account.zig` | `account-info` | Account metadata and data |
| `instruction.zig` | `instruction` | Instruction and AccountMeta |
| `message.zig` | `message` | Transaction message |
| `transaction.zig` | `transaction` | Signed transaction |

## Serialization

| Zig Module | Rust Crate | Description |
|------------|------------|-------------|
| `bincode.zig` | `bincode` | Bincode serialization |
| `borsh.zig` | `borsh` | Borsh serialization |
| `short_vec.zig` | `short-vec` | Compact u16 encoding |

## Program Foundation

| Zig Module | Rust Crate | Description |
|------------|------------|-------------|
| `entrypoint.zig` | `program-entrypoint` | BPF entrypoint |
| `error.zig` | `program-error` | Program error types |
| `log.zig` | `program-log` | Logging via syscall |
| `syscalls.zig` | `define-syscall` | Syscall definitions |
| `allocator.zig` | - | BPF heap allocator |
| `bpf.zig` | - | BPF utilities |
| `context.zig` | - | Entrypoint parsing |
| `program_memory.zig` | `program-memory` | Memory operations |
| `program_option.zig` | `program-option` | Option types |
| `program_pack.zig` | `program-pack` | Pack/Unpack traits |
| `msg.zig` | `msg` | Message utilities |
| `stable_layout.zig` | `stable-layout` | Stable layout traits |

## Sysvars

| Zig Module | Rust Crate | Description |
|------------|------------|-------------|
| `clock.zig` | `clock` | Cluster time |
| `rent.zig` | `rent` | Rent parameters |
| `slot_hashes.zig` | `slot-hashes` | Recent slot hashes |
| `slot_history.zig` | `slot-history` | Slot history bitvector |
| `epoch_schedule.zig` | `epoch-schedule` | Epoch timing |
| `instructions_sysvar.zig` | `instructions-sysvar` | Instruction introspection |
| `last_restart_slot.zig` | `last-restart-slot` | Last restart slot |
| `sysvar.zig` | `sysvar` | Sysvar utilities |
| `sysvar_id.zig` | `sysvar-id` | Sysvar IDs |
| `epoch_rewards.zig` | `epoch-rewards` | Epoch rewards |

## Hash Functions

| Zig Module | Rust Crate | Description |
|------------|------------|-------------|
| `blake3.zig` | `blake3-hasher` | Blake3 syscall |
| `sha256_hasher.zig` | `sha256-hasher` | SHA-256 syscall |
| `keccak_hasher.zig` | `keccak-hasher` | Keccak-256 syscall |
| `epoch_rewards_hasher.zig` | `epoch-rewards-hasher` | SipHash-1-3 |

## Native Programs

| Zig Module | Rust Crate | Description |
|------------|------------|-------------|
| `system_program.zig` | `system-interface` | System program |
| `bpf_loader.zig` | `loader-v2-interface`, `loader-v3-interface` | BPF loaders |
| `loader_v4.zig` | `loader-v4-interface` | Loader v4 |
| `compute_budget.zig` | `compute-budget-interface` | Compute budget |
| `address_lookup_table.zig` | `address-lookup-table-interface` | ALT program |
| `ed25519_program.zig` | `ed25519-program` | Ed25519 verification |
| `secp256k1_program.zig` | `secp256k1-program` | Secp256k1 verification |
| `secp256r1_program.zig` | `secp256r1-program` | P-256 verification |
| `feature_gate.zig` | `feature-gate-interface` | Feature activation |
| `vote_interface.zig` | `vote-interface` | Vote program |
| `nonce.zig` | `nonce` | Durable nonce |

## Advanced Crypto

| Zig Module | Rust Crate | Description |
|------------|------------|-------------|
| `bn254.zig` | `bn254` | BN254 curve for ZK |
| `big_mod_exp.zig` | `big-mod-exp` | Modular exponentiation |
| `bls_signatures.zig` | `bls-signatures` | BLS12-381 signatures |

## Error Types

| Zig Module | Rust Crate | Description |
|------------|------------|-------------|
| `error.zig` | `program-error` | Program errors |
| `instruction_error.zig` | `instruction-error` | Instruction errors |
| `transaction_error.zig` | `transaction-error` | Transaction errors |

## SDK Layer (No Syscall Dependencies)

| Zig Module | Description |
|------------|-------------|
| `sdk/src/public_key.zig` | Pure PublicKey type |
| `sdk/src/hash.zig` | Pure Hash type |
| `sdk/src/signature.zig` | Pure Signature type |
| `sdk/src/keypair.zig` | Pure Keypair type |
| `sdk/src/instruction.zig` | Pure Instruction types |
| `sdk/src/bincode.zig` | Pure bincode serialization |
| `sdk/src/borsh.zig` | Pure borsh serialization |
| `sdk/src/native_token.zig` | SOL/Lamports utilities |
| `sdk/src/nonce.zig` | Durable nonce types |
| `sdk/src/epoch_info.zig` | EpochInfo (RPC response) |
| `sdk/src/c_option.zig` | COption<T> for SPL compatibility |

## SPL Programs

| Zig Module | Rust Source | Description |
|------------|-------------|-------------|
| `sdk/src/spl/token/` | `solana-program-library/token` | SPL Token |
| `sdk/src/spl/stake/` | `solana-program/stake` | Stake program |
| `sdk/src/spl/memo.zig` | `solana-program/memo` | Memo program |
