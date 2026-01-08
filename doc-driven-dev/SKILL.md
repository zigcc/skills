---
name: doc-driven-dev
description: This skill provides documentation-driven development workflow guidance. It ensures proper Story file creation, ROADMAP status tracking, and documentation synchronization. Essential for creating or updating Story files, checking ROADMAP.md status, validating completion status, and syncing documentation with code changes.
license: MIT
compatibility:
  - opencode
  - claude-code
metadata:
  version: "1.0.0"
  category: "development-workflow"
  doc_language: "chinese"
---

# Document-Driven Development Guide

> **Core Principle**: Documentation first, code follows, tests verify, documentation closes.
> All features must follow the documentation-driven development cycle.

This skill ensures proper documentation workflow, preventing common mistakes like code without Story updates or incomplete feature tracking.

**Project Documentation Structure**:
- Stories: `stories/` (version-based feature tracking)
- Design Docs: `docs/design/` (architecture and decisions)
- API Docs: `docs/` (user-facing documentation)
- Changelog: `CHANGELOG.md` (session-based updates)
- Roadmap: `ROADMAP.md` (version planning)

**Related Skills**:
- `solana-sdk-zig`: Rust source references and test compatibility
- `zig-0.15`: Zig API usage
- `zig-memory`: Memory management patterns

## References

> Detailed templates and examples:

| Document | Path | Content |
|----------|------|---------|
| **CHANGELOG Template** | `references/changelog-template.md` | Session entry format, version release format |

## Development Cycle (Required)

Every feature/change **MUST** follow this workflow:

```
┌─────────────────────────────────────────────────────────────────┐
│  1. Documentation Preparation                                    │
│     ├── Update/create design docs (docs/design/)                │
│     ├── Update ROADMAP.md (if new feature)                      │
│     └── Create/Update Story file (stories/)                     │
├─────────────────────────────────────────────────────────────────┤
│  2. Coding Phase                                                 │
│     ├── Implement feature code                                   │
│     ├── Add code comments with Rust source references           │
│     ├── Sync update docs/ (REQUIRED!)                           │
│     └── Update Story checkboxes as features complete            │
├─────────────────────────────────────────────────────────────────┤
│  3. Testing Phase                                                │
│     ├── Unit tests (zig test src/xxx.zig)                       │
│     ├── Integration tests (zig build test)                      │
│     └── All tests MUST pass before proceeding                   │
├─────────────────────────────────────────────────────────────────┤
│  4. Documentation Finalization                                   │
│     ├── Update CHANGELOG.md with session entry                  │
│     ├── Update Story status (⏳ → ✅) if ALL complete           │
│     └── Update README.md (if user-visible changes)              │
└─────────────────────────────────────────────────────────────────┘
```

## Story File Format

### Directory Structure

```
stories/
├── v0.1.0-core-types.md
├── v0.2.0-serialization.md
├── v0.29.0-program-sdk-completion.md
├── v1.0.0-sdk-restructure.md
├── v2.0.0-spl-token.md
└── v2.2.0-stake-program.md
```

### Story Template

```markdown
# Story: vX.Y.Z Feature Name

> Brief description (one sentence)

## Goals

- Goal 1
- Goal 2

## Acceptance Criteria

### module_name.zig

- [ ] Feature 1
- [ ] Feature 2
- [ ] Unit tests

### Integration

- [ ] root.zig exports
- [ ] Documentation update
- [ ] Tests passing

## Completion Status

- Start date: YYYY-MM-DD
- Completion date: YYYY-MM-DD
- Status: ⏳ In Progress / ✅ Completed
```

## Status Markers

| Marker | Location | Meaning | When to Use |
|--------|----------|---------|-------------|
| `⏳` | ROADMAP, stories, docs | Pending/In Progress | Feature started but not complete |
| `🔨` | ROADMAP, stories | Currently Working | Active development this session |
| `✅` | ROADMAP, stories | Completed | ALL checkboxes are `[x]` |
| `[ ]` | stories, docs | Unchecked task | Task not yet done |
| `[x]` | stories, docs | Completed task | Task finished and verified |
| `TODO` | Code comments | To implement | Future work |
| `FIXME` | Code comments | To fix | Known issue |
| `XXX` | Code comments | Attention needed | Needs review |

## Story Sync Rules (Critical)

| Timing | Required Action |
|--------|-----------------|
| Start new version | Create Story file, list ALL acceptance criteria |
| Complete single feature | Change `[ ]` to `[x]` for that feature |
| Complete entire version | **ONLY** update status to ✅ when ALL `[ ]` are `[x]` |
| Add new feature | Add acceptance criteria to Story |
| Before version release | Ensure all `[ ]` are `[x]` |

### Common Mistakes

```markdown
# ❌ WRONG - Marking complete with unchecked items
## Completion Status
- Status: ✅ Completed

## Acceptance Criteria
- [x] Feature 1
- [ ] Feature 2  ← Still unchecked!

# ✅ CORRECT - All items checked before marking complete
## Completion Status
- Status: ✅ Completed

## Acceptance Criteria
- [x] Feature 1
- [x] Feature 2
```

