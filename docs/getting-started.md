[Home](../README.md) > [Docs](./index.md) > Getting Started

# Getting Started with Claude Code Base

> **Last Updated**: 2026-02-18 | **Status**: Final

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
4. **Project type**: web-frontend, backend-api, fullstack, cli-library, infrastructure, or power-platform
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

The intelligent sync wizard (v3.0) provides additive-only sync to existing projects. It **never overwrites** your CLAUDE.md or README.md.

### Using the Sync Script

```powershell
# Navigate to claude-code-base
cd path/to/claude-code-base

# Run the intelligent sync wizard
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\existing-project"
```

### How It Works (10-Step Flow)

The sync wizard walks through these steps:

| Step | What Happens |
|------|-------------|
| **0. Prerequisites** | Validates git, loads manifest.json and plugin-skill-map.json |
| **1. Load State** | Scans target for existing skills, commands, CLAUDE.md, config.yaml |
| **2. Detect Config** | If `template_profile` exists, shows detected values for confirmation |
| **3. Wizard** | Interactive prompts for project type, language, framework, dev frameworks, additional skill groups |
| **4. Calculate Delta** | Expands selections into full candidate skill/command list via manifest |
| **5. Global Dedup** | Reads `~/.claude/settings.json` for plugins, scans `~/.claude/skills/`. Categorizes each skill as: to-install, skip-plugin, partial-plugin, skip-global, skip-exists |
| **6. CLAUDE.md Analysis** | Parses into sections, finds missing ones, scans for unfilled `[PLACEHOLDER]` patterns, auto-detects values (git remote, dir name, date), prompts for rest |
| **7. Preview** | Shows categorized diff of all proposed changes |
| **8. Approval** | User confirms. DryRun exits here. Force skips the prompt |
| **9. Execute** | Copies approved skills/commands, merges CLAUDE.md (additive), creates config files, writes template_profile |
| **10. Summary** | Statistics, dedup savings, next steps |

### Sync Options

```powershell
# Preview all changes (no modifications)
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\project" -DryRun

# Pre-specify project configuration
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\project" `
    -ProjectType "backend-api" `
    -PrimaryLanguage "python" `
    -Framework "fastapi"

# Include additional skill groups
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\project" `
    -AdditionalSkillGroups @("ai_ml", "cloud_infra")

# Include dev frameworks
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\project" `
    -DevFrameworks @("prp", "harness")

# Non-interactive (requires params or existing profile)
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\project" -Force

# Skip backup creation
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\project" -NoBackup
```

### What Gets Synced (and What Doesn't)

| File / Directory | Behavior |
|-----------------|----------|
| **CLAUDE.md** | Additive only - adds missing sections, fills placeholders, never modifies existing content |
| **README.md** | Never touched |
| **.claude/config.yaml** | Appends/updates `template_profile` section only |
| **.claude/settings.json** | Never overwritten |
| **.claude/hooks/, context/** | Copies only files that don't exist |
| **.claude/SESSION_KNOWLEDGE.md, DEVELOPMENT_LOG.md** | Created only if missing |
| **.vscode/extensions.json** | Created only if missing |
| **.vscode/settings.json** | Never overwritten |
| **.gitattributes, .pre-commit-config.yaml** | Created only if missing |
| **scripts/sync-claude-code.ps1, validate-claude-code.ps1, update-project.ps1** | Always updated (self-update) |
| **PRPs/** | Only if PRP dev framework selected AND no PRPs/ directory exists |
| **Skills** | Only relevant ones not already installed, not covered by global plugins/skills |
| **Commands** | Only relevant ones not already installed |

### Global Plugin Deduplication

The sync wizard reads your global Claude Code configuration to avoid installing redundant skills:

- **Global plugins** (`~/.claude/settings.json`): If a plugin (e.g., `code-review`, `playwright`) already covers a local skill, it's skipped
- **Partial overlap**: When a plugin partially covers a skill, the wizard recommends installing the local skill but shows a note about the overlap
- **Global skills** (`~/.claude/skills/`): Skills already installed globally are skipped
- **Existing skills**: Skills already in the target project are never re-installed

The mapping is defined in `templates/plugin-skill-map.json`.

### CLAUDE.md Smart Merge

When syncing to a project that already has a CLAUDE.md:

1. Both files are parsed into `##` sections
2. Template conditional sections (`<!-- IF PRP -->` etc.) are filtered based on selected dev frameworks
3. Missing sections are identified and inserted at the correct canonical position
4. Unfilled `[PLACEHOLDER]` patterns are detected
5. Auto-detectable values (git remote URL, directory name, date) are filled automatically
6. Remaining placeholders are prompted via wizard
7. **Existing content is never modified**

### Adding Skills Later

Re-run the sync wizard with different options:

```powershell
# Add AI/ML skills to an existing project
.\scripts\sync-claude-code.ps1 -TargetPath "E:\Repos\project" `
    -AdditionalSkillGroups @("ai_ml")
```

The wizard will detect your existing configuration and only install the new skills. Skills already present in the project, globally, or covered by plugins are skipped automatically.

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
