---
name: harness-reviewer
version: 1.0.0
description: Code review skill for autonomous harness. Reviews code changes before marking features complete. Checks architecture consistency, security, code quality, and best practices. Provides actionable feedback or approval. Use when validating code in harness workflow or performing comprehensive code reviews.
---

# Harness Review Skill

Specialized code review skill for the autonomous harness system. Reviews code changes before features are marked complete, ensuring code quality, architectural consistency, and security best practices.

## Triggers

Use this skill when:
- Reviewing code in harness workflow
- Validating code before completion
- Checking architecture consistency
- Performing security reviews
- Keywords: harness review, code review, review changes, architecture check, security scan, quality check

## Core Mission

Provide thorough code review that:
1. **Catches issues early** - Before they become technical debt
2. **Ensures consistency** - With existing patterns and architecture
3. **Verifies security** - No vulnerabilities introduced
4. **Provides feedback** - Actionable, specific, constructive

---

## Review Modes

### Mode 1: Review Specific Feature
Review changes for a specific task/feature.

### Mode 2: Review Recent Changes
Review git diff from recent commits.

### Mode 3: Architecture Review
Deep review of architectural patterns and consistency.

### Mode 4: Security Scan
Focused security vulnerability detection.

---

## Review Protocol

### STEP 1: Gather Context

```bash
# Get recent changes
git log --oneline -5
git diff HEAD~1 --stat
git diff HEAD~1 --name-only
```

```python
# Get task details from Archon
task = find_tasks(task_id="<TASK_ID>")
feature_requirements = task["description"]

# Get session notes for context
notes = find_documents(project_id=PROJECT_ID, query="Session Notes")
```

### STEP 2: Identify Changed Files

```bash
# Get list of changed files
git diff HEAD~1 --name-only

# Categorize changes
# - Source code: src/**
# - Tests: tests/**
# - Config: *.json, *.yaml, *.toml
# - Documentation: docs/**, *.md
```

### STEP 3: Perform Code Review

For each changed file, check:

#### 3.1 Code Quality
- [ ] Functions are focused (single responsibility)
- [ ] Variable names are meaningful
- [ ] No commented-out code
- [ ] No debug statements left in
- [ ] Proper error handling
- [ ] No obvious bugs or logic errors

#### 3.2 Architecture Consistency
- [ ] Follows existing patterns in codebase
- [ ] Correct layer placement (services, controllers, etc.)
- [ ] Dependencies flow in correct direction
- [ ] No circular dependencies
- [ ] Proper separation of concerns

#### 3.3 Security
- [ ] No hardcoded secrets or credentials
- [ ] Input validation present
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output escaping)
- [ ] Authentication/authorization checks
- [ ] Sensitive data handling

#### 3.4 Testing
- [ ] Tests exist for new functionality
- [ ] Tests cover edge cases
- [ ] Tests are meaningful (not just for coverage)
- [ ] No tests removed or weakened

#### 3.5 Documentation
- [ ] Public APIs documented
- [ ] Complex logic has comments
- [ ] README updated if needed
- [ ] Breaking changes noted

### STEP 4: Generate Review Report

```python
review_result = {
    "status": "approved" | "changes_requested" | "blocked",
    "summary": "...",
    "findings": [
        {
            "severity": "critical" | "major" | "minor" | "suggestion",
            "file": "path/to/file",
            "line": 42,
            "issue": "Description of issue",
            "suggestion": "How to fix"
        }
    ],
    "tests_verified": True | False,
    "architecture_ok": True | False,
    "security_ok": True | False
}
```

### STEP 5: Update Archon Task

```python
manage_task("update",
    task_id="<TASK_ID>",
    description=f"""[ORIGINAL_DESCRIPTION]

---
## Code Review (by harness-reviewer)
**Timestamp**: {timestamp}
**Status**: {review_status}

### Summary
{review_summary}

### Findings
{format_findings(findings)}

### Checks
- [{"x" if code_quality_ok else " "}] Code Quality
- [{"x" if architecture_ok else " "}] Architecture Consistency
- [{"x" if security_ok else " "}] Security
- [{"x" if tests_verified else " "}] Tests Verified

### Verdict
{verdict_message}
"""
)
```

---

## Review Standards

### Critical (Must Fix Before Completion)
- Security vulnerabilities
- Data loss potential
- Breaking changes without migration
- Missing authentication/authorization
- Exposed secrets or credentials

### Major (Should Fix)
- Significant code quality issues
- Architecture violations
- Missing error handling
- Incomplete test coverage for critical paths

