# Zig 0.15.x Skill for AI Coding Assistants

> A comprehensive knowledge base for AI coding assistants to write correct Zig 0.15.x code.

## Problem

Most AI language models (LLMs) have outdated Zig knowledge from versions 0.11-0.14. This causes:

- ❌ Compilation errors from using deprecated APIs
- ❌ Incorrect patterns that worked in older versions
- ❌ Frustrating debugging sessions

**Examples of common mistakes:**

```zig
// ❌ WRONG (0.13 and earlier)
var list = std.ArrayList(T).init(allocator);
try list.append(item);  // Missing allocator!

// ❌ WRONG (old HTTP API)
var req = try client.open(.GET, uri, .{});  // open() doesn't exist!
try req.send();
try req.wait();

// ❌ WRONG (old JSON API)
const json = try std.json.stringifyAlloc(allocator, data, .{});  // Doesn't exist!
```

## Solution

This skill provides **verified, source-checked** API documentation for Zig 0.15.x, ensuring AI assistants generate correct code.

## Contents

```
skills/zig-0.15/
├── SKILL.md                              # Main skill file with API guidance
├── VERSIONING.md                         # Version compatibility notes
├── README.md                             # This file
├── references/
│   ├── stdlib-api-reference.md           # Comprehensive std library reference
│   ├── migration-patterns.md             # Migration from older versions
│   └── production-codebases.md           # Real-world Zig projects for learning
└── scripts/
    └── check-zig-version.sh              # Verify Zig version compatibility
```

## Usage

### For Claude/OpenCode Users

**Method 1: Direct Reference**

Ask the AI to read the skill file:

```
Read skills/zig-0.15/SKILL.md and help me write an HTTP client
```

**Method 2: Include in System Prompt**

Add to your project's `AGENTS.md` or system configuration:

```markdown
## Zig Development

When writing Zig code, always reference `skills/zig-0.15/SKILL.md` for correct API usage.
```

**Method 3: OpenCode Config (if supported)**

Create `.opencode/config.json`:

```json
{
  "skills": [
    {
      "name": "zig-0.15",
      "path": "skills/zig-0.15/SKILL.md",
      "auto_load": true,
      "triggers": [".zig", "build.zig"]
    }
  ]
}
```

### For Other AI Tools

Copy the contents of `SKILL.md` into your AI tool's context or knowledge base.

### As a Git Submodule

```bash
# Add to your project
git submodule add https://github.com/user/zig-0.15-skill.git skills/zig-0.15

# Update
git submodule update --remote
```

## Key API Changes Covered

| Category | Old API (0.13-) | New API (0.15+) |
|----------|-----------------|-----------------|
| **ArrayList** | `list.append(item)` | `list.append(allocator, item)` |
| **HTTP Client** | `client.open()` / `req.send()` | `client.request()` / `req.sendBodyComplete()` |
| **JSON** | `std.json.stringifyAlloc()` | `std.json.Stringify` (writer-based) |
| **Ed25519** | `SecretKey` as `[32]u8` | `SecretKey` as struct with 64 bytes |
| **@typeInfo** | `.Slice`, `.Struct` | `.slice`, `.@"struct"` |

## Verification

All APIs in this skill have been verified against **Zig 0.15.2** source code:

```bash
# Check your Zig version
zig version  # Should be 0.15.x

# Or use the provided script
./skills/zig-0.15/scripts/check-zig-version.sh
```

## Library Resources

The skill includes curated lists of production-quality Zig libraries:

- **HTTP**: http.zig, tls.zig
- **CLI**: zig-clap
- **Logging**: log.zig
- **Caching**: cache.zig
- **Benchmarking**: zig-bench
- **Debugging**: pretty
- **Blockchain/Ethereum**: Zeam, ssz.zig
- **AI/ML**: ZML
- **Compiler**: llvm-zig

See `references/production-codebases.md` for the full list.

## Contributing

### Reporting Issues

If you find an incorrect API or missing documentation:

1. Verify against Zig 0.15.x source code
2. Open an issue with:
   - The incorrect code example
   - The correct code example
   - Link to Zig source (if possible)

### Adding New APIs

1. Check the API exists in Zig 0.15.x std library
2. Add examples to the appropriate file
3. Include both ❌ wrong and ✅ correct patterns
4. Submit a PR

## Roadmap

- [ ] Add more std library modules (fs, os, Thread)
- [ ] Add build.zig patterns and best practices
- [ ] Create automated tests against Zig compiler
- [ ] Support for Zig 0.16.x when released

## License

MIT License - Feel free to use in any project.

## Related Projects

- [Zig Language](https://ziglang.org/)
- [Zig Standard Library Docs](https://ziglang.org/documentation/0.15.2/std/)
- [awesome-zig](https://github.com/zigcc/awesome-zig)

---

**Note**: This skill is specifically for Zig **0.15.x**. For other versions, API details may differ significantly.
