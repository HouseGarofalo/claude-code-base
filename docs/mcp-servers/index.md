# MCP Servers Documentation

> **Purpose**: Setup guides and documentation for MCP (Model Context Protocol) servers included in the Claude Code Base template.

---

## Available MCP Servers

| Server | Description | Status |
|--------|-------------|--------|
| [Crawl4AI](./crawl4ai-setup.md) | Web crawling with Vector & Graph RAG | In Development |

---

## What are MCP Servers?

MCP (Model Context Protocol) servers extend Claude Code's capabilities by providing access to external tools and data sources. They run as separate processes and communicate with Claude Code via the MCP protocol.

### Key Benefits

- **Modular**: Add capabilities without modifying Claude Code
- **Isolated**: Each server runs in its own process
- **Typed**: Strong typing via MCP schema definitions
- **Flexible**: Can be written in any language (Python, TypeScript, etc.)

---

## Server Locations

All MCP server implementations are in the `mcp-servers/` directory:

```
mcp-servers/
└── crawl4ai-rag/           # Web crawling + RAG server
    ├── src/                # Server source code
    ├── tests/              # Unit tests
    ├── .env.example        # Environment template
    ├── supabase_setup.sql  # Vector DB setup
    ├── neo4j_setup.cypher  # Graph DB setup
    └── README.md           # Quick reference
```

---

## Configuration

MCP servers are registered in one of these locations:

| Location | Scope | Priority |
|----------|-------|----------|
| `~/.claude/mcp.json` | Global (all projects) | Lowest |
| `.vscode/mcp.json` | Project (VS Code) | Medium |
| `.claude/mcp.json` | Project (Claude Code) | Highest |

### Example Configuration

See [.claude/mcp.json.example](../../.claude/mcp.json.example) for a complete example.

---

## Adding a New MCP Server

1. Create a new directory under `mcp-servers/`
2. Implement the MCP protocol (use FastMCP for Python)
3. Add documentation in `docs/mcp-servers/`
4. Update this index

### Template Structure

```
mcp-servers/my-server/
├── src/
│   └── my_mcp_server.py
├── tests/
│   └── test_server.py
├── .env.example
├── pyproject.toml
└── README.md
```

---

## Related Documentation

- [MCP Dependencies](../mcp-dependencies.md) - General MCP setup and dependencies
- [MCP Development Skill](../../.claude/skills/mcp-development/) - Building MCP servers
