# Learning from Production Zig Codebases

> **Last Updated**: January 2026
> **Zig Version**: 0.15.x (specifically 0.15.2)
>
> All libraries listed here are actively maintained and compatible with Zig 0.15.x.
> Check each project's `build.zig.zon` for exact version requirements.

## How to Check Library Compatibility

Before using any Zig library, verify it works with your Zig version:

```bash
# 1. Check build.zig.zon for minimum version
cat build.zig.zon | grep -i "minimum_zig_version"

# 2. Check CI workflow for Zig version
cat .github/workflows/*.yml | grep -i "zig"

# 3. Check recent commits (active maintenance?)
git log --oneline -10

# 4. Try to build
zig build
```

**Version Compatibility Legend**:
- ✅ = Verified compatible with Zig 0.15.x
- ⚠️ Check = May need verification, check project's build.zig.zon
- ❌ = Known incompatible or abandoned

---

Real-world Zig projects to study for best practices and patterns.

## Sig - Solana Validator in Zig (HIGHLY RELEVANT)

**Repository**: https://github.com/Syndica/sig
**Documentation**: https://sig.fun/
**Stars**: 350+ | **License**: Apache 2.0

**Why this is the most important reference for solana-program-sdk-zig**:
- Solana validator completely rewritten in Zig
- Same domain as our SDK (Solana blockchain)
- Shows how to implement Solana protocols in Zig
- Reference for Solana data structures, serialization, networking
- Actively developed by Syndica team

**What to learn**:
- Solana protocol implementation in Zig
- Gossip protocol, turbine, consensus
- Transaction processing patterns
- RPC server implementation
- Solana-specific data structures (Pubkey, Signature, etc.)
- High-performance networking in Zig

**Key directories**:
```
sig/
├── src/
│   ├── core/            # Core Solana types
│   ├── gossip/          # Gossip protocol
│   ├── ledger/          # Ledger/blockstore
│   ├── rpc/             # RPC server
│   └── consensus/       # Consensus mechanisms
```

**Useful patterns to study**:
- Compare their Pubkey/Signature implementations with ours
- Serialization patterns (bincode compatibility)
- How they handle Solana's account model
- Networking and async I/O for blockchain

---

## ZML - High-Performance AI Inference (MACHINE LEARNING)

**Repository**: https://github.com/zml/zml
**Website**: https://zml.ai/
**Documentation**: https://docs.zml.ai/
**Stars**: 3k+ | **License**: Apache 2.0

**Why this is valuable**:
- Production-grade ML inference framework written in Zig
- Runs on NVIDIA, AMD, Google TPU, AWS Trainium
- Built on OpenXLA/MLIR/Bazel
- Python-free stack for maximum performance
- Featured at FOSDEM 2025 and dotAI 2024

**What to learn**:
- High-performance Zig code for compute-intensive workloads
- Hardware abstraction across different accelerators
- Production deployment patterns
- Zig + C FFI integration (MLIR, XLA)
- Build system integration (Bazel + Zig)

**Key features**:
- Zero-compromise hardware portability
- Very high performance (no Python overhead)
- Highly expressive API
- Self-contained Docker deployments

---

## Zeam - Ethereum Client in Zig (BLOCKCHAIN REFERENCE)

**Repository**: https://github.com/blockblaz/zeam

**Why this is valuable**:
- Ethereum execution client written in Zig
- Another blockchain implementation in Zig
- Can compare patterns between Solana (Sig) and Ethereum (Zeam)

**What to learn**:
- Blockchain client architecture in Zig
- EVM implementation patterns
- P2P networking for blockchain
- State management and storage
- RLP encoding (compare with bincode/borsh)

---

## Bun - JavaScript Runtime

**Repository**: https://github.com/oven-sh/bun

**What to learn**:
- Large-scale Zig project structure (~200k+ lines)
- Async I/O patterns
- C/C++ FFI integration (JavaScriptCore, BoringSSL)
- Build system for complex projects
- Memory management at scale
- Cross-platform development

**Key directories**:
```
bun/
├── src/
│   ├── bun.js/          # JS bindings
│   ├── http/            # HTTP client/server
│   ├── io/              # I/O abstractions
│   └── deps/            # Dependency management
├── build.zig            # Complex build configuration
```

**Useful patterns to study**:
- `src/allocators.zig` - Custom allocator implementations
- `src/http/` - HTTP client/server patterns
- `src/io/` - I/O abstractions and buffering

