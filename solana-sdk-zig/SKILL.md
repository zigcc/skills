---
name: solana-sdk-zig
description: This skill provides Solana SDK development guidance for Zig implementations. It ensures correct Rust source references, proper crate-to-module mapping, and test compatibility. Essential for writing Zig code that implements Solana SDK functionality, adding Rust source references, and creating integration tests.
license: MIT
compatibility:
  - opencode
  - claude-code
metadata:
  version: "1.0.0"
  language: "zig"
  category: "blockchain-sdk"
  rust_sdk_version: "3.0"
---

# Solana SDK Zig Development Guide

> **Project Scope**: This skill is for the Solana Program SDK Zig project, a Zig rewrite of the official Rust Solana SDK.
> All implementations must maintain 100% compatibility with the Rust SDK.

This skill ensures correct Solana SDK development in Zig, preventing common mistakes when porting Rust code.

**Official Rust SDK Repository**:
- Solana SDK (monorepo): https://github.com/anza-xyz/solana-sdk
- Agave Validator: https://github.com/anza-xyz/agave
- SPL Programs: https://github.com/solana-labs/solana-program-library

**Zig SDK Project Structure**:
- Program SDK: `src/` (on-chain program development)
- SDK Layer: `sdk/src/` (pure types, no syscall dependencies)
- Integration Tests: `program-test/integration/`
- Examples: `examples/`

**Related Zig Projects**:
| Project | URL | Description |
|---------|-----|-------------|
| **Sig** | https://github.com/Syndica/sig | Solana validator in Zig - most relevant! |
| Zeam | https://github.com/blockblaz/zeam | Ethereum client in Zig |
| ssz.zig | https://github.com/blockblaz/ssz.zig | SSZ serialization |

## Rust Source Reference Format (Required)

Every `.zig` file **MUST** include a Rust source reference at the top:

```zig
// ❌ WRONG - No source reference
const std = @import("std");
pub const Pubkey = struct { ... };

// ✅ CORRECT - With Rust source reference
//! Zig implementation of Solana SDK's pubkey module
//!
//! Rust source: https://github.com/anza-xyz/solana-sdk/blob/master/pubkey/src/lib.rs
//!
//! This module provides the Pubkey type representing a Solana public key (Ed25519).

const std = @import("std");

/// A Solana public key (32 bytes)
///
/// Rust equivalent: `solana_pubkey::Pubkey`
/// Source: https://github.com/anza-xyz/solana-sdk/blob/master/pubkey/src/lib.rs#L50
pub const Pubkey = struct {
    data: [32]u8,
    // ...
};
```

### Reference Format Rules

| Element | Format | Example |
|---------|--------|---------|
| Module-level | `//!` doc comment | File top |
| Type-level | `///` doc comment | Before struct/enum |
| Function-level | `///` doc comment (optional) | Complex function impl |
| Line reference | `#L{line}` or `#L{start}-L{end}` | `#L50` or `#L50-L100` |

## solana-sdk Repository Structure

The solana-sdk is a monorepo where each module is an independent crate.

> **See**: `references/crate-mapping.md` for the complete Rust crate to Zig module mapping (60+ modules).

### Common Mappings (Quick Reference)

| Zig Module | Rust Crate | GitHub Path |
|------------|------------|-------------|
| `public_key.zig` | `pubkey` | `pubkey/src/lib.rs` |
| `hash.zig` | `hash` | `hash/src/lib.rs` |
| `signature.zig` | `signature` | `signature/src/lib.rs` |
| `keypair.zig` | `keypair` | `keypair/src/lib.rs` |
| `account.zig` | `account-info` | `account-info/src/lib.rs` |
| `instruction.zig` | `instruction` | `instruction/src/lib.rs` |
| `clock.zig` | `clock` | `clock/src/lib.rs` |
| `rent.zig` | `rent` | `rent/src/lib.rs` |
| `bincode.zig` | `bincode` (external) | Uses Rust bincode format |
| `borsh.zig` | `borsh` (external) | Uses Rust borsh format |

### Common Link Errors

```bash
# ❌ WRONG - old path structure
sdk/src/pubkey.rs

# ❌ WRONG - extra sdk/ prefix
sdk/pubkey/src/lib.rs

# ✅ CORRECT - direct crate name
pubkey/src/lib.rs
```

### Link Verification Command

```bash
# Verify link is accessible (should return 200)
curl -s -o /dev/null -w "%{http_code}" \
  "https://github.com/anza-xyz/solana-sdk/blob/master/pubkey/src/lib.rs"
```

## Unit Test Completeness (Required)

Every Rust `#[test]` function **MUST** have a corresponding Zig `test` block.

```zig
// ❌ WRONG - Missing test or simplified
// Rust has: #[test] fn test_create_program_address()
// Zig has: (nothing)

// ✅ CORRECT - Full test with source reference
/// Rust test: test_create_program_address
/// Source: https://github.com/anza-xyz/solana-sdk/blob/master/pubkey/src/lib.rs#L500
test "pubkey: create program address" {
    // Test logic MUST match Rust version exactly
    const seeds = &[_][]const u8{ "hello"[0..] };
    const program_id = Pubkey.comptimeFromBase58("BPFLoader1111111111111111111111111111111111");

    const result = try Pubkey.createProgramAddress(seeds, program_id);
    try std.testing.expectEqual(expected_pubkey, result);
}
```

