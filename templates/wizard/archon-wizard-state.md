# Project Wizard State: [PROJECT_NAME]

> Template for persisting wizard state to Archon documents. Replace bracketed placeholders with actual values.

---

## Metadata

| Field | Value |
|-------|-------|
| **Session ID** | [UUID - auto-generated] |
| **Started** | [YYYY-MM-DD HH:MM:SS] |
| **Last Updated** | [YYYY-MM-DD HH:MM:SS] |
| **Current Phase** | [0-7] |
| **Framework** | [PRP\|HARNESS\|SPECKIT] |
| **Status** | [in-progress\|completed\|cancelled] |

---

## Phase Progress

Track completion status for each phase:

- [ ] Phase 0: Resume Check
- [ ] Phase 1: Framework Selection
- [ ] Phase 2: Project Basics
- [ ] Phase 3: Technical Stack
- [ ] Phase 4: Framework Configuration
- [ ] Phase 5: Archon Integration
- [ ] Phase 6: Execution
- [ ] Phase 7: Save State

**Progress**: [X]/7 phases ([XX]%)

---

## Configuration

### Project Basics

```json
{
  "name": "",
  "description": "",
  "type": "",
  "repository_path": "",
  "github_org": "",
  "visibility": "private",
  "init_options": {
    "readme": true,
    "gitignore": true,
    "license": "MIT",
    "ci_cd": true
  }
}
```

### Technical Stack

```json
{
  "language": "",
  "framework": "",
  "database": "",
  "package_manager": ""
}
```

### Framework Configuration

#### For PRP Framework

```json
{
  "complexity": "medium",
  "phases": 3,
  "testing": "standard",
  "documentation": "standard"
}
```

#### For Autonomous Harness

```json
{
  "max_tasks": 30,
  "granularity": "medium",
  "iteration_limit": 50,
  "model": "claude-sonnet-4-20250514",
  "agents": ["initializer", "coder", "tester"],
  "mcp_servers": ["filesystem", "git"],
  "testing": "unit_integration",
  "browser_tool": "playwright",
  "allowed_commands": ["npm", "npx", "node", "python", "pip", "git", "ls", "cat", "mkdir", "rm", "cp", "mv"],
  "fs_restrictions": "project_only"
}
```

#### For SpecKit Framework

```json
{
  "detail_level": "standard",
  "clarification": "balanced",
  "checklist_granularity": "standard",
  "ralph_enabled": false,
  "ralph_iterations": 5,
  "ralph_threshold": 0.9,
  "traceability": "basic",
  "compliance": null
}
```

### Archon Integration

```json
{
  "project_id": "",
  "is_new": true,
  "parent_id": null,
  "task_breakdown": "generate",
  "default_assignee": "claude-code",
  "documents": ["session_context", "architecture"]
}
```

---

## Generated Artifacts

Track all files and resources created by the wizard:

### Repository & Git

- [ ] Directory created: `[path]`
- [ ] Git initialized
- [ ] Initial commit made
- [ ] GitHub repo created: `[url]`
- [ ] Remote origin configured

### Configuration Files

- [ ] `.claude/config.yaml` - Project configuration
- [ ] `.gitignore` - Git ignore rules
- [ ] `.pre-commit-config.yaml` - Pre-commit hooks
- [ ] `.editorconfig` - Editor configuration

### Framework Artifacts

#### PRP Framework

- [ ] `PRPs/prds/initial-setup-prd.md` - Initial PRD
- [ ] `PRPs/plans/` - Plans directory
- [ ] `PRPs/reviews/` - Reviews directory

#### Autonomous Harness

- [ ] `.harness/config.yaml` - Harness configuration
- [ ] `.harness/INITIALIZER_PROMPT.md` - Initializer agent prompt
- [ ] `.harness/CODER_PROMPT.md` - Coder agent prompt
- [ ] `.harness/TESTER_PROMPT.md` - Tester agent prompt
- [ ] `.harness/REVIEWER_PROMPT.md` - Reviewer agent prompt (if enabled)

#### SpecKit Framework

- [ ] `specs/SPEC_TEMPLATE.md` - Specification template
- [ ] `specs/requirements/` - Requirements directory
- [ ] `specs/design/` - Design directory
- [ ] `specs/verification/` - Verification directory
- [ ] `checklists/VERIFICATION_CHECKLIST.md` - Verification checklist

### Archon Resources

- [ ] Archon project created: `[project_id]`
- [ ] Session Context document created
- [ ] Architecture document created
- [ ] Deployment document created (if applicable)
- [ ] Initial tasks created: `[count]` tasks

---

## Execution Log

Record significant events during wizard execution:

| Timestamp | Phase | Action | Result | Notes |
|-----------|-------|--------|--------|-------|
| [timestamp] | 0 | Resume check | No previous session | Started fresh |
| [timestamp] | 1 | Framework selection | PRP selected | User preference |
| [timestamp] | 2 | Project basics | Validated | Path exists |
| | | | | |

---

## Error Recovery

If execution was interrupted, record recovery information:

### Last Successful Phase

**Phase**: [X]
**Completed At**: [timestamp]
**State Saved**: Yes/No

### Failed Step (if applicable)

**Step**: [step description]
**Error**: [error message]
**Attempted Recovery**: [yes/no]
**Recovery Result**: [success/failed]

### Manual Steps Required

1. [Step 1 - if any manual intervention needed]
2. [Step 2]

---

## Resume Instructions

To resume this wizard session:

```bash
# Using the wizard command
/project-wizard resume

# Or directly reference this session
/project-wizard resume --session-id [SESSION_ID]
```

### Pre-Resume Checklist

Before resuming, verify:

- [ ] Archon MCP server is available
- [ ] GitHub CLI is authenticated (if GitHub repo needed)
- [ ] Target directory is accessible
- [ ] No conflicting changes have been made

### Resume From Phase [X]

The wizard will:

1. Load this state document
2. Validate existing artifacts
3. Continue from Phase [X]: [Phase Name]
4. Skip completed phases unless `--force-rerun` specified

---

## Notes

Additional context or decisions made during the wizard session:

- [Note 1]
- [Note 2]

---

## Quick Commands

```bash
# Check wizard status
/wizard-status

# Resume wizard
/project-wizard resume

# Start fresh (archives this state)
/project-wizard fresh

# View Archon project
find_projects(project_id="[project_id]")

# View generated tasks
find_tasks(filter_by="project", filter_value="[project_id]")
```

---

*State Version*: 1.0
*Created By*: Project Wizard v1.0
*Last Modified*: [timestamp]
