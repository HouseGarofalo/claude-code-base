---
name: speckit-wizard
version: 1.0.0
description: SpecKit wizard for specification-driven development. Creates detailed feature specifications, requirements checklists, and integrates with Ralph loop for iterative implementation with validation. Use when building complex features needing formal requirements, creating testable specifications, or implementing with checklist-validated progress.
---

# SpecKit Wizard: Specification-Driven Development

Guide users through creating detailed, testable specifications that drive implementation. SpecKit transforms vague feature requests into structured specifications with acceptance criteria, requirements checklists, and technical plans that integrate with Ralph loop for iterative completion.

## Triggers

Use this skill when:
- User selected SpecKit in project wizard
- Complex features needing detailed specifications
- Projects requiring formal requirements documentation
- Integration with Ralph iterative loop needed
- Creating features with clear acceptance criteria
- Building systems that need traceability
- Keywords: speckit, specification, spec, requirements, checklist, formal spec, specify, clarify, plan, acceptance criteria

## Core Philosophy

```
SPECKIT PRINCIPLES

1. SPECIFICATION BEFORE CODE
   - Never implement without a spec
   - Specs prevent scope creep
   - Specs enable parallel work

2. REQUIREMENTS ARE TESTABLE
   - Every requirement maps to a test
   - If you can't test it, rewrite it
   - Acceptance criteria in Gherkin format

3. CHECKLISTS DRIVE PROGRESS
   - One checkbox per deliverable
   - Automated validation where possible
   - Visual progress tracking

4. ITERATIVE REFINEMENT
   - Specs evolve through clarification
   - Plans adapt to discoveries
   - Ralph loop handles implementation
```

---

## Architecture Overview

```
SPECKIT PIPELINE

                    ┌──────────────────────────────────────────────┐
                    │               USER INPUT                      │
                    │  "I need a feature that does X, Y, and Z"    │
                    └───────────────────┬──────────────────────────┘
                                        │
                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                           PHASE 1: @speckit-specify                            │
│                                                                                │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │   Extract   │───>│  Identify   │───>│   Draft     │───>│  Generate   │   │
│  │   Concepts  │    │   Actors    │    │   Stories   │    │    Spec     │   │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘   │
│                                                                                │
│  Output: specs/NNN-feature-name/spec.md (Draft)                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                           PHASE 2: @speckit-clarify                            │
│                                                                                │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │   Detect    │───>│    Ask      │───>│   Record    │───>│   Update    │   │
│  │ Ambiguities │    │  Questions  │    │  Decisions  │    │    Spec     │   │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘   │
│                                                                                │
│  Output: specs/NNN-feature-name/spec.md (Finalized)                           │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                           PHASE 3: @speckit-plan                               │
│                                                                                │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │   Analyze   │───>│   Break     │───>│   Order     │───>│  Generate   │   │
│  │Architecture │    │   Tasks     │    │   by Deps   │    │    Plan     │   │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘   │
│                                                                                │
│  Output: specs/NNN-feature-name/plan.md                                       │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                        PHASE 4: @speckit-implement                             │
│                                                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                         IMPLEMENTATION LOOP                              │ │
│  │                                                                          │ │
│  │   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐            │ │
│  │   │  Pick   │───>│  Code   │───>│ Validate│───>│ Update  │            │ │
│  │   │  Task   │    │  It     │    │  It     │    │Checklist│            │ │
│  │   └─────────┘    └─────────┘    └────┬────┘    └────┬────┘            │ │
│  │        ▲                             │              │                  │ │
│  │        │              ┌──────────────┘              │                  │ │
│  │        │              ▼                             │                  │ │
│  │        │         [FAIL]──> Fix ─────────────────────┘                  │ │
│  │        │              │                                                │ │
│  │        └──────────────┴─── [PASS] ◄────────────────────────────────── │ │
│  │                                                                          │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                                │
│  Optional: Delegates to @ralph-loop for autonomous iteration                  │
│                                                                                │
│  Output: Implementation + specs/NNN-feature-name/checklists/requirements.md  │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
                    ┌──────────────────────────────────────────────┐
                    │              SPEC_COMPLETE                    │
                    │  All requirements validated and checked off  │
                    └──────────────────────────────────────────────┘
```

### Artifact Structure

