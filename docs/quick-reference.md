[Home](../README.md) > [Docs](./index.md) > Quick Reference

# Quick Reference

> **Last Updated**: 2026-01-23 | **Status**: Final

Command cheat sheet for Claude Code Base.

---

## Table of Contents

- [Slash Commands](#slash-commands)
- [PowerShell Scripts](#powershell-scripts)
- [Archon Commands](#archon-commands)
- [RAG Commands](#rag-commands)
- [Git Commands](#git-commands)
- [MCP Server Tools](#mcp-server-tools)
- [Task Status Flow](#task-status-flow)
- [Key File Locations](#key-file-locations)

---

## Slash Commands

### Session Management

| Command | Description | When to Use |
|---------|-------------|-------------|
| `/start` | Initialize session, load context | Beginning of every session |
| `/status` | Show project and task status | Check current state anytime |
| `/end` | Save context, commit work | End of every session |

### Configuration

| Command | Description | When to Use |
|---------|-------------|-------------|
| `/new-project` | Create and configure new project | Setting up new project |
| `/sync` | Sync Claude Code files from template | Update existing project |
| `/validate` | Check configuration validity | After setup or changes |

### PRP Framework

| Command | Description | When to Use |
|---------|-------------|-------------|
| `/prp-prd` | Create product requirements document | Large feature (1+ week) |
| `/prp-plan` | Create implementation plan | Before coding |
| `/prp-implement` | Execute implementation plan | During development |

---

## PowerShell Scripts

### Project Setup

```powershell
# Interactive project wizard
.\scripts\setup-claude-code-project.ps1

# Non-interactive mode
.\scripts\setup-claude-code-project.ps1 -NonInteractive `
    -ParentPath "E:\Repos" `
    -ProjectName "my-project" `
    -GitHubOrg "MyOrg"

# Skip optional features
.\scripts\setup-claude-code-project.ps1 -SkipGitHub -SkipArchon
```

### Sync Utility

```powershell
# Sync to existing project
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\my-project"

# Preview changes (dry run)
.\scripts\sync-claude-code.ps1 -TargetPath "..." -DryRun

# Skip backup
.\scripts\sync-claude-code.ps1 -TargetPath "..." -NoBackup

# Force (no prompts)
.\scripts\sync-claude-code.ps1 -TargetPath "..." -Force
```

### Validation

```powershell
# Validate current directory
.\scripts\validate-claude-code.ps1

# Validate specific path
.\scripts\validate-claude-code.ps1 -ProjectPath "E:\Repos\my-project"

# Auto-fix issues
.\scripts\validate-claude-code.ps1 -Fix

# Verbose output
.\scripts\validate-claude-code.ps1 -Verbose
```

---

## Archon Commands

### Projects

```python
# List all projects
find_projects()

# Search projects
find_projects(query="authentication")

# Get specific project
find_projects(project_id="uuid-here")

# Create project
manage_project("create",
    title="Project Name",
    description="Description",
    github_repo="https://github.com/..."
)

# Update project
manage_project("update",
    project_id="uuid",
    description="Updated description"
)

# Delete project
manage_project("delete", project_id="uuid")
```

### Tasks

```python
# List all tasks
find_tasks()

# Filter by status
find_tasks(filter_by="status", filter_value="todo")
find_tasks(filter_by="status", filter_value="doing")
find_tasks(filter_by="status", filter_value="review")
find_tasks(filter_by="status", filter_value="done")

# Filter by project
find_tasks(filter_by="project", filter_value="project-uuid")

# Get specific task
find_tasks(task_id="task-uuid")

# Create task
manage_task("create",
    project_id="project-uuid",
    title="Task title",
    description="Detailed description",
    feature="feature-label",
    assignee="User"
)

# Update task status
manage_task("update", task_id="uuid", status="doing")
manage_task("update", task_id="uuid", status="review")
manage_task("update", task_id="uuid", status="done")

# Delete task
manage_task("delete", task_id="uuid")
```

### Documents

```python
# List project documents
find_documents(project_id="uuid")

# Search documents
find_documents(project_id="uuid", query="architecture")

# Get specific document
find_documents(project_id="uuid", document_id="doc-uuid")

# Create document
manage_document("create",
    project_id="uuid",
    title="Document Title",
    document_type="spec",  # spec, design, note, prp, api, guide
    content={"key": "value"},
    tags=["tag1", "tag2"]
)

# Update document
manage_document("update",
    project_id="uuid",
    document_id="doc-uuid",
    content={"updated": "content"}
)

# Delete document
manage_document("delete",
    project_id="uuid",
    document_id="doc-uuid"
)
```

---

## RAG Commands

```python
# List available knowledge sources
rag_get_available_sources()

# Search knowledge base (use 2-5 keywords)
rag_search_knowledge_base(
    query="React hooks",
    match_count=5
)

# Search specific source
rag_search_knowledge_base(
    query="authentication",
    source_id="src_xxx",
    match_count=5
)

# Search code examples
rag_search_code_examples(
    query="FastAPI middleware",
    match_count=5
)

# Read full page
rag_read_full_page(page_id="uuid")
rag_read_full_page(url="https://...")

# List pages in source
rag_list_pages_for_source(source_id="src_xxx")
```

---

## Git Commands

### Status and History

```bash
# Current status
git status

# Recent commits
git log --oneline -10

# Current branch
git branch --show-current

# Show changes
git diff
git diff --staged
```

### Branching

```bash
# Create and switch branch
git checkout -b feature/my-feature

# Switch branch
git checkout main

# List branches
git branch -a
```

### Committing

```bash
# Stage files
git add path/to/file
git add .claude/ PRPs/

# Commit with message
git commit -m "feat(scope): description"

# Commit types: feat, fix, docs, style, refactor, test, chore
```

### Syncing

```bash
# Pull latest
git pull origin main

# Push changes
git push origin feature/my-feature

# Push and set upstream
git push -u origin feature/my-feature
```

---

## MCP Server Tools

### Archon (Task Management)

| Tool | Purpose |
|------|---------|
| `find_projects` | List/search projects |
| `manage_project` | Create/update/delete projects |
| `find_tasks` | List/search tasks |
| `manage_task` | Create/update/delete tasks |
| `find_documents` | List/search documents |
| `manage_document` | Create/update/delete documents |

### Brave Search

| Tool | Purpose |
|------|---------|
| `brave_web_search` | General web search |
| `brave_local_search` | Location-based search |
| `brave_video_search` | Video search |
| `brave_news_search` | News search |
| `brave_image_search` | Image search |

### Serena (Code Intelligence)

| Tool | Purpose |
|------|---------|
| `find_symbol` | Find code symbols |
| `get_symbols_overview` | File symbol overview |
| `find_referencing_symbols` | Find references |
| `search_for_pattern` | Regex search in code |
| `replace_symbol_body` | Refactor code |

### Playwright (Browser Automation)

| Tool | Purpose |
|------|---------|
| `navigate` | Go to URL |
| `click` | Click element |
| `fill` | Fill input |
| `screenshot` | Take screenshot |
| `evaluate` | Run JavaScript |

---

## Task Status Flow

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   todo ──────► doing ──────► review ──────► done        │
│                                                         │
│   Not         In            Awaiting       Completed    │
│   started     progress      review                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Status Commands

```python
# Move through workflow
manage_task("update", task_id="...", status="doing")   # Start
manage_task("update", task_id="...", status="review")  # Submit
manage_task("update", task_id="...", status="done")    # Complete
```

---

## Key File Locations

### Configuration

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Main Claude Code instructions |
| `.claude/config.yaml` | Archon project link |
| `.claude/settings.json` | Claude Code settings |
| `.vscode/mcp.json` | MCP server configuration |
| `.vscode/settings.json` | VS Code settings |
| `.pre-commit-config.yaml` | Security scanning hooks |

### Session Context

| File | Purpose |
|------|---------|
| `.claude/SESSION_KNOWLEDGE.md` | Current session state |
| `.claude/DEVELOPMENT_LOG.md` | Activity history |
| `.claude/FAILED_ATTEMPTS.md` | Failed approaches |

### Commands and Skills

| Directory | Purpose |
|-----------|---------|
| `.claude/commands/` | Slash commands |
| `.claude/skills/` | Model-invoked skills |

### PRP Framework

| Directory | Purpose |
|-----------|---------|
| `PRPs/prds/` | Product requirements |
| `PRPs/plans/` | Implementation plans |
| `PRPs/issues/` | Issue investigations |
| `PRPs/reports/` | Implementation reports |
| `PRPs/templates/` | Reusable templates |

---

## Quick Workflows

### Starting a Session

```
1. /start                    # Load context
2. Review status briefing
3. Pick a task or create one
4. Begin work
```

### Ending a Session

```
1. /end                      # Save context
2. Review session summary
3. Verify commits created
4. Note next steps
```

### Feature Development

```
1. /prp-prd "feature name"   # Create PRD
2. /prp-plan PRPs/prds/...   # Create plan
3. /prp-implement PRPs/...   # Execute plan
4. /end                      # Save progress
```

### Quick Status Check

```
/status                      # Full status
```

Or quick format:
```
STATUS: [Project]
Tasks: X doing | Y review | Z todo
Git: main - clean
Next: [Top priority]
```

---

*[Back to Documentation Index](./index.md)*
