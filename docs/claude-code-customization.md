[Home](../README.md) > [Docs](./index.md) > Customization Guide

# Claude Code Customization Guide

> **Last Updated**: 2026-01-23 | **Status**: Final

How to customize the Claude Code Base template for your specific project needs.

---

## Table of Contents

- [Overview](#overview)
- [Customizing CLAUDE.md](#customizing-claudemd)
- [Adding Custom Skills](#adding-custom-skills)
- [Adding Custom Commands](#adding-custom-commands)
- [Modifying VS Code Settings](#modifying-vs-code-settings)
- [Extending MCP Configuration](#extending-mcp-configuration)
- [Customizing PRP Templates](#customizing-prp-templates)
- [Best Practices](#best-practices)

---

## Overview

The Claude Code Base template is designed to be customized for your project. Key customization points:

| Component | File/Location | Purpose |
|-----------|---------------|---------|
| AI Instructions | `CLAUDE.md` | Project-specific rules and context |
| Skills | `.claude/skills/` | Model-invoked behaviors |
| Commands | `.claude/commands/` | User-invoked actions |
| VS Code | `.vscode/` | Editor settings and extensions |
| MCP Servers | `.vscode/mcp.json` | Extended capabilities |
| PRP Templates | `PRPs/templates/` | Development workflows |

---

## Customizing CLAUDE.md

`CLAUDE.md` is the central instructions file that Claude reads at every session start.

### Step 1: Replace Placeholders

Find and replace these placeholders:

| Placeholder | Replace With | Example |
|-------------|--------------|---------|
| `[ARCHON_PROJECT_ID]` | Archon project UUID | `550e8400-e29b-41d4-a716-446655440000` |
| `[PROJECT_TITLE]` | Human-readable name | `My Awesome App` |
| `[GITHUB_REPO]` | Repository URL | `https://github.com/org/repo` |
| `[REPOSITORY_PATH]` | Local filesystem path | `E:\Repos\MyOrg\my-app` |
| `[PRIMARY_STACK]` | Technologies used | `TypeScript, React, Node.js` |
| `[PRIMARY_LANGUAGE]` | Main language | `TypeScript` |
| `[PRIMARY_STRUCTURE]` | Source organization | `src/components/, src/services/` |

### Step 2: Customize Code Style Guidelines

Update the Code Style section with your conventions:

```markdown
## Code Style Guidelines

### TypeScript Guidelines

| Principle | Description |
|-----------|-------------|
| Type Safety | Use strict TypeScript, avoid `any` |
| Naming | PascalCase for components, camelCase for functions |
| Imports | Group by external, internal, relative |

### React Guidelines

| Pattern | Usage |
|---------|-------|
| Components | Functional components with hooks |
| State | Zustand for global, useState for local |
| Styling | Tailwind CSS utility classes |

### API Guidelines

| Pattern | Usage |
|---------|-------|
| Endpoints | RESTful with versioning |
| Validation | Zod schemas for all inputs |
| Errors | Standardized error response format |
```

### Step 3: Update Layer Responsibilities

Map your project's architecture:

```markdown
### Layer Responsibilities

| Layer | Responsibility | Location |
|-------|---------------|----------|
| **UI** | React components | `src/components/` |
| **Pages** | Route components | `src/pages/` |
| **Hooks** | Custom React hooks | `src/hooks/` |
| **Services** | Business logic | `src/services/` |
| **API** | API client | `src/api/` |
| **Types** | TypeScript types | `src/types/` |
| **Utils** | Utility functions | `src/utils/` |
```

### Step 4: Configure Testing Section

Update test commands and coverage targets:

```markdown
## Testing Requirements

### Test Coverage Standards

| Test Type | Coverage Target | Location |
|-----------|----------------|----------|
| **Unit Tests** | 80%+ | `tests/unit/` |
| **Integration Tests** | Critical paths | `tests/integration/` |
| **E2E Tests** | Happy paths | `tests/e2e/` |

### Commands

```bash
# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run E2E
npm run test:e2e
```
```

### Step 5: Add Project-Specific Rules

Add rules after the existing critical rules:

```markdown
### Rule 4: [Your Rule Name]

**Description of what this rule enforces**

**ALWAYS:**
- Requirement 1
- Requirement 2

**NEVER:**
- Prohibition 1
- Prohibition 2

**Example:**
```code
// Good example
```

### Rule 5: API Design Standards

**All API endpoints must follow RESTful conventions**

**ALWAYS:**
- Use plural nouns for resources (`/users`, not `/user`)
- Include API version in URL (`/api/v1/`)
- Return consistent error format

**NEVER:**
- Use verbs in URLs (`/getUser`)
- Mix singular and plural resources
- Return raw error messages to clients
```

---

## Adding Custom Skills

Skills are model-invoked based on context matching.

### Step 1: Create Skill Directory

```powershell
mkdir .claude/skills/my-skill
```

### Step 2: Create SKILL.md

```markdown
---
name: my-skill
description: |
  What this skill does and when to use it.
  Include keywords that should trigger activation.
  Keywords: react, component, hook, state
---

# My Skill

## Overview

Brief description of what this skill accomplishes.

## When to Use

Activate this skill when:
- User mentions React components
- User asks about state management
- User needs help with hooks

## Instructions

### Step 1: Understand the Request

Analyze what the user needs...

### Step 2: Apply Patterns

Use these patterns from the codebase:
- Pattern A: `src/components/Button.tsx`
- Pattern B: `src/hooks/useAuth.ts`

### Step 3: Implement Solution

Provide solution following project conventions...

## Examples

### Example 1: Creating a Component

**Input:** "Create a button component"

**Output:**
```tsx
// src/components/Button.tsx
interface ButtonProps {
  label: string;
  onClick: () => void;
}

export function Button({ label, onClick }: ButtonProps) {
  return (
    <button
      className="px-4 py-2 bg-blue-500 text-white rounded"
      onClick={onClick}
    >
      {label}
    </button>
  );
}
```
```

### Step 3: Test the Skill

In Claude Code, mention the trigger keywords and verify the skill activates.

### Skill Best Practices

| Do | Don't |
|----|-------|
| Include specific trigger keywords | Use vague descriptions |
| Provide concrete examples | Give abstract instructions |
| Reference actual project files | Use generic patterns |
| Include error handling | Assume happy path only |

---

## Adding Custom Commands

Commands are user-invoked via `/command-name`.

### Step 1: Create Command File

```markdown
<!-- .claude/commands/deploy.md -->
---
name: deploy
description: Deploy the application to staging or production
---

# /deploy - Deployment Command

Execute deployment to the specified environment.

## Usage

```
/deploy [environment]
```

Where `environment` is:
- `staging` - Deploy to staging
- `production` - Deploy to production (requires confirmation)

## Steps to Execute

### Step 1: Verify Prerequisites

```bash
# Check git status
git status

# Ensure on correct branch
git branch --show-current
```

### Step 2: Run Tests

```bash
npm test
npm run build
```

### Step 3: Deploy

**For staging:**
```bash
npm run deploy:staging
```

**For production:**
```bash
# Confirm with user first
npm run deploy:production
```

### Step 4: Verify Deployment

```bash
# Check deployment status
npm run deploy:status
```

## Output Format

```
DEPLOYMENT SUMMARY
==================
Environment: [staging/production]
Branch: [branch name]
Commit: [commit hash]
Status: [success/failed]
URL: [deployment URL]
```

## Error Handling

If deployment fails:
1. Check error logs
2. Rollback if necessary
3. Report issue to user
```

### Step 2: Test the Command

Type `/deploy` in Claude Code to verify it works.

### Command Best Practices

| Do | Don't |
|----|-------|
| Define clear steps | Leave steps ambiguous |
| Include error handling | Assume success |
| Specify output format | Return unstructured output |
| Validate prerequisites | Skip validation |

---

## Modifying VS Code Settings

### settings.json

Customize editor behavior in `.vscode/settings.json`:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "files.exclude": {
    "**/node_modules": true,
    "**/.git": true,
    "**/dist": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/*.min.js": true
  }
}
```

### extensions.json

Recommend extensions for your project:

```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next",
    "formulahendry.auto-rename-tag",
    "christian-kohler.path-intellisense"
  ]
}
```

### keybindings.json

Add project-specific keybindings:

```json
[
  {
    "key": "ctrl+shift+t",
    "command": "workbench.action.terminal.sendSequence",
    "args": { "text": "npm test\n" }
  },
  {
    "key": "ctrl+shift+b",
    "command": "workbench.action.terminal.sendSequence",
    "args": { "text": "npm run build\n" }
  }
]
```

---

## Extending MCP Configuration

### Adding New Servers

Edit `.vscode/mcp.json`:

```json
{
  "servers": {
    // Existing servers...

    // Add new server
    "my-server": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@example/mcp-server"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

### Custom HTTP Server

For custom MCP servers:

```json
{
  "servers": {
    "custom-api": {
      "url": "http://localhost:3000/mcp",
      "type": "http"
    }
  }
}
```

### Environment-Specific Configuration

Use environment variables for flexible configuration:

```json
{
  "servers": {
    "database": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@anthropic-ai/mcp-server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    }
  }
}
```

Then set different values per environment:

```bash
# Development (.env)
DATABASE_URL=postgresql://localhost/dev

# Production (environment)
DATABASE_URL=postgresql://prod-server/prod
```

---

## Customizing PRP Templates

### PRD Template

Customize `PRPs/templates/prd-template.md` for your workflow:

```markdown
# PRD: [Feature Name]

## Overview

| Field | Value |
|-------|-------|
| Author | [Your name] |
| Created | [Date] |
| Status | Draft / Review / Approved |
| Priority | P0 / P1 / P2 |

## Problem Statement

[What problem does this solve?]

## User Stories

- As a [user type], I want [action] so that [benefit]

## Requirements

### Functional Requirements

1. [Requirement 1]
2. [Requirement 2]

### Non-Functional Requirements

1. Performance: [Target]
2. Security: [Requirements]

## Technical Approach

[High-level technical approach]

## Implementation Phases

### Phase 1: [Name]
- [ ] Task 1
- [ ] Task 2

### Phase 2: [Name]
- [ ] Task 3
- [ ] Task 4

## Success Metrics

| Metric | Target |
|--------|--------|
| [Metric 1] | [Target] |

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| [Risk 1] | [Mitigation] |
```

### Plan Template

Customize `PRPs/templates/plan-template.md`:

```markdown
# Implementation Plan: [Feature Name]

> **PRD**: [Link to PRD]
> **Phase**: X of Y
> **Assignee**: [Name]

## Context

### Relevant Files

| File | Purpose |
|------|---------|
| `src/file.ts` | [Description] |

### Patterns to Follow

```typescript
// Example from codebase
```

## Tasks

### Task 1: [Name]

**Description**: [What to do]

**Files to modify**:
- `src/file.ts`

**Validation**:
```bash
npm test
```

### Task 2: [Name]

...

## Definition of Done

- [ ] All tests passing
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Deployed to staging
```

---

## Best Practices

### CLAUDE.md Best Practices

| Do | Don't |
|----|-------|
| Be specific about conventions | Use vague guidelines |
| Include real code examples | Use pseudo-code |
| Reference actual file paths | Use generic paths |
| Update when patterns change | Let it become stale |

### Skills Best Practices

| Do | Don't |
|----|-------|
| One skill per capability | Create monolithic skills |
| Clear trigger keywords | Vague descriptions |
| Include error handling | Assume success |
| Provide examples | Abstract instructions only |

### Commands Best Practices

| Do | Don't |
|----|-------|
| Validate prerequisites | Skip validation |
| Define output format | Unstructured output |
| Include rollback steps | Assume success |
| Test before committing | Deploy untested commands |

### General Customization Tips

1. **Start minimal**: Add customizations as needed
2. **Document changes**: Note why customizations were made
3. **Test thoroughly**: Verify customizations work as expected
4. **Keep updated**: Sync with template updates periodically
5. **Share patterns**: Document successful patterns for team

---

## Customization Checklist

When customizing for a new project:

- [ ] Replace all placeholders in CLAUDE.md
- [ ] Update code style guidelines for your stack
- [ ] Configure layer responsibilities
- [ ] Set up test commands and targets
- [ ] Add project-specific rules
- [ ] Create necessary skills
- [ ] Create necessary commands
- [ ] Configure VS Code settings
- [ ] Enable required MCP servers
- [ ] Customize PRP templates
- [ ] Test with `/start` command
- [ ] Verify Archon connection
- [ ] Commit customizations

---

## Related Documents

- [Getting Started](./getting-started.md) - Initial setup
- [Architecture](./architecture.md) - Template structure
- [MCP Dependencies](./mcp-dependencies.md) - MCP server setup
- [Quick Reference](./quick-reference.md) - Command reference

---

*[Back to Documentation Index](./index.md)*
