# AI Coding Assistant Skills

> 为 AI 编码助手提供的专业技能库，确保生成正确、现代的代码。

## 简介

大多数 AI 语言模型（LLMs）的知识存在滞后，经常生成过时 API 的代码。这个技能库提供了经过验证的、针对特定版本的 API 文档和最佳实践，帮助 AI 助手生成正确的代码。

## 可用技能

| 技能 | 描述 | 目标版本 |
|------|------|----------|
| [zig-0.15](./zig-0.15/) | Zig 语言 API 指南 | Zig 0.15.x |
| [zig-0.16](./zig-0.16/) | Zig 0.16-dev 迁移与兼容说明 | Zig 0.16-dev |
| [zig-memory](./zig-memory/) | Zig 内存管理与资源清理规范 | Zig 0.15.x |


## 在 Codex 中安装 skill

你可以在 Codex CLI 里直接执行：

```text
read https://github.com/zigcc/skills
@install-skills
```

或直接让助手逐个安装：

```text
请安装这个仓库中的所有 skill： https://github.com/zigcc/skills
```

## 在 Claude Code 中使用

### 方法 1: 项目级配置（推荐）

在你的项目根目录创建 `CLAUDE.md` 文件：

```markdown
# Claude Code 项目配置

## Zig 开发

当编写 Zig 代码时，请按版本与场景引用对应技能：

- Zig 0.15.x 项目：`skills/zig-0.15/SKILL.md`
- Zig 0.16-dev 迁移/兼容：`skills/zig-0.16/SKILL.md`
- 内存管理与泄漏排查：`skills/zig-memory/SKILL.md`

## 自动加载规则

- 当处理 `.zig` 文件时，优先参考 `zig-0.15` 或 `zig-0.16`
- 涉及 `Allocator`、`defer/errdefer` 时，同时参考 `zig-memory`
```

### 方法 2: 对话中直接引用

在与 Claude Code 对话时，可以直接请求加载 skill：

```
请先判断目标 Zig 版本：
- 0.15.x：先阅读 skills/zig-0.15/SKILL.md
- 0.16-dev：先阅读 skills/zig-0.16/SKILL.md
并在涉及内存分配时再阅读 skills/zig-memory/SKILL.md

示例：请按 Zig 0.15.x 帮我编写一个 HTTP 客户端
```

### 方法 3: 使用 /skill 命令

如果你的 Claude Code 配置支持自定义 skill，可以在 `.claude/settings.json` 中配置：

```json
{
  "skills": {
    "zig-0.15": {
      "path": "skills/zig-0.15/SKILL.md",
      "description": "Zig 0.15.x API guidance",
      "triggers": ["*.zig", "build.zig", "std.http", "std.ArrayList"]
    },
    "zig-0.16": {
      "path": "skills/zig-0.16/SKILL.md",
      "description": "Zig 0.16-dev migration notes",
      "triggers": ["std.Io", "std.net", "tcp", "random", "tls"]
    },
    "zig-memory": {
      "path": "skills/zig-memory/SKILL.md",
      "description": "Zig memory management patterns",
      "triggers": ["Allocator", "defer", "errdefer", "malloc", "free"]
    }
  }
}
```

然后使用命令：

```
/skill zig-0.15
```

建议按任务先后执行：

- 先调用对应版本 skill：`/skill zig-0.15` 或 `/skill zig-0.16`
- 有内存管理相关问题再调用：`/skill zig-memory`

### 方法 4: 添加为 Git Submodule

```bash
# 添加到你的项目
git submodule add https://github.com/zigcc/skills.git skills

# 更新
git submodule update --remote
```

## 在 OpenCode 中使用

OpenCode 支持以下技能文件位置：

| 位置 | 路径 | 说明 |
|------|------|------|
| 项目本地 | `.opencode/skill/<name>/SKILL.md` | 项目级技能 |
| 全局 | `~/.config/opencode/skill/<name>/SKILL.md` | 用户级技能 |
| Claude 兼容（项目） | `.claude/skills/<name>/SKILL.md` | Claude Code 兼容 |
| Claude 兼容（全局） | `~/.claude/skills/<name>/SKILL.md` | Claude Code 兼容 |

