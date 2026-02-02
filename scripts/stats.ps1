<#
.SYNOPSIS
    Display repository statistics for a Claude Code project.

.DESCRIPTION
    This script analyzes and displays:
    - Skills count by category
    - Commands count
    - Context files count
    - Total lines of code
    - File size breakdown
    - Recent changes

.PARAMETER Path
    Path to the repository to analyze. Defaults to current directory.

.PARAMETER OutputFormat
    Output format: table, json, or markdown.

.PARAMETER IncludeGitStats
    Include git statistics (commits, contributors, etc.).

.EXAMPLE
    .\stats.ps1

.EXAMPLE
    .\stats.ps1 -Path "E:\Repos\my-project" -OutputFormat json

.EXAMPLE
    .\stats.ps1 -IncludeGitStats

.NOTES
    Author: Claude Code Base
    Version: 1.0.0
#>

[CmdletBinding()]
param(
    [string]$Path,
    [ValidateSet("table", "json", "markdown")]
    [string]$OutputFormat = "table",
    [switch]$IncludeGitStats
)

# ============================================================================
# Configuration
# ============================================================================

$ErrorActionPreference = "Continue"

if (-not $Path) {
    $Path = Get-Location
}

if (-not (Test-Path $Path)) {
    Write-Host "Path not found: $Path" -ForegroundColor Red
    exit 1
}