```
specs/
└── NNN-feature-name/
    ├── spec.md                    # Feature specification
    │   ├── Overview
    │   ├── Problem Statement
    │   ├── User Scenarios (prioritized)
    │   ├── Functional Requirements
    │   ├── Non-Functional Requirements
    │   ├── Acceptance Criteria (Gherkin)
    │   └── Assumptions & Decisions
    │
    ├── plan.md                    # Technical implementation plan
    │   ├── Architecture Analysis
    │   ├── Implementation Tasks
    │   ├── Dependencies
    │   └── Testing Strategy
    │
    └── checklists/
        ├── requirements.md        # Main requirements checklist
        ├── testing.md             # Test coverage checklist
        └── review.md              # Pre-merge review checklist
```

---

## Setup Wizard

When activated, guide user through SpecKit configuration:

### Phase 1: Feature Information

```markdown
## SpecKit Wizard - Phase 1: Feature Information

**1. Feature Name:**
   Short, descriptive name for the feature (e.g., "user-authentication", "payment-processing")
   > This becomes the spec directory name: specs/NNN-[feature-name]/

**2. Feature Description:**
   Detailed description of what you want to build.

   Include as much context as possible:
   - What problem does this solve?
   - Who are the users?
   - What should it do?
   - What should it NOT do?
   - Any constraints or requirements?

   > The more detail you provide, the better the specification.

**3. Feature Priority:**
   - P0: Critical - Must have for launch
   - P1: High - Important but can delay
   - P2: Medium - Nice to have
   - P3: Low - Future consideration
```

### Phase 2: Specification Detail Level

```markdown
## Phase 2: Specification Detail Level

**4. Detail Level:**
   How comprehensive should the specification be?

   - **Minimal**: Basic requirements, key user stories only
     - Best for: Simple features, prototypes, quick iterations
     - Output: ~50 lines spec, ~10 requirements

   - **Standard**: Complete requirements, user stories, acceptance criteria
     - Best for: Most production features
     - Output: ~150 lines spec, ~25 requirements

   - **Comprehensive**: Detailed requirements, edge cases, error scenarios, test matrices
     - Best for: Critical systems, compliance needs, complex integrations
     - Output: ~300+ lines spec, ~50+ requirements

   > Default: Standard

**5. Domain Context:**
   What domain is this feature in?

   - Web Application
   - API/Backend Service
   - CLI Tool
   - Data Pipeline
   - Infrastructure
   - Mobile Application
   - Library/SDK
   - Other: [specify]
```

### Phase 3: Clarification Preferences

```markdown
## Phase 3: Clarification Preferences

**6. Clarification Tolerance:**
   How should ambiguities be handled?

   - **Ask Many Questions**: Pause and ask for every ambiguity found
     - Pro: Most accurate spec
     - Con: Slower process, more interruptions

   - **Balanced** (Recommended): Ask only critical questions (max 3 rounds)
     - Pro: Good accuracy with reasonable speed
     - Con: Some assumptions may need revision

   - **Make Assumptions**: Use reasonable defaults, document all assumptions
     - Pro: Fastest spec generation
     - Con: May need significant revision

   > Default: Balanced

**7. Assumption Documentation Style:**
   How should assumptions be recorded?

   - **Inline**: Document assumptions next to relevant requirements
   - **Dedicated Section**: Collect all assumptions in one section
   - **Both**: Inline + summary section

   > Default: Both
```

### Phase 4: Checklist Configuration

```markdown
## Phase 4: Checklist Configuration

**8. Checklist Granularity:**
   How detailed should the requirements checklist be?

   - **High-Level**: One checkbox per major requirement (FR-001, FR-002)
     - Best for: Quick overview, management tracking
     - ~10-20 items

   - **Detailed**: One checkbox per acceptance criterion
     - Best for: Development tracking, QA validation
     - ~25-50 items

   - **Granular**: One checkbox per test case
     - Best for: Compliance, audit trails, comprehensive testing
     - ~50-100+ items

   > Default: Detailed

**9. Checklist Tracking Method:**
   How should checklist progress be updated?

   - **Manual**: Developer marks items complete
   - **Semi-Automatic**: Update on test pass (prompt for confirmation)
   - **Automatic**: CI integration updates on green tests

   > Default: Manual

**10. Generate Additional Checklists:**
    - [ ] Testing Checklist (test coverage tracking)
    - [ ] Review Checklist (pre-merge validation)
    - [ ] Deployment Checklist (release preparation)

   > Default: Testing + Review enabled
```

### Phase 5: Ralph Loop Integration

