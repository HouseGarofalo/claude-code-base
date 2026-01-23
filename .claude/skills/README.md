# Claude Code Skills

This directory contains **skills** - reusable instruction sets that Claude can invoke automatically based on context.

## What are Skills?

Skills are markdown files with YAML frontmatter that define:
- **When** to activate (based on description matching)
- **What** to do (detailed instructions)
- **How** to execute (step-by-step guidance)

Unlike slash commands (user-invoked), skills are **model-invoked** - Claude automatically activates relevant skills based on the task at hand.

## Directory Structure

```
skills/
├── README.md                    # This file
├── archon-workflow/
│   └── SKILL.md                 # Archon task/project management
├── code-review/
│   └── SKILL.md                 # Code review practices
├── documentation/
│   └── SKILL.md                 # Technical documentation
├── git-workflow/
│   └── SKILL.md                 # Advanced Git operations
├── github/
│   └── SKILL.md                 # GitHub operations via gh CLI
├── mcp-development/
│   └── SKILL.md                 # MCP server development
├── prompt-engineering/
│   └── SKILL.md                 # Prompt engineering techniques
└── prp-framework/
    └── SKILL.md                 # Product requirement prompts
```

## Skill File Format

Skills use a specific format with YAML frontmatter:

```markdown
---
name: skill-name
description: |
  Brief description of what this skill does and when to use it.
  This description is used for matching - include keywords that
  would trigger this skill. Maximum 1024 characters.
---

# Skill Name

## Overview

What this skill accomplishes.

## When to Use

- Trigger condition 1
- Trigger condition 2

## Instructions

Detailed step-by-step instructions for Claude to follow.

## Examples

Example inputs and expected outputs.
```

## Naming Conventions

- **Directory name**: `lowercase-with-hyphens`
- **Skill file**: Always named `SKILL.md`
- **Name field**: Must match directory name
- **Max length**: 64 characters for name

## Skill Discovery

Claude discovers skills from two locations:
1. `~/.claude/skills/` - Global skills (available in all projects)
2. `.claude/skills/` - Project skills (this directory)

Project skills take precedence over global skills with the same name.

## Best Practices

1. **Descriptive triggers** - Write descriptions that clearly indicate when to activate
2. **Focused scope** - One skill, one capability
3. **Clear instructions** - Unambiguous, step-by-step guidance
4. **Include examples** - Show expected inputs and outputs
5. **Error handling** - What to do when things go wrong

## Documentation

- [Skills Overview](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Creating Skills](https://docs.anthropic.com/en/docs/claude-code/tutorials/skills)
- [Skill Format Reference](https://docs.anthropic.com/en/docs/claude-code/reference/skill-format)

## Project Skills

| Skill | Description | Triggers |
|-------|-------------|----------|
| [github](./github/SKILL.md) | GitHub operations via gh CLI | github, PR, issue, Actions |
| [git-workflow](./git-workflow/SKILL.md) | Advanced Git workflows | rebase, cherry-pick, bisect, worktree |
| [mcp-development](./mcp-development/SKILL.md) | MCP server development | mcp, tool provider, resources |
| [prompt-engineering](./prompt-engineering/SKILL.md) | Prompt engineering techniques | prompt, CoT, few-shot |
| [prp-framework](./prp-framework/SKILL.md) | Product requirement prompts | prp, prd, feature spec |
| [archon-workflow](./archon-workflow/SKILL.md) | Archon task management | archon, task, project, rag |
| [code-review](./code-review/SKILL.md) | Code review practices | review, PR review, audit |
| [documentation](./documentation/SKILL.md) | Technical documentation | docs, readme, api docs |

---

*Add more skills to this directory to teach Claude project-specific capabilities.*