## Validation Commands

```bash
# Check uncompleted tasks in stories/
grep -rn "\[ \]" stories/

# Check story status markers
grep -rn "Status:" stories/

# Check ROADMAP status
grep -n "⏳\|✅" ROADMAP.md

# Full scan (one command)
echo "=== ROADMAP.md ===" && grep -n "⏳" ROADMAP.md && \
echo "=== stories/ ===" && grep -rn "\[ \]\|⏳" stories/ && \
echo "=== docs/ ===" && grep -rn "TODO\|FIXME\|⏳\|\[ \]" docs/ && \
echo "=== src/ ===" && grep -rn "TODO\|FIXME\|XXX" src/ --include="*.zig"

# Verify Story-ROADMAP consistency
echo "=== ROADMAP ===" && grep -n "✅\|⏳" ROADMAP.md
echo "=== Stories ===" && grep -rn "Status:" stories/
```

## Completion Criteria

A version can **ONLY** be marked as "completed" when ALL conditions are met:

| Criterion | Verification |
|-----------|--------------|
| Core functionality 100% | All `[ ]` are `[x]` in Story |
| All tests passing | `zig build test` shows 0 failures |
| No memory leaks | Testing allocator reports no leaks |
| Documentation synced | CHANGELOG updated, Story status correct |
| Issues documented | Any deferred items noted |

## Refactoring Rules

When doing architecture changes, follow this **strict order**:

```
Phase 1: Refactor Existing Code
    ├── Move/reorganize file structure
    ├── Update import paths and dependencies
    ├── Run tests: zig build test
    └── Ensure all existing tests 100% pass
    └── Commit: "refactor: reorganize project structure"

Phase 2: Verify Refactoring Complete
    ├── Compilation passes, no errors
    ├── All original tests pass
    ├── Functionality unchanged from before
    └── DO NOT proceed until 100% verified

Phase 3: Add New Features (ONLY after Phase 2)
    ├── Add new modules/files
    ├── Implement new features
    ├── Add tests for new features
    └── Commit: "feat: add new feature"
```

### Prohibited Refactoring Behaviors

| Behavior | Status |
|----------|--------|
| Mix refactoring + new features in one commit | ❌ PROHIBITED |
| Start new features before refactoring tests pass | ❌ PROHIBITED |
| Skip test verification between phases | ❌ PROHIBITED |
| Combine Phase 1 and Phase 3 in same commit | ❌ PROHIBITED |

## CHANGELOG Format

> **See**: `references/changelog-template.md` for complete templates.

### Session Entry (Daily Work)

```markdown
### Session YYYY-MM-DD-NNN

**Date**: YYYY-MM-DD
**Goal**: Brief description of session goal

#### Completed Work
1. Implemented feature X
2. Fixed bug in Y
3. Added tests for Z

#### Test Results
- Unit tests: 305 tests passed
- Integration tests: 53 vectors verified

#### Next Steps
- [ ] Task for next session
```

### Version Release Entry

```markdown
## [vX.Y.Z] - YYYY-MM-DD

### Added
- New feature 1
- New feature 2

### Changed
- Modified behavior 1

### Fixed
- Bug fix 1
```

## Test Requirements

**All code changes MUST pass tests before commit**:

```bash
# Run full test suite
./solana-zig/zig build test --summary all

# Or run SDK tests
cd sdk && ../solana-zig/zig build test --summary all
```

### On Test Failure

| Situation | Action |
|-----------|--------|
| Test fails | Fix immediately, do NOT commit |
| Cannot fix quickly | Revert changes, investigate |
| Need help | Ask before committing broken code |

**Critical**: `zig build test` must 100% pass before `git commit`.

## Common Error Scenarios

| Error | Cause | Fix |
|-------|-------|-----|
| Story says ✅ but has `[ ]` | Premature completion | Uncheck ✅, complete remaining items |
| ROADMAP and Story disagree | Sync issue | Run validation commands, align status |
| Code complete, Story unchanged | Forgot to update | Update Story checkboxes immediately |
| Tests fail after "complete" | Incomplete verification | Never mark complete without test pass |

## Verification Checklist

Before marking any version complete:

- [ ] `grep -rn "\[ \]" stories/vX.Y.Z-*.md` returns nothing
- [ ] `zig build test` shows 100% pass
- [ ] CHANGELOG.md has session entry
- [ ] Story status updated (⏳ → ✅)
- [ ] ROADMAP.md version marked ✅

## Prohibited Actions

- ❌ **Code complete but Story not updated**
- ❌ **Story marked ✅ but code not implemented**
- ❌ **Skip Story and develop directly**
- ❌ **Release version with `[ ]` remaining**
- ❌ **Mark Story ✅ when partial features complete**
- ❌ **Commit code that fails tests**
- ❌ **Mix refactoring and new features in one commit**
