# Security Policy

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please report it responsibly.

### How to Report

1. **Do NOT** open a public issue for security vulnerabilities
2. Email security concerns to the repository maintainers
3. Include detailed information about the vulnerability
4. Allow reasonable time for response before public disclosure

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Resolution Target**: Within 30 days (depending on severity)

---

## Security Features

This repository includes several security measures:

### Secret Detection

#### gitleaks

Scans commits for hardcoded secrets including:
- API keys
- Passwords
- Private keys
- Tokens
- Connection strings

Configuration: `.gitleaks.toml` (if customization needed)

#### detect-secrets

Baseline-aware secret detection that:
- Maintains a baseline of known false positives
- Scans for new secrets in commits
- Supports multiple secret types

Configuration: `.secrets.baseline`

### Pre-commit Hooks

All security tools run automatically before commits:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    hooks:
      - id: gitleaks

  - repo: https://github.com/Yelp/detect-secrets
    hooks:
      - id: detect-secrets
```

### Best Practices Enforced

1. **No secrets in code** - Use environment variables
2. **No sensitive files committed** - `.gitignore` blocks `.env` files
3. **Automated scanning** - Pre-commit hooks catch issues early
4. **Code review required** - CODEOWNERS enforces review

---

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

---

## Security Checklist for Contributors

Before submitting code:

- [ ] No hardcoded secrets, API keys, or passwords
- [ ] No sensitive file paths or personal information
- [ ] Environment variables used for configuration
- [ ] Pre-commit hooks pass locally
- [ ] No new security warnings introduced

---

## Additional Resources

- [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
- [gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [detect-secrets Documentation](https://github.com/Yelp/detect-secrets)