```markdown
## Phase 5: Ralph Loop Integration

**11. Enable Ralph Loop?**
    Should implementation use Ralph's iterative loop methodology?

    - **Yes**: Ralph manages implementation iterations
      - Self-correcting development
      - Automatic retry on failures
      - Archon task integration

    - **No**: Sequential manual implementation
      - Direct coding without iteration wrapper
      - Manual validation steps

   > Default: Yes (recommended for complex features)

**12. If Ralph Enabled - Configuration:**

    **Max Iterations per Requirement:**
    How many attempts before marking a requirement as blocked?
    > Default: 3

    **Completion Promise:**
    What signals that implementation is complete?
    - SPEC_COMPLETE (all checklist items checked)
    - TESTS_PASS (all tests green)
    - MANUAL_APPROVAL (human sign-off required)
    > Default: SPEC_COMPLETE

    **Escape Hatch Strategy:**
    What to do when stuck on a requirement?
    - **Mark Blocked, Continue**: Skip blocked item, proceed with others
    - **Mark Blocked, Stop**: Halt and request human intervention
    - **Decompose**: Break requirement into smaller pieces

    > Default: Mark Blocked, Continue
```

---

## Phase Execution: @speckit-specify

### Input Processing

Parse the user's feature description to extract:

```yaml
extraction_targets:
  actors:
    description: "Who interacts with this feature?"
    examples: ["user", "admin", "system", "external service"]

  actions:
    description: "What actions can be performed?"
    examples: ["create", "update", "delete", "view", "export"]

  entities:
    description: "What data/objects are involved?"
    examples: ["account", "order", "document", "notification"]

  constraints:
    description: "What limits or rules apply?"
    examples: ["max 100 items", "admin only", "rate limited"]

  triggers:
    description: "What initiates this feature?"
    examples: ["user click", "scheduled job", "API call", "event"]

  outcomes:
    description: "What results from using this feature?"
    examples: ["data saved", "email sent", "report generated"]

  edge_cases:
    description: "What unusual situations might occur?"
    examples: ["empty input", "duplicate entry", "timeout"]

  dependencies:
    description: "What existing systems does this touch?"
    examples: ["auth service", "database", "third-party API"]
```

### Specification Template

Generate specification using this structure:

```markdown
# Feature Specification: [FEATURE_NAME]

## Overview

| Field | Value |
|-------|-------|
| **Feature ID** | [NNN-feature-name] |
| **Branch** | feature/[NNN-feature-name] |
| **Status** | Draft |
| **Priority** | [P0/P1/P2/P3] |
| **Created** | [DATE] |
| **Author** | [SpecKit] |

## Problem Statement

### Background
[Context about why this feature is needed]

### Problem
[Clear statement of the problem being solved]

### Impact
[What happens if this problem isn't solved]

### Success Metrics
- [Measurable outcome 1]
- [Measurable outcome 2]

---

## User Scenarios

### Scenario Priority Key
- **P1**: Critical path - Must work for feature to be usable
- **P2**: Important - Significantly impacts user experience
- **P3**: Enhancement - Nice to have, not blocking

### P1-S1: [Primary Scenario Name]

**Priority**: P1 (Critical)
**Actor**: [Who performs this action]
**Description**: [What the user does and why]
**Frequency**: [How often this occurs]
**Business Value**: [Why this matters]

#### Preconditions
- [What must be true before this scenario]
- [Required state or data]

#### Flow
1. [Step 1]
2. [Step 2]
3. [Step 3]

#### Acceptance Criteria
```gherkin
Feature: [FEATURE_NAME] - [Scenario Name]

  Scenario: [Happy path description]
    Given [initial context]
    And [additional context]
    When [action taken]
    Then [expected outcome]
    And [additional outcome]

  Scenario: [Alternative path]
    Given [different context]
    When [action taken]
    Then [different outcome]