### Test Verification Commands

```bash
# 1. Count Rust tests in a module
curl -s "https://raw.githubusercontent.com/anza-xyz/solana-sdk/master/pubkey/src/lib.rs" \
  | grep -c "#\[test\]"

# 2. Count Zig tests in corresponding module
grep -c "^test " src/public_key.zig

# 3. Zig test count MUST be >= Rust test count
```

### Prohibited Test Behaviors

| Behavior | Status |
|----------|--------|
| Skip Rust test | ❌ PROHIBITED |
| Simplify complex test | ❌ PROHIBITED |
| Modify expected values | ❌ PROHIBITED |
| Use `// TODO: add test` | ❌ PROHIBITED |
| Add Zig-specific tests | ✅ ALLOWED (in addition to Rust tests) |

## Integration Test Pattern (Serialization Compatibility)

Integration tests verify **binary-level** compatibility with Rust SDK:

```
Rust SDK                          Zig SDK
   │                                 │
   ▼                                 ▼
bincode::serialize(&struct)    sdk.bincode.serialize(struct)
   │                                 │
   ▼                                 ▼
  bytes ═══════════════════════════ bytes
              MUST be identical
```

### Correct Integration Test Pattern

```zig
// ✅ CORRECT - Verifies serialization compatibility
test "instruction_error_serialization: Zig SDK matches Rust SDK" {
    // 1. Load test vector from JSON (generated by Rust)
    const vector = try loadTestVector("instruction_error_vectors.json");

    // 2. Construct Zig struct with input data
    const zig_error = InstructionError{ .Custom = vector.custom_code };

    // 3. Serialize using Zig SDK
    var zig_buffer: [256]u8 = undefined;
    const bytes_written = try bincode.serialize(InstructionError, zig_error, &zig_buffer);

    // 4. Compare byte-for-byte with Rust serialization
    try std.testing.expectEqualSlices(u8, vector.rust_encoded, zig_buffer[0..bytes_written]);
}
```

### Wrong Integration Test Pattern

```zig
// ❌ WRONG - Only verifies constants, not serialization
test "instruction_error_constants: check values" {
    try std.testing.expectEqual(@as(usize, 32), PUBKEY_SIZE);
    // This does NOT verify serialization compatibility!
}
```

### Test Vector JSON Format

```json
{
    "name": "custom_error_42",
    "custom_code": 42,
    "encoded": [8, 0, 0, 0, 42, 0, 0, 0]
}
```

## Toolchain Requirements

**MUST use solana-zig-bootstrap**, not system zig:

```bash
# ✅ CORRECT - Use project's solana-zig
./solana-zig/zig build
./solana-zig/zig build test
./solana-zig/zig version  # Should show 0.15.2

# ❌ WRONG - System zig lacks SBF target
zig build       # ERROR: no member 'sbf' in Target.Cpu.Arch
zig build test  # ERROR: no member 'solana' in Target.Os.Tag
```

### Why solana-zig?

Standard Zig lacks Solana's SBF (Solana BPF) target:
- No `sbf` CPU architecture
- No `solana` OS target
- No native SBF linker

solana-zig-bootstrap adds:
- `sbf` CPU architecture
- `solana` OS target
- Native SBF linker (no sbpf-linker needed)

## Extended References

> Detailed API references and mapping guides:

| Document | Path | Content |
|----------|------|---------|
| **Crate Mapping** | `references/crate-mapping.md` | Complete Rust crate → Zig module mapping (60+ modules) |

### Quick Lookup Guide

- **Adding new module?** → Check `references/crate-mapping.md` for Rust source path
- **Finding Rust test?** → Use GitHub search in `anza-xyz/solana-sdk` repo
- **Serialization issues?** → Check `program-test/integration/` for test vectors

## Common Error Messages and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `no member 'sbf'` | Using system zig | Use `./solana-zig/zig` |
| Serialization mismatch | Endianness or padding | Check bincode/borsh impl |
| `expected [N]u8, found [M]u8` | Struct size mismatch | Verify `extern struct` layout |
| Link 404 | Wrong crate path | Check `references/crate-mapping.md` |

## Verification Checklist

Before submitting code:

- [ ] Every `.zig` file has `//!` Rust source reference
- [ ] GitHub links are verified accessible
- [ ] All Rust `#[test]` have corresponding Zig tests
- [ ] Integration tests verify serialization (not just constants)
- [ ] Using `./solana-zig/zig` (not system zig)
- [ ] `zig build test` passes 100%

## Prohibited Actions

- ❌ Creating modules without Rust source references
- ❌ Using invalid or unverified GitHub links
- ❌ Omitting module-level `//!` documentation
- ❌ Missing any Rust `#[test]` in Zig implementation
- ❌ Simplifying or skipping complex test cases
- ❌ Modifying test expected values to make tests pass
- ❌ Using system zig instead of solana-zig
