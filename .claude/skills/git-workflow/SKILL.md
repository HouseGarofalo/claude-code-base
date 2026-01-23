---
name: git-workflow
description: Advanced Git workflows including interactive rebase, cherry-pick, bisect for bug hunting, reflog recovery, submodules, worktrees, and complex merge strategies. Use when debugging with git bisect, cleaning history, recovering lost commits, or managing complex version control scenarios.
---

# Git Workflow Skill

## Triggers

Use this skill when you see:
- git, branch, merge, rebase, commit
- worktree, stash, cherry-pick, bisect
- reflog, reset, revert, amend
- submodule, subtree, sparse checkout
- conflict resolution, history cleanup

## Instructions

### Branching Strategy

```bash
# Feature branch workflow
git checkout -b feature/description main
git checkout -b bugfix/issue-123 main
git checkout -b hotfix/critical-fix production

# List branches
git branch -a
git branch --merged main
git branch --no-merged main

# Delete branches
git branch -d feature/completed
git branch -D feature/force-delete
git push origin --delete feature/old-branch

# Rename branch
git branch -m old-name new-name
```

### Rebasing

```bash
# Rebase onto main
git checkout feature-branch
git rebase main

# Interactive rebase (last N commits)
git rebase -i HEAD~5

# Rebase onto specific commit
git rebase --onto main feature-start feature-end

# Continue after resolving conflicts
git rebase --continue

# Abort rebase
git rebase --abort

# Skip problematic commit
git rebase --skip
```

### Interactive Rebase Commands

In interactive rebase editor:
- `pick` - use commit as-is
- `reword` - change commit message
- `edit` - stop to amend commit
- `squash` - combine with previous commit
- `fixup` - squash but discard message
- `drop` - remove commit
- `exec` - run command

```bash
# Squash last 3 commits
git rebase -i HEAD~3
# Change 'pick' to 'squash' for commits to combine

# Reorder commits
git rebase -i HEAD~5
# Move lines to reorder
```

### Cherry-Pick

```bash
# Pick single commit
git cherry-pick abc123

# Pick multiple commits
git cherry-pick abc123 def456

# Pick range of commits
git cherry-pick abc123..def456

# Cherry-pick without committing
git cherry-pick -n abc123

# Continue after conflict
git cherry-pick --continue

# Abort
git cherry-pick --abort
```

### Git Bisect (Bug Hunting)

```bash
# Start bisect
git bisect start

# Mark current as bad
git bisect bad

# Mark known good commit
git bisect good v1.0.0

# Git will checkout middle commit
# Test it, then mark:
git bisect good  # or
git bisect bad

# When found, reset
git bisect reset

# Automated bisect with test script
git bisect start HEAD v1.0.0
git bisect run npm test
```

### Worktrees

```bash
# Create worktree for parallel work
git worktree add ../project-hotfix hotfix-branch
git worktree add ../project-feature feature-branch

# List worktrees
git worktree list

# Remove worktree
git worktree remove ../project-hotfix

# Prune stale worktrees
git worktree prune
```

### Stashing

```bash
# Stash changes
git stash
git stash push -m "Description"

# Stash including untracked
git stash -u

# Stash specific files
git stash push -m "message" -- file1.txt file2.txt

# List stashes
git stash list

# Apply stash
git stash apply stash@{0}
git stash pop  # apply and remove

# View stash contents
git stash show -p stash@{0}

# Create branch from stash
git stash branch new-branch stash@{0}

# Drop stash
git stash drop stash@{0}
git stash clear  # drop all
```

### Reflog (Recovery)

```bash
# View reflog
git reflog
git reflog show HEAD
git reflog show feature-branch

# Recover deleted branch
git reflog
# Find commit before deletion
git checkout -b recovered-branch abc123

# Undo hard reset
git reflog
# Find commit before reset
git reset --hard abc123

# Recover dropped stash
git fsck --no-reflog | grep commit
# Find orphaned commits
git stash apply abc123
```

### Reset and Revert

```bash
# Soft reset (keep changes staged)
git reset --soft HEAD~1

# Mixed reset (keep changes unstaged)
git reset HEAD~1
git reset --mixed HEAD~1

# Hard reset (discard changes)
git reset --hard HEAD~1

# Reset specific file
git reset HEAD file.txt

# Revert commit (creates new commit)
git revert abc123
git revert abc123 --no-commit

# Revert merge commit
git revert -m 1 merge_commit_hash
```

### Conflict Resolution

```bash
# View conflicts
git status
git diff --name-only --diff-filter=U

# Use ours/theirs
git checkout --ours file.txt
git checkout --theirs file.txt

# Use merge tool
git mergetool

# After resolving
git add resolved-file.txt
git commit  # or continue rebase/merge
```

### Submodules

```bash
# Add submodule
git submodule add https://github.com/owner/repo path/to/submodule

# Initialize submodules after clone
git submodule init
git submodule update
# Or combined:
git submodule update --init --recursive

# Update submodules to latest
git submodule update --remote

# Remove submodule
git submodule deinit path/to/submodule
git rm path/to/submodule
rm -rf .git/modules/path/to/submodule
```

### Advanced Operations

```bash
# Amend last commit
git commit --amend
git commit --amend --no-edit  # keep message
git commit --amend --author="Name <email>"

# Fixup commit (for later squash)
git commit --fixup abc123
git rebase -i --autosquash main

# Clean untracked files
git clean -n  # dry run
git clean -f  # force
git clean -fd  # include directories
git clean -fX  # only ignored files

# Archive
git archive --format=zip HEAD > archive.zip

# Blame
git blame file.txt
git blame -L 10,20 file.txt

# Log with graph
git log --oneline --graph --all
git log --oneline --first-parent main
```

### Merge Strategies

```bash
# Standard merge
git merge feature-branch

# No fast-forward (always create merge commit)
git merge --no-ff feature-branch

# Fast-forward only
git merge --ff-only feature-branch

# Squash merge (no merge commit)
git merge --squash feature-branch
git commit -m "Merge feature"

# Merge with strategy
git merge -s recursive -X theirs feature-branch
git merge -s ours feature-branch  # keep ours entirely
```

## Best Practices

1. **Commit Often**: Small, logical commits are easier to manage
2. **Write Good Messages**: Explain why, not just what
3. **Rebase Before PR**: Clean history before review
4. **Never Rebase Public Branches**: Only rebase local/feature branches
5. **Use Worktrees**: For parallel work without stashing
6. **Tag Releases**: Semantic versioning for releases
7. **Keep Main Clean**: Protect main branch, require PRs
