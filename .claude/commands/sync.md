---
name: sync
description: Sync Claude Code configuration from claude-code-base template using the intelligent wizard
---

# /sync - Sync Claude Code Configuration (v3.0)

Run the sync-claude-code.ps1 intelligent wizard to additively sync Claude Code configuration from the template.

## Key Behaviors

- **Never overwrites** CLAUDE.md or README.md
- Only adds missing sections and fills placeholders in CLAUDE.md
- Only installs skills/commands relevant to the detected project type
- Skips skills already covered by global plugins or global skills
- Interactive wizard for decisions and ambiguous inputs

## Prerequisites

- PowerShell must be available
- The sync script must exist at `scripts/sync-claude-code.ps1`
- The target must be a Git repository

## Steps to Execute

### Step 1: Locate Sync Script and Template

Check if the sync script exists and determine the template path:

```bash
ls -la scripts/sync-claude-code.ps1 2>/dev/null || echo "Sync script not found in current project"
```

### Step 2: Determine Sync Direction

Ask the user to clarify the sync operation:

**Option A: Sync TO this project (update from template)**
- Source: claude-code-base template repository
- Target: Current project directory

**Option B: Sync FROM template (if running from claude-code-base)**
- Source: Current project (must be claude-code-base)
- Target: Another project directory

### Step 3: Run Dry Run First

Always run a dry run to preview the categorized changes:

```powershell
# Sync TO current project
pwsh -File scripts/sync-claude-code.ps1 -TargetPath "." -DryRun

# Sync TO another project
pwsh -File scripts/sync-claude-code.ps1 -TargetPath "[target_path]" -DryRun
```

### Step 4: Review Preview

The wizard shows a categorized preview:

```
PROPOSED CHANGES
================

SKILLS TO INSTALL (12):
  + archon-workflow
  + code-review
  ...

SKILLS SKIPPED (covered by global plugin):
  - playwright-mcp  (covered by: Playwright Plugin)
  - code-reviewer-agent  (covered by: PR Review Toolkit Plugin)

SKILLS SKIPPED (already in project):
  - testing
  - github-actions

COMMANDS TO INSTALL (8):
  + start.md
  + end.md
  ...

CLAUDE.MD UPDATES (additive only, existing content preserved):
  + Section: PRP Framework
  ~ Placeholder filled: [PROJECT_TITLE]

CONFIG FILES:
  + .claude/SESSION_KNOWLEDGE.md (create)
  ~ scripts/sync-claude-code.ps1 (update)

TEMPLATE PROFILE: Will be written/updated in .claude/config.yaml
```

### Step 5: Confirm and Execute

After reviewing the preview, ask user to confirm:

```powershell
pwsh -File scripts/sync-claude-code.ps1 -TargetPath "[target_path]"
```

For non-interactive execution with specific configuration:

```powershell
pwsh -File scripts/sync-claude-code.ps1 -TargetPath "[target_path]" `
    -ProjectType "backend-api" `
    -PrimaryLanguage "python" `
    -Framework "fastapi" `
    -DevFrameworks @("prp") `
    -Force
```

### Step 6: Post-Sync Actions

After sync completes:

1. Review the summary statistics (skills installed, dedup savings, etc.)
2. Review any new config files for project-specific customizations
3. Run validation: `.\scripts\validate-claude-code.ps1`
4. Commit the changes:

```bash
git add .claude .vscode scripts
git commit -m "chore: sync Claude Code configuration from template"
```

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `-TargetPath` | string | Path to the target codebase |
| `-ProjectType` | string | web-frontend, backend-api, fullstack, cli-library, infrastructure |
| `-PrimaryLanguage` | string | typescript, python, csharp, go, java, rust, javascript |
| `-Framework` | string | react, nextjs, fastapi, express, etc. |
| `-DevFrameworks` | string[] | prp, harness, speckit, spark, worktree |
| `-AdditionalSkillGroups` | string[] | ai_ml, smart_home_iot, niche, cloud_infra |
| `-DryRun` | switch | Preview changes without applying |
| `-Force` | switch | Suppress confirmation prompts |
| `-NoBackup` | switch | Skip backup creation |

## Output Format

```
SYNC COMPLETE
=============
Target:  E:\Repos\my-project
Profile: backend-api / python / fastapi

Statistics:
  Skills installed:      12
  Commands installed:    8
  Configs created:       3
  CLAUDE.md sections:    2
  Placeholders filled:   5

Deduplication savings:
  3 skills skipped (covered by global plugins)
  2 skills skipped (installed globally)

Next steps:
  1. Review synced files
  2. Open with Claude Code and run: /start
  3. Commit changes
```

## Error Handling

- If script not found, provide instructions to obtain it from the template
- If target is not a git repository, warn user
- If plugin-skill-map.json is missing, warn and skip plugin dedup (still works)
- If PowerShell not available, suggest alternative approaches
