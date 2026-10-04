# Zig Skills for AI Coding Assistants

Version-specific Zig skills for AI tools. These skills help assistants generate correct code for modern Zig instead of outdated examples from older releases.

## Available Skills

| Skill | Purpose | Target |
| --- | --- | --- |
| [zig-0.15](./zig-0.15/) | Zig 0.15 API guidance | Zig 0.15.x |
| [zig-0.16](./zig-0.16/) | Zig 0.16 API guidance and migration notes | Zig 0.16.0 |
| [zig-0.17](./zig-0.17/) | Zig 0.17 API guidance and migration notes | Zig 0.17.0 |
| [zig-tiger-style](./zig-tiger-style/) | TigerStyle Zig coding guidelines and best practices | All Zig versions |

## Install

### 1. Via `npx skills`

```bash
# Interactive selection (choose which skills and agents to install)
npx skills add zigcc/skills

# Or install a specific version directly
npx skills add zigcc/skills --skill zig-0.17
```

### 2. Manual Copy

Copy the target skill directory to your AI tool's skill directory:

```bash
# OpenCode (project local)
mkdir -p .opencode/skill && cp -r zig-0.17 .opencode/skill/

# OpenCode (global)
mkdir -p ~/.config/opencode/skill && cp -r zig-0.17 ~/.config/opencode/skill/

# Claude Code
mkdir -p .claude/skills && cp -r zig-0.17 .claude/skills/
```

## Usage

### In Project Rules (Recommended)

Pin your project to a specific Zig version in `CLAUDE.md` or `AGENTS.md` so the AI assistant always follows the correct APIs:

```markdown
# Zig Guidelines

- For Zig 0.17.x, follow `.claude/skills/zig-0.17/SKILL.md` (or `.opencode/skill/zig-0.17/SKILL.md`)
- For Zig 0.16.0, follow `.claude/skills/zig-0.16/SKILL.md` (or `.opencode/skill/zig-0.16/SKILL.md`)
- For Zig 0.15.x, follow `.claude/skills/zig-0.15/SKILL.md` (or `.opencode/skill/zig-0.15/SKILL.md`)
```

### Direct Invocation

- **OpenCode**: Use the slash command:
  ```text
  /skill zig-0.17
  ```
- **Claude Code**: The skill is detected automatically, or mention it in your prompt:
  ```text
  Please use the zig-0.17 skill to review this code.
  ```
- **Prompt reference** (any tool supporting file context):
  ```text
  @file .claude/skills/zig-0.17/SKILL.md
  ```
