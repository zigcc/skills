# Zig Skills for AI Coding Assistants

Version-specific Zig skills for AI tools. These skills help assistants generate correct code for modern Zig instead of outdated examples from older releases.

## Available Skills

| Skill | Purpose | Target |
| --- | --- | --- |
| [zig-0.15](./zig-0.15/) | Zig 0.15 API guidance | Zig 0.15.x |
| [zig-0.16](./zig-0.16/) | Zig 0.16 API guidance and migration notes | Zig 0.16.0 |

## When to Use Which Skill

- Use `zig-0.15` for Zig 0.15.x projects.
- Use `zig-0.16` for Zig 0.16.0 projects or 0.15 -> 0.16 migration work.

## Install

### OpenCode / project local

```bash
mkdir -p .opencode/skill
cp -r zig-0.15 .opencode/skill/zig-0.15
cp -r zig-0.16 .opencode/skill/zig-0.16
```

### OpenCode / global

```bash
mkdir -p ~/.config/opencode/skill
cp -r zig-0.15 ~/.config/opencode/skill/zig-0.15
cp -r zig-0.16 ~/.config/opencode/skill/zig-0.16
```

### Claude Code compatible

```bash
mkdir -p .claude/skills
cp -r zig-0.15 .claude/skills/zig-0.15
cp -r zig-0.16 .claude/skills/zig-0.16
```

### Git submodule

```bash
git submodule add https://github.com/zigcc/skills.git skills
git submodule update --remote
```

## Usage

### Claude Code

Add the relevant skill to `CLAUDE.md`:

```markdown
# Zig

- For Zig 0.15.x, read `skills/zig-0.15/SKILL.md`
- For Zig 0.16.0, read `skills/zig-0.16/SKILL.md`
```

Or load a skill directly in a conversation:

```text
@file .opencode/skill/zig-0.16/SKILL.md
Help me migrate a Zig 0.15 project to 0.16 with minimal changes.
```

### OpenCode

If your setup supports named skills:

```json
{
  "permission": {
    "skill": {
      "zig-0.15": "ask",
      "zig-0.16": "ask"
    }
  }
}
```

Then load the version you need:

```text
/skill zig-0.15
```

### Codex

You can point Codex at this repository and ask it to install the skills:

```text
read https://github.com/zigcc/skills
@install-skills
```

## Repository Layout

```text
zig-skills/
|- zig-0.15/
|  `- SKILL.md
`- zig-0.16/
   `- SKILL.md
```

## Notes

- Each skill is intentionally version-specific.
- Always match the skill to the Zig version used by the project.
- For detailed guidance, open the `SKILL.md` inside the target skill directory.
