# Contributing to Claude Code Base

Thank you for your interest in contributing to Claude Code Base! This document provides guidelines for contributing to the project.

## Table of Contents

- [How to Contribute](#how-to-contribute)
- [Code Style](#code-style)
- [Pull Request Process](#pull-request-process)
- [Pre-commit Requirements](#pre-commit-requirements)

---

## How to Contribute

### Reporting Issues

1. Check existing issues to avoid duplicates
2. Use the issue template if available
3. Provide clear reproduction steps
4. Include relevant system information

### Suggesting Features

1. Open a discussion or issue
2. Describe the use case
3. Explain expected behavior
4. Consider implementation approach

### Submitting Code

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Ensure all tests pass
5. Submit a pull request

---

## Code Style

### PowerShell Scripts

- Use `PascalCase` for function names
- Use `camelCase` for variables
- Include comment-based help for functions
- Follow [PowerShell Best Practices](https://poshcode.gitbook.io/powershell-practice-and-style/)

### Markdown Files

- Use ATX-style headers (`#`)
- Include a table of contents for long documents
- Use fenced code blocks with language identifiers
- Ensure links are valid

### YAML Files

- Use 2-space indentation
- Quote strings containing special characters
- Include comments for complex configurations

---

## Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the code style guidelines
   - Add tests if applicable
   - Update documentation as needed

3. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: description of your changes"
   ```
   Follow [Conventional Commits](https://www.conventionalcommits.org/) format.

4. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   Open a pull request against the `main` branch.

5. **PR Review**
   - Address any feedback
   - Ensure CI checks pass
   - Squash commits if requested

6. **Merge**
   - PRs require at least one approval
   - Maintainers will merge approved PRs

---

## Pre-commit Requirements

All commits must pass pre-commit hooks. Install and configure:

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually (optional)
pre-commit run --all-files
```

### Required Hooks

- **gitleaks** - No secrets in commits
- **detect-secrets** - Baseline-aware secret detection
- **trailing-whitespace** - No trailing whitespace
- **end-of-file-fixer** - Files end with newline
- **check-yaml** - Valid YAML syntax
- **check-json** - Valid JSON syntax

### Bypassing Hooks (Emergency Only)

```bash
git commit --no-verify -m "message"
```

Use sparingly and only when absolutely necessary. Document the reason in the commit message.

---

## Questions?

If you have questions about contributing, open a discussion or reach out to the maintainers.

Thank you for contributing!
