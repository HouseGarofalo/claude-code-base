# PRP Framework Quick Reference

> Product Requirement Planning (PRP) framework template for feature development. Use this for brownfield projects, single features, and stakeholder-driven development.

---

## When to Use PRP

- Feature development within existing codebases
- Enhancements that require stakeholder documentation
- Phased implementation with validation gates
- Projects requiring PRD/Plan artifacts for review

## Workflow Overview

```
/prp-prd  -->  /prp-plan  -->  /prp-implement
   |              |                  |
   v              v                  v
 PRD.md       Plan.md           Code + Tests
```

---

## PRP Configuration Options

### Complexity Levels

| Level | Scope | Duration | Phases |
|-------|-------|----------|--------|
| **Low** | Simple CRUD, minor enhancement | 1-3 days | 2 |
| **Medium** | New feature, moderate scope | 1-2 weeks | 3 |
| **High** | Major feature, significant scope | 2-4 weeks | 4 |
| **Very High** | System-level change | 1+ month | 4-6 |

### Testing Strategies

| Strategy | Includes | Best For |
|----------|----------|----------|
| **Minimal** | Manual testing, happy path | Quick prototypes |
| **Standard** | Unit tests for core logic | Most features |
| **Thorough** | Unit + integration tests | Complex features |
| **Complete** | Unit + integration + E2E + performance | Critical systems |

### Documentation Levels

| Level | Artifacts | Best For |
|-------|-----------|----------|
| **Minimal** | Code comments only | Internal tools |
| **Standard** | README + API docs | Team projects |
| **Thorough** | Full technical docs | Open source |
| **Complete** | Technical + user docs + diagrams | Enterprise |

---

## PRD Quick Template

```markdown
# {Feature Name} PRD

**Status**: Draft | **Version**: 1.0
**Author**: {Name} | **Created**: {Date}

## Overview

### What
{2-3 sentences describing what we're building}

### Why
{Business value and user impact}

## Requirements

### Functional
- [ ] FR-1: {Requirement}
- [ ] FR-2: {Requirement}

### Non-Functional
- [ ] NFR-1: {Performance/Security/etc.}

## Implementation Phases

| Phase | Description | Duration |
|-------|-------------|----------|
| 1 | Foundation | X days |
| 2 | Core Implementation | X days |
| 3 | Polish & Testing | X days |

## Success Criteria
- [ ] {Criterion 1}
- [ ] {Criterion 2}
```

---

## Plan Quick Template

```markdown
# {Feature Name} - Phase {N} Plan

**PRD**: {link to PRD}
**Status**: pending

## Phase Goal
{What this phase delivers}

## Tasks

### Task 1: {Title}
- **Description**: {What to do}
- **Files**: {Files to create/modify}
- **Tests**: {Test requirements}
- **Validation**: `{command}`

### Task 2: {Title}
...

## Validation Commands

```bash
# Run all validations
{test command}
{lint command}
{type check command}
```

## Definition of Done
- [ ] All tasks complete
- [ ] Tests passing
- [ ] Code reviewed
- [ ] Documentation updated
```

---

## Archon Task Format

When creating tasks from a PRP plan:

```python
manage_task("create",
    project_id=PROJECT_ID,
    title="[FR-1.1] Implement user authentication",
    description="""
## Context
From PRD: {prd-name}
Phase: {phase-number}

## Requirements
- {requirement 1}
- {requirement 2}

## Acceptance Criteria
- [ ] {criterion 1}
- [ ] {criterion 2}

## Technical Notes
{implementation hints}
    """,
    status="todo",
    priority="high",
    labels=["phase-1", "authentication"]
)
```

---

## Validation Loop

PRP includes validation at each phase transition:

```
Phase N Complete
      |
      v
Run Validation Commands
      |
      +--[PASS]--> Document Results --> Start Phase N+1
      |
      +--[FAIL]--> Fix Issues --> Re-validate
```

### Common Validation Commands

```bash
# Test validation
npm test
pytest
go test ./...

# Type checking
npm run typecheck
mypy src/

# Lint validation
npm run lint
ruff check .

# Build validation
npm run build
python -m build
```

---

## Directory Structure

```
project/
├── PRPs/
│   ├── prds/
│   │   └── {feature-name}.prd.md
│   ├── plans/
│   │   ├── {feature-name}-phase-1.plan.md
│   │   ├── {feature-name}-phase-2.plan.md
│   │   └── completed/
│   └── reviews/
│       └── {feature-name}-review.md
├── src/
│   └── {implementation}
└── tests/
    └── {tests}
```

---

## Quick Commands

```bash
# Create PRD
/prp-prd "Feature description"

# Create plan from PRD
/prp-plan PRPs/prds/{feature}.prd.md

# Implement plan
/prp-implement PRPs/plans/{feature}-phase-1.plan.md

# Review implementation
/prp-review
```

---

*Template Version*: 1.0
*Framework*: PRP (Product Requirement Planning)
