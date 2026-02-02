# Project Wizard Guide

A comprehensive guide to using the unified project wizard for creating new projects with Claude Code.

---

## Table of Contents

1. [Overview](#overview)
2. [Framework Comparison](#framework-comparison)
3. [Quick Start](#quick-start)
4. [Detailed Walkthrough](#detailed-walkthrough)
5. [Framework Deep Dives](#framework-deep-dives)
6. [Session Management](#session-management)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

---

## Overview

The project wizard (`/project-wizard`) is a comprehensive tool that guides you through setting up new projects using one of three development frameworks. It handles everything from repository creation to Archon task management.

### What the Wizard Does

1. **Framework Selection** - Choose the right methodology for your project
2. **Project Configuration** - Set up project identity, location, and visibility
3. **Technical Stack** - Define language, framework, database, and tooling
4. **Framework Setup** - Configure framework-specific options
5. **Archon Integration** - Create project, documents, and initial tasks
6. **Artifact Generation** - Create all necessary files and directories
7. **State Persistence** - Save progress for multi-session setup

### Key Features

- **Session Persistence** - Pause and resume wizard sessions
- **Three Frameworks** - PRP, Autonomous Harness, and SpecKit
- **Archon Integration** - Automatic project and task creation
- **Validation** - Pre-flight checks before execution
- **Error Recovery** - Graceful handling of failures

---

## Framework Comparison

### Quick Reference

| Aspect | PRP | Harness | SpecKit |
|--------|-----|---------|---------|
| **Best For** | Features, enhancements | Greenfield, complex apps | Compliance, specs |
| **Project Type** | Brownfield | Greenfield | Either |
| **Documentation** | PRD + Plan | Agent prompts | Formal specs |
| **Task Generation** | Manual | Automated (20-50) | Spec-driven |
| **Validation** | Phase gates | Continuous | Checklist |
| **Stakeholder Docs** | Yes | No | Yes |

### PRP Framework (Product Requirement Planning)

**Use when:**
- Adding features to existing codebases
- Stakeholder documentation is required
- Phased implementation with validation gates
- Team collaboration with reviews

**Workflow:**
```
PRD Creation --> Plan Generation --> Implementation --> Review
     |                |                    |              |
     v                v                    v              v
  /prp-prd       /prp-plan          /prp-implement   /prp-review
```

**Artifacts:**
- `PRPs/prds/*.md` - Product Requirements Documents
- `PRPs/plans/*.md` - Implementation Plans
- `PRPs/reviews/*.md` - Review Documents

### Autonomous Harness

**Use when:**
- Building from scratch (greenfield)
- Want autonomous development
- Long-running development cycles
- Complex applications with many features

**Workflow:**
```
Setup --> Initialize --> Code --> Test --> Review (repeat)
   |          |           |        |          |
   v          v           v        v          v
/harness-  /harness-   [Agent]  [Agent]    [Agent]
 setup      init       (Coder)  (Tester)  (Reviewer)
```

**Artifacts:**
- `.harness/config.yaml` - Harness configuration
- `.harness/*_PROMPT.md` - Agent prompt files
- 20-50 Archon tasks generated automatically

### SpecKit Framework

**Use when:**
- Compliance requirements (SOC2, HIPAA, GDPR)
- Complex business logic requiring formal specs
- Audit trails and traceability needed
- Detailed verification checklists required

**Workflow:**
```
Spec Creation --> Validation --> Implementation --> Verification
      |               |               |                |
      v               v               v                v
  Create spec    Validate with   Implement per    Verify against
   document        Ralph loop      spec items       checklist
```

**Artifacts:**
- `specs/*.md` - Formal specifications
- `specs/requirements/` - Requirement documents
- `specs/verification/` - Verification reports
- `checklists/*.md` - Verification checklists

---

## Quick Start

### Start a New Wizard

```bash
# Interactive wizard (recommended for first-time users)
/project-wizard

# Jump directly to a framework
/project-wizard prp
/project-wizard harness
/project-wizard speckit

# Start fresh (ignores previous sessions)
/project-wizard fresh
```

### Resume a Session

```bash
# List and resume
/wizard-resume

# Resume specific project
/wizard-resume my-project

# Resume by session ID
/wizard-resume --session-id abc-123
```

### Check Status

```bash
# Overview of all sessions
/wizard-status

# Specific project details
/wizard-status my-project

# Verify generated artifacts
/wizard-status my-project --artifacts
```

---

## Detailed Walkthrough

### Phase 0: Resume Check

The wizard first checks for existing sessions:

```
EXISTING WIZARD SESSION DETECTED
================================

Project: my-awesome-app
Framework: PRP
Progress: Phase 4 of 7

OPTIONS
-------
1. RESUME - Continue from Phase 4
2. FRESH  - Start a new wizard session
```

### Phase 1: Framework Selection

Choose your development methodology:

```
PROJECT WIZARD - FRAMEWORK SELECTION
====================================

+----------+------------------+-----------------------------+
| Framework| Best For         | Key Features                |
+----------+------------------+-----------------------------+
| PRP      | Features,        | PRD -> Plan -> Implement    |
|          | brownfield       | Stakeholder documentation   |
+----------+------------------+-----------------------------+
| HARNESS  | Greenfield,      | Multi-agent pipeline        |
|          | complex apps     | 20-50 auto-generated tasks  |
+----------+------------------+-----------------------------+
| SPECKIT  | Compliance,      | Formal specifications       |
|          | auditing         | Verification checklists     |
+----------+------------------+-----------------------------+

Which framework? [prp/harness/speckit]
```

### Phase 2: Project Basics

Define your project identity:

```
PROJECT IDENTITY
----------------
1. Project Name: my-awesome-app
2. Description: A modern web application for task management
3. Type: fullstack

REPOSITORY SETUP
----------------
4. Repository Location: E:/Projects/my-awesome-app
5. GitHub Organization: HouseGarofalo
6. Visibility: private
7. Initialize with: [X] README [X] .gitignore [X] LICENSE [X] CI/CD
```

### Phase 3: Technical Stack

Select your technology stack:

```
TECHNICAL STACK
===============

1. Language: TypeScript
2. Framework: React + Vite (frontend) / Hono (backend)
3. Database: PostgreSQL
4. Package Manager: pnpm
```

### Phase 4: Framework Configuration

Framework-specific settings vary by selection.

**PRP Example:**
```
PRP CONFIGURATION
=================

1. Complexity: Medium (1-2 weeks)
2. Phases: 3 (Foundation + Core + Polish)
3. Testing: Standard (unit + integration)
4. Documentation: Standard (README + API docs)
```

**Harness Example:**
```
HARNESS CONFIGURATION
=====================

1. Max Tasks: 30
2. Granularity: Medium (20-40 tasks)
3. Model: claude-sonnet-4-20250514
4. Agents: Initializer, Coder, Tester, Reviewer
5. MCP Servers: filesystem, git, github
```

**SpecKit Example:**
```
SPECKIT CONFIGURATION
=====================

1. Detail Level: Standard
2. Clarification: Balanced
3. Ralph Loop: Enabled (5 iterations, 90% threshold)
4. Traceability: Basic (Req -> Implementation)
```

### Phase 5: Archon Integration

Connect to Archon for task management:

```
ARCHON INTEGRATION
==================

1. Archon Project: Create new
2. Task Breakdown: Generate from description
3. Documents to Create:
   [X] Session Context
   [X] Architecture
   [ ] Deployment
   [ ] API Documentation
```

### Phase 6: Execution

Review and execute:

```
EXECUTION PLAN
==============

The wizard will:
1. [X] Create repository directory structure
2. [ ] Initialize git repository
3. [ ] Create GitHub repository
4. [ ] Create Archon project
5. [ ] Generate framework artifacts
6. [ ] Set up pre-commit hooks
7. [ ] Run initial setup

Proceed? [yes/no]
```

### Phase 7: Completion

Final summary and next steps:

```
PROJECT CREATED SUCCESSFULLY
============================

Project: my-awesome-app
Path: E:/Projects/my-awesome-app
Archon ID: proj-abc123

NEXT STEPS (PRP Framework)
--------------------------
1. Review PRPs/prds/initial-setup-prd.md
2. Run /prp-plan to create implementation plan
3. Run /prp-implement to begin development

Quick Start:
  cd E:/Projects/my-awesome-app
  /start
```

---

## Framework Deep Dives

### PRP Framework Deep Dive

#### When to Choose PRP

- You're enhancing an existing application
- Stakeholders need documentation for review
- You want explicit validation gates between phases
- Team members need clear handoff points

#### PRP Phase Structure

**Phase 1: Foundation**
- Set up project structure
- Configure development environment
- Establish testing framework
- Create base documentation

**Phase 2: Core Implementation**
- Implement main features
- Write unit tests
- Integrate with existing systems
- Document API changes

**Phase 3: Polish**
- Add error handling
- Improve performance
- Complete documentation
- Final testing and review

#### PRP Commands

```bash
/prp-prd "Feature description"     # Create PRD
/prp-plan PRPs/prds/feature.md     # Generate plan
/prp-implement PRPs/plans/plan.md  # Execute plan
/prp-review                        # Review implementation
```

### Autonomous Harness Deep Dive

#### When to Choose Harness

- Building a new application from scratch
- Want automated task generation
- Comfortable with agent-driven development
- Need iterative refinement loops

#### Agent Pipeline

```
+-------------+     +--------+     +--------+     +----------+
| Initializer | --> | Coder  | --> | Tester | --> | Reviewer |
+-------------+     +--------+     +--------+     +----------+
      |                 |              |               |
      v                 v              v               v
  Generate          Implement      Write tests    Review code
   tasks            features       Run tests      Suggest fixes
```

#### Harness Configuration Options

**Task Granularity:**
- **Coarse** (10-20 tasks): Large tasks, faster completion
- **Medium** (20-40 tasks): Balanced approach (recommended)
- **Fine** (40-70 tasks): Small tasks, more control

**Agent Selection:**
- **Initializer**: Always enabled, generates tasks
- **Coder**: Always enabled, implements features
- **Tester**: Recommended, writes and runs tests
- **Reviewer**: Optional, reviews code quality
- **Documenter**: Optional, generates documentation

#### Harness Commands

```bash
/harness-setup                     # Initial configuration
/harness-init                      # Generate tasks from spec
/harness-status                    # Check current status
/harness-next                      # Process next task
```

### SpecKit Framework Deep Dive

#### When to Choose SpecKit

- Working in regulated industries (healthcare, finance)
- Need audit trails and traceability
- Complex business logic requiring formal specs
- Want verification checklists

#### Specification Structure

```markdown
# Specification: Feature Name

## Metadata
- Spec ID, Version, Status, Compliance

## Requirements
- Functional: REQ-F-001, REQ-F-002...
- Non-Functional: REQ-NF-001, REQ-NF-002...

## Design
- Architecture diagrams
- Component specifications
- API definitions

## Verification
- Test plans
- Acceptance criteria
- Traceability matrix
```

#### Ralph Loop (Optional)

The Ralph methodology provides iterative refinement:

1. **Create** initial specification
2. **Review** for completeness
3. **Refine** based on feedback
4. **Validate** against criteria
5. **Repeat** until convergence threshold met

#### SpecKit Commands

```bash
# Create specification
/spec-create "Feature name"

# Validate specification
/spec-validate specs/feature-spec.md

# Track implementation
/spec-status specs/feature-spec.md
```

---

## Session Management

### Understanding Sessions

Each wizard run creates a session that can be:
- **Paused** - Interrupt and resume later
- **Resumed** - Continue from last phase
- **Completed** - Successfully finished
- **Cancelled** - User chose to stop

### Session State Storage

Sessions are stored as Archon documents:

```python
# Find your sessions
find_documents(query="Project Wizard State")

# View session details
find_documents(
    project_id="your-project-id",
    title="Project Wizard State: your-project"
)
```

### Multi-Session Workflows

For complex projects, you might:

1. **Day 1**: Start wizard, complete through Phase 3
2. **Review**: Discuss tech stack with team
3. **Day 2**: Resume, modify Phase 3, continue
4. **Day 3**: Complete execution

```bash
# Day 1: Start
/project-wizard
# Complete phases 1-3, then pause

# Day 2: Resume
/wizard-status           # Check progress
/wizard-resume my-app    # Continue from Phase 4

# Day 3: Complete
/wizard-resume my-app    # Finish remaining phases
```

---

## Troubleshooting

### Common Issues

#### "Archon MCP server not available"

**Cause:** Archon connection is not established

**Solution:**
```bash
# Check MCP status
/mcp

# Verify Archon is listed and connected
# If not, check your MCP configuration
```

#### "Directory already exists"

**Cause:** Target path contains files

**Solution:**
```bash
# Option 1: Use existing directory
# Wizard will ask if you want to use it

# Option 2: Choose different path
# Enter a new path when prompted

# Option 3: Remove existing
rm -rf /path/to/project  # Be careful!
```

#### "GitHub authentication failed"

**Cause:** GitHub CLI not authenticated

**Solution:**
```bash
# Authenticate GitHub CLI
gh auth login

# Verify authentication
gh auth status
```

#### "Session state corrupted"

**Cause:** Incomplete document in Archon

**Solution:**
```bash
# Start fresh, previous state will be archived
/project-wizard fresh
```

### Recovery Procedures

#### Partial Execution Failure

If the wizard fails during Phase 6:

1. Check `/wizard-status project-name --log` for error
2. Fix the underlying issue (permissions, network, etc.)
3. Resume with `/wizard-resume project-name`
4. If resume fails, check `--artifacts` flag

#### Missing Artifacts

If some files weren't created:

```bash
# Check what's missing
/wizard-status project-name --artifacts

# Manually create missing items
mkdir -p /path/to/project/missing/directory

# Or restart that phase
/project-wizard
# Select resume, but force re-run of Phase 6
```

---

## Best Practices

### Framework Selection

1. **Start with your constraints** - Compliance? Greenfield? Team size?
2. **Match complexity to framework** - Simple feature? PRP. Complex app? Harness.
3. **Consider maintenance** - Who will maintain this? Choose accordingly.

### Configuration Tips

1. **Project naming** - Use lowercase, hyphens, descriptive names
2. **Repository path** - Use absolute paths, avoid spaces
3. **Stack selection** - Choose what you know unless learning
4. **Task granularity** - Start with medium, adjust based on experience

### Workflow Tips

1. **Complete one session** - Don't start multiple wizards simultaneously
2. **Verify after execution** - Always run `/wizard-status --artifacts`
3. **Commit early** - The wizard makes initial commit, but verify
4. **Document decisions** - Use the wizard's notes section

### Integration Tips

1. **Archon-first** - Always use Archon for task management
2. **Consistent naming** - Match Archon project names to repo names
3. **Document links** - Keep Archon documents updated
4. **Session context** - Update after each major milestone

---

## Examples

### Example 1: React Application with PRP

```bash
# Start wizard
/project-wizard prp

# Configuration
Project Name: task-manager
Type: fullstack
Language: TypeScript
Framework: Next.js
Database: Supabase

# PRP Configuration
Complexity: Medium
Phases: 3
Testing: Standard
Documentation: Standard

# Result
cd E:/Projects/task-manager
/prp-prd "Task management application with real-time collaboration"
```

### Example 2: API Service with Harness

```bash
# Start wizard
/project-wizard harness

# Configuration
Project Name: user-api
Type: backend-api
Language: Python
Framework: FastAPI
Database: PostgreSQL

# Harness Configuration
Max Tasks: 40
Granularity: Medium
Agents: Initializer, Coder, Tester, Reviewer
Testing: Unit + Integration

# Result
cd E:/Projects/user-api
/harness-init "Create user management API with auth, CRUD, and rate limiting"
```

### Example 3: Compliance Feature with SpecKit

```bash
# Start wizard
/project-wizard speckit

# Configuration
Project Name: payment-processor
Type: library
Language: TypeScript
Database: PostgreSQL

# SpecKit Configuration
Detail Level: Comprehensive
Clarification: Ask Many
Ralph Loop: Enabled
Traceability: Full
Compliance: SOC2

# Result
cd E:/Projects/payment-processor
# Create formal specification before any code
```

---

## Reference

### All Wizard Commands

| Command | Description |
|---------|-------------|
| `/project-wizard` | Start interactive wizard |
| `/project-wizard prp` | Start with PRP framework |
| `/project-wizard harness` | Start with Harness framework |
| `/project-wizard speckit` | Start with SpecKit framework |
| `/project-wizard fresh` | Start fresh, archive previous |
| `/project-wizard resume` | Resume previous session |
| `/wizard-resume` | List and resume sessions |
| `/wizard-status` | Check wizard session status |

### Configuration Files

| File | Purpose |
|------|---------|
| `.claude/config.yaml` | Project configuration |
| `.harness/config.yaml` | Harness configuration |
| `specs/SPEC_TEMPLATE.md` | SpecKit template |
| `PRPs/prds/*.md` | PRP requirements |

### Template Locations

| Template | Path |
|----------|------|
| Wizard State | `templates/wizard/archon-wizard-state.md` |
| PRP Reference | `templates/wizard/prp-template.md` |
| Harness Config | `templates/wizard/harness-config-template.json` |
| SpecKit Spec | `templates/wizard/speckit-spec-template.md` |

---

*Guide Version*: 1.0
*Last Updated*: 2024-01-15
*Wizard Version*: 1.0