---

## Tigerbeetle - Financial Database

**Repository**: https://github.com/tigerbeetle/tigerbeetle

**What to learn**:
- Deterministic execution
- High-reliability code patterns
- Extensive testing strategies
- Storage engine design
- Consensus protocols in Zig

**Key directories**:
```
tigerbeetle/
├── src/
│   ├── tigerbeetle/     # Core database
│   ├── vsr/             # Viewstamped replication
│   └── testing/         # Test infrastructure
```

**Useful patterns to study**:
- Deterministic simulation testing
- Arena allocator usage
- Error handling in critical systems
- Comptime configuration

---

## Mach Engine - Game Engine

**Repository**: https://github.com/hexops/mach

**What to learn**:
- Graphics programming in Zig
- Cross-platform abstraction layers
- ECS (Entity Component System) patterns
- GPU resource management
- Build system for game development

**Key directories**:
```
mach/
├── src/
│   ├── core/            # Core engine
│   ├── gfx/             # Graphics abstractions
│   └── sysgpu/          # GPU backend
```

---

## Ghostty - Terminal Emulator

**Repository**: https://github.com/ghostty-org/ghostty

**What to learn**:
- Terminal emulation
- Cross-platform GUI (GTK, macOS AppKit)
- GPU-accelerated rendering
- Configuration parsing
- Font rendering

---

## How to Study These Codebases

### 1. Start with build.zig
```bash
# Clone and examine build configuration
git clone https://github.com/oven-sh/bun
cd bun
cat build.zig | head -100
```

### 2. Find Zig-specific patterns
```bash
# Search for allocator patterns
rg "Allocator" --type zig -l

# Search for error handling
rg "catch |err|" --type zig

# Search for comptime usage
rg "comptime" --type zig -l
```

### 3. Focus Areas by Project

| If you need to learn... | Study this project |
|------------------------|-------------------|
| Async I/O | Bun |
| Reliability/Testing | Tigerbeetle |
| Graphics/GPU | Mach, Ghostty |
| FFI with C/C++ | Bun |
| Custom allocators | Tigerbeetle, Bun |
| Build system complexity | Bun |
| Cross-platform | Ghostty |

### 4. Use GitHub Code Search
```
# Search across all Zig repos for patterns
repo:oven-sh/bun language:zig "ArrayList"
repo:tigerbeetle/tigerbeetle language:zig "arena"
```

## Version Considerations

These projects may use different Zig versions:
- Check their `build.zig.zon` or CI configuration
- Some track Zig master, others use stable releases
- API patterns may differ from 0.15.x

To check a project's Zig version:
```bash
# Look for version in build config
grep -r "zig" build.zig.zon 2>/dev/null || cat .zigversion 2>/dev/null
```

## Smaller Learning Projects (All 0.15.x Compatible)

If production codebases are overwhelming, start with these actively maintained libraries:

### CLI & TUI

| Project | Stars | URL | Focus | 0.15.x |
|---------|-------|-----|-------|--------|
| zig-clap | 1.4k | https://github.com/Hejsil/zig-clap | CLI argument parsing | ✅ |
| libvaxis | 1.5k | https://github.com/rockorager/libvaxis | Modern TUI framework | ✅ v0.15.2 |

### Networking & HTTP

| Project | Stars | URL | Focus | 0.15.x |
|---------|-------|-----|-------|--------|
| http.zig | 1.3k | https://github.com/karlseguin/http.zig | HTTP/1.1 server | ✅ |
| zig-network | 600+ | https://github.com/ikskuh/zig-network | TCP/UDP networking | ✅ |
| tls.zig | 116 | https://github.com/ianic/tls.zig | TLS 1.2/1.3 client & server | ✅ |

### Async & Event Loops

| Project | Stars | URL | Focus | 0.15.x |
|---------|-------|-----|-------|--------|
| libxev | 2k+ | https://github.com/mitchellh/libxev | Cross-platform event loop (io_uring, epoll, kqueue) | ✅ |
| zig-aio | 200+ | https://github.com/Cloudef/zig-aio | Async I/O library | ✅ |

### Serialization & Parsing

| Project | Stars | URL | Focus | 0.15.x |
|---------|-------|-----|-------|--------|
| zig-protobuf | 365 | https://github.com/Arwalk/zig-protobuf | Protocol Buffers 3 | ✅ |
| zig-toml | 100+ | https://github.com/sam701/zig-toml | TOML parser | ✅ |
| zig-xml | 80+ | https://github.com/nektro/zig-xml | XML parser | ✅ |
| zig-libxml2 | 76 | https://github.com/mitchellh/zig-libxml2 | libxml2 bindings (C FFI) | ✅ |

