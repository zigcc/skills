---
name: zig-0.16
description: Zig 0.16.0 API guidance and porting notes. Use this when writing or upgrading Zig code to the 0.16.0 stable release (std.Io era, @Type removal, @cImport deprecation).
license: MIT
compatibility:
  - opencode
  - claude-code
metadata:
  version: "0.16.0"
  language: "zig"
  category: "programming-language"
---

# Zig 0.16.0 Programming Guide

> **Version Scope**: This skill is pinned to **Zig 0.16.0** (stable).
> **Local Installation**: `~/.local/zig-0.16.0/`
> **Local Language Reference**: `~/.local/zig-0.16.0/doc/langref.html`
> **Local Standard Library Docs**: Run `zig std` to start an offline server
> **Release Notes (online)**: https://ziglang.org/download/0.16.0/release-notes.html

Zig 0.16.0 is a major release introducing `std.Io` as the unified I/O interface, removing `@Type`, deprecating `@cImport`, and significantly reworking the build system package management.

---

## Local Documentation First

Since Zig 0.16.0 is installed locally at `~/.local/zig-0.16.0/`, always prefer local docs over web search:

1. **Language Reference** (offline): open `~/.local/zig-0.16.0/doc/langref.html` in a browser, or read it directly.
2. **Standard Library Docs** (offline): run `zig std` to start a local HTTP server. It prints the URL (e.g. `http://127.0.0.1:12345/`). Use `-p 8080` to fix a port.
3. **Release Notes** (online only): https://ziglang.org/download/0.16.0/release-notes.html

When verifying an API mentioned in this skill, check the local std docs first. Do not assume older online docs match the exact local build.

---

## Quick Reference: Top Breaking Changes

| Old (0.15.x) | New (0.16.0) |
|--------------|--------------|
| `@Type(.Int(...))` | `@Int(.signed, bits)` |
| `@Type(.Struct(...))` | `@Struct(layout, BackingInt, field_names, field_types, field_defaults, field_is_comptime, field_alignments)` |
| `@Type(.Pointer(...))` | `@Pointer(size, attrs, Element, sentinel)` |
| `@Type(.Fn(...))` | `@Fn(param_types, param_attrs, ReturnType, attrs)` |
| `@Type(.Tuple(...))` | `@Tuple(field_types)` |
| `@cImport({...})` | `b.addTranslateC(...)` + `@import("c")` (deprecated) |
| `std.net` | `std.Io.net` |
| `std.ArrayList.init(allocator)` | `std.ArrayList.initCapacity(allocator, n)` |
| `std.crypto.random` | `std.Io.randomSecure(io, buf)` |
| `std.meta.intToEnum` | `std.enums.fromInt` |
| `std.fmt.FormatOptions` | `std.fmt.Options` |
| `std.fmt.bufPrintZ` | `std.fmt.bufPrintSentinel` |
| `std.io.fixedBufferStream` | `std.Io.Writer.fixed(buf)` |
| `error.RenameAcrossMountPoints` | `error.CrossDevice` |
| `error.NotSameFileSystem` | `error.CrossDevice` |
| `error.SharingViolation` | `error.FileBusy` |
| `error.EnvironmentVariableNotFound` | `error.EnvironmentVariableMissing` |
| `std.Build.Step.ConfigHeader` cmake handling | fixed leading whitespace |

---

## Language Changes

### @Type Removed — Use Individual Builtins

`@Type` is gone. Replace with these builtins:

```zig
// Integer type
const MyInt = @Int(.signed, 32);

// Struct type
const MyStruct = @Struct(
    .auto,           // layout
    null,            // BackingInt (for packed)
    &.{"x", "y"},    // field_names
    &.{ i32, i32 },  // field_types
    &.{ null, null },// field_defaults
    &.{ false, false }, // field_is_comptime
    &.{ null, null },// field_alignments
);

// Pointer type
const MyPtr = @Pointer(.one, .{
    .alignment = 8,
    .address_space = .generic,
    .is_const = false,
    .is_volatile = false,
}, u8, null);

// Function type
const MyFn = @Fn(&.{i32, i32}, &.{.{}, .{}}, i32, .{});

// Tuple type
const MyTuple = @Tuple(&.{ i32, bool });

// Enum literal type
const EnumLitType = @EnumLiteral();
```

### @cImport Deprecated — Use Build System Translation

`@cImport` is deprecated. Use `addTranslateC` in `build.zig`:

```zig
// build.zig
const translate_c = b.addTranslateC(.{
    .root_source_file = b.path("src/c.h"),
    .target = target,
    .optimize = optimize,
});
translate_c.linkSystemLibrary("glfw", .{});

const exe = b.addExecutable(.{
    .name = "myapp",
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
        .target = target,
        .imports = &.{
            .{ .name = "c", .module = translate_c.createModule() },
        },
    }),
});
```

