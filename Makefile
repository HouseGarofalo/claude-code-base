.PHONY: help setup lint validate sync new-project stats clean

# Default target
help:
	@echo "Claude Code Base - Available Commands"
	@echo ""
	@echo "  make setup        Install pre-commit hooks"
	@echo "  make lint         Run all linters"
	@echo "  make validate     Run validation script"
	@echo "  make sync TARGET= Sync to target repository"
	@echo "  make new-project  Run project wizard"
	@echo "  make stats        Show repository statistics"
	@echo "  make clean        Clean temp files"

setup:
	pip install pre-commit
	pre-commit install
	pre-commit install --hook-type commit-msg

lint:
	pre-commit run --all-files

validate:
	pwsh -File scripts/validate-claude-code.ps1

sync:
ifndef TARGET
	$(error TARGET is required. Usage: make sync TARGET=/path/to/repo)
endif
	pwsh -File scripts/sync-claude-code.ps1 -TargetPath "$(TARGET)"

new-project:
	pwsh -File scripts/setup-claude-code-project.ps1

stats:
	@echo "Repository Statistics"
	@echo "Skills: $$(find .claude/skills -type d -mindepth 1 | wc -l)"
	@echo "Commands: $$(find .claude/commands -name '*.md' | wc -l)"
	@echo "Total files: $$(find . -type f | wc -l)"

clean:
	rm -rf temp/
	rm -rf .claude-backup/
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete
