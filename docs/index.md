# Claude Code Base Documentation

> A standardized template for Claude Code projects with Archon integration, security scanning, and best practices.

---

## Welcome

Welcome to the Claude Code Base documentation. This template provides a production-ready foundation for any project using Claude Code, including:

- Pre-configured CLAUDE.md with Archon integration
- Session management commands (`/start`, `/status`, `/end`)
- PRP (Product Requirement Prompt) framework for structured development
- Security scanning via pre-commit hooks
- MCP server configuration for enhanced capabilities

---

## Quick Navigation

### Getting Started

| Document | Description |
|----------|-------------|
| [Getting Started](./getting-started.md) | Step-by-step setup guide |
| [Quick Reference](./quick-reference.md) | Command cheat sheet |
| [FAQ](./FAQ.md) | Common questions and troubleshooting |

### Configuration

| Document | Description |
|----------|-------------|
| [Customization Guide](./claude-code-customization.md) | Customize CLAUDE.md, skills, and commands |
| [MCP Dependencies](./mcp-dependencies.md) | MCP server setup and configuration |
| [Architecture](./architecture.md) | Template structure and components |

### Deployment & Operations

| Document | Description |
|----------|-------------|
| [Deployment Guide](./deployment.md) | Deploy template, skills, and CI/CD integration |
| [Contributing Guide](./contributing.md) | How to contribute skills, commands, and scripts |

### Standards & Migration

| Document | Description |
|----------|-------------|
| [Style Guide](./STYLE_GUIDE.md) | Documentation standards |
| [Migration Guide](./migration-guide.md) | Migrating from github-copilot-base |

---

## Quick Links

### Common Tasks

- **Set up a new project**: [Getting Started > Using the Project Wizard](./getting-started.md#option-1-using-the-project-wizard-recommended)
- **Customize CLAUDE.md**: [Customization Guide > CLAUDE.md](./claude-code-customization.md#customizing-claudemd)
- **Add a new skill**: [Customization Guide > Skills](./claude-code-customization.md#adding-custom-skills)
- **Configure MCP servers**: [MCP Dependencies](./mcp-dependencies.md)
- **Sync to existing project**: [Getting Started > Syncing](./getting-started.md#syncing-to-existing-projects)
- **Deploy skills globally**: [Deployment Guide > Deploying Skills](./deployment.md#deploying-skills-globally)
- **Contribute to the project**: [Contributing Guide](./contributing.md)

### Key Commands

```
/start    - Initialize session, load context
/status   - Check project and task status
/end      - Save context, update logs, commit work
/validate - Verify project configuration
/sync     - Sync Claude Code files from template
```

### Key Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Main instructions for Claude Code |
| `.claude/config.yaml` | Archon project configuration |
| `.vscode/mcp.json` | MCP server configuration |
| `.pre-commit-config.yaml` | Security scanning hooks |

---

## Project Structure Overview

```
your-project/
├── CLAUDE.md                 # Claude Code instructions
├── .claude/
│   ├── config.yaml           # Archon project link
│   ├── settings.json         # Claude Code settings
│   ├── commands/             # Slash commands
│   └── skills/               # Model-invoked skills
├── .vscode/
│   ├── mcp.json              # MCP server configuration
│   └── settings.json         # VS Code settings
├── PRPs/                     # PRP framework artifacts
│   ├── prds/                 # Product requirement documents
│   ├── plans/                # Implementation plans
│   └── templates/            # Reusable templates
└── scripts/                  # Setup and validation scripts
```

---

## Getting Help

1. **Check the FAQ**: [FAQ.md](./FAQ.md) covers common issues
2. **Review the architecture**: [architecture.md](./architecture.md) explains how components work together
3. **Consult official docs**: [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)

---

## Version Information

- **Template Version**: 1.0.0
- **Last Updated**: 2026-01-23
- **Claude Code Compatibility**: Latest

---

*Made with Claude Code*
