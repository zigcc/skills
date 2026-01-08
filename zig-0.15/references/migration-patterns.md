# Zig 0.15 Migration Patterns

Quick reference for migrating code from older Zig versions to 0.15.x.

**Official Release Notes**: https://ziglang.org/download/0.15.1/release-notes.html

## Writergate: I/O Migration (CRITICAL)

The entire `std.io` reader/writer system has been rewritten. Old APIs are deprecated.

### Before (0.14 - generic writers)

```zig
const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, World!\n", .{});
}
```

### After (0.15+ - new std.Io.Writer)

```zig
const std = @import("std");

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;

    try stdout.print("Hello, World!\n", .{});
    try stdout.flush();  // Don't forget to flush!
}
```

### Key Differences

1. **User provides buffer**: `var buffer: [N]u8 = undefined;`
2. **Get interface pointer**: `&writer.interface`
3. **Must flush**: `try stdout.flush();`
4. **Non-generic**: `*std.Io.Writer` is a concrete type

### File Reading Migration

```zig
// ❌ Before (0.14)
var file = try std.fs.cwd().openFile("data.txt", .{});
var reader = file.reader();
const line = try reader.readUntilDelimiterAlloc(allocator, '\n', 4096);

// ✅ After (0.15+)
var file = try std.fs.cwd().openFile("data.txt", .{});
var buffer: [4096]u8 = undefined;
var file_reader = file.reader(&buffer);
const reader: *std.Io.Reader = &file_reader.interface;

while (reader.takeDelimiterExclusive('\n')) |line| {
    // process line
} else |err| switch (err) {
    error.EndOfStream => {},
    else => return err,
}
```

### Adapter for Legacy Code

If you need to use old-style writers with new APIs:

```zig
fn legacyFunction(old_writer: anytype) !void {
    var adapter = old_writer.adaptToNewApi(&.{});
    const w: *std.Io.Writer = &adapter.new_interface;
    try w.print("{s}", .{"works with new API"});
}
```

## ArrayList Migration

### Before (0.13 and earlier)

```zig
var list = std.ArrayList(T).init(allocator);
defer list.deinit();

try list.append(item);
try list.appendSlice(items);
try list.ensureTotalCapacity(100);
const owned = try list.toOwnedSlice();
```

### After (0.15+)

```zig
var list = try std.ArrayList(T).initCapacity(allocator, 16);
defer list.deinit(allocator);

try list.append(allocator, item);
try list.appendSlice(allocator, items);
try list.ensureTotalCapacity(allocator, 100);
const owned = try list.toOwnedSlice(allocator);
```

### Quick Fix Pattern

Find and replace these patterns:

| Find | Replace |
|------|---------|
| `list.append(` | `list.append(allocator, ` |
| `list.appendSlice(` | `list.appendSlice(allocator, ` |
| `list.addOne()` | `list.addOne(allocator)` |
| `list.toOwnedSlice()` | `list.toOwnedSlice(allocator)` |
| `list.deinit()` | `list.deinit(allocator)` |

## Ed25519 Migration

### Before (0.13)

```zig
const Ed25519 = std.crypto.sign.Ed25519;

const seed: [32]u8 = get_seed();
const kp = Ed25519.KeyPair.fromSecretKey(seed);

const sig = try Ed25519.Signature.fromBytes(sig_bytes);
```

### After (0.15+)

```zig
const Ed25519 = std.crypto.sign.Ed25519;

const seed: [32]u8 = get_seed();
const kp = try Ed25519.KeyPair.generateDeterministic(seed);

const sig = Ed25519.Signature.fromBytes(sig_bytes);
```

### Key Differences

1. `SecretKey` is now 64 bytes (seed + pubkey), not 32
2. Use `generateDeterministic(seed)` instead of `fromSecretKey(seed)`
3. `Signature.fromBytes` no longer returns an error union

## HTTP Client Migration

### Before (0.13 fetch API)

```zig
var client = std.http.Client{ .allocator = allocator };
defer client.deinit();

const result = try client.fetch(.{
    .url = "https://api.example.com/data",
    .response_storage = .{ .dynamic = &response_buffer },
});
```

### After (0.15+ request/response API)

```zig
var client: std.http.Client = .{ .allocator = allocator };
defer client.deinit();

const uri = try std.Uri.parse("https://api.example.com/data");
var req = try client.open(.GET, uri, .{});
defer req.deinit();

try req.send();
try req.wait();

var body = std.ArrayList(u8).init(allocator);
defer body.deinit();
try req.reader().readAllArrayList(&body, 10 * 1024 * 1024);
```

