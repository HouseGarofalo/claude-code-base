[Home](../README.md) > [Docs](./index.md) > Deployment Guide

# Deployment Guide

> **Last Updated**: 2026-02-02 | **Status**: Final

This guide covers deploying the Claude Code Base template to new projects, deploying skills globally, team-wide deployment strategies, and CI/CD integration.

---

## Table of Contents

- [Deploying the Template](#deploying-the-template)
- [Deploying Skills Globally](#deploying-skills-globally)
- [Deploying to Teams](#deploying-to-teams)
- [CI/CD Integration](#cicd-integration)
- [Cloud and Remote Deployment](#cloud-and-remote-deployment)
- [Versioning and Updates](#versioning-and-updates)

---

## Deploying the Template

### Option 1: Using the Project Wizard (Recommended)

The `setup-claude-code-project.ps1` script provides an interactive wizard for creating new projects.

```powershell
# Navigate to the template directory
cd E:\Repos\HouseGarofalo\claude-code-base

# Run the wizard
.\scripts\setup-claude-code-project.ps1
```

The wizard will:

1. Check prerequisites (Git, GitHub CLI, Python)
2. Prompt for project details (name, path, type, GitHub org)
3. Copy template files to the new project
4. Initialize Git repository with pre-commit hooks
5. Create GitHub repository with branch protection (optional)
6. Replace placeholders in configuration files
7. Set up Archon project linkage (optional)

**Non-Interactive Mode:**

```powershell
.\scripts\setup-claude-code-project.ps1 `
    -NonInteractive `
    -ParentPath "E:\Repos" `
    -ProjectName "my-new-api" `
    -Description "My new API project" `
    -ProjectType "backend-api" `
    -GitHubOrg "MyOrganization" `
    -Visibility "private"
```

**Skipping Optional Steps:**

```powershell
# Skip GitHub repository creation
.\scripts\setup-claude-code-project.ps1 -SkipGitHub

# Skip Archon project creation
.\scripts\setup-claude-code-project.ps1 -SkipArchon

# Skip both
.\scripts\setup-claude-code-project.ps1 -SkipGitHub -SkipArchon
```

### Option 2: Manual Deployment

If you prefer manual control over the deployment process:

**Step 1: Copy Template Files**

```powershell
# Create project directory
mkdir E:\Repos\my-project
cd E:\Repos\my-project

# Copy template (excluding git history and generated files)
robocopy "E:\Repos\HouseGarofalo\claude-code-base" "." /E /XD ".git" "node_modules" "__pycache__" ".venv" "temp"
```

**Step 2: Initialize Git**

```bash
git init
git add .
git commit -m "feat: initial project setup from claude-code-base template"
```

**Step 3: Install Pre-commit Hooks**

```bash
pip install pre-commit
pre-commit install
pre-commit install --hook-type commit-msg
```

**Step 4: Update Configuration Files**

Edit the following files to replace placeholders:

| File | Placeholders to Replace |
|------|-------------------------|
| `CLAUDE.md` | `[ARCHON_PROJECT_ID]`, `[PROJECT_TITLE]`, `[GITHUB_REPO]`, `[REPOSITORY_PATH]` |
| `.claude/config.yaml` | `archon_project_id`, `project_title`, `local_path`, `github_repo` |
| `.claude/SESSION_KNOWLEDGE.md` | Project-specific context |

**Step 5: Create GitHub Repository (Optional)**

```bash
gh repo create my-org/my-project --private --source=. --push
```

### What Gets Deployed

| Component | Purpose |
|-----------|---------|
| `CLAUDE.md` | Main Claude Code instructions |
| `.claude/` | Configuration, commands, skills, session tracking |
| `.vscode/` | VS Code settings, MCP configuration |
| `PRPs/` | PRP framework templates |
| `scripts/` | Utility scripts (validation, sync) |
| `docs/` | Documentation |
| `.github/` | Issue templates, PR templates |
| `.pre-commit-config.yaml` | Security scanning hooks |
| `.gitignore` | Standard ignores |
| `.gitattributes` | Git configuration |

---

## Deploying Skills Globally

Skills deployed to `~/.claude/skills/` are available across all projects.

### Using deploy-skills.ps1

```powershell
# Deploy all skills from the template
.\scripts\deploy-skills.ps1

# Preview what would be deployed (dry run)
.\scripts\deploy-skills.ps1 -DryRun

# Deploy only specific category
.\scripts\deploy-skills.ps1 -Category "devops"
.\scripts\deploy-skills.ps1 -Category "ai-development"

# Force overwrite without prompts
.\scripts\deploy-skills.ps1 -Force

# Skip backup creation
.\scripts\deploy-skills.ps1 -NoBackup
```

### Manual Skill Deployment

```powershell
# Copy single skill
Copy-Item -Recurse ".\.claude\skills\archon-workflow" "$env:USERPROFILE\.claude\skills\"

# Copy all skills from a category
Copy-Item -Recurse ".\.claude\skills\devops\*" "$env:USERPROFILE\.claude\skills\"

# Verify deployment
Get-ChildItem "$env:USERPROFILE\.claude\skills"
```

### Selective Deployment by Category

The template organizes skills into categories:

| Category | Skills |
|----------|--------|
| `ai-development` | langchain, llamaindex, pydantic-ai, crewai |
| `cloud` | aws-lambda, azure-ai, azure-aks, cloudflare |
| `devops` | docker-compose, kubernetes-helm, bicep |
| `frontend` | react-typescript, nextjs-app-router, svelte-kit, vue-typescript |
| `networking` | nginx-proxy, haproxy, adguard-home |
| `productivity` | obsidian, excalidraw, markitdown |
| `web-automation` | playwright-mcp, web-automation |
| `data-visualization` | grafana-dashboards, streamlit-dashboards |

```powershell
# Deploy multiple categories
@("devops", "cloud", "ai-development") | ForEach-Object {
    .\scripts\deploy-skills.ps1 -Category $_ -Force
}
```

### Verifying Skill Deployment

```powershell
# List deployed skills
Get-ChildItem "$env:USERPROFILE\.claude\skills" -Directory | Select-Object Name

# Test skills for valid structure
.\tests\test-skills.ps1 -SkillsPath "$env:USERPROFILE\.claude\skills"

# In Claude Code, verify with:
# Claude will auto-discover skills in ~/.claude/skills/
```

---

## Deploying to Teams

### Sharing Skills Across Team Members

**Option 1: Git Repository Distribution**

1. Create a dedicated skills repository:

```bash
gh repo create my-org/claude-skills --private
cd claude-skills
git init

# Copy skills
cp -r ../claude-code-base/.claude/skills/* ./skills/

# Add deployment script
cp ../claude-code-base/scripts/deploy-skills.ps1 ./scripts/

git add .
git commit -m "feat: initial skill library"
git push -u origin main
```

2. Team members clone and deploy:

```bash
git clone https://github.com/my-org/claude-skills.git
cd claude-skills
.\scripts\deploy-skills.ps1
```

**Option 2: Network Share Distribution**

```powershell
# Copy to network share
Copy-Item -Recurse ".\.claude\skills\*" "\\server\share\claude-skills\"

# Team members deploy from share
robocopy "\\server\share\claude-skills" "$env:USERPROFILE\.claude\skills" /E
```

### Organization-Wide Deployment

**Using Group Policy (Windows Domains)**

1. Create a startup script that deploys skills:

```powershell
# deploy-claude-skills.ps1 (placed on SYSVOL)
$Source = "\\domain.com\SYSVOL\domain.com\claude-skills"
$Dest = "$env:USERPROFILE\.claude\skills"

if (-not (Test-Path $Dest)) {
    New-Item -ItemType Directory -Path $Dest -Force
}

robocopy $Source $Dest /E /MIR /R:1 /W:1 /LOG:NUL
```

2. Assign via Group Policy Object (GPO) as a logon script

**Using Enterprise Software Deployment**

Package the skills as an MSIX or MSI for deployment via:
- Microsoft Intune
- SCCM/ConfigMgr
- PDQ Deploy
- Similar tools

### Enterprise Templates

Create standardized project templates for different use cases:

```
enterprise-templates/
├── backend-api/           # API project template
│   ├── CLAUDE.md
│   ├── .claude/
│   └── ...
├── frontend-app/          # Frontend project template
│   ├── CLAUDE.md
│   ├── .claude/
│   └── ...
├── fullstack/             # Full-stack template
├── infrastructure/        # IaC template
└── shared/
    ├── skills/            # Organization-approved skills
    └── commands/          # Standard commands
```

Each template can include:
- Organization-specific CLAUDE.md instructions
- Pre-approved skills and commands
- Configured MCP servers
- Security policies

---

## CI/CD Integration

### GitHub Actions for Template Validation

Create `.github/workflows/validate-template.yml`:

```yaml
name: Validate Template

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: windows-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install pre-commit
        run: pip install pre-commit

      - name: Validate YAML files
        run: |
          Get-ChildItem -Recurse -Filter "*.yaml" | ForEach-Object {
            Write-Host "Validating: $($_.FullName)"
            python -c "import yaml; yaml.safe_load(open('$($_.FullName)'))"
          }
        shell: pwsh

      - name: Validate Skills
        run: .\tests\test-skills.ps1 -SkillsPath ".\.claude\skills"
        shell: pwsh

      - name: Run Template Tests
        run: .\tests\test-template.ps1
        shell: pwsh

      - name: Check for secrets
        run: |
          pip install detect-secrets
          detect-secrets scan --baseline .secrets.baseline
        shell: pwsh
```

### Automated Skill Deployment

Create a workflow that deploys skills on release:

```yaml
name: Deploy Skills

on:
  release:
    types: [published]

jobs:
  deploy:
    runs-on: windows-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Validate Skills
        run: .\tests\test-skills.ps1 -SkillsPath ".\.claude\skills"
        shell: pwsh

      - name: Package Skills
        run: |
          Compress-Archive -Path ".\.claude\skills\*" -DestinationPath "skills-${{ github.ref_name }}.zip"
        shell: pwsh

      - name: Upload Release Asset
        uses: softprops/action-gh-release@v1
        with:
          files: skills-${{ github.ref_name }}.zip
```

### Pre-commit Hooks in CI

The template includes pre-commit configuration for CI:

```yaml
# In your CI workflow
- name: Run pre-commit
  run: |
    pip install pre-commit
    pre-commit run --all-files
```

**Required Hooks:**

| Hook | Purpose |
|------|---------|
| `gitleaks` | Detect hardcoded secrets |
| `detect-secrets` | Baseline-aware secret detection |
| `trailing-whitespace` | Remove trailing whitespace |
| `end-of-file-fixer` | Ensure newline at end of files |
| `check-yaml` | Validate YAML syntax |
| `check-json` | Validate JSON syntax |
| `check-added-large-files` | Prevent large file commits |

---

## Cloud and Remote Deployment

### GitHub Codespaces Setup

Create `.devcontainer/devcontainer.json`:

```json
{
  "name": "Claude Code Base",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",

  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.11"
    },
    "ghcr.io/devcontainers/features/node:1": {
      "version": "lts"
    },
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },

  "postCreateCommand": "pip install pre-commit && pre-commit install",

  "customizations": {
    "vscode": {
      "extensions": [
        "anthropics.claude-code"
      ],
      "settings": {
        "editor.formatOnSave": true
      }
    }
  },

  "mounts": [
    "source=${localWorkspaceFolder}/.vscode/mcp.json,target=/home/vscode/.claude/mcp.json,type=bind"
  ]
}
```

### DevContainer Deployment

Create `.devcontainer/Dockerfile`:

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install prerequisites
RUN apt-get update && apt-get install -y \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install pre-commit
RUN pip3 install pre-commit

# Set up Claude Code directory
RUN mkdir -p /home/vscode/.claude/skills

# Copy default skills (during build)
COPY .claude/skills/ /home/vscode/.claude/skills/

# Set permissions
RUN chown -R vscode:vscode /home/vscode/.claude
```

### Remote Development Considerations

When developing remotely, consider:

| Aspect | Consideration |
|--------|---------------|
| **MCP Servers** | Some MCP servers require local access; configure alternatives for remote |
| **Credentials** | Use environment variables or secret managers, never commit credentials |
| **File Paths** | Use relative paths in CLAUDE.md where possible |
| **Performance** | Codespaces may have different performance characteristics |
| **Networking** | Some skills may need network access; ensure firewall rules allow this |

**Remote MCP Configuration:**

```json
{
  "mcpServers": {
    "archon": {
      "type": "stdio",
      "command": "uvx",
      "args": ["--from", "archon-ai", "archon"],
      "env": {
        "DATABASE_URL": "${ARCHON_DATABASE_URL}",
        "ARCHON_API_KEY": "${ARCHON_API_KEY}"
      }
    }
  }
}
```

---

## Versioning and Updates

### Template Versioning Strategy

The template follows [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes to CLAUDE.md structure, command interfaces, or skill formats
- **MINOR**: New features, new skills, new commands (backward compatible)
- **PATCH**: Bug fixes, documentation updates, minor improvements

**Version is tracked in:**

- `.claude/config.yaml` (`template_version`)
- `docs/index.md` (documentation reference)
- `CHANGELOG.md` (detailed changes)

### Using update-project.ps1

The update script allows selective updates from the template:

```powershell
# Preview all changes (dry run)
.\scripts\update-project.ps1 -TargetPath "E:\Repos\my-project" -DryRun

# Update everything
.\scripts\update-project.ps1 -TargetPath "E:\Repos\my-project" -UpdateType all

# Update only specific components
.\scripts\update-project.ps1 -TargetPath "E:\Repos\my-project" -UpdateType claude-config
.\scripts\update-project.ps1 -TargetPath "E:\Repos\my-project" -UpdateType scripts
.\scripts\update-project.ps1 -TargetPath "E:\Repos\my-project" -UpdateType docs
```

**Update Types:**

| Type | Components Updated |
|------|-------------------|
| `all` | Everything below |
| `claude-config` | `.claude/`, `CLAUDE.md` |
| `vscode` | `.vscode/` |
| `prps` | `PRPs/` templates |
| `scripts` | `scripts/` utilities |
| `docs` | `docs/` documentation |
| `github` | `.github/`, `.pre-commit-config.yaml`, `.gitattributes` |

**Options:**

```powershell
# Force update without prompts
.\scripts\update-project.ps1 -TargetPath "E:\Repos\my-project" -Force

# Attempt to merge changes (for critical files)
.\scripts\update-project.ps1 -TargetPath "E:\Repos\my-project" -Merge

# Skip backup creation (not recommended)
.\scripts\update-project.ps1 -TargetPath "E:\Repos\my-project" -NoBackup
```

### Handling Breaking Changes

When upgrading across major versions:

1. **Review the CHANGELOG** for breaking changes
2. **Backup your project** before updating
3. **Run update with dry-run** first to see changes
4. **Update incrementally** if multiple major versions behind
5. **Test thoroughly** after updating

**Example Migration:**

```powershell
# 1. Check current version
Get-Content ".\.claude\config.yaml" | Select-String "template_version"

# 2. Review changes
Get-Content "E:\Repos\HouseGarofalo\claude-code-base\CHANGELOG.md"

# 3. Backup
git commit -am "chore: backup before template update"
git tag "pre-update-backup"

# 4. Dry run
.\scripts\update-project.ps1 -TargetPath "." -DryRun

# 5. Apply update
.\scripts\update-project.ps1 -TargetPath "." -UpdateType all

# 6. Verify and commit
.\scripts\validate-claude-code.ps1
git add .
git commit -m "chore: update from claude-code-base template v2.0.0"
```

### Keeping Skills Up to Date

For global skills deployment:

```powershell
# Check for skill updates
cd E:\Repos\HouseGarofalo\claude-code-base
git pull

# Redeploy skills
.\scripts\deploy-skills.ps1 -Force
```

---

## Related Documents

- [Getting Started](./getting-started.md)
- [Architecture](./architecture.md)
- [MCP Dependencies](./mcp-dependencies.md)
- [Migration Guide](./migration-guide.md)
- [Contributing](../CONTRIBUTING.md)

---

*[Back to Documentation Index](./index.md)*
