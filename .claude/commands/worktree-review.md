---
description: Review a pull request in an isolated Git worktree
---

# Worktree Review

Set up an isolated worktree to review a pull request without disrupting your current work.

## When to Use

Use this when you need to:
- Review a PR while keeping your current work untouched
- Run tests and check functionality in isolation
- Make review suggestions in a clean environment

## Arguments

$ARGUMENTS

---

## Setting Up PR Review Worktree

### Step 1: Fetch the PR

```bash
git fetch origin pull/{pr-number}/head:pr-{pr-number}
```

### Step 2: Create isolated review worktree

```bash
git worktree add ../{repo-name}-pr-{pr-number} pr-{pr-number}
cd ../{repo-name}-pr-{pr-number}
```

### Step 3: Set up for testing

```bash
# Install dependencies
npm install  # or relevant setup command

# Run tests
npm test

# Start the app (if applicable)
npm start
```

## Review Checklist

- [ ] **Code Quality**: Is the code clean and well-structured?
- [ ] **Tests**: Are there adequate tests? Do they pass?
- [ ] **Functionality**: Does the feature work as described?
- [ ] **Edge Cases**: Are edge cases handled?
- [ ] **Performance**: Any performance concerns?
- [ ] **Security**: Any security issues?
- [ ] **Documentation**: Is documentation updated?

## Providing Feedback

```bash
# If you need to suggest changes, you can create a branch
git checkout -b pr-{pr-number}-suggestions
# Make changes, commit, and reference in review comments
```

## After Review - Cleanup

```bash
# Return to your work
cd ../{repo-name}

# Remove the review worktree
git worktree remove ../{repo-name}-pr-{pr-number}

# Delete the local branch
git branch -d pr-{pr-number}
```

## Quick Reference

| Action | Command |
|--------|---------|
| Go to review | `cd ../{repo-name}-pr-{pr-number}` |
| Return to work | `cd ../{repo-name}` |
| List worktrees | `git worktree list` |
| Remove worktree | `git worktree remove ../{folder}` |

## Alternative: GitHub CLI Review

For lighter reviews without full worktree setup:

```bash
# View PR details
gh pr view {pr-number}

# View PR diff
gh pr diff {pr-number}

# Checkout PR directly (switches current branch)
gh pr checkout {pr-number}
```
