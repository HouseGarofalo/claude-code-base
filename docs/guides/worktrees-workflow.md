[Home](../../README.md) > [Docs](../index.md) > Worktrees Workflow

# Git Worktrees Workflow Guide

> **Last Updated**: 2026-02-02
> **Purpose**: Complete guide for using Git worktrees for parallel development

---

## Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
- [Workflow Patterns](#workflow-patterns)
- [Best Practices](#best-practices)
- [IDE Integration](#ide-integration)
- [Troubleshooting](#troubleshooting)
- [Quick Reference](#quick-reference)

---

## Overview

Git worktrees allow you to have multiple working directories attached to the same repository. Each worktree can have a different branch checked out, enabling true parallel development.

### Key Benefits

| Benefit | Description |
|---------|-------------|
| **No Stashing** | Keep uncommitted work while switching context |
| **Parallel Development** | Work on multiple features simultaneously |
| **PR Review Isolation** | Review PRs without disturbing your work |
| **Fast Context Switching** | Just `cd` to another directory |
| **Shared History** | All worktrees share the same Git database |

### How Worktrees Work

```
my-project/                     <- Main worktree (your normal repo)
├── .git/                       <- Shared Git database
├── src/
└── ...

../my-project-feature-auth/     <- Linked worktree
├── .git -> my-project/.git     <- Points to main .git
├── src/                        <- Independent working files
└── ...

../my-project-pr-123/           <- Another linked worktree
├── .git -> my-project/.git
├── src/
└── ...
```

---

## Getting Started

### Prerequisites

- Git 2.20 or later
- Sufficient disk space (each worktree is a full checkout)

### Basic Commands

```bash
# List all worktrees
git worktree list

# Create worktree for existing branch
git worktree add ../path branch-name

# Create worktree with new branch
git worktree add -b new-branch ../path

# Remove worktree
git worktree remove ../path

# Clean up stale entries
git worktree prune
```

---

## Workflow Patterns

### Pattern 1: Parallel Feature Development

**Scenario**: You're working on feature A, but need to also work on feature B.

```bash
# You're on feature-a in main repo
# Create worktree for feature-b
git worktree add -b feature-b ../my-project-feature-b main

# Work on feature-b
cd ../my-project-feature-b
npm install
# ... make changes ...

# Switch back to feature-a
cd ../my-project
# Your feature-a work is exactly as you left it!
```

### Pattern 2: PR Review in Isolation

**Scenario**: Review a PR without disturbing your current work.

```bash
# Fetch the PR
git fetch origin pull/123/head:pr-123

# Create review worktree
git worktree add ../my-project-pr-123 pr-123

# Review
cd ../my-project-pr-123
npm install
npm test
npm start  # Test functionality

# After review, clean up
cd ../my-project
git worktree remove ../my-project-pr-123
git branch -d pr-123
```

### Pattern 3: Hotfix While Mid-Feature

**Scenario**: Production bug while you're mid-feature with uncommitted changes.

```bash
# Create hotfix worktree from main
git worktree add ../my-project-hotfix main

# Work on hotfix
cd ../my-project-hotfix
git checkout -b hotfix/critical-bug
# ... fix the bug ...
git add . && git commit -m "fix: critical bug"
git push origin hotfix/critical-bug

# Create PR, get it merged

# Clean up and return to feature
cd ../my-project
git worktree remove ../my-project-hotfix
# Your feature work is still there, unchanged!
```

### Pattern 4: Long-running Experiment

**Scenario**: Major refactor or experiment that spans days/weeks.

```bash
# Create and lock experiment worktree
git worktree add -b experiment/new-architecture ../my-project-experiment main
git worktree lock --reason "Architecture experiment" ../my-project-experiment

# Work on experiment over time
cd ../my-project-experiment
# ... experimental changes over days/weeks ...

# When done, unlock and merge or discard
git worktree unlock ../my-project-experiment
# Either create PR or force remove
```

### Pattern 5: Compare Two Versions

**Scenario**: Compare behavior between two versions side by side.

```bash
# Create worktrees for both versions
git worktree add --detach ../my-project-v1.0 v1.0.0
git worktree add --detach ../my-project-v2.0 v2.0.0

# Run both versions
cd ../my-project-v1.0 && npm start &
cd ../my-project-v2.0 && npm start &

# Compare behavior

# Clean up
git worktree remove ../my-project-v1.0
git worktree remove ../my-project-v2.0
```

---

## Best Practices

### Naming Convention

Use consistent naming:
```
{repo-name}-{type}-{identifier}
```

| Type | Example |
|------|---------|
| Feature | `my-app-feature-auth` |
| PR Review | `my-app-pr-123` |
| Experiment | `my-app-experiment-graphql` |
| Hotfix | `my-app-hotfix` |
| Version | `my-app-v1.0.0` |

### DO

| Practice | Why |
|----------|-----|
| Create worktrees in sibling directories | Avoids nested repo issues |
| Use descriptive names | Easy to identify purpose |
| Lock long-running worktrees | Prevents accidental deletion |
| Clean up after use | Saves disk space |
| Run `npm install` in each worktree | Dependencies aren't shared |

### DON'T

| Anti-Pattern | Why |
|--------------|-----|
| Create worktrees inside repo | Causes git confusion |
| Manually delete directories | Leaves stale git entries |
| Keep too many worktrees | Disk space waste |
| Share node_modules | Path issues, conflicts |
| Forget about locked worktrees | Become orphaned |

---

## IDE Integration

### VS Code

**Opening Worktrees:**
```bash
cd ../my-project-feature-auth
code .
```

**Multi-root Workspace:**
Create a `.code-workspace` file to see all worktrees:

```json
{
  "folders": [
    { "path": ".", "name": "main" },
    { "path": "../my-project-feature-auth", "name": "feature-auth" },
    { "path": "../my-project-pr-123", "name": "pr-123" }
  ]
}
```

**Recommended Extensions:**
- GitLens - Visualize worktrees and branches
- Git Graph - See branches across worktrees

### Excluding Worktrees from Search

In `.vscode/settings.json`:
```json
{
  "search.exclude": {
    "../*-pr-*/**": true,
    "../*-feature-*/**": true,
    "../*-experiment-*/**": true
  }
}
```

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| "branch already checked out" | Branch is in another worktree - use different branch or remove that worktree |
| "not a git repository" | Worktree link broken - run `git worktree prune` |
| Can't remove worktree | May be locked - run `git worktree unlock ../path` first |
| Missing dependencies | Run install command in each worktree separately |
| Stale worktree entries | Run `git worktree prune` |

### Diagnostic Commands

```bash
# See all worktrees with status
git worktree list --porcelain

# Check for issues
git fsck

# Repair worktrees
git worktree repair

# See what would be pruned
git worktree prune --dry-run
```

### Recovery

If a worktree gets corrupted:
```bash
# Remove stale entry
git worktree prune

# Re-create
git worktree add ../path branch
```

---

## Quick Reference

### Commands Cheat Sheet

| Action | Command |
|--------|---------|
| List worktrees | `git worktree list` |
| Add from branch | `git worktree add ../path branch` |
| Add new branch | `git worktree add -b branch ../path` |
| Remove | `git worktree remove ../path` |
| Lock | `git worktree lock ../path` |
| Unlock | `git worktree unlock ../path` |
| Prune | `git worktree prune` |

### Available Claude Code Commands

| Tool | Purpose | Invocation |
|------|---------|------------|
| Worktrees Skill | Documentation | Activated by context |
| Feature Command | New feature worktree | `/worktree-feature` |
| Review Command | PR review worktree | `/worktree-review` |
| Experiment Command | Locked experiment | `/worktree-experiment` |

---

## Related Resources

- [Git Worktrees Skill](../../.claude/skills/git-worktrees/SKILL.md)
- [Git Documentation](https://git-scm.com/docs/git-worktree)