```

#### Edge Cases
- [Edge case 1]: [How to handle]
- [Edge case 2]: [How to handle]

---

### P1-S2: [Second Critical Scenario]
[Same structure as above]

---

### P2-S1: [Important Scenario]
[Same structure as above]

---

## Requirements

### Functional Requirements

#### Core Functionality

| ID | Requirement | Priority | Testable |
|----|-------------|----------|----------|
| FR-001 | System MUST [capability] | P1 | [Test approach] |
| FR-002 | System MUST [capability] | P1 | [Test approach] |
| FR-003 | System SHOULD [capability] | P2 | [Test approach] |

#### Data Requirements

| ID | Requirement | Priority | Testable |
|----|-------------|----------|----------|
| FR-010 | System MUST store [data] | P1 | [Test approach] |
| FR-011 | System MUST validate [data] | P1 | [Test approach] |

#### Integration Requirements

| ID | Requirement | Priority | Testable |
|----|-------------|----------|----------|
| FR-020 | System MUST integrate with [service] | P1 | [Test approach] |

### Non-Functional Requirements

#### Performance

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-001 | Response time | < [X]ms | [How to measure] |
| NFR-002 | Throughput | > [X] req/s | [How to measure] |

#### Security

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-010 | Authentication | [Type] | [Verification] |
| NFR-011 | Authorization | [Model] | [Verification] |

#### Reliability

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-020 | Availability | [X]% uptime | [Monitoring] |
| NFR-021 | Error handling | [Strategy] | [Verification] |

---

## Success Criteria

The feature is complete when:

- [ ] All P1 scenarios pass acceptance tests
- [ ] All P1 functional requirements verified
- [ ] All non-functional requirements within targets
- [ ] Code review approved
- [ ] Documentation updated

---

## Out of Scope

**Explicitly excluded from this feature:**

- [Exclusion 1]: [Why excluded, where it belongs]
- [Exclusion 2]: [Why excluded, where it belongs]

---

## Assumptions

**Decisions made during specification:**

| ID | Assumption | Rationale | Impact if Wrong |
|----|------------|-----------|-----------------|
| A-001 | [Assumption] | [Why assumed] | [Mitigation] |
| A-002 | [Assumption] | [Why assumed] | [Mitigation] |

---

## Open Questions

**[NEEDS CLARIFICATION]** markers indicate items requiring user input:

- [ ] **Q1**: [Question about requirement]
  - Context: [Why this matters]
  - Options: [Possible answers]

- [ ] **Q2**: [Question about edge case]
  - Context: [Why this matters]
  - Options: [Possible answers]

---

## Glossary

| Term | Definition |
|------|------------|
| [Term 1] | [Definition] |
| [Term 2] | [Definition] |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | [DATE] | SpecKit | Initial draft |
```

---

## Phase Execution: @speckit-clarify

### Ambiguity Detection

Scan the specification for:

```yaml
ambiguity_patterns:
  vague_terms:
    patterns: ["should", "might", "could", "various", "etc", "some", "many"]
    action: "Replace with specific, measurable terms"

  missing_details:
    patterns: ["TBD", "TODO", "NEEDS CLARIFICATION", "???", "[...]"]
    action: "Gather specific information"

  implicit_assumptions:
    patterns: ["obviously", "clearly", "as usual", "standard"]
    action: "Make assumptions explicit"

  undefined_behavior:
    patterns: ["error", "fail", "invalid", "edge case"]
    action: "Define specific handling"

  scope_creep_risk:
    patterns: ["and more", "also", "plus", "additionally"]
    action: "Confirm in scope or exclude"
```

### Question Prioritization

```yaml
question_priority:
  critical:
    - Affects core functionality
    - Blocks multiple requirements
    - Security or compliance related
    - Requires user/business decision

  important:
    - Affects user experience
    - Has significant implementation impact
    - Needs domain expertise

  minor:
    - Affects edge cases only
    - Has reasonable default
    - Purely technical decision
```

### Clarification Session

```markdown
## SpecKit Clarification - [FEATURE_NAME]

I've reviewed the specification and identified [N] items needing clarification.

### Critical Questions (Must Answer)

**Q1: [Question]**
Context: [Why this matters for the spec]
Affects: [Requirements impacted: FR-001, FR-005]
Options:
  a) [Option A] - [Implications]
  b) [Option B] - [Implications]
  c) [Other - please specify]

Your choice: ___

---

**Q2: [Question]**
...

---

### Assumptions Made (Review)

For the following items, I've made assumptions. Please confirm or correct:

| # | Assumption | Your Feedback |
|---|------------|---------------|
| 1 | [Assumption] | ✓ Correct / ✗ Wrong: ___ |
| 2 | [Assumption] | ✓ Correct / ✗ Wrong: ___ |

---

### Minor Items (Proceeding with Defaults)

These items have reasonable defaults. I'll proceed unless you object:

- [Item 1]: Defaulting to [value] because [reason]
- [Item 2]: Defaulting to [value] because [reason]

Object to any? (list numbers or "none"): ___
```