# Statistics object
$Stats = [ordered]@{
    Repository = @{
        Path = $Path
        Name = Split-Path $Path -Leaf
        AnalyzedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    Skills = @{
        Total = 0
        Categories = @{}
    }
    Commands = @{
        Total = 0
        Categories = @{}
    }
    ContextFiles = @{
        Total = 0
        Files = @()
    }
    CodeStats = @{
        TotalFiles = 0
        TotalLines = 0
        TotalSize = 0
        ByExtension = @{}
    }
    RecentChanges = @()
    GitStats = @{}
}

# ============================================================================
# Helper Functions
# ============================================================================

function Get-LineCount {
    param([string]$FilePath)

    try {
        return (Get-Content $FilePath -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
    }
    catch {
        return 0
    }
}

function Format-FileSize {
    param([long]$Bytes)

    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "$Bytes bytes"
}

function Write-TableHeader {
    param([string]$Title)

    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================================================
# Analysis Functions
# ============================================================================

function Get-SkillStats {
    $skillsPath = Join-Path $Path "skills"

    if (-not (Test-Path $skillsPath)) {
        # Check template location
        $skillsPath = Join-Path $Path "templates\skill-template"
        if (-not (Test-Path $skillsPath)) {
            return
        }
    }

    $skillFiles = Get-ChildItem -Path $skillsPath -Filter "SKILL.md" -Recurse -File -ErrorAction SilentlyContinue

    foreach ($skill in $skillFiles) {
        $categoryDir = Split-Path (Split-Path $skill.FullName -Parent) -Parent
        $category = Split-Path $categoryDir -Leaf

        if (-not $Stats.Skills.Categories.ContainsKey($category)) {
            $Stats.Skills.Categories[$category] = 0
        }
        $Stats.Skills.Categories[$category]++
        $Stats.Skills.Total++
    }
}

function Get-CommandStats {
    $commandsPath = Join-Path $Path "commands"

    if (-not (Test-Path $commandsPath)) {
        # Check template location
        $commandsPath = Join-Path $Path "templates\command-template"
        if (-not (Test-Path $commandsPath)) {
            return
        }
    }

    $categories = Get-ChildItem -Path $commandsPath -Directory -ErrorAction SilentlyContinue

    foreach ($category in $categories) {
        $commands = Get-ChildItem -Path $category.FullName -Filter "*.md" -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne "README.md" }

        if ($commands.Count -gt 0) {
            $Stats.Commands.Categories[$category.Name] = $commands.Count
            $Stats.Commands.Total += $commands.Count
        }
    }
}

function Get-ContextFileStats {
    $claudeDir = Join-Path $Path ".claude"

    if (-not (Test-Path $claudeDir)) {
        return
    }

    $contextFiles = Get-ChildItem -Path $claudeDir -Filter "*.md" -File -ErrorAction SilentlyContinue
    $contextFiles += Get-ChildItem -Path $claudeDir -Filter "*.yaml" -File -ErrorAction SilentlyContinue
    $contextFiles += Get-ChildItem -Path $claudeDir -Filter "*.yml" -File -ErrorAction SilentlyContinue

    # Also check for CLAUDE.md in root
    $claudeMd = Join-Path $Path "CLAUDE.md"
    if (Test-Path $claudeMd) {
        $Stats.ContextFiles.Files += "CLAUDE.md"
        $Stats.ContextFiles.Total++
    }

    foreach ($file in $contextFiles) {
        $Stats.ContextFiles.Files += ".claude\$($file.Name)"
        $Stats.ContextFiles.Total++
    }
}

function Get-CodeStats {
    # File extensions to track
    $codeExtensions = @(
        ".ps1", ".py", ".js", ".ts", ".tsx", ".jsx",
        ".cs", ".java", ".go", ".rs", ".rb", ".php",
        ".sh", ".bash", ".zsh",
        ".yaml", ".yml", ".json", ".toml",
        ".md", ".mdx",
        ".html", ".css", ".scss", ".sass",
        ".sql", ".graphql"
    )

    $files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch '\\node_modules\\|\\\.git\\|\\venv\\|\\__pycache__\\|\\bin\\|\\obj\\'
        }

    foreach ($file in $files) {
        $ext = $file.Extension.ToLower()

        if ($ext -in $codeExtensions) {
            $Stats.CodeStats.TotalFiles++
            $Stats.CodeStats.TotalSize += $file.Length

            $lines = Get-LineCount -FilePath $file.FullName
            $Stats.CodeStats.TotalLines += $lines

            if (-not $Stats.CodeStats.ByExtension.ContainsKey($ext)) {
                $Stats.CodeStats.ByExtension[$ext] = @{
                    Files = 0
                    Lines = 0
                    Size = 0
                }
            }

            $Stats.CodeStats.ByExtension[$ext].Files++
            $Stats.CodeStats.ByExtension[$ext].Lines += $lines
            $Stats.CodeStats.ByExtension[$ext].Size += $file.Length
        }
    }
}

function Get-RecentChanges {
    $gitDir = Join-Path $Path ".git"

    if (-not (Test-Path $gitDir)) {
        return
    }

    try {
        Push-Location $Path

        # Get recent commits
        $commits = git log --oneline -10 2>$null
        if ($commits) {
            $Stats.RecentChanges = $commits -split "`n" | ForEach-Object {
                @{
                    Hash = $_.Substring(0, 7)
                    Message = $_.Substring(8)
                }
            }
        }

        Pop-Location
    }
    catch {
        # Git not available or not a repo
    }
}

function Get-GitStats {
    $gitDir = Join-Path $Path ".git"

    if (-not (Test-Path $gitDir)) {
        return
    }

    try {
        Push-Location $Path

        # Total commits
        $totalCommits = (git rev-list --count HEAD 2>$null)
        if ($totalCommits) {
            $Stats.GitStats.TotalCommits = [int]$totalCommits
        }

        # Contributors
        $contributors = git shortlog -sn HEAD 2>$null
        if ($contributors) {
            $Stats.GitStats.Contributors = ($contributors -split "`n").Count
        }

        # Current branch
        $branch = git branch --show-current 2>$null
        if ($branch) {
            $Stats.GitStats.CurrentBranch = $branch.Trim()
        }

        # First commit date
        $firstCommit = git log --reverse --format="%ai" 2>$null | Select-Object -First 1
        if ($firstCommit) {
            $Stats.GitStats.FirstCommit = $firstCommit.Substring(0, 10)
        }

        # Last commit date
        $lastCommit = git log -1 --format="%ai" 2>$null
        if ($lastCommit) {
            $Stats.GitStats.LastCommit = $lastCommit.Substring(0, 10)
        }

        # Uncommitted changes
        $status = git status --porcelain 2>$null
        if ($status) {
            $Stats.GitStats.UncommittedChanges = ($status -split "`n").Count
        }
        else {
            $Stats.GitStats.UncommittedChanges = 0
        }

        Pop-Location
    }
    catch {
        # Git not available
    }
}

# ============================================================================
# Output Functions
# ============================================================================

function Write-TableOutput {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "         Claude Code Base - Repository Statistics                     " -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Repository: $($Stats.Repository.Name)" -ForegroundColor White
    Write-Host "  Path:       $($Stats.Repository.Path)" -ForegroundColor Gray
    Write-Host "  Analyzed:   $($Stats.Repository.AnalyzedAt)" -ForegroundColor Gray

    # Skills
    Write-TableHeader "Skills ($($Stats.Skills.Total) total)"

    if ($Stats.Skills.Categories.Count -gt 0) {
        $sorted = $Stats.Skills.Categories.GetEnumerator() | Sort-Object Value -Descending
        foreach ($category in $sorted) {
            Write-Host "  $($category.Key.PadRight(25)) $($category.Value)" -ForegroundColor White
        }
    }
    else {
        Write-Host "  No skills found" -ForegroundColor Gray
    }

    # Commands
    Write-TableHeader "Commands ($($Stats.Commands.Total) total)"

    if ($Stats.Commands.Categories.Count -gt 0) {
        $sorted = $Stats.Commands.Categories.GetEnumerator() | Sort-Object Value -Descending
        foreach ($category in $sorted) {
            Write-Host "  $($category.Key.PadRight(25)) $($category.Value)" -ForegroundColor White
        }
    }
    else {
        Write-Host "  No commands found" -ForegroundColor Gray
    }

    # Context Files
    Write-TableHeader "Context Files ($($Stats.ContextFiles.Total) total)"

    if ($Stats.ContextFiles.Files.Count -gt 0) {
        foreach ($file in $Stats.ContextFiles.Files) {
            Write-Host "  - $file" -ForegroundColor White
        }
    }
    else {
        Write-Host "  No context files found" -ForegroundColor Gray
    }

    # Code Statistics
    Write-TableHeader "Code Statistics"

    Write-Host "  Total Files:      $($Stats.CodeStats.TotalFiles)" -ForegroundColor White
    Write-Host "  Total Lines:      $($Stats.CodeStats.TotalLines.ToString('N0'))" -ForegroundColor White
    Write-Host "  Total Size:       $(Format-FileSize $Stats.CodeStats.TotalSize)" -ForegroundColor White
    Write-Host ""

    if ($Stats.CodeStats.ByExtension.Count -gt 0) {
        Write-Host "  By Extension:" -ForegroundColor Cyan
        $sorted = $Stats.CodeStats.ByExtension.GetEnumerator() | Sort-Object { $_.Value.Lines } -Descending | Select-Object -First 10

        foreach ($ext in $sorted) {
            $extName = $ext.Key.PadRight(10)
            $files = "$($ext.Value.Files) files".PadRight(12)
            $lines = "$($ext.Value.Lines.ToString('N0')) lines".PadRight(15)
            $size = Format-FileSize $ext.Value.Size
            Write-Host "    $extName $files $lines $size" -ForegroundColor White
        }
    }

    # Recent Changes
    if ($Stats.RecentChanges.Count -gt 0) {
        Write-TableHeader "Recent Changes"

        foreach ($commit in $Stats.RecentChanges | Select-Object -First 5) {
            Write-Host "  $($commit.Hash) $($commit.Message)" -ForegroundColor White
        }
    }

    # Git Statistics
    if ($IncludeGitStats -and $Stats.GitStats.Count -gt 0) {
        Write-TableHeader "Git Statistics"

        if ($Stats.GitStats.TotalCommits) {
            Write-Host "  Total Commits:    $($Stats.GitStats.TotalCommits)" -ForegroundColor White
        }
        if ($Stats.GitStats.Contributors) {
            Write-Host "  Contributors:     $($Stats.GitStats.Contributors)" -ForegroundColor White
        }
        if ($Stats.GitStats.CurrentBranch) {
            Write-Host "  Current Branch:   $($Stats.GitStats.CurrentBranch)" -ForegroundColor White
        }
        if ($Stats.GitStats.FirstCommit) {
            Write-Host "  First Commit:     $($Stats.GitStats.FirstCommit)" -ForegroundColor White
        }
        if ($Stats.GitStats.LastCommit) {
            Write-Host "  Last Commit:      $($Stats.GitStats.LastCommit)" -ForegroundColor White
        }
        if ($Stats.GitStats.UncommittedChanges -gt 0) {
            Write-Host "  Uncommitted:      $($Stats.GitStats.UncommittedChanges) file(s)" -ForegroundColor Yellow
        }
    }

    Write-Host ""
}

function Write-JsonOutput {
    $Stats | ConvertTo-Json -Depth 10
}

function Write-MarkdownOutput {
    Write-Output "# Repository Statistics"
    Write-Output ""
    Write-Output "- **Repository:** $($Stats.Repository.Name)"
    Write-Output "- **Path:** ``$($Stats.Repository.Path)``"
    Write-Output "- **Analyzed:** $($Stats.Repository.AnalyzedAt)"
    Write-Output ""

    Write-Output "## Skills ($($Stats.Skills.Total) total)"
    Write-Output ""
    if ($Stats.Skills.Categories.Count -gt 0) {
        Write-Output "| Category | Count |"
        Write-Output "|----------|-------|"
        $sorted = $Stats.Skills.Categories.GetEnumerator() | Sort-Object Value -Descending
        foreach ($category in $sorted) {
            Write-Output "| $($category.Key) | $($category.Value) |"
        }
    }
    else {
        Write-Output "No skills found."
    }
    Write-Output ""

    Write-Output "## Commands ($($Stats.Commands.Total) total)"
    Write-Output ""
    if ($Stats.Commands.Categories.Count -gt 0) {
        Write-Output "| Category | Count |"
        Write-Output "|----------|-------|"
        $sorted = $Stats.Commands.Categories.GetEnumerator() | Sort-Object Value -Descending
        foreach ($category in $sorted) {
            Write-Output "| $($category.Key) | $($category.Value) |"
        }
    }
    else {
        Write-Output "No commands found."
    }
    Write-Output ""

    Write-Output "## Code Statistics"
    Write-Output ""
    Write-Output "- **Total Files:** $($Stats.CodeStats.TotalFiles)"
    Write-Output "- **Total Lines:** $($Stats.CodeStats.TotalLines.ToString('N0'))"
    Write-Output "- **Total Size:** $(Format-FileSize $Stats.CodeStats.TotalSize)"
    Write-Output ""

    if ($Stats.CodeStats.ByExtension.Count -gt 0) {
        Write-Output "### By Extension"
        Write-Output ""
        Write-Output "| Extension | Files | Lines | Size |"
        Write-Output "|-----------|-------|-------|------|"
        $sorted = $Stats.CodeStats.ByExtension.GetEnumerator() | Sort-Object { $_.Value.Lines } -Descending | Select-Object -First 10
        foreach ($ext in $sorted) {
            Write-Output "| $($ext.Key) | $($ext.Value.Files) | $($ext.Value.Lines.ToString('N0')) | $(Format-FileSize $ext.Value.Size) |"
        }
    }
    Write-Output ""

    if ($IncludeGitStats -and $Stats.GitStats.Count -gt 0) {
        Write-Output "## Git Statistics"
        Write-Output ""
        if ($Stats.GitStats.TotalCommits) { Write-Output "- **Total Commits:** $($Stats.GitStats.TotalCommits)" }
        if ($Stats.GitStats.Contributors) { Write-Output "- **Contributors:** $($Stats.GitStats.Contributors)" }
        if ($Stats.GitStats.CurrentBranch) { Write-Output "- **Current Branch:** $($Stats.GitStats.CurrentBranch)" }
        if ($Stats.GitStats.FirstCommit) { Write-Output "- **First Commit:** $($Stats.GitStats.FirstCommit)" }
        if ($Stats.GitStats.LastCommit) { Write-Output "- **Last Commit:** $($Stats.GitStats.LastCommit)" }
    }
}

# ============================================================================
# Main Execution
# ============================================================================

# Gather statistics
Get-SkillStats
Get-CommandStats
Get-ContextFileStats
Get-CodeStats
Get-RecentChanges

if ($IncludeGitStats) {
    Get-GitStats
}

# Output results
switch ($OutputFormat) {
    "json" { Write-JsonOutput }
    "markdown" { Write-MarkdownOutput }
    default { Write-TableOutput }
}
