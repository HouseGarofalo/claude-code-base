---
name: autonomous-agent-harness
version: 2.0.0
description: Set up autonomous coding agent projects with long-running harnesses using Archon MCP for state management. Creates complete project scaffolds with initializer/coding agent prompts, feature tracking, session handoffs, security configuration, and browser testing integration. Based on Anthropic's effective harnesses guide. Use when building autonomous coding agents, long-running AI workflows, or multi-session development projects.
---

# Autonomous Coding Agent Harness Setup

Create fully-configured autonomous coding agent projects that can work across multiple sessions with proper state management, handoffs, and testing. Uses **Archon MCP** for project/task tracking, enabling persistent state management and context preservation.

## Triggers

Use this skill when:
- Building autonomous coding agent projects
- Setting up long-running AI workflows with state management
- Creating multi-session development projects
- Implementing agent harnesses with handoffs
- Building coding agents that persist state across sessions
- Keywords: autonomous agent, harness, coding agent, archon, state management, session handoff, multi-session

## Quick Start

Use these prompts to interact with the harness system:

| Command | Description |
|---------|-------------|
| `/harness-setup` | Launch full setup wizard |
| `/harness-quick` | Quick setup with smart defaults |
| `/harness-init` | Initialize project (first session) |
| `/harness-next` | Start next coding session |
| `/harness-status` | Check project status |
| `/harness-resume` | Resume existing project |

---

## Architecture Overview

```
                    MULTI-AGENT PIPELINE

   /harness-setup -> @harness-wizard
         |
         v
   /harness-init -> @harness-initializer
         |
         v
   /harness-next -> @harness-coder
         |
         +---> @harness-tester (parallel)
         |
         +---> @harness-reviewer (before completion)
         |
         v
   [Repeat for each feature]

   State Management: Archon MCP (Projects, Tasks, Documents)
```

### Agent Pipeline

| Agent | Role | When Used |
|-------|------|-----------|
| `@harness-wizard` | Interactive setup | Initial configuration |
| `@harness-initializer` | Generate tasks from spec | First session only |
| `@harness-coder` | Implement features | Every coding session |
| `@harness-tester` | Run tests & verify | After implementation (parallel) |
| `@harness-reviewer` | Code review | Before marking complete |

## Features

- **Multi-Agent System**: Four specialized agents working together
- **Archon State Management**: Projects, tasks, and documents via MCP
- **Clean Handoffs**: Session notes and context for seamless continuation
- **Parallel Testing**: Testing agent can run in background
- **Code Review**: Optional review before feature completion
- **Multiple Execution Modes**: Terminal, background, or SDK

---

## Project Setup Questionnaire

When the user requests to set up an autonomous coding agent project, gather the following information systematically:

### Phase 1: Project Basics

```
PROJECT BASICS

1. Project Name:
   What should the project be called? (e.g., "saas-dashboard", "e-commerce-api")

2. Project Description:
   Brief description of what you're building (1-3 sentences)

3. Project Type:
   - Web Application (Frontend + Backend)
   - API/Backend Only
   - CLI Application
   - Full-Stack with Database
   - Mobile App Backend
   - Other

4. GitHub Repository:
   Will this use a GitHub repo? If yes, provide URL (or "create new")
```

### Phase 2: Technical Stack

```
TECHNICAL STACK

5. Primary Language:
   TypeScript/JavaScript, Python, Go, Rust, Java, Other

6. Framework (if applicable):
   - Frontend: (React, Vue, Svelte, Next.js, etc.)
   - Backend: (Express, FastAPI, Gin, Actix, Spring, etc.)

7. Database:
   PostgreSQL, MySQL/MariaDB, MongoDB, SQLite, Supabase, Firebase, None/TBD

8. Package Manager:
   npm, yarn, pnpm, pip/poetry, go mod, cargo
```

### Phase 3: Agent Configuration

```
AGENT CONFIGURATION

9. Max Features/Tasks:
   How many features should the initializer create? (recommended: 20-50)
   Default: 30

10. Session Iteration Limit:
    Max iterations per coding session? (0 = unlimited)
    Default: 50

11. Claude Model:
    - claude-opus-4-5-20251101 (Recommended for complex projects)
    - claude-sonnet-4-20250514 (Faster, good balance)
    - claude-haiku-3-5-20241022 (Quick iterations)

12. MCP Servers to Enable:
    - Archon (Required - state management)
    - Playwright (Browser automation testing)
    - GitHub (Repository operations)
    - Brave Search (Web research)
```

---

## Project Generation Workflow

After collecting all questionnaire responses, execute this workflow:

### Step 1: Create Archon Project

