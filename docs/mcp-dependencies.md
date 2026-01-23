[Home](../README.md) > [Docs](./index.md) > MCP Dependencies

# MCP Server Dependencies

> **Last Updated**: 2026-01-23 | **Status**: Final

Guide to setting up and configuring MCP (Model Context Protocol) servers for Claude Code Base.

---

## Table of Contents

- [Overview](#overview)
- [Required Servers](#required-servers)
- [Recommended Servers](#recommended-servers)
- [Optional Servers](#optional-servers)
- [Environment Variables](#environment-variables)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

---

## Overview

MCP servers extend Claude Code's capabilities by providing access to external services, databases, and tools. They communicate via the Model Context Protocol.

### How MCP Works

```
Claude Code  <-->  MCP Layer  <-->  External Services
     |                |                    |
     |-- Request ---> |-- API Call ------> |
     |<-- Response -- |<-- Result -------- |
```

### Configuration Location

MCP servers are configured in `.vscode/mcp.json`:

```json
{
  "servers": {
    "server-name": {
      "command": "...",
      "args": [...],
      "env": {...}
    }
  }
}
```

---

## Required Servers

### Archon

**Purpose**: Project/task management, document storage, knowledge base (RAG)

**Status**: Required for full template functionality

**Configuration**:
```json
{
  "servers": {
    "archon": {
      "url": "http://localhost:8051/mcp",
      "type": "http"
    }
  }
}
```

**Prerequisites**:
- Archon server running on localhost:8051
- No additional environment variables needed

**Verification**:
```powershell
# Check if Archon is running
curl http://localhost:8051/health
```

**Capabilities**:
| Tool | Purpose |
|------|---------|
| `find_projects` | List/search projects |
| `manage_project` | Create/update/delete projects |
| `find_tasks` | List/search tasks |
| `manage_task` | Create/update/delete tasks |
| `find_documents` | List/search documents |
| `manage_document` | Create/update/delete documents |
| `rag_search_knowledge_base` | Search documentation |
| `rag_search_code_examples` | Find code examples |

---

## Recommended Servers

### Brave Search

**Purpose**: Web search capabilities

**Status**: Highly recommended for research tasks

**Configuration**:
```json
{
  "servers": {
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

**Prerequisites**:
- Node.js installed
- Brave API key (get from [Brave Search API](https://brave.com/search/api/))

**Environment Variable**:
```bash
BRAVE_API_KEY=your-brave-api-key
```

**Capabilities**:
| Tool | Purpose |
|------|---------|
| `brave_web_search` | General web search |
| `brave_local_search` | Location-based search |
| `brave_video_search` | Video search |
| `brave_news_search` | News articles |
| `brave_image_search` | Image search |

---

### Serena

**Purpose**: Code intelligence and refactoring

**Status**: Recommended for development tasks

**Configuration**:
```json
{
  "servers": {
    "serena": {
      "command": "uvx",
      "args": [
        "--from",
        "git+https://github.com/oraios/serena",
        "serena",
        "start-mcp-server",
        "--context",
        "ide-assistant"
      ]
    }
  }
}
```

**Prerequisites**:
- Python with uv/uvx installed
- No API key required

**Capabilities**:
| Tool | Purpose |
|------|---------|
| `find_symbol` | Find code symbols |
| `get_symbols_overview` | File symbol overview |
| `find_referencing_symbols` | Find references |
| `search_for_pattern` | Regex search |
| `replace_symbol_body` | Refactor code |
| `rename_symbol` | Rename across codebase |

---

### Playwright

**Purpose**: Browser automation and testing

**Status**: Recommended for web development

**Configuration**:
```json
{
  "servers": {
    "playwright": {
      "command": "cmd",
      "args": ["/c", "npx", "@anthropic-ai/mcp-server-playwright"]
    }
  }
}
```

**Prerequisites**:
- Node.js installed
- Playwright browsers installed (`npx playwright install`)

**Capabilities**:
| Tool | Purpose |
|------|---------|
| `navigate` | Go to URL |
| `click` | Click elements |
| `fill` | Fill inputs |
| `screenshot` | Capture page |
| `evaluate` | Run JavaScript |

---

## Optional Servers

### Context7 (Documentation Lookup)

**Purpose**: Library and framework documentation

**Configuration**:
```json
{
  "servers": {
    "context7": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@context7/mcp-server"]
    }
  }
}
```

### Filesystem

**Purpose**: Enhanced file operations

**Configuration**:
```json
{
  "servers": {
    "filesystem": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@anthropic-ai/mcp-server-filesystem"]
    }
  }
}
```

### PostgreSQL

**Purpose**: Database operations

**Configuration**:
```json
{
  "servers": {
    "postgres": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@anthropic-ai/mcp-server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    }
  }
}
```

**Environment Variable**:
```bash
DATABASE_URL=postgresql://user:pass@host:5432/db
```

### SQLite

**Purpose**: Local database operations

**Configuration**:
```json
{
  "servers": {
    "sqlite": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@anthropic-ai/mcp-server-sqlite"],
      "env": {
        "SQLITE_PATH": "${SQLITE_PATH}"
      }
    }
  }
}
```

### Docker

**Purpose**: Container management

**Configuration**:
```json
{
  "servers": {
    "docker": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@anthropic-ai/mcp-server-docker"]
    }
  }
}
```

### Memory

**Purpose**: Persistent memory across sessions

**Configuration**:
```json
{
  "servers": {
    "memory": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@anthropic-ai/mcp-server-memory"]
    }
  }
}
```

### Sequential Thinking

**Purpose**: Enhanced reasoning chains

**Configuration**:
```json
{
  "servers": {
    "sequential-thinking": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@anthropic-ai/mcp-server-sequential-thinking"]
    }
  }
}
```

---

## Environment Variables

### Setting Variables

**Option 1: Project .env file**
```bash
# .env (in project root)
BRAVE_API_KEY=your-key
DATABASE_URL=postgresql://...
```

**Option 2: Global Claude .env**
```bash
# ~/.claude/.env
BRAVE_API_KEY=your-key
```

**Option 3: System environment**
```powershell
# PowerShell
$env:BRAVE_API_KEY = "your-key"
```

### Required Variables by Server

| Server | Variable | How to Get |
|--------|----------|------------|
| Brave Search | `BRAVE_API_KEY` | [Brave Search API](https://brave.com/search/api/) |
| PostgreSQL | `DATABASE_URL` | Your database connection string |
| SQLite | `SQLITE_PATH` | Path to SQLite file |
| OpenAI | `OPENAI_API_KEY` | [OpenAI Platform](https://platform.openai.com/) |
| Hugging Face | `HF_TOKEN` | [Hugging Face](https://huggingface.co/settings/tokens) |
| Datadog | `DD_API_KEY`, `DD_APP_KEY` | [Datadog](https://app.datadoghq.com/organization-settings/api-keys) |
| Sentry | `SENTRY_AUTH_TOKEN` | [Sentry](https://sentry.io/settings/account/api/auth-tokens/) |

---

## Configuration

### Full Example mcp.json

```json
{
  "servers": {
    // Required
    "archon": {
      "url": "http://localhost:8051/mcp",
      "type": "http"
    },

    // Recommended
    "brave-search": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@anthropic-ai/mcp-server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    },
    "serena": {
      "command": "uvx",
      "args": [
        "--from",
        "git+https://github.com/oraios/serena",
        "serena",
        "start-mcp-server",
        "--context",
        "ide-assistant"
      ]
    },
    "playwright": {
      "command": "cmd",
      "args": ["/c", "npx", "@anthropic-ai/mcp-server-playwright"]
    }
  },
  "inputs": []
}
```

### Enabling/Disabling Servers

To enable a commented server:
1. Remove the `//` comment markers
2. Ensure environment variables are set
3. Restart Claude Code