### Minor (Consider Fixing)
- Code style inconsistencies
- Suboptimal patterns
- Missing edge case tests
- Documentation gaps

### Suggestion (Nice to Have)
- Performance optimizations
- Code organization improvements
- Additional documentation
- Better variable naming

---

## Output Format

### Approved

```markdown
## Code Review: APPROVED

**Feature**: [FEATURE_NAME]
**Task**: [TASK_ID]
**Reviewer**: harness-reviewer

### Summary
Code changes implement the feature correctly and follow project standards.

### Checks
- [x] Code Quality - Clean, readable code
- [x] Architecture - Follows existing patterns
- [x] Security - No vulnerabilities found
- [x] Tests - Adequate coverage

### Suggestions (Optional)
1. Consider extracting the validation logic to a utility function
2. Add JSDoc comment to the exported interface

**Verdict**: Ready to merge
**Archon Updated**: Yes
```

### Changes Requested

```markdown
## Code Review: CHANGES REQUESTED

**Feature**: [FEATURE_NAME]
**Task**: [TASK_ID]
**Reviewer**: harness-reviewer

### Summary
Good implementation overall, but a few issues need addressing.

### Findings

#### Major: Missing Input Validation
**File**: `src/api/users.ts:45`
**Issue**: User input not validated before database query
**Fix**: Add Zod schema validation before processing

```typescript
// Current
const user = req.body;
await db.users.create(user);

// Suggested
const userSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100)
});
const user = userSchema.parse(req.body);
await db.users.create(user);
```

#### Minor: Inconsistent Error Handling
**File**: `src/services/auth.ts:78`
**Issue**: Some paths throw, others return null
**Fix**: Standardize on throwing AuthError for auth failures

### Checks
- [x] Code Quality
- [x] Architecture
- [ ] Security - Input validation needed
- [x] Tests

**Verdict**: Address findings and re-request review
**Archon Updated**: Yes (status set to "review")
```

### Blocked

```markdown
## Code Review: BLOCKED

**Feature**: [FEATURE_NAME]
**Task**: [TASK_ID]
**Reviewer**: harness-reviewer

### Summary
Critical security issue found that must be addressed.

### Blockers

#### CRITICAL: Hardcoded API Key
**File**: `src/services/payment.ts:12`
**Issue**: API key hardcoded in source code
**Risk**: Credential exposure if code is public

```typescript
// CRITICAL - REMOVE THIS
const STRIPE_KEY = "sk_live_abc123...";
```

**Fix**:
1. Remove key from code immediately
2. Rotate the exposed key in Stripe dashboard
3. Use environment variable instead

### Checks
- [ ] Security - CRITICAL ISSUE

**Verdict**: DO NOT MERGE - Address critical issue first
**Archon Updated**: Yes (task reset to "doing")
```

---

## Common Issues to Watch For

### Security
| Issue | Detection | Fix |
|-------|-----------|-----|
| Hardcoded secrets | `grep -r "sk_" "api_key" "password"` | Use env vars |
| SQL injection | Raw query strings with interpolation | Parameterized queries |
| XSS | `dangerouslySetInnerHTML`, `innerHTML` | Sanitize/escape |
| Auth bypass | Missing auth middleware | Add guards |
| CSRF | Forms without tokens | Add CSRF tokens |

### Code Quality
| Issue | Detection | Fix |
|-------|-----------|-----|
| God functions | Functions > 50 lines | Split into smaller |
| Magic numbers | Unexplained numeric values | Use constants |
| Deep nesting | > 3 levels of indentation | Early returns |
| Dead code | Unreachable or unused | Remove |
| Copy-paste | Duplicated blocks | Extract function |

### Architecture
| Issue | Detection | Fix |
|-------|-----------|-----|
| Wrong layer | Business logic in controller | Move to service |
| Circular deps | Import cycles | Restructure |
| Leaky abstraction | Implementation details exposed | Add interface |
| Missing boundaries | Direct DB access from UI | Add service layer |

---

## Critical Rules

1. **NEVER approve with critical issues** - Block the completion
2. **BE SPECIFIC** - Include file, line, and fix suggestion
3. **BE CONSTRUCTIVE** - Explain why, not just what
4. **CHECK TESTS** - Verify tests exist and are meaningful
5. **FOLLOW STANDARDS** - Use project's existing patterns as baseline
6. **UPDATE ARCHON** - Record review results for tracking
7. **RESET STATUS if blocked** - Task goes back to "doing"
