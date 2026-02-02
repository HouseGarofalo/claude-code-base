[Home](../../README.md) > [Docs](../index.md) > Codespaces Workflow

# GitHub Codespaces Workflow Guide

> **Last Updated**: 2026-02-02
> **Purpose**: Complete guide for using GitHub Codespaces cloud development environments

---

## Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
- [Environment Profiles](#environment-profiles)
- [Common Workflows](#common-workflows)
- [DevContainer Configuration](#devcontainer-configuration)
- [Secrets and Environment Variables](#secrets-and-environment-variables)
- [Cost Management](#cost-management)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Overview

GitHub Codespaces provides cloud-based development environments that work from any device. Benefits include:

| Benefit | Description |
|---------|-------------|
| **Instant Setup** | Pre-configured environments ready in seconds |
| **Consistent** | Same environment for all team members |
| **Powerful** | Up to 32 cores, 64GB RAM |
| **Portable** | Work from any device with a browser |
| **Integrated** | Seamless GitHub integration |

### When to Use Codespaces

Use Codespaces when:
- Complex local setup required
- Limited local hardware
- Reviewing PRs quickly
- Teaching or demos
- Cross-platform development

Use local development when:
- Offline work required
- Handling sensitive data
- Cost constraints apply

---

## Getting Started

### Quick Start

```bash
# Create codespace for current repository
gh codespace create

# Create with specific machine type
gh codespace create -m standardLinux

# Open in VS Code
gh codespace code
```

### From the GitHub UI

1. Navigate to your repository
2. Click **Code** > **Codespaces** tab
3. Click **Create codespace on main**

---

## Environment Profiles

This repository includes pre-configured development environments:

### Available Profiles

| Profile | Location | Best For |
|---------|----------|----------|
| **Standard** | `.devcontainer/devcontainer.json` | General development |
| **Web Frontend** | `.devcontainer/web-frontend/` | React, Vue, Angular |
| **Backend API** | `.devcontainer/backend-api/` | Node, Python with databases |
| **Data Science** | `.devcontainer/data-science/` | Jupyter, ML libraries |
| **.NET** | `.devcontainer/dotnet/` | C#, ASP.NET Core |
| **Go** | `.devcontainer/go/` | Go applications |
| **Rust** | `.devcontainer/rust/` | Rust applications |

### Using a Specific Profile

```bash
# Use web frontend profile
gh codespace create --devcontainer-path .devcontainer/web-frontend/devcontainer.json

# Use backend API profile
gh codespace create --devcontainer-path .devcontainer/backend-api/devcontainer.json

# Use data science profile
gh codespace create --devcontainer-path .devcontainer/data-science/devcontainer.json
```

---

## Common Workflows

### Feature Development

```bash
# 1. Create codespace on feature branch
gh codespace create -r owner/repo -b feature/new-feature

# 2. Open in VS Code
gh codespace code

# 3. Develop normally
npm install
npm run dev

# 4. Commit and push
git add . && git commit -m "feat: add feature"
git push

# 5. Stop when done (saves costs)
gh codespace stop
```

### PR Review

```bash
# 1. Create codespace from PR branch
gh codespace create -r owner/repo -b pr-branch

# 2. Open and test
gh codespace code

# 3. Run tests
npm test

# 4. Test functionality
npm start

# 5. Delete when done
gh codespace delete
```

---

## DevContainer Configuration

### Key Configuration Options

```json
{
  // Base image or Dockerfile
  "image": "mcr.microsoft.com/devcontainers/universal:2",

  // Additional features (languages, tools)
  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/devcontainers/features/python:1": {}
  },

  // VS Code extensions
  "customizations": {
    "vscode": {
      "extensions": ["anthropics.claude-code"]
    }
  },

  // Port forwarding
  "forwardPorts": [3000, 5000],

  // Setup commands
  "postCreateCommand": "npm install"
}
```

### Lifecycle Commands

| Command | When It Runs | Use For |
|---------|--------------|---------|
| `initializeCommand` | Before container build | Local machine setup |
| `onCreateCommand` | Container first created | One-time setup |
| `postCreateCommand` | After container created | Install dependencies |
| `postStartCommand` | Every container start | Start services |
| `postAttachCommand` | VS Code attaches | Welcome messages |

---

## Secrets and Environment Variables

### Setting Secrets

```bash
# Repository-level secret for Codespaces
gh secret set API_KEY --app codespaces

# User-level secret (all your Codespaces)
gh secret set NPM_TOKEN --user
```

### Using Secrets

In `devcontainer.json`:
```json
{
  "containerEnv": {
    "DATABASE_URL": "${localEnv:DATABASE_URL}"
  },
  "secrets": {
    "API_KEY": {
      "description": "API key for external service"
    }
  }
}
```

---

## Cost Management

### Understanding Costs

| Machine Type | vCPUs | RAM | Cost/Hour* |
|--------------|-------|-----|------------|
| Basic | 2 | 8GB | $0.18 |
| Standard | 4 | 16GB | $0.36 |
| Large | 8 | 32GB | $0.72 |
| XL | 16 | 64GB | $1.44 |

*Approximate costs, check GitHub pricing for current rates

### Cost-Saving Strategies

1. **Stop when idle**: `gh codespace stop`
2. **Delete unused**: `gh codespace delete`
3. **Right-size machines**: Don't over-provision
4. **Set idle timeout**: Configure in GitHub settings

### Commands

```bash
# Stop codespace (no charges while stopped)
gh codespace stop

# List and find old codespaces
gh codespace list

# Delete unused codespaces
gh codespace delete -c codespace-name
```

---

## Best Practices

### DO

| Practice | Why |
|----------|-----|
| Use prebuilds | Faster startup |
| Stop when idle | Avoid charges |
| Use right machine size | Don't overpay |
| Configure devcontainer | Consistent environments |
| Use secrets properly | Never hardcode credentials |

### DON'T

| Anti-Pattern | Why |
|--------------|-----|
| Leave running overnight | Wasted money |
| Use XL for simple tasks | Overkill |
| Skip postCreateCommand | Manual setup every time |
| Commit secrets | Security risk |
| Too many codespaces | Clutter and costs |

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Slow startup | Enable prebuilds |
| Build fails | Check postCreateCommand logs |
| Extension not working | Verify extension ID in config |
| Port not accessible | Check forwardPorts configuration |
| Out of storage | Delete files or increase disk |

### Diagnostic Commands

```bash
# View codespace details
gh codespace view -c name

# View logs
gh codespace logs -c name

# SSH for debugging
gh codespace ssh -c name

# Check machine type
gh codespace list --json name,machinetype
```

---

## Quick Reference

### CLI Commands

| Action | Command |
|--------|---------|
| Create | `gh codespace create -r owner/repo` |
| List | `gh codespace list` |
| Open VS Code | `gh codespace code -c name` |
| Open browser | `gh codespace view -c name -w` |
| SSH | `gh codespace ssh -c name` |
| Stop | `gh codespace stop -c name` |
| Delete | `gh codespace delete -c name` |

---

## Related Resources

- [Codespaces Skill](../../.claude/skills/codespaces/SKILL.md)
- [DevContainer Configurations](../../.devcontainer/)
- [GitHub Codespaces Documentation](https://docs.github.com/codespaces)
