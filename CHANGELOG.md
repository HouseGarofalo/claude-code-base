# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2026-02-18

### Changed

- **BREAKING**: Complete rewrite of `sync-claude-code.ps1` with intelligent wizard-based sync
  - Never overwrites CLAUDE.md or README.md (additive-only merge)
  - Interactive wizard for project type, language, framework, dev frameworks, additional skill groups
  - Global plugin deduplication: reads `~/.claude/settings.json` and skips skills covered by enabled plugins
  - Global skill deduplication: skips skills already in `~/.claude/skills/`
  - CLAUDE.md smart merge: adds missing sections at correct canonical positions, fills placeholders with auto-detection
  - 10-step flow: prerequisites, load state, detect config, wizard, calculate delta, global dedup, CLAUDE.md analysis, preview, approval, execute
  - Categorized preview showing skills to install, skipped (plugin/global/exists), commands, CLAUDE.md changes, config files
  - New parameters: `-ProjectType`, `-PrimaryLanguage`, `-Framework`, `-DevFrameworks`, `-AdditionalSkillGroups`

### Added

- `templates/plugin-skill-map.json` - Maps global Claude Code plugins to the local skills they cover
  - Supports `partial` flag for skills with incomplete plugin overlap
  - Covers: code-review, code-simplifier, pr-review-toolkit, frontend-design, playwright, security-guidance, agent-sdk-dev, feature-dev plugins

### Removed

- Legacy full-overwrite sync mode (previously used for projects without `template_profile`)

## [2.0.0] - 2026-01-23

### Added

- Selective setup wizard (`setup-claude-code-project.ps1` v2.0)
- Template profile (`template_profile` in config.yaml) for sync tracking
- Manifest-based skill/command group selection
- Selective sync based on template profile
- Update script (`update-project.ps1`) for component-level updates

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