Then in Zig: `const c = @import("c");`

**Note**: The C translator is now backed by arocc instead of libclang.

### Switch Improvements

- `packed struct` and `packed union` may now be used as switch prong items (compared by backing integer).
- `decl literals` and result-type-dependent expressions (e.g. `@enumFromInt`) may now be used as switch prong items.
- Union tag captures are now allowed for all prongs, not just inline ones.
- Switch prong captures may no longer all be discarded.
- `.awake` atomic order removed; use `.monotonic` / `.seq_cst`.

### Other Language-Level Gotchas

- **Small integer types coerce to floats** — e.g. `u8` → `f32` is now allowed.
- **Runtime vector indexes forbidden** — vector indexing must be comptime-known.
- **Vectors and arrays no longer support in-memory coercion** — must explicitly cast element-wise.
- **Trivial local addresses cannot be returned from functions** — e.g. `return &local;` is rejected more consistently.
- **Packed unions must not have unused bits** — all bit patterns must be valid.
- **Pointers forbidden in packed structs/unions**.
- **Explicitly-aligned pointer types are now distinct** from naturally-aligned ones in type system.
- **Simplified dependency loop rules** — most code still works, but self-referential alignment queries now error.

---

## Standard Library: std.Io

### Networking

- `std.net` is gone. Use `std.Io.net` (types: `IpAddress`, `Stream`, `Server`, `UnixAddress`).
- High-level helpers like `tcpConnectToHost`, `Address.parseIp`, `Stream.connect` removed. Use `Io` vtables: `io.vtable.netConnectIp`, `netRead`, `netWrite`, `netListenIp`, `netAccept`.
- Raw fd operations: use `std.os.linux.socket`, `accept4`, `connect`, `bind`, `listen`, `write`, `read`, `close`.
- `posix.socket`, `posix.bind`, `posix.accept`, `posix.shutdown`, `posix.writev`, `posix.listen`, `posix.pipe2`, `posix.getrandom`, `std.net.has_unix_sockets` removed.
- Epoll: `std.os.linux.epoll_create1/epoll_ctl/epoll_wait` directly.
- New: `std.Io.net.Socket.createPair` for socketpair usage in tests.

### I/O Readers/Writers

- Writer/reader interfaces live under `std.Io`. TLS expects `*std.Io.Reader` / `*std.Io.Writer` (struct fields `.interface`). Pass pointers to interfaces, not call `interface()` as a function.
- `std.time.sleep` removed; use `std.Io.sleep(io, Duration, Clock)`.
- `std.Io.GenericWriter`, `std.Io.AnyWriter`, `std.Io.null_writer`, `std.Io.CountingReader` removed.

### Time / Random / Env / Exit

- `std.time.milliTimestamp` removed. Use `std.time.Timer` or `std.Io.Clock.now(clock, io)` and compare `Timestamp.nanoseconds`.
- Random secure bytes: `std.Io.randomSecure(io, buf)`; no `std.crypto.random` or `std.posix.getrandom` convenience.
- `std.process.getEnvVarOwned` removed; use `std.c.getenv` and copy.
- `std.posix.exit` removed; use `std.process.exit`.

### TLS Client Options

- `std.crypto.tls.Client.Options` requires `entropy: *const [entropy_len]u8` and `realtime_now_seconds: i64`. Fill entropy with `std.Io.randomSecure`; compute seconds with `Io.Clock.now(.real, io)` / `ns_per_s`.

### MemoryPool API Changes

- `std.heap.MemoryPool(T).initCapacity(allocator, n)` returns the pool.
- `create`/`destroy` now require allocator. No bare `init()` or zero-arg `deinit()`.

### Format Options

- `std.fmt.Options` replaces `FormatOptions`.
- `std.fmt.format` helper removed; call `writer.print` directly (writers live in `std.Io.Writer`).
- `std.fmt.Formatter` renamed to `Alt`.
- `std.fmt.bufPrintZ` renamed to `std.fmt.bufPrintSentinel`.

### Randomness / Crypto

- `std.crypto.random` removed. Use an `std.Io` instance: `const io = std.Io.Threaded.global_single_threaded.ioBasic(); io.random(&buf);`.
- `Ed25519.KeyPair.generate` now requires an `io: std.Io` argument.

### Enum Conversion

- `std.meta.intToEnum` removed. Use `std.enums.fromInt(EnumType, value)` (returns `?EnumType`).
- `meta.declList` removed.

### Fixed-Buffer Writers in Tests

- `std.io.fixedBufferStream` removed. For in-memory writes use `var w = std.Io.Writer.fixed(buf);` and read bytes with `std.Io.Writer.buffered(&w)`.
- `std.ArrayList` no longer has `.init(allocator)` shorthand; use `.initCapacity(allocator, n)`.