```python
# Create project in Archon
manage_project("create",
    title="<PROJECT_NAME>",
    description="<PROJECT_DESCRIPTION>",
    github_repo="<GITHUB_URL>"
)
# Save returned project_id for all subsequent operations
```

### Step 2: Generate Directory Structure

```
<project_name>/
├── .archon_project.json        # Project marker with Archon project_id
├── .claude_settings.json       # Security settings and allowed commands
├── app_spec.txt                # Application specification
├── init.sh                     # Environment setup script
├── claude-progress.txt         # Session progress tracking
├── features.json               # Feature registry (pass/fail tracking)
├── prompts/
│   ├── initializer_prompt.md   # First session prompt
│   └── coding_prompt.md        # Continuation session prompt
├── src/                        # Application source code
├── tests/                      # Test files
└── docs/                       # Documentation
```

### Step 3: Generate Configuration Files

**.archon_project.json**:
```json
{
  "project_id": "<ARCHON_PROJECT_ID>",
  "project_name": "<PROJECT_NAME>",
  "created_at": "<TIMESTAMP>",
  "status": "initializing"
}
```

**.claude_settings.json**:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm:*)",
      "Bash(node:*)",
      "Bash(git:*)",
      "Bash(python:*)",
      "Bash(pip:*)",
      "Bash(pytest:*)",
      "Read", "Write", "Edit", "Glob", "Grep"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(sudo:*)",
      "Bash(curl:*)",
      "Bash(wget:*)"
    ]
  },
  "mcp_servers": ["archon", "playwright-mcp"],
  "model": "<SELECTED_MODEL>",
  "max_iterations": <ITERATION_LIMIT>
}
```

---

## Handoff Workflow

### Between Sessions

The coding agent should follow this handoff protocol:

1. **Update Progress File**:
   ```
   ## Session: <DATE>

   ### Completed:
   - Task #1: Feature description (DONE)
   - Task #2: Feature description (IN PROGRESS)

   ### Blockers:
   - None / List any blockers

   ### Next Steps:
   - Continue Task #2
   - Start Task #3

   ### Notes for Next Session:
   - Important context or decisions made
   ```

2. **Update Archon META Task**:
   ```python
   manage_task("update",
       task_id="<META_TASK_ID>",
       description="Updated session summary:\n\n<PROGRESS_SUMMARY>"
   )
   ```

3. **Git Commit**:
   ```bash
   git add .
   git commit -m "Session end: <SUMMARY>

   Completed: <TASK_LIST>
   Next: <NEXT_TASK>"
   ```

---

## Archon MCP Quick Reference

### Project Management
```python
# Create project
manage_project("create", title="My App", description="...", github_repo="...")

# Get project
find_projects(project_id="uuid")

# List all projects
find_projects()
```

### Task Management
```python
# Create task
manage_task("create",
    project_id="...",
    title="Feature name",
    description="Details...",
    status="todo",
    assignee="Coding Agent",
    task_order=50,
    feature="Auth"
)

# Update task status
manage_task("update", task_id="...", status="doing")
manage_task("update", task_id="...", status="review")
manage_task("update", task_id="...", status="done")

# Get tasks
find_tasks(filter_by="project", filter_value="<project_id>")
find_tasks(filter_by="status", filter_value="todo")
find_tasks(task_id="<specific_task_id>")
```

### Task Status Flow
```
todo -> doing -> review -> done
```

---

## Best Practices

1. **Incremental Progress**: Work on single features per session
2. **Test Everything**: Verify E2E functionality, not just code changes
3. **Clean Handoffs**: Leave environment ready for next session
4. **Explicit State**: Never assume - always check Archon for current state
5. **Atomic Commits**: Commit after each feature completion
6. **No Test Shortcuts**: Never modify tests to pass artificially
7. **Document Decisions**: Add context to Archon tasks and progress file
8. **Verify Before Claiming**: Test features before marking complete

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Agent skips testing | Add explicit testing requirements in prompt |
| Lost context between sessions | Check claude-progress.txt and Archon META task |
| Feature marked done but broken | Run E2E tests, update features.json status |
| Archon connection failed | Verify MCP server configuration |
| Agent declares premature completion | Require explicit feature count verification |

### Recovery Commands

```bash
# Check project status
find_tasks(filter_by="project", filter_value="<PROJECT_ID>")

# View recent progress
cat claude-progress.txt
git log --oneline -10

# Verify features
cat features.json | jq '.features[] | select(.status=="failing")'

# Reset stuck task
manage_task("update", task_id="...", status="todo")
```

---

## Notes

- This skill requires **Archon MCP server** to be configured and running
- Playwright MCP is recommended for E2E testing but optional
- The agent harness works best with detailed, specific app specifications
- For complex projects, consider breaking into phases (MVP, v1, v2)
- Review and adjust generated prompts based on project-specific needs
