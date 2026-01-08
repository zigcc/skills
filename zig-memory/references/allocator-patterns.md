# Zig Allocator Patterns Reference

## Standard Allocators

| Allocator | Use Case | Thread Safety |
|-----------|----------|---------------|
| `std.heap.page_allocator` | Large allocations, backed by OS | Yes |
| `std.heap.GeneralPurposeAllocator` | General use, debugging | Yes |
| `std.heap.ArenaAllocator` | Batch allocations, single free | No |
| `std.heap.FixedBufferAllocator` | Stack-backed, no heap | No |
| `std.testing.allocator` | Tests, leak detection | No |

## GeneralPurposeAllocator (GPA)

Best for general use and debugging:

```zig
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();  // Reports leaks on deinit
    const allocator = gpa.allocator();

    // Use allocator...
}
```

### GPA Options

```zig
var gpa = std.heap.GeneralPurposeAllocator(.{
    .safety = true,           // Enable safety checks (default)
    .thread_safe = true,      // Thread safety (default)
    .never_unmap = false,     // Keep pages mapped for debugging
    .retain_metadata = false, // Keep allocation metadata
}){};
```

## ArenaAllocator

Best for batch allocations freed together:

```zig
var arena = std.heap.ArenaAllocator.init(backing_allocator);
defer arena.deinit();  // Frees ALL allocations

const temp = arena.allocator();
const str1 = try temp.alloc(u8, 100);
const str2 = try temp.alloc(u8, 200);
// No individual frees needed - arena.deinit() frees everything
```

### Arena Use Cases

- Temporary computations
- Request handling (allocate per request, free at end)
- Parsing (allocate AST nodes, free when done)

## FixedBufferAllocator

For stack-backed allocations (no heap):

```zig
var buffer: [4096]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buffer);
const allocator = fba.allocator();

// Allocations come from buffer, no heap usage
const data = try allocator.alloc(u8, 100);
```

### FixedBufferAllocator Use Cases

- Embedded systems
- No-heap environments
- Known maximum allocation size

## Testing Allocator

Automatically detects memory leaks:

```zig
test "example" {
    const allocator = std.testing.allocator;

    const data = try allocator.alloc(u8, 100);
    defer allocator.free(data);  // REQUIRED or test fails

    // Test code...
}
```

### Leak Detection Output

```
Test [1/1] test.example... [gpa] memory address 0x... was never freed
[gpa] leaked 100 bytes
1/1 test.example... FAILED (leak detected)
```

## Allocation Functions

| Function | Description | Return |
|----------|-------------|--------|
| `alloc(T, n)` | Allocate n items of T | `![]T` |
| `create(T)` | Allocate single T | `!*T` |
| `dupe(T, slice)` | Duplicate slice | `![]T` |
| `dupeZ(T, slice)` | Duplicate with null terminator | `![:0]T` |
| `realloc(slice, n)` | Resize allocation | `![]T` |
| `free(slice)` | Free allocation | `void` |
| `destroy(ptr)` | Free single item | `void` |

## Common Patterns

### Owned String Return

```zig
fn createMessage(allocator: Allocator, name: []const u8) ![]u8 {
    return try std.fmt.allocPrint(allocator, "Hello, {s}!", .{name});
}

// Caller must free
const msg = try createMessage(allocator, "World");
defer allocator.free(msg);
```

### Builder Pattern

```zig
const Builder = struct {
    allocator: Allocator,
    items: std.ArrayList(Item),

    pub fn init(allocator: Allocator) Builder {
        return .{
            .allocator = allocator,
            .items = std.ArrayList(Item).init(allocator),
        };
    }

    pub fn deinit(self: *Builder) void {
        self.items.deinit();
    }

    pub fn add(self: *Builder, item: Item) !void {
        try self.items.append(item);
    }
};
```

### Resource Handle

```zig
const Resource = struct {
    data: []u8,
    allocator: Allocator,

    pub fn init(allocator: Allocator, size: usize) !Resource {
        return .{
            .data = try allocator.alloc(u8, size),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Resource) void {
        self.allocator.free(self.data);
    }
};
```

## Solana BPF Allocator

In Solana programs, use the BPF bump allocator:

```zig
const allocator = @import("solana_program_sdk").allocator.bpf_allocator;

// Limited to 32KB heap
const data = try allocator.alloc(u8, 1024);
// Note: BPF allocator does NOT support free()
```

### BPF Heap Limits

- Total heap: 32KB
- No deallocation support
- Use stack for small/fixed allocations
- Pre-calculate sizes when possible