### Post-Clarification Update

After clarification, update spec with:

```markdown
---

## Clarification Record

**Session Date**: [DATE]
**Questions Asked**: [N]
**Decisions Made**: [N]

| Question | Decision | Rationale |
|----------|----------|-----------|
| [Q1] | [Decision] | [User's reasoning] |
| [Q2] | [Decision] | [User's reasoning] |

**Assumptions Confirmed**: [List]
**Assumptions Corrected**: [List with corrections]

---
```

---

## Phase Execution: @speckit-plan

### Architecture Analysis

Before planning, analyze:

```yaml
analysis_checklist:
  existing_code:
    - What existing systems does this touch?
    - What patterns are already established?
    - What can be reused vs. created new?

  dependencies:
    - What external services are needed?
    - What internal APIs will be called?
    - What new dependencies are required?

  data_flow:
    - Where does data originate?
    - How does it transform?
    - Where is it stored?

  integration_points:
    - What interfaces need to be created?
    - What existing interfaces need modification?
    - What contracts must be maintained?
```

### Technical Plan Template

```markdown
# Technical Plan: [FEATURE_NAME]

## Overview

| Field | Value |
|-------|-------|
| **Spec Reference** | specs/[NNN-feature-name]/spec.md |
| **Estimated Effort** | [Hours/Days] |
| **Risk Level** | [Low/Medium/High] |
| **Created** | [DATE] |

---

## Architecture Analysis

### System Context

```
[ASCII diagram showing where feature fits in system]
```

### Affected Components

| Component | Change Type | Risk | Notes |
|-----------|-------------|------|-------|
| [Component A] | New | Low | [Details] |
| [Component B] | Modify | Medium | [Details] |
| [Component C] | None | - | Read-only dependency |

### Data Model Changes

```
[Entity diagram or schema changes]
```

### API Changes

| Endpoint | Method | Change | Breaking |
|----------|--------|--------|----------|
| /api/v1/[resource] | POST | New | No |
| /api/v1/[resource]/:id | PUT | Modified | No |

---

## Implementation Tasks

### Phase 1: Foundation

**Task 1.1: [Foundation Task]**
- **Purpose**: [What this enables]
- **Files**:
  - `src/[path]/[file.ts]` - [What it does]
  - `src/[path]/[file.ts]` - [What it does]
- **Dependencies**: None
- **Validation**:
  ```bash
  [command to verify]
  ```
- **Archon Task**: Create with order=100

---

**Task 1.2: [Data Layer Task]**
- **Purpose**: [What this enables]
- **Files**:
  - `src/models/[model.ts]` - [What it does]
  - `src/db/migrations/[migration.ts]` - [What it does]
- **Dependencies**: Task 1.1
- **Validation**:
  ```bash
  [command to verify]
  ```
- **Archon Task**: Create with order=90

---

### Phase 2: Core Implementation

**Task 2.1: [Core Logic Task]**
- **Purpose**: [What this enables]
- **Files**:
  - `src/services/[service.ts]` - [What it does]
- **Dependencies**: Task 1.2
- **Requirements Covered**: FR-001, FR-002, FR-003
- **Validation**:
  ```bash
  [command to verify]
  ```
- **Archon Task**: Create with order=80

---

**Task 2.2: [API Layer Task]**
- **Purpose**: [What this enables]
- **Files**:
  - `src/api/[endpoint.ts]` - [What it does]
  - `src/api/validators/[validator.ts]` - [What it does]
- **Dependencies**: Task 2.1
- **Requirements Covered**: FR-004, FR-005
- **Validation**:
  ```bash
  [command to verify]
  ```
- **Archon Task**: Create with order=70

---

### Phase 3: Testing & Polish

**Task 3.1: [Unit Tests]**
- **Purpose**: Verify individual components
- **Files**:
  - `tests/unit/[component].test.ts`
- **Dependencies**: Task 2.2
- **Coverage Target**: 80%
- **Validation**:
  ```bash
  npm test -- --coverage
  ```
- **Archon Task**: Create with order=60

---

**Task 3.2: [Integration Tests]**
- **Purpose**: Verify component interactions
- **Files**:
  - `tests/integration/[feature].test.ts`
- **Dependencies**: Task 3.1
- **Scenarios Covered**: P1-S1, P1-S2
- **Validation**:
  ```bash
  npm run test:integration
  ```
- **Archon Task**: Create with order=50

---

**Task 3.3: [Documentation]**
- **Purpose**: Update docs for new feature
- **Files**:
  - `docs/[feature].md`
  - `README.md` (if needed)
- **Dependencies**: Task 3.2
- **Validation**: Manual review
- **Archon Task**: Create with order=40

---

## Testing Strategy

### Test Pyramid

```
        /\
       /E2E\        <- 10% (Critical paths only)
      /------\
     / Integ  \     <- 30% (Component interactions)
    /----------\
   /   Unit     \   <- 60% (Individual functions)
  /--------------\
