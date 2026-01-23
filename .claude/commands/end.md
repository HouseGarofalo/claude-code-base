---
name: end
description: Save context, update logs, and commit work before ending session
---

# /end - Session End Protocol

Execute the complete session end protocol to preserve context and save work.

## Steps to Execute

### Step 1: Update Session Knowledge

Update `.claude/SESSION_KNOWLEDGE.md` with current session state:

- What was worked on this session
- Current state of in-progress work
- Important decisions made
- Discoveries or learnings
- Context needed for next session

### Step 2: Update Development Log

Append to `.claude/DEVELOPMENT_LOG.md`:

```markdown
## [Current Date and Time]

### Work Completed
- [List of completed items]

### In Progress
- [Items still being worked on]

### Decisions Made
- [Any architectural or design decisions]

### Notes
- [Any other relevant notes]
```

### Step 3: Update Failed Attempts (if applicable)

If any approaches failed during this session, document them in `.claude/FAILED_ATTEMPTS.md`:

```markdown
## [Date] - [Brief Title]

**Attempted:** [What was tried]
**Result:** [What happened]
**Reason:** [Why it failed]
**Lesson:** [What to do instead]
```

### Step 4: Update Archon Task Status

```python
# Update any in-progress tasks with current status
# Read config to get project ID

# For each task worked on:
manage_task("update", task_id="[task_id]", status="[appropriate status]")

# Update session context document in Archon if it exists
find_documents(project_id="[archon_project_id]", query="Session Context")
# If found, update with current session summary
```

### Step 5: Update Config Timestamp

Update the `updated_at` field in `.claude/config.yaml` to current timestamp.

### Step 6: Git Operations

```bash
# Check what needs to be committed
git status

# Stage context files
git add .claude/SESSION_KNOWLEDGE.md .claude/DEVELOPMENT_LOG.md .claude/FAILED_ATTEMPTS.md .claude/config.yaml

# Check for other changes that should be committed
git diff --name-only

# Create commit with session summary
# DO NOT push unless explicitly requested
```

Commit message format:
```
chore: end session - [brief summary of work]

- [Key item 1]
- [Key item 2]
- Updated session context
```

### Step 7: Provide Session Summary

```
SESSION END SUMMARY
===================
Session Duration: [estimated time]

WORK COMPLETED
--------------
- [Completed item 1]
- [Completed item 2]

WORK IN PROGRESS
----------------
- [In-progress item with status]

CONTEXT SAVED
-------------
- SESSION_KNOWLEDGE.md: Updated
- DEVELOPMENT_LOG.md: Updated
- FAILED_ATTEMPTS.md: [Updated/No changes]
- Archon Tasks: [X tasks updated]
- Git Commit: [commit hash if created]

NEW DISCOVERIES
---------------
- [Any important learnings]

RECOMMENDED FOR NEXT SESSION
----------------------------
1. [What to focus on]
2. [Any follow-up needed]

Session context has been preserved for continuity.
```

## Important Notes

- NEVER push to remote unless explicitly requested
- ALWAYS preserve context before ending
- If there are uncommitted code changes, ask user before proceeding
- Ensure all task statuses are accurate in Archon