## @typeInfo Migration

### Before (0.13 PascalCase)

```zig
const info = @typeInfo(T);
switch (info) {
    .Struct => |s| { ... },
    .Enum => |e| { ... },
    .Union => |u| { ... },
    .Pointer => |p| {
        if (p.size == .Slice) { ... }
    },
}
```

### After (0.15+ lowercase)

```zig
const info = @typeInfo(T);
switch (info) {
    .@"struct" => |s| { ... },
    .@"enum" => |e| { ... },
    .@"union" => |u| { ... },
    .pointer => |p| {
        if (p.size == .slice) { ... }
    },
}
```

### All Changed Enum Values

| 0.13 | 0.15+ |
|------|-------|
| `.Type` | `.type` |
| `.Void` | `.void` |
| `.Bool` | `.bool` |
| `.Int` | `.int` |
| `.Float` | `.float` |
| `.Pointer` | `.pointer` |
| `.Array` | `.array` |
| `.Struct` | `.@"struct"` |
| `.Enum` | `.@"enum"` |
| `.Union` | `.@"union"` |
| `.Optional` | `.optional` |
| `.ErrorUnion` | `.error_union` |
| `.ErrorSet` | `.error_set` |
| `.Fn` | `.@"fn"` |
| `.Slice` (in pointer.size) | `.slice` |

## Custom Format Function Migration

### Before (0.13)

```zig
pub fn format(
    self: Self,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    _ = fmt;
    _ = options;
    try writer.print("{s}", .{self.name});
}

const output = try std.fmt.allocPrint(allocator, "{}", .{value});
```

### After (0.15+)

```zig
pub fn format(self: Self, writer: anytype) !void {
    try writer.print("{s}", .{self.name});
}

const output = try std.fmt.allocPrint(allocator, "{f}", .{value});
```

### Key Change
- Use `{f}` format specifier instead of `{}`
- Simpler function signature (no fmt, no options)

## Base64 Migration

### Before (0.13)

```zig
const encoded = std.base64.standard.encode(&buf, data);
const decoded = try std.base64.standard.decode(&buf, encoded);
```

### After (0.15+)

```zig
const encoded = std.base64.standard.Encoder.encode(&buf, data);
const decoded = try std.base64.standard.Decoder.decode(&buf, encoded);
```

## Build System Migration (MAJOR CHANGES)

**Official Guide**: https://ziglang.org/learn/build-system/

### Before (0.14 and earlier)

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "myapp",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addModule("mymodule", module);
    b.installArtifact(exe);
}
```

### After (0.15+)

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "myapp",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.root_module.addImport("mymodule", module);
    b.installArtifact(exe);
}
```

### Key Build System Changes

| 0.14 | 0.15+ |
|------|-------|
| `.root_source_file = .{ .path = "..." }` | `.root_source_file = b.path("...")` |
| `target` at top level | `target` in `createModule()` |
| `optimize` at top level | `optimize` in `createModule()` |
| `b.addSharedLibrary(...)` | `b.addLibrary(.{ .linkage = .dynamic, ... })` |
| `b.addStaticLibrary(...)` | `b.addLibrary(.{ .linkage = .static, ... })` |
| `exe.addModule("name", mod)` | `exe.root_module.addImport("name", mod)` |
| Host target implicit | `b.graph.host` for native target |

### Library Migration

```zig
// ❌ Before (0.14)
const lib = b.addSharedLibrary(.{
    .name = "mylib",
    .root_source_file = .{ .path = "src/lib.zig" },
    .target = target,
    .optimize = optimize,
});

// ✅ After (0.15+)
const lib = b.addLibrary(.{
    .name = "mylib",
    .linkage = .dynamic,
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    }),
});
```

### Test Migration

```zig
// ❌ Before (0.14)
const unit_tests = b.addTest(.{
    .root_source_file = .{ .path = "src/main.zig" },
    .target = target,
    .optimize = optimize,
});

// ✅ After (0.15+)
const unit_tests = b.addTest(.{
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    }),
});
```

## Common Compilation Errors

| Error Message | Likely Cause | Fix |
|--------------|--------------|-----|
| `expected 2 argument(s), found 1` | ArrayList missing allocator | Add allocator param |
| `no member named 'Struct'` | @typeInfo case | Use `.@"struct"` |
| `no field named 'response_storage'` | Old fetch API | Use request/response |
| `expected type 'SecretKey', found '[32]u8'` | Ed25519 change | Use generateDeterministic |
| `expected error union type` | Signature.fromBytes | Remove `try` |
| `no field named 'path'` | Build system path | Use `b.path()` |