```

### Test Mapping

| Requirement | Test Type | Test File | Status |
|-------------|-----------|-----------|--------|
| FR-001 | Unit | tests/unit/[file] | Pending |
| FR-002 | Unit | tests/unit/[file] | Pending |
| FR-003 | Integration | tests/integration/[file] | Pending |
| P1-S1 | E2E | tests/e2e/[file] | Pending |

### Validation Commands

```bash
# Build
[BUILD_CMD]

# Unit Tests
[UNIT_TEST_CMD]

# Integration Tests
[INTEGRATION_TEST_CMD]

# Lint
[LINT_CMD]

# Type Check
[TYPE_CHECK_CMD]

# Full Validation
[BUILD_CMD] && [TEST_CMD] && [LINT_CMD]
```

---

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Medium | High | [Strategy] |
| [Risk 2] | Low | Medium | [Strategy] |

---

## Migration / Deployment Notes

### Database Migrations
- [ ] Migration script created
- [ ] Rollback script created
- [ ] Tested on staging data

### Feature Flags
- [ ] Flag: `FEATURE_[NAME]_ENABLED`
- [ ] Default: `false`
- [ ] Rollout plan: [Strategy]

### Rollback Plan
1. [Step 1]
2. [Step 2]
3. [Step 3]

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | [DATE] | SpecKit | Initial plan |
```

---

## Phase Execution: @speckit-implement

### Checklist Generation

Generate requirements checklist from spec:

```markdown
# Requirements Checklist: [FEATURE_NAME]

## Specification Quality

Before implementation, verify spec is ready:

- [ ] No `[NEEDS CLARIFICATION]` markers remain
- [ ] All mandatory sections complete
- [ ] All requirements have test approach defined
- [ ] Acceptance criteria in Gherkin format
- [ ] Out of scope clearly defined
- [ ] Assumptions documented and confirmed

**Spec Status**: [ ] Ready for Implementation

---

## Functional Requirements

### Core Functionality

| Status | ID | Requirement | Test | Notes |
|--------|-----|-------------|------|-------|
| [ ] | FR-001 | [Description] | `tests/[path]` | |
| [ ] | FR-002 | [Description] | `tests/[path]` | |
| [ ] | FR-003 | [Description] | `tests/[path]` | |

### Data Requirements

| Status | ID | Requirement | Test | Notes |
|--------|-----|-------------|------|-------|
| [ ] | FR-010 | [Description] | `tests/[path]` | |
| [ ] | FR-011 | [Description] | `tests/[path]` | |

### Integration Requirements

| Status | ID | Requirement | Test | Notes |
|--------|-----|-------------|------|-------|
| [ ] | FR-020 | [Description] | `tests/[path]` | |

---

## Acceptance Scenarios

| Status | ID | Scenario | Test | Notes |
|--------|-----|----------|------|-------|
| [ ] | P1-S1 | [Primary scenario] | `tests/e2e/[path]` | |
| [ ] | P1-S2 | [Secondary scenario] | `tests/e2e/[path]` | |
| [ ] | P2-S1 | [Enhancement scenario] | `tests/e2e/[path]` | |

---

## Non-Functional Requirements

| Status | ID | Requirement | Metric | Notes |
|--------|-----|-------------|--------|-------|
| [ ] | NFR-001 | [Performance] | [Target] | |
| [ ] | NFR-010 | [Security] | [Criteria] | |

---

## Validation Commands

```bash
# Quick validation (run frequently)
[BUILD_CMD] && [LINT_CMD]

# Full validation (before marking complete)
[BUILD_CMD] && [TEST_CMD] && [LINT_CMD]

