---
name: start
description: Initialize a new Claude Code session with full context loading
---

# /start - Session Startup Protocol

Execute the complete startup protocol for this project.

## Steps to Execute

### Step 1: Load Project Configuration

Read `.claude/config.yaml` and extract:
- `archon_project_id`
- `project_title`
- `github_repo`
- `local_path`
- `default_branch`

```bash
cat .claude/config.yaml
```

If config is missing or contains placeholder values `[PLACEHOLDER]`, notify the user that the project needs to be configured first. Suggest running `/new-project` or manually updating the config.

### Step 2: Load Session Context Files

Read the following files to understand current project state:

```bash
cat .claude/SESSION_KNOWLEDGE.md 2>/dev/null || echo "No session knowledge file found"
cat .claude/DEVELOPMENT_LOG.md 2>/dev/null || echo "No development log found"
cat .claude/FAILED_ATTEMPTS.md 2>/dev/null || echo "No failed attempts log found"
```

### Step 3: Check Archon Status

Query Archon for project and task information. Use the `archon_project_id` from config.

```python
# Get project details
find_projects(project_id="[archon_project_id from config]")

# Get in-progress tasks
find_tasks(filter_by="status", filter_value="doing", project_id="[archon_project_id]")

# Get pending tasks
find_tasks(filter_by="status", filter_value="todo", project_id="[archon_project_id]", per_page=5)

# Get project documents
find_documents(project_id="[archon_project_id]")
```

### Step 4: Review Git Status

Check the current state of the repository:

```bash
git status
git log --oneline -5
git branch --show-current
```

### Step 5: Output Status Briefing

Provide a comprehensive summary in this format:

```
SESSION STARTUP COMPLETE
========================

PROJECT CONFIGURATION
---------------------
Project ID:     [archon_project_id]
Project Title:  [project_title]
Repository:     [github_repo]
Local Path:     [local_path]
Branch:         [current git branch]

CONTEXT LOADED
--------------
Session Knowledge:  [Loaded/Not Found]
Development Log:    [X entries]
Failed Attempts:    [X entries to avoid]

ARCHON STATUS
-------------
Project:           [Connected/Not Found]
Documents:         [X documents]
In-Progress Tasks: [list any doing tasks]
Pending Tasks:     [count of todo tasks]

GIT STATUS
----------
Branch:            [current branch]
Uncommitted:       [clean/X files changed]
Last Commits:
  - [commit 1]
  - [commit 2]

LAST SESSION CONTEXT
--------------------
[Summary from SESSION_KNOWLEDGE.md if available]

RECOMMENDED NEXT STEPS
----------------------
Option A: [Continue in-progress task if any]
Option B: [Pick up next todo task]
Option C: [Address any issues found]

AWAITING YOUR DIRECTION
```

## Error Handling

- If Archon MCP is not available, note this and continue with local context only
- If config.yaml has placeholder values, prompt user to configure the project
- If git is not initialized, note this as an issue to address