To disable a server:
1. Comment out the server block with `//`
2. Or remove the server entry entirely

---

## Troubleshooting

### Common Issues

#### Server Not Responding

**Symptoms**: Tools not available, connection errors

**Solutions**:
1. Check server is running:
   ```powershell
   # For Archon
   curl http://localhost:8051/health
   ```
2. Verify port is correct
3. Restart VS Code
4. Check firewall settings

#### npx Command Failed

**Symptoms**: "npx: command not found" or package errors

**Solutions**:
1. Verify Node.js installed:
   ```powershell
   node --version
   npx --version
   ```
2. Clear npm cache:
   ```powershell
   npm cache clean --force
   ```
3. Reinstall package:
   ```powershell
   npx -y @anthropic-ai/mcp-server-brave-search
   ```

#### Environment Variable Not Found

**Symptoms**: "API key not set" or authentication errors

**Solutions**:
1. Check variable is set:
   ```powershell
   echo $env:BRAVE_API_KEY
   ```
2. Restart VS Code after setting variables
3. Verify .env file location and format

#### Archon Connection Failed

**Symptoms**: "Could not connect to Archon" errors

**Solutions**:
1. Verify Archon is running on port 8051
2. Check URL in mcp.json is correct
3. Test health endpoint:
   ```powershell
   curl http://localhost:8051/health
   ```

#### Serena/uvx Issues

**Symptoms**: "uvx: command not found"

**Solutions**:
1. Install uv:
   ```powershell
   pip install uv
   ```
2. Verify uvx is in PATH:
   ```powershell
   uvx --version
   ```

### Diagnostic Commands

```powershell
# Check all required tools
node --version
npx --version
python --version
uvx --version

# Test Archon
curl http://localhost:8051/health

# Test environment variables
echo $env:BRAVE_API_KEY

# Verify mcp.json syntax
Get-Content .vscode/mcp.json | ConvertFrom-Json
```

### Logs and Debugging

1. **VS Code Output Panel**: View > Output > Select "MCP" from dropdown
2. **Claude Code Logs**: Check Claude Code's built-in logging
3. **Server-specific logs**: Check each server's documentation

---

## Server Categories Summary

| Category | Servers | Purpose |
|----------|---------|---------|
| **Core** | Archon | Task/project management |
| **Search** | Brave Search, Context7 | Web and documentation search |
| **Development** | Serena, Playwright | Code intelligence, testing |
| **Database** | PostgreSQL, SQLite, Redis | Data operations |
| **DevOps** | Docker, Kubernetes | Container/orchestration |
| **AI/ML** | OpenAI, Ollama, Hugging Face | AI model access |
| **Monitoring** | Datadog, Sentry | Observability |
| **Enterprise** | Azure DevOps, Jira, Slack | Team integration |

---

## Related Documents

- [Architecture](./architecture.md) - How components fit together
- [Getting Started](./getting-started.md) - Initial setup
- [Customization Guide](./claude-code-customization.md) - Extending the template
- [FAQ](./FAQ.md) - Common questions

---

*[Back to Documentation Index](./index.md)*