# Coverage check
[COVERAGE_CMD]
```

---

## Progress Summary

| Category | Total | Complete | Remaining |
|----------|-------|----------|-----------|
| Functional | [N] | [X] | [N-X] |
| Scenarios | [N] | [X] | [N-X] |
| Non-Functional | [N] | [X] | [N-X] |
| **Overall** | [N] | [X] | [N-X] |

---

## Blockers

| Requirement | Issue | Attempts | Status |
|-------------|-------|----------|--------|
| | | | |

---

## Completion Criteria

Feature is complete when:
- [ ] All Functional Requirements checked
- [ ] All P1 Acceptance Scenarios checked
- [ ] All Non-Functional Requirements checked
- [ ] Full validation passes
- [ ] Code review approved
- [ ] Documentation updated

**Feature Status**: [ ] SPEC_COMPLETE
```

### Implementation Loop

For each unchecked requirement:

```yaml
implementation_loop:
  1_select_requirement:
    - Pick next unchecked FR-XXX
    - Read requirement details from spec
    - Identify corresponding plan task

  2_implement:
    - Follow plan task instructions
    - Write code in specified files
    - Follow existing patterns

  3_write_test:
    - Create/update test file
    - Cover happy path + edge cases
    - Match acceptance criteria

  4_validate:
    command: "[BUILD_CMD] && [TEST_CMD]"
    on_pass: Continue to step 5
    on_fail: Return to step 2 with error analysis

  5_update_checklist:
    - Mark requirement as checked
    - Update progress summary
    - Commit changes with message: "feat([FEATURE]): implement FR-XXX"

  6_check_completion:
    if: All requirements checked
    then: Mark SPEC_COMPLETE
    else: Return to step 1
```

---

## Ralph Loop Integration

When Ralph loop is enabled, configure integration:

### Ralph Configuration

```json
{
  "loop_id": "ralph-speckit-[feature]-[timestamp]",
  "archon_project_id": "[PROJECT_ID]",
  "spec_path": "specs/NNN-feature/spec.md",
  "plan_path": "specs/NNN-feature/plan.md",
  "checklist_path": "specs/NNN-feature/checklists/requirements.md",

  "iteration_config": {
    "max_iterations_per_requirement": 3,
    "max_total_iterations": 50,
    "pause_between_iterations": 0
  },

  "completion_config": {
    "promise": "SPEC_COMPLETE",
    "check_checklist": true,
    "require_all_tests_pass": true,
    "require_lint_pass": true
  },

  "escape_hatch": {
    "iterations_before_block": 3,
    "block_action": "mark_blocked_continue",
    "blocked_notification": "archon_task_comment"
  },

  "validation": {
    "build": "[BUILD_CMD]",
    "test": "[TEST_CMD]",
    "lint": "[LINT_CMD]"
  }
}
```

### Ralph Handoff

When starting Ralph loop:

```markdown
## Ralph Loop Handoff: [FEATURE_NAME]

### Objective
Implement all requirements in specs/[NNN-feature]/spec.md using the
technical plan in specs/[NNN-feature]/plan.md.

### Success Criteria
All items in specs/[NNN-feature]/checklists/requirements.md are checked.

### Iteration Protocol

For each iteration:

1. **Read State**
   - Load checklist from specs/[NNN-feature]/checklists/requirements.md
   - Find first unchecked requirement
   - Load corresponding plan task

2. **Implement**
   - Follow plan task instructions
   - Write code in specified files
   - Create/update tests

3. **Validate**
   ```bash
   [BUILD_CMD] && [TEST_CMD]
   ```

4. **Update State**
   - If PASS: Check off requirement in checklist, commit
   - If FAIL: Analyze error, fix, re-validate (max 3 attempts)
   - If BLOCKED: Mark blocked in checklist, move to next

5. **Check Completion**
   - If all requirements checked: Output `<promise>SPEC_COMPLETE</promise>`
   - If blocked items exist: Output `<promise>NEEDS_REVIEW</promise>`
   - Otherwise: Continue to next requirement

### Validation Commands
```bash
[BUILD_CMD]
[TEST_CMD]
[LINT_CMD]
```

### Archon References
- Project: [PROJECT_ID]
- Feature Tasks: [TASK_IDS]
- Document: [DOC_ID]

### Escape Conditions
- Max 3 failures per requirement
- Max 50 total iterations
- Output `<promise>BLOCKED</promise>` if stuck globally
```

---

## Archon Task Creation

Create Archon tasks from plan:

