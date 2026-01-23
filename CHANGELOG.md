# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-23

### Added

- Initial release of Claude Code Base template
- Project setup wizard (`setup-claude-code-project.ps1`)
- Sync functionality (`sync-claude-code.ps1`)
- Validation script (`validate-claude-code.ps1`)
- Pre-commit configuration with gitleaks and detect-secrets
- Comprehensive `.gitignore` for multi-language projects
- `.gitattributes` for consistent line endings
- CODEOWNERS file for repository ownership
- Security policy (SECURITY.md)
- Contributing guidelines (CONTRIBUTING.md)
- MIT License
- Documentation structure

### Security

- Integrated gitleaks for secret detection
- Integrated detect-secrets for baseline-aware scanning
- Pre-commit hooks for automated security checks
