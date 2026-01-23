# Claude Code Commands

This directory contains **slash commands** for Claude Code.

## What are Slash Commands?

Slash commands are shortcuts that trigger specific Claude Code behaviors. When you type `/command-name` in Claude Code, it looks for a matching markdown file in this directory and follows its instructions.

## Available Commands

### Session Management

| Command | Description | File |
|---------|-------------|------|
| `/start` | Initialize a new session with full context loading | `start.md` |
| `/status` | Show current project and task status | `status.md` |
| `/end` | Save context, update logs, and commit work | `end.md` |

### Configuration & Setup

| Command | Description | File |
|---------|-------------|------|
| `/new-project` | Create and configure a new Claude Code project | `new-project.md` |
| `/sync` | Sync Claude Code configuration from template | `sync.md` |
| `/validate` | Validate configuration and project setup | `validate.md` |

### PRP Framework (Product Requirements Planning)

| Command | Description | File |
|---------|-------------|------|
| `/prp-prd` | Create a new Product Requirements Document | `prp-prd.md` |
| `/prp-plan` | Create implementation plan from a PRD | `prp-plan.md` |
| `/prp-implement` | Execute an implementation plan | `prp-implement.md` |

## Quick Start Workflow

1. **New Project Setup:**
   ```
   /new-project    # Configure project and create Archon integration
   /validate       # Verify setup is correct
   ```

2. **Daily Session:**
   ```
   /start          # Begin session, load context
   /status         # Check current state
   [work]          # Do your work
   /end            # Save context, commit changes
   ```

3. **Feature Development:**
   ```
   /prp-prd        # Document the feature requirements
   /prp-plan       # Create implementation plan
   /prp-implement  # Execute the plan with validation
   ```

## Creating a Command

1. Create a markdown file: `commands/your-command.md`
2. The filename (without `.md`) becomes the command name
3. Add YAML frontmatter with `name` and `description`
4. Write instructions that Claude should follow when the command is invoked

### Command File Format

```markdown
---
name: command-name
description: Brief description of what the command does
---

# /command-name - Full Title

[Detailed instructions for Claude to follow]

## Steps to Execute

1. [Step 1]
2. [Step 2]

## Output Format

[Expected output format]
```

## Best Practices

1. **Keep commands focused** - One command, one purpose
2. **Be explicit** - Write clear, unambiguous instructions
3. **Include error handling** - What to do if something fails
4. **Add validation** - Verify prerequisites before executing
5. **Document outputs** - Specify expected output formats
6. **Use YAML frontmatter** - Include name and description

## Documentation

- [Claude Code Commands Documentation](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
- [Creating Custom Commands](https://docs.anthropic.com/en/docs/claude-code/tutorials/slash-commands)

---

*Add your custom commands to this directory to extend Claude Code's capabilities.*