```python
# Create feature-level parent task
parent = manage_task("create",
    project_id=PROJECT_ID,
    title=f"Feature: {FEATURE_NAME}",
    description=f"""Implement {FEATURE_NAME} per specification.

## Specification
- Spec: specs/{FEATURE_ID}/spec.md
- Plan: specs/{FEATURE_ID}/plan.md
- Checklist: specs/{FEATURE_ID}/checklists/requirements.md

## Requirements Summary
- Functional: {FR_COUNT}
- Scenarios: {SCENARIO_COUNT}
- Non-Functional: {NFR_COUNT}

## Success Criteria
All items in requirements checklist are checked.
""",
    status="todo",
    feature=FEATURE_NAME,
    task_order=100
)

# Create tasks from plan
for task in plan_tasks:
    manage_task("create",
        project_id=PROJECT_ID,
        title=task["title"],
        description=f"""## Purpose
{task["purpose"]}

## Files
{task["files"]}

## Dependencies
{task["dependencies"]}

## Requirements Covered
{task["requirements"]}

## Validation
```bash
{task["validation"]}
```
""",
        status="todo",
        feature=FEATURE_NAME,
        task_order=task["order"]
    )
```

---

## Error Handling

### Specification Errors

| Error | Resolution |
|-------|------------|
| Empty feature description | Prompt for more detail |
| Conflicting requirements | Flag for clarification |
| Untestable requirement | Rewrite to be measurable |
| Missing acceptance criteria | Generate from requirement |

### Implementation Errors

| Error | Resolution |
|-------|------------|
| Test failure | Analyze error, fix code, retry |
| Build failure | Check dependencies, fix syntax |
| Lint failure | Auto-fix where possible |
| Timeout | Reduce scope, break into smaller tasks |

### Ralph Integration Errors

| Error | Resolution |
|-------|------------|
| Stuck on requirement | Mark blocked, continue |
| Max iterations reached | Output NEEDS_REVIEW |
| Archon unavailable | Fall back to local state |
| Invalid spec format | Regenerate spec section |

---

## Best Practices

### Specification Writing

1. **Be Specific**: "Users can sort by date" vs. "Users can sort the list"
2. **Be Testable**: Every requirement should have a clear test
3. **Be Prioritized**: P1 items should be truly critical
4. **Be Bounded**: Clearly state what's NOT included

### Checklist Management

1. **One Item = One Deliverable**: Don't combine multiple things
2. **Ordered by Dependency**: Earlier items enable later items
3. **Validated by Tests**: Link each item to specific tests
4. **Updated Immediately**: Check off as you complete

### Ralph Integration

1. **Clear Prompts**: Give Ralph unambiguous instructions
2. **Small Iterations**: One requirement per iteration
3. **Fast Feedback**: Quick validation commands
4. **Escape Hatches**: Don't let Ralph spin forever

---

## Quick Commands

| Command | Description |
|---------|-------------|
| `/speckit-specify` | Generate spec from description |
| `/speckit-clarify` | Resolve spec ambiguities |
| `/speckit-plan` | Create technical plan from spec |
| `/speckit-implement` | Start implementation with checklist |
| `/speckit-checklist` | View/update requirements checklist |
| `/speckit-status` | Show spec completion status |
| `/speckit-ralph` | Start Ralph loop for feature |

### Quick Start Examples

```bash
# Full wizard
/speckit-wizard

# Quick spec generation
/speckit-specify "User authentication with OAuth2"

# Start implementation on existing spec
/speckit-implement --spec specs/042-user-auth/spec.md

# Check status
/speckit-status --feature user-auth

# Start Ralph loop
/speckit-ralph --spec specs/042-user-auth
```

---

## Configuration Files

### .speckit/config.json

```json
{
  "version": "1.0",
  "defaults": {
    "detail_level": "standard",
    "clarification_tolerance": "balanced",
    "checklist_granularity": "detailed",
    "ralph_enabled": true
  },
  "paths": {
    "specs_dir": "specs",
    "tests_dir": "tests"
  },
  "validation": {
    "build": "npm run build",
    "test": "npm test",
    "lint": "npm run lint"
  },
  "archon": {
    "project_id": "[PROJECT_ID]",
    "feature_label_prefix": "spec-"
  }
}
```

---

## Notes

- SpecKit works best with detailed initial descriptions
- Clarification reduces implementation surprises
- Checklists provide visible progress tracking
- Ralph integration enables autonomous completion
- Always commit specs before implementation
- Treat specs as living documents - update as you learn
