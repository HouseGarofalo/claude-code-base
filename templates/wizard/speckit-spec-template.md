# Specification: [FEATURE_NAME]

> SpecKit Framework specification template for formal, compliance-ready development. Use this for complex features requiring detailed specifications, verification checklists, and traceability.

---

## Metadata

| Field | Value |
|-------|-------|
| **Spec ID** | SPEC-[NUMBER] |
| **Version** | 1.0 |
| **Status** | Draft \| In Review \| Approved \| Implementing \| Verified |
| **Author** | [Name] |
| **Created** | [YYYY-MM-DD] |
| **Last Updated** | [YYYY-MM-DD] |
| **Archon Project** | [project_id] |
| **Compliance** | [None \| SOC2 \| HIPAA \| GDPR \| Custom] |

### Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Name] | Initial specification |
| | | | |

### Reviewers

| Role | Name | Status | Date |
|------|------|--------|------|
| Technical Lead | [Name] | Pending | |
| Security | [Name] | Pending | |
| Product Owner | [Name] | Pending | |

---

## 1. Overview

### 1.1 Purpose

[2-3 sentences describing the purpose of this specification]

### 1.2 Scope

**In Scope:**
- [Item 1]
- [Item 2]
- [Item 3]

**Out of Scope:**
- [Item 1]
- [Item 2]

### 1.3 Definitions

| Term | Definition |
|------|------------|
| [Term] | [Definition] |
| [Term] | [Definition] |

### 1.4 References

| Document | Version | Link |
|----------|---------|------|
| [Related Spec] | [Version] | [Link] |
| [API Reference] | [Version] | [Link] |

---

## 2. Requirements

### 2.1 Functional Requirements

#### REQ-F-001: [Requirement Title]

| Field | Value |
|-------|-------|
| **Priority** | P0 \| P1 \| P2 |
| **Status** | Proposed \| Approved \| Implemented \| Verified |
| **Rationale** | [Why this requirement exists] |

**Description:**
[Detailed description of the requirement]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

**Traceability:**
- Design: DES-[XXX]
- Test: TST-[XXX]
- Code: [file:line reference]

---

#### REQ-F-002: [Requirement Title]

| Field | Value |
|-------|-------|
| **Priority** | P0 \| P1 \| P2 |
| **Status** | Proposed \| Approved \| Implemented \| Verified |
| **Rationale** | [Why this requirement exists] |

**Description:**
[Detailed description]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

**Traceability:**
- Design: DES-[XXX]
- Test: TST-[XXX]

---

### 2.2 Non-Functional Requirements

#### REQ-NF-001: Performance

| Metric | Requirement | Target | Measurement |
|--------|-------------|--------|-------------|
| Response Time | P95 latency | < 200ms | APM monitoring |
| Throughput | Requests/sec | > 1000 | Load testing |
| Resource Usage | Memory | < 512MB | Container limits |

#### REQ-NF-002: Security

| Requirement | Implementation | Verification |
|-------------|----------------|--------------|
| Authentication | [Method] | [How to verify] |
| Authorization | [Method] | [How to verify] |
| Data Encryption | [Method] | [How to verify] |
| Audit Logging | [Method] | [How to verify] |

#### REQ-NF-003: Reliability

| Metric | Requirement | Target |
|--------|-------------|--------|
| Availability | Uptime | 99.9% |
| Recovery Time | RTO | < 15 minutes |
| Data Durability | Backup retention | 30 days |

---

## 3. Design

### 3.1 Architecture

```
[ASCII diagram or reference to architecture document]

+----------------+     +----------------+     +----------------+
|    Client      | --> |     API        | --> |   Database     |
+----------------+     +----------------+     +----------------+
                            |
                            v
                       +----------------+
                       |  External API  |
                       +----------------+
```

### 3.2 Component Design

#### DES-001: [Component Name]

**Purpose:** [What this component does]

**Interfaces:**
```typescript
interface ComponentInterface {
  method1(param: Type): ReturnType;
  method2(param: Type): ReturnType;
}
```

**Dependencies:**
- [Dependency 1]
- [Dependency 2]

**Implements:** REQ-F-001, REQ-F-002

---

### 3.3 Data Model

#### Entity: [EntityName]

```
+-------------------+
|    EntityName     |
+-------------------+
| id: UUID (PK)     |
| field1: Type      |
| field2: Type      |
| created_at: Time  |
| updated_at: Time  |
+-------------------+
```

**Constraints:**
- [Constraint 1]
- [Constraint 2]

**Indexes:**
- `idx_entity_field1` on `field1`

---

### 3.4 API Design

