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

The wizard will ask for:

1. **Parent directory**: Where to create the project (e.g., `E:\Repos`)
2. **Project name**: Lowercase with hyphens (e.g., `my-awesome-app`)
3. **Description**: Brief description of the project
4. **Project type**: web-frontend, backend-api, fullstack, cli-library, or infrastructure
5. **GitHub organization**: Your GitHub org or username
6. **Repository visibility**: private or public
7. **Archon integration**: Whether to set up task management

### What the Wizard Does

1. Creates project directory with template files
2. Initializes Git repository
3. Installs pre-commit hooks
4. Replaces placeholders in configuration files
5. Creates GitHub repository (optional)
6. Enables branch protection and secret scanning (optional)
7. Prepares Archon project configuration

### Wizard Options

```powershell
# Full interactive mode
.\scripts\setup-claude-code-project.ps1

# Skip GitHub creation
.\scripts\setup-claude-code-project.ps1 -SkipGitHub

# Skip Archon setup
.\scripts\setup-claude-code-project.ps1 -SkipArchon

# Non-interactive mode
.\scripts\setup-claude-code-project.ps1 -NonInteractive `
    -ParentPath "E:\Repos" `
    -ProjectName "my-api" `
    -GitHubOrg "MyOrg" `
    -ProjectType "backend-api"
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

- `.claude/` directory (commands, skills, config)
- `.vscode/` directory (settings, MCP config)
- `CLAUDE.md`
- `PRPs/` directory (templates)
- `.gitattributes`
- `.pre-commit-config.yaml`
- Sync and validation scripts

### After Syncing

1. Update placeholders in CLAUDE.md
2. Configure `.claude/config.yaml`
3. Review and customize MCP servers
4. Run validation: `.\scripts\validate-claude-code.ps1`

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

[1/8] Checking Required Directories...
[PASS] All directories present

[2/8] Checking Required Files...
[PASS] All files present

...

========================================
 Validation Summary
========================================

Assets Found:
   Skills:   8
   Commands: 9

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