### Logging & Metrics

| Project | Stars | URL | Focus | 0.15.x |
|---------|-------|-----|-------|--------|
| log.zig | 157 | https://github.com/karlseguin/log.zig | Structured logging (logfmt/JSON) | ✅ |
| logly.zig | New | https://github.com/muhammad-fiaz/logly.zig | Full-featured logging (async, rotation) | ✅ 0.15.0+ |

### Date/Time

| Project | Stars | URL | Focus | 0.15.x |
|---------|-------|-----|-------|--------|
| zig-datetime | 50+ | https://github.com/frmdstryr/zig-datetime | Timezone/DST handling | ⚠️ Check |
| zig-time | 30+ | https://github.com/nektro/zig-time | Parsing/formatting | ⚠️ Check |

### Data Structures

| Project | Stars | URL | Focus | 0.15.x |
|---------|-------|-----|-------|--------|
| zig-graph | 101 | https://github.com/mitchellh/zig-graph | Directed graph data structure | ✅ |

### Math & SIMD

| Project | Stars | URL | Focus | 0.15.x |
|---------|-------|-----|-------|--------|
| zmath | 78 | https://github.com/zig-gamedev/zmath | SIMD math (game dev) | ✅ |
| zm | 40+ | https://github.com/griush/zm | Vectors, matrices | ⚠️ Check |

### Tools & Development

| Project | Stars | URL | Focus | 0.15.x |
|---------|-------|-----|-------|--------|
| ZLS | 4.5k | https://github.com/zigtools/zls | Language Server Protocol | ✅ v0.15.0 |
| zig-tree-sitter | 50+ | https://github.com/tree-sitter/zig-tree-sitter | Syntax parsing | ✅ |
| anyzig | 142 | https://github.com/marler8997/anyzig | Zig version manager | ✅ |

### System & Low-Level

| Project | Stars | URL | Focus | 0.15.x |
|---------|-------|-----|-------|--------|
| zbpf | 100+ | https://github.com/tw4452852/zbpf | eBPF library | ⚠️ Check |

### Learning Resources

| Project | Stars | URL | Focus | 0.15.x |
|---------|-------|-----|-------|--------|
| Zig Cookbook | 500+ | https://github.com/zigcc/zig-cookbook | Practical recipes | ✅ |
| Zig Algorithms | 200+ | https://github.com/TheAlgorithms/Zig | Data structures | ✅ |

### Ecosystem Index

| Project | Stars | URL | Focus | Notes |
|---------|-------|-----|-------|-------|
| awesome-zig | 2k | https://github.com/zigcc/awesome-zig | Curated list of Zig projects | ⚠️ See below |

> **⚠️ awesome-zig 版本兼容性警告**:
> 
> `awesome-zig` 是发现 Zig 库的绝佳资源，但**很多库可能尚未更新到 Zig 0.15.x**。
> 
> **使用前必须检查**:
> 1. 查看项目的 `build.zig.zon` 中的 `minimum_zig_version`
> 2. 检查最近的 commit 日期和 CI 状态
> 3. 查看 Issues/PRs 中是否有 0.15 兼容性讨论
> 
> **常见问题**:
> - 旧的 ArrayList API (不带 allocator 参数)
> - 旧的 build.zig API (`.path` vs `b.path()`)
> - 旧的 std.io.Writer 接口 (Writergate 之前)
> 
> **推荐做法**: 优先使用本文档中标注 ✅ 的库，它们已验证兼容 Zig 0.15.x。

---

## TheAlgorithms/Zig - Data Structures & Algorithms

**Repository**: https://github.com/TheAlgorithms/Zig

**What to learn**:
- Idiomatic Zig implementations of classic algorithms
- Clean, readable code patterns
- Testing patterns for algorithms
- Generic programming in Zig

**Algorithm categories**:
- Sorting (quicksort, mergesort, heapsort, etc.)
- Searching (binary search, linear search)
- Data structures (linked lists, trees, graphs, heaps)
- String algorithms
- Math algorithms

**Why study this**:
- Smaller, focused code (easier to understand than large projects)
- Well-documented implementations
- Good for learning Zig idioms
- Test-driven development examples