### 方法 1: 项目本地安装（推荐）

```bash
# 复制全部技能到项目的 .opencode/skill 目录
mkdir -p .opencode/skill
cp -r zig-0.15 zig-0.16 zig-memory .opencode/skill/

# 或者创建符号链接
ln -s $(pwd)/zig-0.15 .opencode/skill/zig-0.15
ln -s $(pwd)/zig-0.16 .opencode/skill/zig-0.16
ln -s $(pwd)/zig-memory .opencode/skill/zig-memory
```

单独安装某个 skill（按需）：

```bash
# 安装单个 skill（用参数替换 <name>）
mkdir -p .opencode/skill
cp -r zig-<name> .opencode/skill/zig-<name>
```

示例：

```bash
cp -r zig-0.15 .opencode/skill/zig-0.15
cp -r zig-0.16 .opencode/skill/zig-0.16
cp -r zig-memory .opencode/skill/zig-memory
```

### 方法 2: 全局安装

```bash
# 复制全部技能到用户配置目录
mkdir -p ~/.config/opencode/skill
cp -r zig-0.15 zig-0.16 zig-memory ~/.config/opencode/skill/

# 这样所有项目都可以使用此技能
```

单独安装某个 skill（按需）：

```bash
# 安装单个 skill（用参数替换 <name>）
mkdir -p ~/.config/opencode/skill
cp -r zig-<name> ~/.config/opencode/skill/zig-<name>
```

### 方法 3: Claude Code 兼容安装

```bash
# 项目级（.claude/skills）安装全部
mkdir -p .claude/skills
cp -r zig-0.15 zig-0.16 zig-memory .claude/skills/

# 或全局（~/.claude/skills）安装全部
mkdir -p ~/.claude/skills
cp -r zig-0.15 zig-0.16 zig-memory ~/.claude/skills/
```

## Claude/OpenCode 按版本快速加载模板（可复制）

### CLAUDE.md 模板

```markdown
# CLAUDE.md

## Zig 开发

先判断 Zig 版本：
- 0.15.x：参考 `skills/zig-0.15/SKILL.md`
- 0.16-dev：参考 `skills/zig-0.16/SKILL.md`

涉及内存管理（Allocator/defer/errdefer）时再补充：
- `skills/zig-memory/SKILL.md`
```

### opencode.json 模板

```json
{
  "permission": {
    "skill": {
      "zig-0.15": "ask",
      "zig-0.16": "ask",
      "zig-memory": "ask"
    }
  }
}
```

### 会话加载模板（按任务）

```text
@file .opencode/skill/zig-0.15/SKILL.md
（或）
@file .opencode/skill/zig-0.16/SKILL.md

@file .opencode/skill/zig-memory/SKILL.md  # 如涉及内存管理
```

单独安装某个 skill（按需）：

```bash
# 项目级或全局按单个 skill 安装（用参数替换 <name>）
mkdir -p <target-dir>
cp -r zig-<name> <target-dir>/zig-<name>
```

例如：

```bash
cp -r zig-memory ~/.claude/skills/zig-memory
```

### 权限配置

在 `opencode.json` 中配置技能权限：

```json
{
  "permission": {
    "skill": {
      "zig-0.15": "allow",
      "zig-0.16": "allow",
      "zig-memory": "allow"
    }
  }
}
```

### 方法 4: 会话中手动加载

```
@file .opencode/skill/zig-0.15/SKILL.md

帮我编写一个使用 ArrayList 的程序
```

```
@file .opencode/skill/zig-0.16/SKILL.md

我在迁移 0.15 项目到 0.16，需要最小改动建议
```

## 技能结构

每个技能遵循标准结构：

```
skills/<skill-name>/
├── SKILL.md                    # 主技能文件（AI 读取的核心内容）
├── README.md                   # 技能说明文档（可选）
├── VERSIONING.md               # 版本兼容性说明（可选）
├── references/                 # 参考资料
│   └── ...
└── scripts/                    # 辅助脚本
    └── ...
```

