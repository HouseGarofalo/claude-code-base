# Claude Code Base

> Template repository for Claude Code projects with standardized configuration, security scanning, and sync capabilities.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [What's Included](#whats-included)
- [MCP Servers](#mcp-servers)
- [Security Features](#security-features)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

Claude Code Base provides a standardized foundation for Claude Code projects. It includes three main capabilities:

### Project Setup (`setup-claude-code-project.ps1`)

Interactive wizard that configures a new project with:
- `.claude/` directory structure with CLAUDE.md and settings.json
- Pre-commit hooks for security scanning
- Git configuration with proper line endings
- Optional Archon project integration

### Sync Functionality (`sync-claude-code.ps1`)

Keep projects synchronized with the base template:
- Pull latest configurations and best practices
- Merge updates without overwriting local customizations
- Selective sync for specific components

### Validation (`validate-claude-code.ps1`)

Verify project configuration meets standards:
- Check required files exist
- Validate CLAUDE.md structure
- Ensure pre-commit hooks are installed
- Report compliance status

---

## Quick Start

### Option 1: Interactive Wizard (Recommended)

```powershell
# Clone the repository
git clone https://github.com/HouseGarofalo/claude-code-base.git
cd claude-code-base

# Run the setup wizard
.\scripts\setup-claude-code-project.ps1
```

### Option 2: Manual Setup

1. Copy the template files to your project
2. Customize `.claude/CLAUDE.md` for your project
3. Install pre-commit hooks: `pre-commit install`
4. Run validation: `.\scripts\validate-claude-code.ps1`

---

## What's Included

```
claude-code-base/
├── .claude/                    # Claude Code configuration
│   ├── CLAUDE.md              # Project instructions
│   ├── settings.json          # Editor settings
│   ├── mcp.json.example       # MCP server configuration example
│   └── reference/             # Reference documentation
├── mcp-servers/               # MCP server implementations
│   └── crawl4ai-rag/          # Web crawling + Vector/Graph RAG
├── scripts/                    # Setup and maintenance scripts
│   ├── setup-claude-code-project.ps1
│   ├── sync-claude-code.ps1
│   └── validate-claude-code.ps1
├── docs/                       # Documentation
│   ├── setup-guide.md
│   ├── sync-guide.md
│   ├── best-practices.md
│   └── mcp-servers/           # MCP server documentation
├── .pre-commit-config.yaml    # Pre-commit hook configuration
├── .gitignore                 # Comprehensive gitignore
├── .gitattributes             # Line ending normalization
├── CODEOWNERS                 # Repository ownership
├── CONTRIBUTING.md            # Contribution guidelines
├── SECURITY.md                # Security policy
├── CHANGELOG.md               # Version history
├── LICENSE                    # MIT License
└── README.md                  # This file
```

---

## MCP Servers

This template includes MCP (Model Context Protocol) servers that extend Claude Code's capabilities.

### Crawl4AI RAG Server

Web crawling with optional Vector and Graph RAG storage for AI-ready content.

**Quick Start** (basic crawling, no database required):

```bash
cd mcp-servers/crawl4ai-rag
pip install -e .
python -m src.crawl4ai_mcp_server
```

**With RAG Storage** (requires Azure OpenAI + Supabase/Neo4j):

1. Copy `.env.example` to `.env` and configure credentials
2. Run database setup scripts (`supabase_setup.sql`, `neo4j_setup.cypher`)
3. Start the server with storage enabled

**Configuration** - Add to `.claude/mcp.json`:

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "python",
      "args": ["-m", "src.crawl4ai_mcp_server"],
      "cwd": "${workspaceFolder}/mcp-servers/crawl4ai-rag"
    }
  }
}
```

📖 **Full documentation**: [docs/mcp-servers/crawl4ai-setup.md](docs/mcp-servers/crawl4ai-setup.md)

---

## Security Features

This template includes robust security measures:

- **gitleaks** - Scans commits for hardcoded secrets and API keys
- **detect-secrets** - Baseline-aware secret detection
- **Pre-commit hooks** - Automated checks before every commit
- **SECURITY.md** - Clear vulnerability reporting process

All security tools run automatically via pre-commit hooks. No secrets should ever be committed to version control.

---

## Documentation

| Document | Description |
|----------|-------------|
| [Setup Guide](docs/setup-guide.md) | Detailed setup instructions |
| [Sync Guide](docs/sync-guide.md) | How to sync with base template |
| [Best Practices](docs/best-practices.md) | Claude Code best practices |
| [MCP Servers](docs/mcp-servers/index.md) | MCP server setup and usage |
| [Contributing](CONTRIBUTING.md) | How to contribute |
| [Security](SECURITY.md) | Security policy |
| [Changelog](CHANGELOG.md) | Version history |

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with Claude Code
