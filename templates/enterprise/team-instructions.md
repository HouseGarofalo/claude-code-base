# Team Claude Code Instructions Template

> **Purpose**: Template for team-specific Claude Code customization
> **Usage**: Copy to your repository as `CLAUDE.md` and customize

---

## Team: [TEAM_NAME]

### Project Context

**Project Type**: [web-app/api/library/infrastructure]
**Primary Stack**: [e.g., TypeScript, Python, .NET]
**Team Size**: [number]

---

## Coding Standards

### General Rules

1. **Language**: [TypeScript/Python/C#/Go]
2. **Style Guide**: [Link or name of style guide]
3. **Formatting**: [Prettier/Black/dotnet format]
4. **Linting**: [ESLint/Ruff/StyleCop]

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | [kebab-case/PascalCase] | `user-service.ts` |
| Functions | [camelCase/snake_case] | `getUserById` |
| Classes | PascalCase | `UserService` |
| Constants | UPPER_SNAKE | `MAX_RETRIES` |
| Interfaces | [I-prefix/no-prefix] | `IUserRepository` |

### File Organization

```
src/
├── components/     # [Description]
├── services/       # [Description]
├── utils/          # [Description]
└── types/          # [Description]
```

---

## Architecture Guidelines

### Patterns We Use

- [Pattern 1]: [When to use]
- [Pattern 2]: [When to use]
- [Pattern 3]: [When to use]

### Patterns to Avoid

- [Anti-pattern 1]: [Why]
- [Anti-pattern 2]: [Why]

### Dependencies

**Approved Libraries**:
- [Library]: [Purpose]
- [Library]: [Purpose]

**Restricted Libraries**:
- [Library]: [Reason]

---

## Testing Requirements

### Test Coverage

- Minimum coverage: [80%]
- Critical paths: [100%]

### Test Types Required

| Change Type | Unit | Integration | E2E |
|------------|------|-------------|-----|
| New feature | Yes | Yes | [Yes/No] |
| Bug fix | Yes | [Optional] | No |
| Refactor | Yes | [Optional] | No |

### Test Naming

```
[Method]_[Scenario]_[ExpectedResult]
```

---

## Security Requirements

### Mandatory Checks

- [ ] No hardcoded secrets
- [ ] Input validation on all user input
- [ ] Parameterized queries for database access
- [ ] Authentication on protected endpoints
- [ ] Authorization checks for sensitive operations

### Restricted Operations

The following require security team review:
- [ ] Cryptographic implementations
- [ ] Authentication changes
- [ ] Authorization changes
- [ ] External API integrations

---

## PR Requirements

### PR Title Format

```
[type]: Brief description

Types: feat, fix, docs, style, refactor, test, chore
```

### PR Checklist

- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No console.log/print statements
- [ ] No commented-out code
- [ ] Follows team naming conventions
- [ ] Reviewed by minimum [N] reviewers

### Commit Message Format

```
type(scope): subject

body (optional)

footer (optional)
```

---

## Documentation Requirements

### Code Documentation

**Required for**:
- Public APIs
- Complex algorithms
- Non-obvious logic
- Configuration options

**Format**:
- [JSDoc/docstrings/XML comments]

### README Requirements

Every new module/service needs:
- Purpose description
- Setup instructions
- Usage examples
- Configuration options

---

## AI Assistant Instructions

### Preferred Behaviors

When generating code, Claude should:
1. Follow our naming conventions exactly
2. Use our approved libraries only
3. Include comprehensive error handling
4. Add inline comments for complex logic
5. Generate tests alongside implementations

### Avoid

Claude should NOT:
1. Use deprecated patterns
2. Introduce new dependencies without discussion
3. Generate code without proper types
4. Skip error handling
5. Use magic numbers/strings

### Response Preferences

- Be concise and direct
- Explain reasoning for non-obvious decisions
- Ask clarifying questions when requirements are unclear
- Provide alternatives when multiple approaches exist

---

## Common Tasks

### Creating a New [Component/Service/Module]

1. [Step 1]
2. [Step 2]
3. [Step 3]

### Adding a New API Endpoint

1. [Step 1]
2. [Step 2]
3. [Step 3]

### Database Migrations

1. [Step 1]
2. [Step 2]
3. [Step 3]

---

## Environment Setup

### Required Tools

- [Tool 1]: version [X]
- [Tool 2]: version [X]

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| [VAR] | [Description] | [Yes/No] |

### Local Development

```bash
# Setup steps
[command 1]
[command 2]
```

---

## Contacts

| Role | Contact |
|------|---------|
| Tech Lead | [name/email] |
| Security | [name/email] |
| DevOps | [name/email] |

---

## Change Log

| Date | Author | Changes |
|------|--------|---------|
| [DATE] | [NAME] | Initial version |
