[Home](../README.md) > [Docs](./index.md) > Getting Started

# Getting Started with Claude Code Base

> **Last Updated**: 2026-01-23 | **Status**: Final

This guide walks you through setting up a new project using the Claude Code Base template.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Option 1: Using the Project Wizard (Recommended)](#option-1-using-the-project-wizard-recommended)
- [Option 2: Manual Clone](#option-2-manual-clone)
- [Post-Setup Configuration](#post-setup-configuration)
- [First Steps](#first-steps)
- [Syncing to Existing Projects](#syncing-to-existing-projects)
- [Validating Your Setup](#validating-your-setup)

---

## Prerequisites

Before setting up your project, ensure you have the following installed:

### Required

| Tool | Minimum Version | Installation |
|------|-----------------|--------------|
| **Git** | 2.30+ | [git-scm.com](https://git-scm.com/) |
| **GitHub CLI** | 2.0+ | [cli.github.com](https://cli.github.com/) |
| **Python** | 3.9+ | [python.org](https://www.python.org/) |
| **Node.js** | 18+ | [nodejs.org](https://nodejs.org/) |

### Recommended

| Tool | Purpose |
|------|---------|
| **VS Code** | IDE with Claude Code extension |
| **pre-commit** | Automated security scanning |
| **uv/uvx** | Fast Python package management |

### Verify Installation

```powershell
# Check versions
git --version          # Should be 2.30+
gh --version           # Should be 2.0+
python --version       # Should be 3.9+
node --version         # Should be 18+

# Verify GitHub CLI authentication
gh auth status         # Should show "Logged in"
```

---

## Option 1: Using the Project Wizard (Recommended)

The interactive wizard automates project creation with full configuration.

### Step 1: Clone the Template

```powershell
git clone https://github.com/HouseGarofalo/claude-code-base.git
cd claude-code-base
```

### Step 2: Run the Wizard

```powershell
.\scripts\setup-claude-code-project.ps1
```

### Step 3: Follow the Prompts

The wizard guides you through several stages:

1. **Parent directory**: Where to create the project (e.g., `E:\Repos`)
2. **Project name**: Lowercase with hyphens (e.g., `my-awesome-app`)
3. **Description**: Brief description of the project
4. **Project type**: web-frontend, backend-api, fullstack, cli-library, or infrastructure
5. **Primary language**: Options vary by project type (e.g., TypeScript, Python, C#, Go, Rust, Java)
6. **Framework**: Options vary by type + language (e.g., React, FastAPI, Next.js, ASP.NET Core)
7. **Development frameworks** (optional): PRP, Harness, SpecKit, Spark, Worktree
8. **GitHub organization**: Your GitHub org or username
9. **Repository visibility**: private or public
10. **Archon integration**: Whether to set up task management

### Selective Setup (v2.0)

The wizard now performs **intelligent selective copying** based on your choices:

- **Skills**: Only relevant skills are copied from 150+ available. For example, a Python backend project gets `core` + `backend` skills (~50), not all 150+.
- **Commands**: Only matching command groups are copied. Dev framework commands (PRP, Harness, etc.) are included only if selected.
- **README.md**: Generated from a project-type-specific template with your language and framework filled in.
- **CLAUDE.md**: Generated from a template with conditional sections. PRP/Harness/SpecKit documentation is only included if those frameworks were selected.
- **.gitignore**: Built from a base template plus language-specific rules (Python, Node.js, C#, Go, Rust, Java).
- **template_profile**: Written to `.claude/config.yaml` to track your selections for future sync/update operations.

### What the Wizard Does

1. Gathers project info, language, framework, and dev framework preferences
2. Selectively copies only relevant skills and commands
3. Generates project-specific README.md and CLAUDE.md
4. Builds language-appropriate .gitignore
5. Initializes Git repository and installs pre-commit hooks
6. Creates GitHub repository with branch protection (optional)
7. Prepares Archon project configuration (optional)
8. Writes `template_profile` to config.yaml for sync tracking

### Wizard Options

```powershell
# Full interactive mode
.\scripts\setup-claude-code-project.ps1

# Skip GitHub creation
.\scripts\setup-claude-code-project.ps1 -SkipGitHub

# Skip Archon setup
.\scripts\setup-claude-code-project.ps1 -SkipArchon

# Non-interactive mode with language/framework
.\scripts\setup-claude-code-project.ps1 -NonInteractive `
    -ParentPath "E:\Repos" `
    -ProjectName "my-api" `
    -GitHubOrg "MyOrg" `
    -ProjectType "backend-api" `
    -PrimaryLanguage "python" `
    -Framework "fastapi"
```

---

## Option 2: Manual Clone

For more control over the setup process:

### Step 1: Clone the Template

```powershell
# Clone to your desired location
git clone https://github.com/HouseGarofalo/claude-code-base.git my-project
cd my-project

# Remove the original git history
Remove-Item -Recurse -Force .git

# Initialize fresh repository
git init
```

### Step 2: Update Configuration Files

Edit the following files and replace placeholders:

#### `.claude/config.yaml`

```yaml
archon_project_id: "YOUR-UUID-HERE"  # Get from Archon
project_title: "My Project"
github_repo: "https://github.com/YourOrg/my-project"
local_path: "E:\Repos\YourOrg\my-project"
```

#### `CLAUDE.md`

Replace these placeholders:
- `[ARCHON_PROJECT_ID]` - Your Archon project UUID
- `[PROJECT_TITLE]` - Human-readable project name
- `[GITHUB_REPO]` - GitHub repository URL
- `[REPOSITORY_PATH]` - Local filesystem path
- `[PRIMARY_STACK]` - Technologies used (e.g., "TypeScript, React")

### Step 3: Install Pre-commit Hooks

```powershell
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install
pre-commit install --hook-type commit-msg
```

### Step 4: Create Initial Commit

```powershell
git add .
git commit -m "feat: initial project setup from claude-code-base template"
```

### Step 5: Create GitHub Repository (Optional)

```powershell
gh repo create YourOrg/my-project --private --source=. --push
```

---

## Post-Setup Configuration

After initial setup, complete these configuration steps:

### 1. Create Archon Project (if using Archon)

In Claude Code, run:

```python
manage_project("create",
    title="My Project",
    description="Project description here",
    github_repo="https://github.com/YourOrg/my-project"
)
```

Copy the returned `project_id` and update `.claude/config.yaml`.

### 2. Set Up Environment Variables

Create a `.env` file (or use `~/.claude/.env` globally):

```bash
# Required for Brave Search MCP
BRAVE_API_KEY=your-brave-api-key

# Optional - add as needed
DATABASE_URL=postgresql://...
OPENAI_API_KEY=sk-...
```

### 3. Configure MCP Servers

Edit `.vscode/mcp.json` to enable/disable MCP servers:

```json
{
  "servers": {
    "archon": {
      "url": "http://localhost:8051/mcp",
      "type": "http"
    },
    "brave-search": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@anthropic-ai/mcp-server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    }
  }
}
```

### 4. Customize CLAUDE.md

See [Customization Guide](./claude-code-customization.md) for detailed instructions.

---

## First Steps

Once your project is set up:

### 1. Open in VS Code

```powershell
code path/to/your-project
```

### 2. Start a Claude Code Session

In Claude Code, type:

```
/start
```

This executes the startup protocol:
- Loads project configuration
- Connects to Archon
- Reviews git status
- Provides session briefing

### 3. Review the Setup

Claude will provide a status briefing. Address any issues:

- **Config missing**: Update `.claude/config.yaml`
- **Archon not connected**: Ensure MCP server is running
- **Placeholders remaining**: Update CLAUDE.md

### 4. Create Your First Task

```
/prp-plan "implement basic project structure"
```

Or directly via Archon:

```python
manage_task("create",
    project_id="your-project-id",
    title="Set up project structure",
    description="Create initial folders and configuration",
    feature="setup"
)
```

---

## Syncing to Existing Projects

To add Claude Code Base configuration to an existing project:

### Using the Sync Script

```powershell
# Navigate to claude-code-base
cd path/to/claude-code-base

# Run sync
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\existing-project"
```

### Sync Options

```powershell
# Preview what would be synced (no changes)
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\project" -DryRun

# Skip backup creation
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\project" -NoBackup

# Force (no confirmation prompts)
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\project" -Force
```

### What Gets Synced

**If your project has a `template_profile`** (created by the setup wizard v2.0):
- Core `.claude/` config files (config.yaml, settings.json, hooks, context)
- `.vscode/` directory (settings, MCP config)
- **Only skills matching your declared `skill_groups`**
- **Only commands matching your declared `command_groups`**
- `.gitattributes` and `.pre-commit-config.yaml`
- Sync, validation, and update scripts
- `PRPs/` directory (only if PRP dev framework was selected)

**If your project has no `template_profile`** (legacy projects):
- Full `.claude/` directory (all skills, commands, config)
- `.vscode/` directory
- `CLAUDE.md`
- `PRPs/` directory
- `.gitattributes` and `.pre-commit-config.yaml`
- Sync and validation scripts

### After Syncing

1. Update placeholders in CLAUDE.md (legacy projects only)
2. Configure `.claude/config.yaml` (legacy projects only)
3. Review and customize MCP servers
4. Run validation: `.\scripts\validate-claude-code.ps1`

### Adding Skills Later

To add skills from the template that weren't included in your initial setup:

1. Copy the desired skill folder from the template's `.claude/skills/` to your project
2. Update `skill_groups` in your `.claude/config.yaml` template_profile to include the new group
3. Future syncs will include the new skills automatically

---

## Validating Your Setup

Run the validation script to check your configuration:

```powershell
.\scripts\validate-claude-code.ps1
```

### Validation Checks

| Check | Description |
|-------|-------------|
| Required directories | `.claude/`, `.vscode/`, `PRPs/`, etc. |
| Required files | `CLAUDE.md`, config files |
| JSON syntax | Settings files are valid JSON |
| Pre-commit config | gitleaks and detect-secrets configured |
| CLAUDE.md placeholders | No unconfigured placeholders |
| Archon connection | Project ID configured |
| Template profile | `template_profile` section exists with required fields |
| Dev framework consistency | Declared dev frameworks match directory structure |

### Fixing Issues

```powershell
# Auto-fix where possible
.\scripts\validate-claude-code.ps1 -Fix

# Verbose output
.\scripts\validate-claude-code.ps1 -Verbose
```

### Expected Output

```
========================================
 Claude Code Base Validator
========================================
Path: E:\Repos\my-project
Fix Mode: False

[1/10] Checking Required Directories...
[PASS] All directories present

[2/10] Checking Required Files...
[PASS] All files present

...

[8/10] Validating Template Profile...
[PASS] template_profile section found

[9/10] Checking Dev Framework Consistency...
[INFO] No dev frameworks declared

[10/10] Generating Optimization Suggestions...
[PASS] No optimization suggestions

========================================
 Validation Summary
========================================

Assets Found:
   Skills:   36
   Commands: 36

[PASS] All validation checks passed!
```

---

## Next Steps

- [Customize CLAUDE.md](./claude-code-customization.md) for your project
- [Configure MCP servers](./mcp-dependencies.md) for enhanced capabilities
- [Review the architecture](./architecture.md) to understand the template
- [Learn the PRP framework](../PRPs/README.md) for structured development

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| `gh auth status` fails | Run `gh auth login` |
| Pre-commit hooks fail | Ensure Python is in PATH |
| MCP server not connecting | Check server is running on correct port |
| Placeholders not replaced | Run wizard again or manually update files |

For more troubleshooting help, see [FAQ](./FAQ.md).

---

*[Back to Documentation Index](./index.md)*