## 使用建议（按场景）

- `zig-0.15`：适合新建或现有的 0.15.x 项目，用于校正旧 API 的差异。
- `zig-0.16`：适合 0.16-dev 迁移窗口，处理 `std.Io`、`std.net` 等 API 重构。
- `zig-memory`：涉及 `Allocator`、`defer` / `errdefer`、资源释放与泄漏排查时的通用复核技能。

## 快速命令清单（复制即用）

| 技能 | 本地安装（项目） | 本地安装（全局） | 加载命令 |
|------|------------------|------------------|----------|
| zig-0.15 | `cp -r zig-0.15 .opencode/skill/zig-0.15` | `cp -r zig-0.15 ~/.config/opencode/skill/zig-0.15` | `/skill zig-0.15` |
| zig-0.16 | `cp -r zig-0.16 .opencode/skill/zig-0.16` | `cp -r zig-0.16 ~/.config/opencode/skill/zig-0.16` | `/skill zig-0.16` |
| zig-memory | `cp -r zig-memory .opencode/skill/zig-memory` | `cp -r zig-memory ~/.config/opencode/skill/zig-memory` | `/skill zig-memory` |

Claude + 会话调用（示例）：

```text
@file .opencode/skill/zig-0.16/SKILL.md
先给我一份 0.15 -> 0.16 的最小迁移清单

@file .opencode/skill/zig-memory/SKILL.md
再检查我的内存释放是否正确
```

### SKILL.md 格式

技能文件使用 YAML frontmatter：

```markdown
---
name: skill-name
description: Brief description of what this skill provides
---

# Skill Title

技能内容...
```

## 创建新技能

### 步骤 1: 创建目录结构

```bash
mkdir -p skills/my-skill/references
mkdir -p skills/my-skill/scripts
```

### 步骤 2: 创建 SKILL.md

```markdown
---
name: my-skill
description: Description for AI to understand when to use this skill
---

# My Skill

## 关键变更

### API 1 (重大变更)

\`\`\`language
// 错误示例 (旧版本)
oldApi();

// 正确示例 (新版本)
newApi();
\`\`\`

## 常见错误和修复

| 错误信息 | 原因 | 修复方法 |
|----------|------|----------|
| error message | cause | fix |

## 参考资源

- Official docs: https://...
```

### 步骤 3: 添加 README.md

说明技能的用途、覆盖范围和使用方法。

### 步骤 4: 添加版本验证脚本（可选）

```bash
#!/bin/bash
# scripts/check-version.sh
# 验证当前环境版本是否兼容
```

## 最佳实践

### 编写 Skill 内容

1. **使用对比示例**：同时展示错误和正确的代码
2. **提供错误对照表**：常见错误信息 -> 原因 -> 修复
3. **包含官方资源链接**：便于 AI 需要时查阅
4. **保持版本明确**：清楚标注适用的版本范围

### 组织技能

1. **按版本分离**：如 `zig-0.15`, `zig-0.16`
2. **核心内容放 SKILL.md**：这是 AI 主要读取的文件
3. **详细参考放 references/**：避免主文件过长

## 支持的 AI 工具

| 工具 | 支持状态 | 配置方式 |
|------|----------|----------|
| Claude Code | 完全支持 | CLAUDE.md / .claude/settings.json |
| OpenCode | 完全支持 | .opencode/config.json |
| Cursor | 部分支持 | .cursorrules |
| GitHub Copilot | 手动 | 通过注释引用 |

## 贡献

### 报告问题

1. 验证 API 是否确实在目标版本中存在
2. 提交 issue 并包含：
   - 错误的代码示例
   - 正确的代码示例
   - 官方文档链接（如果有）

### 添加新技能

1. Fork 这个仓库
2. 按照上述结构创建新技能
3. 确保所有示例代码经过验证
4. 提交 Pull Request

## 许可证

MIT License - 可自由使用于任何项目。

---

**注意**：每个技能针对特定版本。使用前请确认你的项目版本与技能版本匹配。
