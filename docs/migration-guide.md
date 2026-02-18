[Home](../README.md) > [Docs](./index.md) > Migration Guide

# Migration Guide: From github-copilot-base to claude-code-base

> **Last Updated**: 2026-02-18 | **Status**: Final

This guide helps you migrate projects from the github-copilot-base template to claude-code-base.

---

## Table of Contents

- [Overview](#overview)
- [Key Differences](#key-differences)
- [Mapping Table](#mapping-table)
- [Migration Steps](#migration-steps)
- [What to Keep vs Replace](#what-to-keep-vs-replace)
- [Post-Migration Checklist](#post-migration-checklist)

---

## Overview

While both templates provide AI-assisted development configuration, Claude Code Base offers:

- **Archon integration** for persistent task management
- **MCP servers** for extended capabilities
- **Model-invoked skills** (not just user commands)
- **PRP framework** for structured development
- **Session management** with context preservation

---

## Key Differences

### Architecture Comparison

| Aspect | github-copilot-base | claude-code-base |
|--------|---------------------|------------------|
| AI Assistant | GitHub Copilot | Claude Code |
| Instructions File | `.github/copilot-instructions.md` | `CLAUDE.md` |
| Settings Location | `.github/` | `.claude/` |
| Task Management | GitHub Issues | Archon MCP |
| Extended Tools | Limited | MCP servers |
| Commands | PR templates, workflows | Slash commands |
| Skills | None | Model-invoked skills |
| Structured Dev | None | PRP framework |

### Feature Comparison

| Feature | github-copilot-base | claude-code-base |
|---------|---------------------|------------------|
| AI instructions file | Yes | Yes |
| Custom commands | Limited | Slash commands |
| Auto-activated behaviors | No | Skills |
| Persistent task tracking | GitHub Issues | Archon |
| Session context | No | Yes |
| Knowledge base search | No | RAG via Archon |
| Web search | No | Brave Search MCP |
| Code intelligence | Limited | Serena MCP |
| Browser automation | No | Playwright MCP |
| Pre-commit hooks | Varies | gitleaks + detect-secrets |

---

## Mapping Table

### Files and Directories

| github-copilot-base | claude-code-base | Notes |
|---------------------|------------------|-------|
| `.github/copilot-instructions.md` | `CLAUDE.md` | Different format |
| `.github/` | `.claude/` | Configuration directory |
| `.github/workflows/` | (keep) | CI/CD workflows |
| `.github/CODEOWNERS` | `CODEOWNERS` | Move to root |
| `.github/PULL_REQUEST_TEMPLATE.md` | (keep) | PR templates |
| `.github/ISSUE_TEMPLATE/` | (keep) | Issue templates |
| N/A | `.claude/commands/` | New: slash commands |
| N/A | `.claude/skills/` | New: model skills |
| N/A | `.vscode/mcp.json` | New: MCP config |
| N/A | `PRPs/` | New: PRP framework |

### Concepts

| github-copilot-base | claude-code-base | Equivalent |
|---------------------|------------------|------------|
| Copilot Chat | Claude Code | AI assistant |
| Instructions file | CLAUDE.md | AI guidance |
| GitHub Issues | Archon tasks | Task tracking |
| PR comments | Code review skill | Code review |
| Copilot suggestions | Claude responses | AI output |
| N/A | `/start`, `/end` | Session management |
| N/A | RAG search | Documentation search |
| N/A | MCP servers | Extended capabilities |

### Common Patterns

| Pattern | github-copilot-base | claude-code-base |
|---------|---------------------|------------------|
| "Review this code" | Copilot Chat | `/prp-review` or code-review skill |
| "Create a PR" | Manual or Action | `gh pr create` + GitHub skill |
| "Track this task" | GitHub Issue | `manage_task("create", ...)` |
| "Search docs" | External search | `rag_search_knowledge_base()` |
| "Start working" | N/A | `/start` |
| "End session" | N/A | `/end` |

---

## Migration Steps

### Step 1: Backup Current Configuration

```powershell
# Create backup
Copy-Item -Recurse .github .github.backup
```

### Step 2: Run the Intelligent Sync Wizard

```powershell
# From claude-code-base directory
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\your-project"
```

The sync wizard (v3.0) interactively guides you through project type, language, framework, and dev framework selection. It then:
- **Adds** only relevant skills and commands (based on your selections)
- **Skips** skills already covered by global plugins or global skills
- **Merges** missing sections into your CLAUDE.md (additive-only, never overwrites)
- **Fills** placeholders with auto-detected values (git remote, directory name, date)
- **Previews** all proposed changes before applying

See [Getting Started - Syncing to Existing Projects](./getting-started.md#syncing-to-existing-projects) for full details.

### Step 3: Migrate Instructions

Convert `copilot-instructions.md` content to `CLAUDE.md` format.

**Before (copilot-instructions.md):**
```markdown
# Copilot Instructions

## Code Style
- Use TypeScript
- Follow ESLint rules

## Patterns
- Use React hooks
- Prefer functional components
```

**After (CLAUDE.md):**
```markdown
## Code Style Guidelines

### TypeScript Guidelines

| Principle | Description |
|-----------|-------------|
| Type Safety | Use strict TypeScript |
| Linting | Follow ESLint configuration |

### React Patterns

| Pattern | Usage |
|---------|-------|
| Hooks | Prefer React hooks |
| Components | Use functional components |
```

### Step 4: Configure Archon

1. **Create Archon project:**
   ```python
   manage_project("create",
       title="Your Project",
       description="Migrated from github-copilot-base",
       github_repo="https://github.com/..."
   )
   ```

2. **Update config.yaml** with project ID

3. **Migrate GitHub Issues to Archon tasks** (optional):
   ```python
   # For each important issue
   manage_task("create",
       project_id="uuid",
       title="Issue title",
       description="Issue description",
       feature="migration"
   )
   ```

### Step 5: Update VS Code Settings

Merge any custom VS Code settings from your project with the template settings.

**Template provides:**
- `.vscode/settings.json` - Editor settings
- `.vscode/extensions.json` - Recommended extensions
- `.vscode/mcp.json` - MCP server configuration

### Step 6: Set Up MCP Servers

1. **Configure environment variables** for MCP servers:
   ```bash
   # .env or ~/.claude/.env
   BRAVE_API_KEY=your-key
   ```

2. **Enable desired servers** in `.vscode/mcp.json`

### Step 7: Test the Setup

```powershell
# Validate configuration
.\scripts\validate-claude-code.ps1

# Start a Claude Code session
# Type /start in Claude Code
```

---

## What to Keep vs Replace

### Keep (Don't Delete)

| Item | Reason |
|------|--------|
| `.github/workflows/` | CI/CD pipelines |
| `.github/ISSUE_TEMPLATE/` | Issue templates still useful |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR templates still useful |
| `.github/dependabot.yml` | Dependency updates |
| `CODEOWNERS` | Code ownership |

### Replace

| Old | New | Action |
|-----|-----|--------|
| `copilot-instructions.md` | `CLAUDE.md` | Migrate content |
| Custom VS Code settings | Template settings | Merge |

### Add (New Files)

| File/Directory | Purpose |
|----------------|---------|
| `.claude/` | Claude Code configuration |
| `.claude/commands/` | Slash commands |
| `.claude/skills/` | Model-invoked skills |
| `.vscode/mcp.json` | MCP server configuration |
| `PRPs/` | PRP framework |
| `.pre-commit-config.yaml` | Security scanning |

### Optional: Remove

| Item | When to Remove |
|------|----------------|
| `copilot-instructions.md` | After migration complete |
| Copilot-specific settings | If not using Copilot alongside Claude |

---

## Post-Migration Checklist

### Configuration

- [ ] `CLAUDE.md` created with project-specific content
- [ ] `.claude/config.yaml` has Archon project ID
- [ ] `.vscode/mcp.json` configured with desired servers
- [ ] Environment variables set for MCP servers
- [ ] Pre-commit hooks installed

### Verification

- [ ] `.\scripts\validate-claude-code.ps1` passes
- [ ] `/start` command works
- [ ] Archon connection established
- [ ] MCP servers responding

### Content Migration

- [ ] Code style guidelines transferred to CLAUDE.md
- [ ] Project-specific rules added
- [ ] Important GitHub Issues converted to Archon tasks
- [ ] Documentation updated

### Testing

- [ ] Start a Claude Code session
- [ ] Create a test task
- [ ] Run `/status`
- [ ] Run `/end`
- [ ] Verify context persists

### Cleanup

- [ ] Backup archived or deleted
- [ ] Old files removed (if desired)
- [ ] Changes committed
- [ ] Team notified of new workflow

---

## Migration FAQ

### Can I use both Copilot and Claude Code?

Yes, they can coexist. Keep your Copilot instructions if you want both:
- `CLAUDE.md` - Claude Code instructions
- `.github/copilot-instructions.md` - Copilot instructions

### What about my GitHub Issues?

GitHub Issues remain functional. Archon is additive:
- Continue using GitHub Issues for external contributors
- Use Archon for Claude Code session task tracking
- Optionally sync important issues to Archon

### Do I need all MCP servers?

No. Start with essentials:
- **Archon** - Required for task management
- **Brave Search** - Recommended for web research
- **Serena** - Recommended for code intelligence

Enable others as needed.

### What if validation fails?

Common fixes:
1. **Missing directories**: Run with `-Fix` flag
2. **Invalid JSON**: Check syntax in affected files
3. **Placeholders remaining**: Update CLAUDE.md and config.yaml
4. **Missing pre-commit**: Run `pip install pre-commit && pre-commit install`

### How do I handle merge conflicts?

The v3.0 sync wizard is additive-only and should not create conflicts. It never modifies existing content in CLAUDE.md or README.md. If you encounter unexpected issues:
1. Re-run with `-DryRun` to preview all changes first
2. Keep your project-specific customizations
3. Merge custom rules into CLAUDE.md format

---

## Support

If you encounter issues during migration:

1. Check [FAQ](./FAQ.md)
2. Review [Architecture](./architecture.md)
3. Consult [Customization Guide](./claude-code-customization.md)
4. Open an issue on GitHub

---

*[Back to Documentation Index](./index.md)*
