[Home](../README.md) > [Docs](./index.md) > FAQ

# Frequently Asked Questions

> **Last Updated**: 2026-01-23 | **Status**: Final

Common questions and troubleshooting for Claude Code Base.

---

## Table of Contents

- [General Questions](#general-questions)
- [Setup and Configuration](#setup-and-configuration)
- [CLAUDE.md Customization](#claudemd-customization)
- [Skills and Commands](#skills-and-commands)
- [Archon Integration](#archon-integration)
- [MCP Servers](#mcp-servers)
- [Syncing and Migration](#syncing-and-migration)
- [Troubleshooting](#troubleshooting)

---

## General Questions

### What is Claude Code Base?

Claude Code Base is a template repository that provides standardized configuration for projects using Claude Code. It includes:

- Pre-configured `CLAUDE.md` with best practices
- Session management commands (`/start`, `/status`, `/end`)
- Archon integration for task management
- PRP framework for structured development
- Security scanning via pre-commit hooks
- MCP server configuration

### Who should use this template?

This template is designed for:
- Developers using Claude Code regularly
- Teams wanting consistent Claude Code configuration across projects
- Projects requiring task tracking and persistent context
- Anyone who wants security scanning and best practices out of the box

### What's the difference between skills and commands?

| Aspect | Commands | Skills |
|--------|----------|--------|
| Invocation | User-typed (`/start`) | Automatic (context-based) |
| Location | `.claude/commands/` | `.claude/skills/` |
| Trigger | Explicit user action | Model detects relevance |
| Example | `/status` | `archon-workflow` activates when you mention tasks |

---

## Setup and Configuration

### How do I set up a new project?

**Option 1: Use the wizard (recommended)**

```powershell
git clone https://github.com/HouseGarofalo/claude-code-base.git
cd claude-code-base
.\scripts\setup-claude-code-project.ps1
```

**Option 2: Manual clone**

```powershell
git clone https://github.com/HouseGarofalo/claude-code-base.git my-project
cd my-project
# Update placeholders in CLAUDE.md and .claude/config.yaml
```

See [Getting Started](./getting-started.md) for detailed instructions.

### What are the prerequisites?

| Tool | Required | Purpose |
|------|----------|---------|
| Git | Yes | Version control |
| GitHub CLI | Yes | Repository management |
| Python | Yes | Pre-commit hooks |
| Node.js | Recommended | MCP servers |

### How do I verify my setup is correct?

Run the validation script:

```powershell
.\scripts\validate-claude-code.ps1
```

This checks:
- Required directories exist
- Required files present
- JSON syntax valid
- Pre-commit hooks configured
- No unconfigured placeholders
- Archon connection configured

---

## CLAUDE.md Customization

### How do I customize CLAUDE.md for my project?

1. **Replace placeholders**:
   - `[ARCHON_PROJECT_ID]` - Your Archon project UUID
   - `[PROJECT_TITLE]` - Human-readable name
   - `[GITHUB_REPO]` - Repository URL
   - `[REPOSITORY_PATH]` - Local path
   - `[PRIMARY_STACK]` - Technologies used

2. **Update code style section** with your language-specific guidelines

3. **Modify test/lint commands** in the config section

4. **Add project-specific rules** to the Critical Rules section

See [Customization Guide](./claude-code-customization.md) for detailed instructions.

### What sections should I customize?

| Section | What to Change |
|---------|----------------|
| Project Reference | Project ID, title, repo URL, path |
| Code Style Guidelines | Language-specific conventions |
| Testing Requirements | Test commands, coverage targets |
| Layer Responsibilities | Your project's architecture |
| Related Documents | Links to your docs |

### Can I add my own critical rules?

Yes, add rules following the existing pattern:

```markdown
### Rule 4: [Your Rule Name]

**Description of what this rule enforces**

**ALWAYS:**
- Do this
- Do that

**NEVER:**
- Don't do this
- Don't do that
```

Place new rules after the existing ones (Rule 0, 1, 2, 3).

---

## Skills and Commands

### How do I add a new skill?

1. Create the skill directory:
   ```
   .claude/skills/my-skill/SKILL.md
   ```

2. Add YAML frontmatter:
   ```markdown
   ---
   name: my-skill
   description: What this skill does. Keywords that trigger it.
   ---
   ```

3. Write instructions for Claude to follow

4. Test by mentioning trigger keywords in conversation

### How do I add a new command?

1. Create the command file:
   ```
   .claude/commands/my-command.md
   ```

2. Add YAML frontmatter:
   ```markdown
   ---
   name: my-command
   description: What this command does
   ---
   ```

3. Write step-by-step instructions

4. Test by typing `/my-command`

### Why isn't my skill activating?

Common causes:

1. **Description doesn't match** - Ensure keywords in description match what you're saying
2. **Wrong location** - Skill must be in `.claude/skills/[name]/SKILL.md`
3. **Invalid YAML** - Check frontmatter syntax
4. **Name too long** - Max 64 characters

---

## Archon Integration

### How do I set up Archon?

1. **Ensure Archon is running** on `localhost:8051`

2. **Create an Archon project**:
   ```python
   manage_project("create",
       title="My Project",
       description="Project description",
       github_repo="https://github.com/org/repo"
   )
   ```

3. **Copy the project ID** from the response

4. **Update config**:
   ```yaml
   # .claude/config.yaml
   archon_project_id: "copied-uuid-here"
   ```

### How do I check if Archon is connected?

Run `/start` and check the status briefing. If Archon is connected, you'll see:

```
ARCHON STATUS
-------------
Project:           Connected
Documents:         X documents
In-Progress Tasks: [list]
Pending Tasks:     X tasks
```

### How do I create tasks?

```python
manage_task("create",
    project_id="your-project-id",
    title="Task title",
    description="Detailed description with acceptance criteria",
    feature="feature-label",
    assignee="User"
)
```

### How do I update task status?

```python
# Start working
manage_task("update", task_id="task-123", status="doing")

# Submit for review
manage_task("update", task_id="task-123", status="review")

# Complete
manage_task("update", task_id="task-123", status="done")
```

---

## MCP Servers

### What MCP servers are included?

| Server | Purpose | Default Status |
|--------|---------|----------------|
| Archon | Task/project management | Enabled |
| Brave Search | Web search | Enabled |
| Serena | Code intelligence | Enabled |
| Playwright | Browser automation | Enabled |
| Context7 | Documentation lookup | Commented |
| Filesystem | File operations | Commented |
| PostgreSQL | Database operations | Commented |
| Docker | Container management | Commented |

### How do I enable an MCP server?

1. Edit `.vscode/mcp.json`
2. Uncomment the server section
3. Set required environment variables
4. Restart Claude Code

Example:
```json
{
  "servers": {
    "filesystem": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@anthropic-ai/mcp-server-filesystem"]
    }
  }
}
```

### Why isn't my MCP server working?

Check these:

1. **Server running** - Is the MCP server process running?
2. **Correct port** - Is Archon on 8051?
3. **Environment variables** - Are API keys set?
4. **npx available** - Is Node.js installed?
5. **JSON syntax** - Is mcp.json valid?

Test with:
```powershell
# Test Archon
curl http://localhost:8051/health

# Test npx
npx --version
```

---

## Syncing and Migration

### How do I sync to an existing project?

```powershell
# From claude-code-base directory
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\existing-project"
```

This copies:
- `.claude/` directory
- `.vscode/` directory
- `CLAUDE.md`
- `PRPs/` directory
- `.gitattributes`
- `.pre-commit-config.yaml`

### What files are backed up during sync?

Existing files are backed up to `.claude-backup/` with timestamps. To skip backups:

```powershell
.\scripts\sync-claude-code.ps1 -TargetPath "..." -NoBackup
```

### How do I migrate from github-copilot-base?

See [Migration Guide](./migration-guide.md) for detailed instructions.

Key differences:
- `copilot-instructions.md` -> `CLAUDE.md`
- Different command structure
- Archon instead of GitHub Issues for tasks
- MCP servers for extended capabilities

---

## Troubleshooting

### Error: "Archon project_id not configured"

**Cause**: `.claude/config.yaml` has placeholder value

**Fix**:
1. Create Archon project (see [Archon Integration](#archon-integration))
2. Update `archon_project_id` in config.yaml

### Error: "Pre-commit hook failed"

**Cause**: Usually a secret detected or syntax error

**Fix**:
1. Check the error message for details
2. If false positive, update `.secrets.baseline`
3. If real secret, remove from code and use environment variables

### Error: "MCP server not responding"

**Cause**: Server not running or wrong port

**Fix**:
1. Check server is running: `curl http://localhost:8051/health`
2. Check port in `.vscode/mcp.json`
3. Restart the MCP server
4. Restart VS Code

### Error: "Command not found"

**Cause**: Command file missing or invalid

**Fix**:
1. Check file exists: `.claude/commands/[name].md`
2. Verify YAML frontmatter is valid
3. Check `name` field matches filename

### /start shows "placeholders remaining"

**Cause**: CLAUDE.md still has `[PLACEHOLDER]` values

**Fix**:
1. Open `CLAUDE.md`
2. Search for `[` and replace all placeholders
3. Update `.claude/config.yaml` as well

### Tests fail in pre-commit

**Cause**: Pre-commit hooks detecting issues

**Fix**:
1. Read the error message carefully
2. For secret detection: Remove secrets, use env vars
3. For gitleaks: Check `.gitleaks.toml` for exceptions
4. Run `pre-commit run --all-files` to see all issues

### Session context not persisting

**Cause**: `/end` not being run or files not committed

**Fix**:
1. Always run `/end` before closing
2. Check `SESSION_KNOWLEDGE.md` has content
3. Commit the session files
4. If using Archon, check document was updated

---

## Still Need Help?

1. **Check the docs**: [Documentation Index](./index.md)
2. **Review architecture**: [Architecture](./architecture.md)
3. **Official Claude Code docs**: [Anthropic Documentation](https://docs.anthropic.com/en/docs/claude-code)
4. **Report issues**: [GitHub Issues](https://github.com/HouseGarofalo/claude-code-base/issues)

---

*[Back to Documentation Index](./index.md)*
