---
description: Create a new GitHub Codespace with optimal configuration
---

# Create Codespace

Create a new GitHub Codespace with the right configuration for your project.

## Arguments

$ARGUMENTS

---

## Configuration Process

### 1. Gather Project Info

- Repository URL or name
- Project type (frontend, backend, full-stack, data science)
- Any special requirements?

### 2. Recommend Configuration

- Suggest appropriate machine type
- Recommend devcontainer profile if available
- Identify any secrets needed

### 3. Generate Commands

Provide the exact `gh codespace create` command.

### 4. Post-Creation Steps

List any setup commands to run after creation.

---

## Machine Type Guide

| Project Type | Machine | Command Flag |
|--------------|---------|--------------|
| Docs/Simple | Basic (2 core) | `-m basicLinux` |
| Web Apps | Standard (4 core) | `-m standardLinux` |
| Full-Stack | Standard (4 core) | `-m standardLinux` |
| Multi-service | Large (8 core) | `-m premiumLinux` |
| Data Science | XL (16 core) | `-m largePremiumLinux` |

---

## Create Commands

### Basic Creation

```bash
gh codespace create -r {owner}/{repo} -m standardLinux
```

### With Specific Branch

```bash
gh codespace create -r {owner}/{repo} -b {branch-name} -m standardLinux
```

### With DevContainer Profile

```bash
gh codespace create -r {owner}/{repo} -m standardLinux \
  --devcontainer-path .devcontainer/{profile}/devcontainer.json
```

### With Retention Period

```bash
gh codespace create -r {owner}/{repo} -m standardLinux \
  --retention-period 72h
```

---

## After Creation

```bash
# Open in VS Code
gh codespace code

# Open in browser
gh codespace code -w

# List your codespaces
gh codespace list

# Connect via SSH
gh codespace ssh
```

---

## Management Commands

```bash
# Stop codespace (saves costs)
gh codespace stop

# Delete codespace
gh codespace delete

# View codespace details
gh codespace view

# Forward a port
gh codespace ports forward 3000:3000
```

---

## Cost Optimization Tips

- Set idle timeout in GitHub Settings
- Use `gh codespace stop` when taking breaks
- Enable prebuilds for faster future startups
- Choose appropriate machine size for workload
- Delete unused codespaces regularly

---

## DevContainer Configuration

If no devcontainer exists, create one:

```json
// .devcontainer/devcontainer.json
{
  "name": "Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/devcontainers/features/python:1": {}
  },
  "postCreateCommand": "npm install",
  "customizations": {
    "vscode": {
      "extensions": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode"
      ]
    }
  }
}
```
