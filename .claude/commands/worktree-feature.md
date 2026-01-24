---
description: Start a new feature in an isolated Git worktree
---

# Worktree Feature

Start a new feature branch in an isolated Git worktree for parallel development.

## When to Use

Use this when you need to:
- Work on multiple features simultaneously
- Keep your main work untouched while switching context
- Avoid stashing and context-switching overhead

## Arguments

$ARGUMENTS

---

## Creating a Feature Worktree

### Step 1: Create the worktree

```bash
# From your main repository directory
git fetch origin main
git worktree add -b feature/{feature-name} \
  ../{repo-name}-feature-{feature-name} origin/main
```

### Step 2: Set up the worktree

```bash
cd ../{repo-name}-feature-{feature-name}

# Install dependencies (if needed)
npm install  # or pip install -r requirements.txt, etc.

# Open in editor
code .
```

### Step 3: Start developing

Your main repo is untouched. Work freely on this feature:

```bash
# Make changes, commit as usual
git add .
git commit -m "feat({scope}): add new component"
git push -u origin feature/{feature-name}
```

## Switching Between Features

```bash
# Go to main work
cd ../{repo-name}

# Go to this feature
cd ../{repo-name}-feature-{feature-name}
```

## When Done (after PR merged)

```bash
cd ../{repo-name}
git worktree remove ../{repo-name}-feature-{feature-name}
git branch -d feature/{feature-name}
```

## Tips

- Each worktree has its own `node_modules` - run install commands
- Commits and pushes work normally from any worktree
- Use `git worktree list` to see all your worktrees
- Worktrees share the same git history and remote

## Quick Reference

| Action | Command |
|--------|---------|
| Create worktree | `git worktree add -b {branch} ../{folder} origin/main` |
| List worktrees | `git worktree list` |
| Remove worktree | `git worktree remove ../{folder}` |
| Prune stale | `git worktree prune` |