### Collections

- `SegmentedList` removed.
- `BitSet`, `EnumSet`: replace `initEmpty`, `initFull` with decl literals (e.g. `.{}`, `.{ .a = true }`).
- New: `Io.Dir.renamePreserve` — rename without replacing destination.
- `std.Io.Dir.rename` returns `error.DirNotEmpty` rather than `error.PathAlreadyExists`.

### Error Set Renames

```zig
// Old -> New
error.RenameAcrossMountPoints -> error.CrossDevice
error.NotSameFileSystem       -> error.CrossDevice
error.SharingViolation        -> error.FileBusy
error.EnvironmentVariableNotFound -> error.EnvironmentVariableMissing
```

### Math

- `math.sign` now returns the smallest integer type that fits possible values.

### Threading

- `Thread.Mutex.Recursive` removed.

### Compression

- `lzma`, `lzma2`, `xz` updated to `Io.Reader` / `Io.Writer` interfaces.

### Dynamic Libraries

- `DynLib` removed Windows support. Use `LoadLibraryExW` and `GetProcAddress` directly.

---

## Build System Changes

### Fingerprint Required in build.zig.zon

`build.zig.zon` now requires a `fingerprint` field, and `name` must be an enum literal, not a string:

```zig
.{
    .name = .myproject,  // enum literal, not "myproject"
    .fingerprint = 0x123456789abcdef0,
    .version = "0.1.0",
    .dependencies = .{},
}
```

`zig build` will fail if these are missing.

### Local Package Overrides: --fork

New CLI flag for temporary local overrides:

```bash
zig build --fork=/path/to/local/fork
```

Any dependency with matching `name` + `fingerprint` will resolve to the local path instead of being fetched. This is ephemeral — remove the flag to revert.

### Packages Fetched to zig-pkg Directory

Dependencies are now fetched into a local `zig-pkg/` directory (next to `build.zig`) instead of the global cache. After filtering, they are recompressed into the global cache for future reuse.

### Unit Test Timeouts

Specify per-test timeouts:

```bash
zig build test --test-timeout 500ms
```

After the timeout, the test process is killed and restarted for the next test.

### ConfigHeader

- `std.Build.Step.ConfigHeader` now handles leading whitespace for cmake-style config headers correctly.

---

## Compiler / Toolchain

### C Translation

- `@cImport` still exists but is deprecated and now backed by arocc instead of libclang.
- For new code, always use `addTranslateC` in `build.zig`.

### Type Resolution

- Reworked internal type resolution. Most previously-working code still works, and some "dependency loop" errors are now resolved.
- Self-referential alignment queries (e.g. `align(@alignOf(@This()))`) now correctly error.

### LLVM Backend

- Experimental incremental compilation support.
- Error set types now lowered as enums in debug info, so error names are visible at runtime.

---

## Target Support

Notable additions:
- `aarch64-freebsd`, `aarch64-netbsd`, `loongarch64-linux`, `powerpc64le-linux`, `s390x-linux`, `x86_64-freebsd`, `x86_64-netbsd`, `x86_64-openbsd` now tested in CI.
- `aarch64-maccatalyst`, `x86_64-maccatalyst` cross-compilation added.
- Initial `loongarch32-linux` support (no libc yet).
- Basic support added for Alpha, KVX, MicroBlaze, OpenRISC, PA-RISC, SuperH.
- Solaris, AIX, z/OS support removed.
- Stack tracing improved across almost all major targets.

---

## Testing Adjustments

- For in-process client/server tests, use `std.Io.net.Socket.createPair` or raw `socketpair(AF.UNIX, SOCK.STREAM|CLOEXEC, 0, &fds)` to avoid relying on Io vtable network (Threaded nets return `NetworkDown` if not wired).
- Error sets tightened in many std.Io functions — remove unreachable branches accordingly.

---

## Porting Strategy (0.15 → 0.16)

1. **Replace `@Type` calls** with the specific new builtin functions.
2. **Replace `@cImport`** with `addTranslateC` in `build.zig`.
3. **Add `fingerprint` and fix `name`** in `build.zig.zon`.
4. **Thread `std.Io` through your app** — any function doing I/O, sleep, random, or time needs an `io` parameter.
5. **Update `std.net` usages** to `std.Io.net` or raw syscalls.
6. **Update `ArrayList` calls** to pass allocator explicitly and use `initCapacity`.
7. **Fix error set names** (CrossDevice, FileBusy, EnvironmentVariableMissing, DirNotEmpty).
8. **Run `zig build test --test-timeout 500ms`** to catch hanging tests early.

Use this skill when writing new Zig 0.16.0 code or upgrading from 0.15.x.
