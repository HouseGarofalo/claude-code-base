# AI Code Review Audit Checklist

> **Purpose**: Systematic checklist for auditing AI-generated or AI-assisted code
> **Use When**: Code reviews, security audits, compliance checks
> **Frequency**: Every PR with significant AI assistance

---

## Quick Reference

| Risk Level | Review Depth | Approvals Required |
|------------|--------------|-------------------|
| Low | Standard review | 1 developer |
| Medium | Enhanced review | 2 developers |
| High | Security review | Security team + 2 devs |
| Critical | Full audit | Security + Architecture + Legal |

---

## Pre-Review Assessment

### Identify AI Involvement

- [ ] Determine extent of AI assistance
  - [ ] Code suggestions
  - [ ] Generated functions
  - [ ] Full file generation
  - [ ] Test generation
  - [ ] Documentation generation

- [ ] Identify which AI tool was used
  - [ ] Claude Code
  - [ ] Other: ____________

- [ ] Assess risk level based on:
  - [ ] Code sensitivity
  - [ ] Security implications
  - [ ] Compliance requirements

---

## Code Quality Checks

### 1. Correctness

- [ ] **Logic**: Does the code do what it claims to do?
- [ ] **Edge cases**: Are boundary conditions handled?
- [ ] **Error handling**: Are errors caught and handled appropriately?
- [ ] **Return values**: Are all code paths accounted for?
- [ ] **Types**: Are types correct and consistent?

### 2. Completeness

- [ ] **Full implementation**: Is the feature fully implemented?
- [ ] **No TODOs**: Are there unexpanded placeholders?
- [ ] **No magic values**: Are constants properly defined?
- [ ] **All paths tested**: Is test coverage adequate?

### 3. Readability

- [ ] **Clear naming**: Are variables and functions well-named?
- [ ] **Appropriate comments**: Is complex logic explained?
- [ ] **Consistent style**: Does it match project conventions?
- [ ] **Not over-engineered**: Is the solution appropriately simple?

---

## Security Review

### 4. Input Validation

- [ ] All user input validated
- [ ] Input sanitized before use
- [ ] No raw input in queries/commands
- [ ] Appropriate error messages (no info leakage)

### 5. Authentication & Authorization

- [ ] Auth checks present where needed
- [ ] Proper role/permission verification
- [ ] No auth bypass vulnerabilities
- [ ] Session handling is secure

### 6. Data Protection

- [ ] No hardcoded secrets
- [ ] Sensitive data encrypted
- [ ] PII handled per policy
- [ ] Proper logging (no sensitive data)

### 7. Injection Prevention

- [ ] SQL queries parameterized
- [ ] No command injection vectors
- [ ] No XSS vulnerabilities
- [ ] No path traversal issues

### 8. Dependency Security

- [ ] No known vulnerable dependencies
- [ ] Dependencies from trusted sources
- [ ] Minimum necessary permissions

---

## Compliance Checks

### 9. License Compliance

- [ ] No suspicious code patterns
- [ ] No copied open-source code (without proper license)
- [ ] License compatibility verified
- [ ] Attribution provided if required

### 10. Regulatory Compliance

**For GDPR-regulated code:**
- [ ] Data minimization applied
- [ ] Consent handling correct
- [ ] Right to deletion supported
- [ ] Data processing documented

**For HIPAA-regulated code:**
- [ ] PHI properly protected
- [ ] Access controls in place
- [ ] Audit logging enabled
- [ ] Encryption applied

**For PCI-DSS-regulated code:**
- [ ] Cardholder data protected
- [ ] No storage of prohibited data
- [ ] Encryption meets standards

### 11. Data Handling

- [ ] Data retention follows policy
- [ ] Data classification respected
- [ ] Cross-border transfer considered

---

## Testing Verification

### 12. Test Quality

- [ ] Tests actually test the code (not just pass)
- [ ] Tests cover happy path
- [ ] Tests cover error cases
- [ ] Tests cover edge cases
- [ ] Tests are deterministic (not flaky)
- [ ] Test assertions are meaningful

### 13. Test Coverage

- [ ] New code is tested
- [ ] Coverage meets minimum (80%+)
- [ ] Critical paths have integration tests

---

## Documentation Review

### 14. Code Documentation

- [ ] Public APIs documented
- [ ] Complex logic explained
- [ ] Examples provided where helpful
- [ ] No incorrect documentation

### 15. User Documentation

- [ ] README updated if needed
- [ ] API docs updated if needed
- [ ] Changelog updated if needed

---

## Final Checks

### 16. Performance

- [ ] No obvious performance issues
- [ ] No N+1 queries
- [ ] Appropriate caching considered
- [ ] Large data sets handled efficiently

### 17. Maintainability

- [ ] Code is easy to understand
- [ ] No dead code
- [ ] No duplicate code
- [ ] Follows project patterns

### 18. Operational Readiness

- [ ] Logging is appropriate
- [ ] Monitoring can detect issues
- [ ] Errors are actionable
- [ ] Rollback is possible

---

## Review Decision

### Approval

- [ ] All critical items addressed
- [ ] All high-priority items addressed or have exceptions
- [ ] Medium/low items documented for follow-up

### Sign-off

| Role | Name | Date | Decision |
|------|------|------|----------|
| Primary Reviewer | | | Approve / Request Changes |
| Secondary Reviewer | | | Approve / Request Changes |
| Security (if required) | | | Approve / Request Changes |

### Notes

```
[Add any notes, concerns, or follow-up items here]
```

---

## Exception Documentation

If any checklist items are not applicable or exceptions are granted:

| Item | Reason for Exception | Approved By | Date |
|------|---------------------|-------------|------|
| | | | |

---

## Post-Review Actions

- [ ] All review comments addressed
- [ ] Tests pass in CI
- [ ] Security scans pass
- [ ] Documentation complete
- [ ] Ready for merge

---

**Template Version**: 1.0
**Last Updated**: [DATE]
