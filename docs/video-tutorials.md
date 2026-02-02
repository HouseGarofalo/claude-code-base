# Video Tutorials and Learning Resources

A curated collection of video tutorials, guides, and resources for working with Claude Code and this template repository.

## Getting Started

### Introduction to Claude Code

- **[Claude Code Official Documentation](https://docs.anthropic.com/en/docs/claude-code)** - Official Anthropic documentation for Claude Code CLI
- **[Claude Code GitHub Repository](https://github.com/anthropics/claude-code)** - Source code and release notes
- **[Getting Started with Claude Code](https://www.anthropic.com/claude-code)** - Anthropic's official landing page

### Installation and Setup

1. **Install Claude Code CLI**
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```

2. **Authenticate with Anthropic**
   ```bash
   claude auth login
   ```

3. **Initialize a project**
   ```bash
   claude init
   ```

## Core Concepts

### Understanding CLAUDE.md

The `CLAUDE.md` file is the brain of your Claude Code project. It tells Claude:

- What your project is about
- Coding conventions to follow
- Important files and their purposes
- How to handle common tasks

**Key sections to customize:**
- Project overview
- Tech stack
- Coding standards
- File structure
- Common commands

### Skills and Commands

**Skills** are reusable instruction sets that Claude can invoke when needed:
- Stored in `~/.claude/skills/` or `.claude/skills/`
- Activated by description matching
- Great for domain-specific knowledge

**Commands** are user-invoked actions:
- Triggered with `/command-name`
- Useful for repetitive workflows
- Can be project-specific or global

## Tutorial Videos

### Official Resources

| Topic | Resource | Duration |
|-------|----------|----------|
| Introduction | [Claude Code Overview](https://www.anthropic.com/claude-code) | 5 min read |
| CLI Basics | [Claude Code CLI Guide](https://docs.anthropic.com/en/docs/claude-code/cli) | 10 min read |
| Configuration | [CLAUDE.md Guide](https://docs.anthropic.com/en/docs/claude-code/claude-md) | 15 min read |

### Community Tutorials

> Note: Community content may vary in quality and currency. Always verify information against official documentation.

#### YouTube Channels

- **Anthropic Official** - Official announcements and demos
- **AI Code Assistant Reviews** - Comparisons and tutorials
- **Developer Productivity** - Workflow optimization tips

#### Written Guides

- [Claude Code Best Practices](https://docs.anthropic.com/en/docs/claude-code/best-practices) - Official best practices guide
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) - Official MCP documentation
- [Claude API Documentation](https://docs.anthropic.com/en/api) - Full API reference

## Topic-Specific Guides

### Using Skills

Skills extend Claude's capabilities for specific domains:

```markdown
---
name: my-custom-skill
description: Description of what this skill does and when Claude should use it
---

# My Custom Skill

## When to Use
- Scenario 1
- Scenario 2

## Instructions
Step-by-step guidance for Claude...
```

**Best practices:**
- Keep descriptions under 1024 characters
- Use lowercase names with hyphens
- Include clear trigger scenarios
- Provide concrete examples

### Setting Up MCP Servers

Model Context Protocol servers extend Claude's abilities:

1. **Database Operations** - Query databases directly
2. **File System Access** - Enhanced file operations
3. **API Integrations** - Connect to external services
4. **Custom Tools** - Build your own capabilities

**Configuration in VS Code:**
```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["path/to/server.js"]
    }
  }
}
```

### Creating Custom Skills

Step-by-step guide to creating production-ready skills:

1. **Choose a category** - Where does this skill belong?
2. **Write the SKILL.md** - Follow the template structure
3. **Add to your skills directory** - `~/.claude/skills/` or `.claude/skills/`
4. **Test with various prompts** - Ensure it activates correctly

### PRP Workflow Tutorial

Product Requirement Prompts (PRPs) structure complex tasks:

```
PRPs/
├── templates/
│   └── FEATURE_PRP.md
├── active/
│   └── current-feature.md
└── completed/
    └── archived-features.md
```

**When to use PRPs:**
- Multi-file features
- Complex refactoring
- New integrations
- Major architectural changes

## Quick Reference

### Essential Commands

| Command | Description |
|---------|-------------|
| `/start` | Initialize session, load context |
| `/status` | Show project and task status |
| `/next` | Get next available task |
| `/end` | End session, save context |
| `/help` | Show available commands |
| `/cost` | Check token usage |
| `/clear` | Reset conversation context |
| `/compact` | Compress conversation history |

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel current operation |
| `Ctrl+D` | Exit Claude Code |
| `Tab` | Auto-complete file paths |
| `Up/Down` | Navigate command history |

### File Conventions

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Main instructions for Claude |
| `.claude/config.yaml` | Project configuration |
| `.claude/SESSION_KNOWLEDGE.md` | Persistent session state |
| `.claude/DEVELOPMENT_LOG.md` | Activity tracking |
| `PRPs/*.md` | Product Requirement Prompts |

## External Resources

### Documentation

- [Anthropic Documentation](https://docs.anthropic.com/) - Complete API and product docs
- [MCP Specification](https://spec.modelcontextprotocol.io/) - Protocol specification
- [Claude Code GitHub](https://github.com/anthropics/claude-code) - Source and issues

### Community

- [Anthropic Discord](https://discord.gg/anthropic) - Official community
- [GitHub Discussions](https://github.com/anthropics/claude-code/discussions) - Feature requests and Q&A
- [Stack Overflow](https://stackoverflow.com/questions/tagged/claude) - Technical Q&A

### Tools and Extensions

- [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code) - IDE integration
- [MCP Servers Collection](https://github.com/modelcontextprotocol/servers) - Community MCP servers
- [Claude Code Templates](https://github.com/topics/claude-code-template) - Community templates

## Contributing

Found a great tutorial or resource? Submit a PR to add it:

1. Fork this repository
2. Add your resource to this file
3. Include: title, link, brief description
4. Submit a pull request

## Changelog

| Date | Update |
|------|--------|
| 2026-02-02 | Initial documentation created |

---

**Note:** External links and resources may change over time. Please report broken links by creating an issue.
