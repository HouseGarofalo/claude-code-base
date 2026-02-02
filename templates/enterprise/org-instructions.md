# Organization Claude Code Instructions Template

> **Purpose**: Organization-wide Claude Code configuration
> **Location**: Place in `~/.claude/CLAUDE.md` for all users or in organization template

---

# [ORGANIZATION_NAME] - Claude Code Guidelines

## Organization Context

**Industry**: [Technology/Healthcare/Finance/Government/etc.]
**Compliance Requirements**: [SOC 2/HIPAA/PCI-DSS/GDPR/FedRAMP]
**Primary Technologies**: [List main tech stack]

---

## Critical Rules (Override Everything)

### RULE 1: Security First

**NEVER:**
- Generate code that handles credentials without proper encryption
- Suggest storing secrets in code or configuration files
- Create code that logs sensitive information
- Bypass authentication or authorization checks
- Use known vulnerable patterns

**ALWAYS:**
- Use environment variables for secrets
- Implement proper input validation
- Follow secure coding practices
- Encrypt sensitive data at rest and in transit

### RULE 2: Compliance Requirements

For [REGULATION] compliance, all code must:
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

### RULE 3: Approved Technologies

Only suggest solutions using these approved technologies:

| Category | Approved Options |
|----------|-----------------|
| Languages | [TypeScript, Python, C#, Go] |
| Frameworks | [React, FastAPI, .NET Core] |
| Databases | [PostgreSQL, SQL Server, CosmosDB] |
| Cloud | [Azure, AWS] |

---

## Coding Standards

### Universal Requirements

1. **Type Safety**: Use strong typing in all code
2. **Error Handling**: Comprehensive error handling required
3. **Logging**: Structured logging without sensitive data
4. **Testing**: Minimum 80% code coverage

### Security Scanning

All generated code should pass:
- Static analysis (SonarQube/CodeQL)
- Dependency scanning (Snyk/Dependabot)
- Secret scanning (detect-secrets)

---

## Documentation Requirements

### Code Comments

Required for:
- Public interfaces/APIs
- Complex business logic
- Security-related code
- Integration points

### Architecture Documentation

New systems require:
- Architecture Decision Records (ADRs)
- Data flow diagrams
- Security review documentation

---

## Review Requirements

### Code Review Matrix

| Code Type | Minimum Reviewers | Required Reviewers |
|-----------|-------------------|-------------------|
| Standard | 1 | Team member |
| Security-related | 2 | Security team |
| Infrastructure | 2 | DevOps + Security |
| Database changes | 2 | DBA + Developer |

---

## Incident Response

When generating code that might affect:
- **Production systems**: Flag for additional review
- **Security controls**: Require security team approval
- **Compliance controls**: Require compliance team review

---

## AI Usage Guidelines

### Documentation

All PRs with significant AI assistance must:
1. Be tagged with `ai-assisted` label
2. Include extent of AI involvement in description
3. Note which AI tool was used

### Prohibited Uses

AI tools must NOT be used for:
- Generating authentication/authorization logic without review
- Creating cryptographic implementations
- Handling compliance-sensitive data processing
- Bypassing established patterns or controls

---

## Contact Information

| Concern | Contact |
|---------|---------|
| Security Issues | security@[org].com |
| Compliance Questions | compliance@[org].com |
| Policy Exceptions | engineering-leads@[org].com |

---

## Version Control

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | [DATE] | Initial release |

---

**Note**: Team-specific instructions in project CLAUDE.md files supplement but cannot contradict these organization-wide guidelines.
