---
description: Create a locked Git worktree for long-running experiments
---

# Worktree Experiment

Create a locked worktree for experimental work that may span days or weeks.

## When to Use

Use this for:
- Major architectural changes
- Proof-of-concept implementations
- Database migration experiments
- Framework upgrades
- Any work you don't want accidentally deleted

## Arguments

$ARGUMENTS

---

## Creating an Experiment Worktree

### Step 1: Create the experimental worktree

```bash
# Create worktree with new experiment branch
git worktree add -b experiment/{experiment-name} \
  ../{repo-name}-experiment-{name} origin/main
```

### Step 2: Lock the worktree (prevents accidental deletion)

```bash
git worktree lock --reason "{description} - in progress" \
  ../{repo-name}-experiment-{name}
```

### Step 3: Set up the experiment

```bash
cd ../{repo-name}-experiment-{name}

# Install dependencies
npm install  # or pip install, etc.

# Open in editor
code .
```

## Working on the Experiment

```bash
# Switch to experiment
cd ../{repo-name}-experiment-{name}

# Regular commits
git add .
git commit -m "experiment: try new approach"

# Push to remote (for backup)
git push -u origin experiment/{experiment-name}

# Return to main work
cd ../{repo-name}
```

## Checking Worktree Status

```bash
# See all worktrees and lock status
git worktree list --porcelain

# See just the list
git worktree list
```

## Concluding the Experiment

### If successful - merge the changes:

```bash
# In main repo
cd ../{repo-name}

# Unlock and create PR
git worktree unlock ../{repo-name}-experiment-{name}

# Push and create PR via GitHub
git push origin experiment/{experiment-name}
gh pr create --title "feat: {description}"

# After merge, cleanup
git worktree remove ../{repo-name}-experiment-{name}
git branch -d experiment/{experiment-name}
```

### If abandoned - discard the changes:

```bash
cd ../{repo-name}

# Unlock first
git worktree unlock ../{repo-name}-experiment-{name}

# Force remove (discards uncommitted changes)
git worktree remove --force ../{repo-name}-experiment-{name}

# Delete the branch
git branch -D experiment/{experiment-name}
```

## Why Lock Experiments?

| Protection | Benefit |
|------------|---------|
| Prevents `git worktree remove` | Can't accidentally delete days of work |
| Survives `git worktree prune` | Won't be cleaned up as "stale" |
| Clear reason message | Remember why it exists |
