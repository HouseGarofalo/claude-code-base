---
name: sync
description: Sync Claude Code configuration from claude-code-base template
---

# /sync - Sync Claude Code Configuration

Run the sync-claude-code.ps1 script to update Claude Code configuration files from the template.

## Prerequisites

- PowerShell must be available
- The sync script must exist at `scripts/sync-claude-code.ps1`
- If syncing FROM a template, the template path must be known

## Steps to Execute

### Step 1: Locate Sync Script

Check if the sync script exists in the current project:

```bash
ls -la scripts/sync-claude-code.ps1 2>/dev/null || echo "Sync script not found in current project"
```

### Step 2: Determine Sync Direction

Ask the user to clarify the sync operation:

**Option A: Sync TO this project (update from template)**
- Source: claude-code-base template repository
- Target: Current project directory

**Option B: Sync FROM this project (if this IS the template)**
- Source: Current project (must be claude-code-base)
- Target: Another project directory

### Step 3: Run Dry Run First

Always run a dry run first to preview changes:

```powershell
# For syncing TO current project
pwsh -File scripts/sync-claude-code.ps1 -TargetPath "." -DryRun

# For syncing TO another project
pwsh -File scripts/sync-claude-code.ps1 -TargetPath "[target_path]" -DryRun
```

### Step 4: Confirm and Execute

After showing the dry run results, ask user to confirm:

```
SYNC PREVIEW
============
Source: [source path]
Target: [target path]

Files to sync:
- .claude/ directory
- .vscode/ directory
- CLAUDE.md
- PRPs/ directory
- .gitattributes
- .pre-commit-config.yaml
- scripts/sync-claude-code.ps1
- scripts/validate-claude-code.ps1

Existing files will be backed up to .claude-backup/

Proceed with sync? (yes/no)
```

If confirmed:

```powershell
pwsh -File scripts/sync-claude-code.ps1 -TargetPath "[target_path]"
```

### Step 5: Post-Sync Actions

After sync completes:

1. Review synced files for project-specific customizations needed
2. Update `.claude/config.yaml` with project-specific values
3. Update `CLAUDE.md` with project-specific context
4. Recommend committing the changes:

```bash
git add .claude .vscode CLAUDE.md PRPs
git commit -m "chore: sync Claude Code configuration from template"
```

## Output Format

```
SYNC OPERATION
==============
Direction: [TO/FROM] current project
Source:    [source path]
Target:    [target path]

[Dry run results or execution results]

NEXT STEPS
----------
1. Review synced files
2. Update config.yaml with project values
3. Customize CLAUDE.md for project
4. Commit changes
```

## Error Handling

- If script not found, provide instructions to obtain it
- If target is not a git repository, warn user
- If PowerShell not available, suggest alternative approaches
