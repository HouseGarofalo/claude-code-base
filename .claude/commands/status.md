---
name: status
description: Show current project and task status
---

# /status - Project Status Report

Provide a current snapshot of project and task status.

## Steps to Execute

### Step 1: Check Archon Tasks

Query current task status from Archon:

```python
# Load config to get project ID
# Read .claude/config.yaml first

# Get in-progress tasks
find_tasks(filter_by="status", filter_value="doing", project_id="[archon_project_id]")

# Get tasks in review
find_tasks(filter_by="status", filter_value="review", project_id="[archon_project_id]")

# Get pending tasks
find_tasks(filter_by="status", filter_value="todo", project_id="[archon_project_id]", per_page=10)
```

### Step 2: Check Git Status

```bash
git status
git log --oneline -3
git diff --stat HEAD~1 2>/dev/null || echo "No previous commit to compare"
```

### Step 3: Check for Background Processes

Note any running processes or pending operations.

### Step 4: Review Recent Activity

```bash
cat .claude/DEVELOPMENT_LOG.md 2>/dev/null | tail -30
```

### Step 5: Output Status Report

```
PROJECT STATUS REPORT
=====================
Generated: [current timestamp]

TASK STATUS (Archon)
--------------------
In Progress:
  [X] [task title] - [assignee]
      Status: doing
      Description: [brief description]

In Review:
  [X] [task title]
      Status: review

Pending (Next 5):
  [ ] [task title] - Priority: [order]
  [ ] [task title] - Priority: [order]
  ...

Completed Recently:
  [count] tasks completed

GIT STATUS
----------
Branch:     [current branch]
Status:     [clean/dirty]
Changes:    [X files modified, Y staged]

Recent Commits:
  - [hash] [message]
  - [hash] [message]

SESSION ACTIVITY
----------------
[Recent entries from development log]

BLOCKERS/ISSUES
---------------
[Any identified blockers or issues]

RECOMMENDATIONS
---------------
1. [What to focus on next]
2. [Any maintenance needed]
```

## Quick Status Format

If user requests "quick" or "brief" status, provide condensed version:

```
STATUS: [Project Title]
Tasks: [X] doing | [Y] review | [Z] todo
Git: [branch] - [clean/X changes]
Next: [Top priority task]
```
