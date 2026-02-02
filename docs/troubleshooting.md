# Troubleshooting Guide

Common issues and solutions for Claude Code projects.

## Table of Contents

- [MCP Server Issues](#mcp-server-issues)
- [Skill Issues](#skill-issues)
- [Command Issues](#command-issues)
- [Archon Connection Issues](#archon-connection-issues)
- [Permission Issues](#permission-issues)
- [Context Issues](#context-issues)
- [Git Issues](#git-issues)
- [Environment Issues](#environment-issues)

---

## MCP Server Issues

### Server Not Connecting

**Symptoms:**
- "MCP server not available" messages
- Tools from MCP server not appearing
- `/mcp` shows server as disconnected

**Solutions:**

1. **Check server configuration:**
   ```bash
   # View mcp.json configuration
   cat .vscode/mcp.json
   ```

2. **Verify the command exists:**
   ```bash
   # For npm-based servers
   npx -y @anthropic/mcp-brave-search --version

   # For Python-based servers
   archon --version
   ```

3. **Check environment variables:**
   ```powershell
   # PowerShell
   $env:BRAVE_API_KEY
   $env:ARCHON_API_URL
   ```

4. **Restart Claude Code:**
   - Close and reopen VS Code
   - Or run `/mcp restart` if available

5. **Check logs:**
   ```bash
   # Check Claude Code logs
   cat ~/.claude/logs/mcp-*.log
   ```

### Server Timeout

**Symptoms:**
- Server connects but operations time out
- Slow responses from MCP tools

**Solutions:**

1. **Increase timeout in mcp.json:**
   ```json
   {
     "mcpServers": {
       "archon": {
         "command": "archon",
         "args": ["mcp-server"],
         "timeout": 60000
       }
     }
   }
   ```

2. **Check network connectivity:**
   ```bash
   # Test API endpoint
   curl -I https://your-archon-api.com/health
   ```

3. **Check server resource usage:**
   - Ensure sufficient memory/CPU
   - Close unnecessary applications

### Server Crashes

**Symptoms:**
- Server disconnects mid-operation
- Repeated reconnection attempts

**Solutions:**

1. **Update the server package:**
   ```bash
   npm update -g @anthropic/mcp-brave-search
   pip install --upgrade archon-ai
   ```

2. **Check for version compatibility:**
   - Ensure Claude Code version matches server requirements
   - Check server documentation for compatibility matrix

3. **Run server manually to see errors:**
   ```bash
   # Run the server command directly
   npx -y @anthropic/mcp-brave-search
   ```

---

## Skill Issues

### Skill Not Activating

**Symptoms:**
- Claude doesn't recognize skill trigger phrases
- Skill instructions not being followed

**Solutions:**

1. **Verify skill location:**
   ```bash
   # Global skills
   ls ~/.claude/skills/

   # Project skills
   ls .claude/skills/
   ```

2. **Check SKILL.md format:**
   ```yaml
   ---
   name: skill-name
   description: Clear description with trigger keywords
   ---

   # Skill Name

   ## Instructions
   ```

3. **Validate skill name:**
   - Must be lowercase letters, numbers, hyphens only
   - Maximum 64 characters
   - No spaces or underscores

4. **Check description:**
   - Must be under 1024 characters
   - Include trigger keywords
   - Be specific about when to use

5. **Restart Claude Code** to reload skills

### Skill Not Found in Global Directory

**Solutions:**

1. **Deploy skills:**
   ```powershell
   .\scripts\deploy-skills.ps1
   ```

2. **Verify deployment:**
   ```bash
   ls ~/.claude/skills/your-skill-name/SKILL.md
   ```

3. **Check permissions:**
   ```bash
   # Ensure readable
   cat ~/.claude/skills/your-skill-name/SKILL.md
   ```

### Skill Conflicting with Another

**Symptoms:**
- Wrong skill activates
- Unexpected behavior

**Solutions:**

1. **Review skill descriptions** - make them more specific
2. **Use unique trigger phrases** in descriptions
3. **Check for duplicate skill names** across directories

---

## Command Issues

### Command Not Found

**Symptoms:**
- `/your-command` shows "Unknown command"

**Solutions:**

1. **Verify command location:**
   ```bash
   # Global commands
   ls ~/.claude/commands/

   # Project commands
   ls .claude/commands/
   ```

2. **Check filename:**
   - Must be `command-name.md`
   - Filename becomes `/command-name`

3. **Validate markdown format:**
   ```markdown
   # Command Name

   ## Description
   What this command does.

   ## Usage
   /command-name [args]

   ## Instructions
   ...
   ```

4. **Restart Claude Code** to reload commands

### Command Executes Incorrectly

**Solutions:**

1. **Check command instructions** for clarity
2. **Add explicit examples** in the command file
3. **Verify any referenced files/paths exist**

---

## Archon Connection Issues

### Cannot Connect to Archon API

**Symptoms:**
- `find_tasks()` fails
- "Connection refused" errors

**Solutions:**

1. **Check API URL:**
   ```powershell
   $env:ARCHON_API_URL
   # Should be something like: https://your-archon-instance.com
   ```

2. **Test connectivity:**
   ```bash
   curl -I $ARCHON_API_URL/health
   ```

3. **Check authentication:**
   ```powershell
   $env:ARCHON_API_KEY
   ```

4. **Verify firewall/proxy settings**

### Tasks Not Syncing

**Symptoms:**
- Changes not persisting
- Stale task data

**Solutions:**

1. **Check network connectivity**
2. **Verify project ID:**
   ```yaml
   # .claude/config.yaml
   archon_project_id: "your-uuid-here"
   ```

3. **Clear local cache:**
   ```bash
   rm -rf ~/.claude/cache/archon/
   ```

### Project Not Found

**Solutions:**

1. **Verify project ID in config.yaml**
2. **Check project exists in Archon:**
   ```python
   find_projects(project_id="your-uuid")
   ```
3. **Create project if needed:**
   ```python
   manage_project("create", title="Your Project")
   ```

---

## Permission Issues

### Cannot Read/Write Files

**Symptoms:**
- "Access denied" errors
- File operations fail

**Solutions:**

1. **Check file permissions:**
   ```bash
   ls -la path/to/file
   ```

2. **Check directory permissions:**
   ```bash
   ls -la path/to/directory/
   ```

3. **On Windows, check if file is locked:**
   - Close applications that might have the file open
   - Check for antivirus interference

4. **Run as administrator** if necessary (be cautious)

### Cannot Execute Scripts

**Symptoms:**
- PowerShell scripts fail with execution policy error

**Solutions:**

1. **Check execution policy:**
   ```powershell
   Get-ExecutionPolicy
   ```

2. **Set appropriate policy:**
   ```powershell
   # For current user
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Bypass for single script:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File script.ps1
   ```

---

## Context Issues

### Context Too Large

**Symptoms:**
- "Context limit exceeded" warnings
- Slow responses
- Truncated outputs

**Solutions:**

1. **Check context usage:**
   ```
   /cost
   ```

2. **Compact conversation:**
   ```
   /compact
   ```

3. **Clear and restart:**
   ```
   /clear
   ```

4. **Use references instead of loading full files:**
   ```markdown
   See .claude/reference/file.md for details
   ```

5. **Split large tasks** into smaller sessions

### Lost Context After Clear

**Symptoms:**
- Claude forgets previous work
- Has to re-discover project structure

**Solutions:**

1. **Update Session Knowledge before clearing:**
   - Save state to `.claude/SESSION_KNOWLEDGE.md`
   - Update Archon documents

2. **Use Archon documents for persistence:**
   - Architecture.md
   - Deployment.md
   - Context.md

3. **Reference config files:**
   ```bash
   cat .claude/config.yaml
   ```

---

## Git Issues

### Pre-commit Hooks Failing

**Symptoms:**
- Commits rejected
- Hook errors

**Solutions:**

1. **Run hooks manually:**
   ```bash
   pre-commit run --all-files
   ```

2. **Update hooks:**
   ```bash
   pre-commit autoupdate
   ```

3. **Skip hooks temporarily (use sparingly):**
   ```bash
   git commit --no-verify -m "message"
   ```

4. **Fix the underlying issues** the hooks are catching

### Merge Conflicts

**Solutions:**

1. **Let Claude help resolve:**
   ```
   Help me resolve the merge conflicts in file.ts
   ```

2. **Use VS Code's merge editor**

3. **Abort and restart if needed:**
   ```bash
   git merge --abort
   ```

---

## Environment Issues

### Missing Environment Variables

**Symptoms:**
- Features not working
- "API key not found" errors

**Solutions:**

1. **Check .env file exists:**
   ```bash
   ls -la .env
   ```

2. **Verify variables are set:**
   ```powershell
   # PowerShell
   Get-Content .env | ForEach-Object {
     $parts = $_ -split '=', 2
     if ($parts[0] -notmatch '^#') {
       Write-Host "$($parts[0]): $(if ([Environment]::GetEnvironmentVariable($parts[0])) { 'SET' } else { 'NOT SET' })"
     }
   }
   ```

3. **Load .env file:**
   ```powershell
   # PowerShell - load for current session
   Get-Content .env | ForEach-Object {
     if ($_ -match '^([^#][^=]+)=(.*)$') {
       [Environment]::SetEnvironmentVariable($matches[1], $matches[2])
     }
   }
   ```

4. **Use .env.example as reference:**
   ```bash
   cp .env.example .env
   # Then fill in actual values
   ```

### Node/Python Version Mismatch

**Symptoms:**
- Package installation failures
- Syntax errors

**Solutions:**

1. **Check versions:**
   ```bash
   node --version
   python --version
   ```

2. **Use version manager:**
   ```bash
   # Node - use nvm
   nvm use 20

   # Python - use pyenv
   pyenv local 3.11
   ```

3. **Check project requirements** in README or setup docs

---

## Getting More Help

If these solutions don't resolve your issue:

1. **Check Claude Code documentation:** https://code.claude.com/docs
2. **Search GitHub issues:** https://github.com/anthropics/claude-code/issues
3. **Review error logs:**
   ```bash
   cat ~/.claude/logs/*.log
   ```
4. **Gather diagnostic info:**
   ```bash
   claude --version
   node --version
   python --version
   ```

When reporting issues, include:
- Claude Code version
- Operating system
- Steps to reproduce
- Error messages (full text)
- Relevant configuration files (redact secrets)