#### Endpoint: [METHOD] [PATH]

**Request:**
```json
{
  "field1": "type",
  "field2": "type"
}
```

**Response:**
```json
{
  "id": "uuid",
  "field1": "value",
  "created_at": "timestamp"
}
```

**Error Responses:**
| Code | Description |
|------|-------------|
| 400 | Invalid request |
| 401 | Unauthorized |
| 404 | Not found |
| 500 | Internal error |

---

## 4. Verification

### 4.1 Test Plan

#### TST-001: [Test Name]

| Field | Value |
|-------|-------|
| **Type** | Unit \| Integration \| E2E \| Performance |
| **Requirement** | REQ-F-001 |
| **Priority** | High |

**Preconditions:**
- [Condition 1]
- [Condition 2]

**Test Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Results:**
- [Result 1]
- [Result 2]

**Actual Results:** [To be filled during testing]

---

### 4.2 Verification Checklist

#### Pre-Implementation

- [ ] Specification reviewed and approved
- [ ] Design reviewed by technical lead
- [ ] Security review completed (if applicable)
- [ ] Test plan created
- [ ] Dependencies identified and available

#### During Implementation

- [ ] Code follows style guide
- [ ] Unit tests written for all functions
- [ ] Integration tests written
- [ ] Error handling implemented
- [ ] Logging implemented
- [ ] Documentation updated

#### Post-Implementation

- [ ] All tests passing
- [ ] Code review completed
- [ ] Security scan passed
- [ ] Performance benchmarks met
- [ ] Documentation complete
- [ ] Traceability matrix updated

---

## 5. Traceability Matrix

| Requirement | Design | Implementation | Test | Status |
|-------------|--------|----------------|------|--------|
| REQ-F-001 | DES-001 | `src/feature.ts` | TST-001 | Pending |
| REQ-F-002 | DES-002 | `src/feature.ts` | TST-002 | Pending |
| REQ-NF-001 | DES-003 | `src/perf.ts` | TST-003 | Pending |

---

## 6. Compliance (if applicable)

### 6.1 Compliance Requirements

| Framework | Requirement | Implementation | Evidence |
|-----------|-------------|----------------|----------|
| [SOC2/HIPAA/etc] | [Specific requirement] | [How addressed] | [Documentation] |

### 6.2 Audit Trail

| Date | Action | Actor | Evidence |
|------|--------|-------|----------|
| [Date] | Spec approved | [Name] | [Link to approval] |
| [Date] | Implementation complete | [Name] | [Commit hash] |
| [Date] | Testing complete | [Name] | [Test report] |

---

## 7. Clarifications Log

Track questions and clarifications during specification development:

| ID | Question | Asker | Date Asked | Answer | Date Answered |
|----|----------|-------|------------|--------|---------------|
| CLR-001 | [Question] | [Name] | [Date] | [Answer] | [Date] |
| CLR-002 | [Question] | [Name] | [Date] | [Answer] | [Date] |

---

## 8. Assumptions

Document assumptions made during specification:

| ID | Assumption | Impact if Wrong | Validation |
|----|------------|-----------------|------------|
| ASM-001 | [Assumption] | [Impact] | [How to validate] |
| ASM-002 | [Assumption] | [Impact] | [How to validate] |

---

## 9. Ralph Loop (if enabled)

For iterative refinement using Ralph methodology:

### Iteration History

| Iteration | Focus | Changes Made | Convergence |
|-----------|-------|--------------|-------------|
| 1 | Initial spec | Created baseline | 60% |
| 2 | Requirements refinement | Added REQ-F-003 | 75% |
| 3 | Design review | Updated DES-001 | 85% |
| 4 | Final review | Minor clarifications | 95% |

### Convergence Criteria

- [ ] All requirements have acceptance criteria (Target: 100%)
- [ ] All requirements traced to design (Target: 100%)
- [ ] All designs traced to tests (Target: 100%)
- [ ] No open critical clarifications (Target: 0)
- [ ] Stakeholder approval obtained (Target: 100%)

**Current Convergence:** [XX]%
**Target Convergence:** [90]%

---

## Appendix

### A. Related Specifications

- [Link to related spec 1]
- [Link to related spec 2]

### B. External References

- [Reference 1]
- [Reference 2]

### C. Archon Integration

```python
# View specification tasks
find_tasks(filter_by="project", filter_value="PROJECT_ID")

# View specification document
find_documents(project_id="PROJECT_ID", title="Specification: FEATURE_NAME")
```

---

*Specification Version*: 1.0
*SpecKit Framework Version*: 1.0
*Generated*: [timestamp]
