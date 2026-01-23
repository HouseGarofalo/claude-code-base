# Claude Code Base - Just Commands

# Default recipe - show help
default:
    @just --list

# Install pre-commit hooks
setup:
    pip install pre-commit
    pre-commit install
    pre-commit install --hook-type commit-msg

# Run all linters
lint:
    pre-commit run --all-files

# Run validation script
validate:
    pwsh -File scripts/validate-claude-code.ps1

# Sync to target repository
sync target:
    pwsh -File scripts/sync-claude-code.ps1 -TargetPath "{{target}}"

# Run project wizard
new-project:
    pwsh -File scripts/setup-claude-code-project.ps1

# Show repository statistics
stats:
    @echo "Repository Statistics"
    @echo "Skills: $(find .claude/skills -type d -mindepth 1 | wc -l)"
    @echo "Commands: $(find .claude/commands -name '*.md' | wc -l)"
    @echo "Total files: $(find . -type f | wc -l)"

# Clean temporary files
clean:
    rm -rf temp/
    rm -rf .claude-backup/
    find . -name "*.pyc" -delete
    find . -name "__pycache__" -delete

# Dry run sync to target
sync-dry target:
    pwsh -File scripts/sync-claude-code.ps1 -TargetPath "{{target}}" -DryRun
