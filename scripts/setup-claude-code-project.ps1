<#
.SYNOPSIS
    Interactive wizard for setting up a new project from claude-code-base template.

.DESCRIPTION
    This script provides an interactive wizard that guides users through creating
    a new project with:
    - Project folder creation
    - Template file copying
    - Git initialization with pre-commit hooks
    - GitHub repository creation with branch protection and secret scanning
    - Archon project creation for task/document management
    - Placeholder replacement in CLAUDE.md and config.yaml

.PARAMETER NonInteractive
    Run in non-interactive mode using provided parameters.

.PARAMETER ParentPath
    Parent directory where the project folder will be created.

.PARAMETER ProjectName
    Name of the project (lowercase with hyphens).

.PARAMETER Description
    Brief description of the project.

.PARAMETER ProjectType
    Type of project (web-frontend, backend-api, fullstack, cli-library, infrastructure).

.PARAMETER GitHubOrg
    GitHub organization or username for the repository.

.PARAMETER Visibility
    Repository visibility (private, public).

.PARAMETER SkipArchon
    Skip Archon project creation.

.PARAMETER SkipGitHub
    Skip GitHub repository creation.

.EXAMPLE
    .\setup-claude-code-project.ps1

.EXAMPLE
    .\setup-claude-code-project.ps1 -NonInteractive -ParentPath "E:\Repos" -ProjectName "my-api" -GitHubOrg "MyOrg"

.EXAMPLE
    .\setup-claude-code-project.ps1 -SkipArchon -SkipGitHub

.NOTES
    Author: Claude Code Base
    Version: 1.0.0
#>

[CmdletBinding()]
param(
    [switch]$NonInteractive,
    [string]$ParentPath,
    [string]$ProjectName,
    [string]$Description = "",
    [ValidateSet("web-frontend", "backend-api", "fullstack", "cli-library", "infrastructure")]
    [string]$ProjectType = "backend-api",
    [string]$GitHubOrg,
    [ValidateSet("private", "public")]
    [string]$Visibility = "private",
    [switch]$SkipArchon,
    [switch]$SkipGitHub
)

# ============================================================================
# Configuration
# ============================================================================

$ErrorActionPreference = "Stop"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplatePath = Split-Path -Parent $ScriptPath

# Default patterns to exclude from copying
$ExcludePatterns = @(
    ".git",
    ".git\*",
    "node_modules",
    "node_modules\*",
    "__pycache__",
    "__pycache__\*",
    "*.pyc",
    ".venv",
    ".venv\*",
    "venv",
    "venv\*",
    "bin",
    "obj",
    ".vs",
    ".idea",
    "*.log",
    "*.tmp",
    ".secrets.baseline",
    "temp",
    "temp\*",
    "scripts\setup-claude-code-project.ps1"  # Don't copy this script itself
)

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Banner {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "         Claude Code Base - Project Wizard                            " -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Create a new project with Claude Code best practices," -ForegroundColor Gray
    Write-Host "  Archon integration, and GitHub configuration." -ForegroundColor Gray
    Write-Host ""
}

function Write-Step {
    param(
        [int]$Number,
        [string]$Title
    )
    Write-Host ""
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " Step $Number : $Title" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

function Write-Status {
    param(
        [string]$Message,
        [ValidateSet("SUCCESS", "ERROR", "WARNING", "WORKING", "INFO")]
        [string]$Status = "INFO"
    )

    $icon = switch ($Status) {
        "SUCCESS" { "[OK]" }
        "ERROR"   { "[X]" }
        "WARNING" { "[!]" }
        "WORKING" { "[~]" }
        default   { "[i]" }
    }

    $color = switch ($Status) {
        "SUCCESS" { "Green" }
        "ERROR"   { "Red" }
        "WARNING" { "Yellow" }
        "WORKING" { "Cyan" }
        default   { "White" }
    }

    Write-Host "$icon $Message" -ForegroundColor $color
}

function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$Default = "",
        [string[]]$ValidOptions = @(),
        [switch]$Required
    )

    $displayPrompt = $Prompt
    if ($Default) {
        $displayPrompt += " [$Default]"
    }
    $displayPrompt += ": "

    if ($ValidOptions.Count -gt 0) {
        Write-Host "  Options: $($ValidOptions -join ', ')" -ForegroundColor Gray
    }

    do {
        $input = Read-Host $displayPrompt
        if ([string]::IsNullOrWhiteSpace($input) -and $Default) {
            $input = $Default
        }

        if ($Required -and [string]::IsNullOrWhiteSpace($input)) {
            Write-Host "  This field is required." -ForegroundColor Red
            continue
        }

        if ($ValidOptions.Count -gt 0 -and $input -notin $ValidOptions) {
            Write-Host "  Please select from: $($ValidOptions -join ', ')" -ForegroundColor Red
            continue
        }

        break
    } while ($true)

    return $input
}

function Test-Prerequisites {
    Write-Step 1 "Checking Prerequisites"

    $allGood = $true

    # Check git
    try {
        $gitVersion = git --version 2>&1
        Write-Status "Git: $gitVersion" "SUCCESS"
    }
    catch {
        Write-Status "Git not found. Please install Git." "ERROR"
        $allGood = $false
    }

    # Check gh CLI
    try {
        $ghVersion = gh --version 2>&1 | Select-Object -First 1
        Write-Status "GitHub CLI: $ghVersion" "SUCCESS"

        # Check authentication
        $authStatus = gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Status "GitHub CLI authenticated" "SUCCESS"
        }
        else {
            Write-Status "GitHub CLI not authenticated. Run 'gh auth login'" "WARNING"
            if (-not $SkipGitHub) {
                $allGood = $false
            }
        }
    }
    catch {
        Write-Status "GitHub CLI not found. Install from https://cli.github.com" "WARNING"
        if (-not $SkipGitHub) {
            Write-Status "GitHub repository creation will be skipped." "INFO"
        }
    }

    # Check Python (for pre-commit)
    try {
        $pythonVersion = python --version 2>&1
        Write-Status "Python: $pythonVersion" "SUCCESS"
    }
    catch {
        Write-Status "Python not found. Pre-commit hooks may not work." "WARNING"
    }

    # Check if template path exists
    if (-not (Test-Path $TemplatePath)) {
        Write-Status "Template path not found: $TemplatePath" "ERROR"
        $allGood = $false
    }
    else {
        Write-Status "Template found: $TemplatePath" "SUCCESS"
    }

    return $allGood
}

function Test-ShouldExclude {
    param(
        [string]$RelativePath,
        [string[]]$Patterns
    )

    foreach ($pattern in $Patterns) {
        if ($RelativePath -like $pattern -or $RelativePath -like "*\$pattern" -or $RelativePath -like "*\$pattern\*") {
            return $true
        }
    }
    return $false
}

function Copy-TemplateFiles {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    # Ensure destination exists
    if (-not (Test-Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    }

    # Get all items from source
    $sourceItems = Get-ChildItem -Path $SourcePath -Recurse -Force

    # Track statistics
    $stats = @{
        Copied = 0
        Skipped = 0
        Directories = 0
    }

    foreach ($item in $sourceItems) {
        # Calculate relative path
        $relativePath = $item.FullName.Substring($SourcePath.Length).TrimStart('\')

        # Check if should exclude
        if (Test-ShouldExclude -RelativePath $relativePath -Patterns $ExcludePatterns) {
            $stats.Skipped++
            continue
        }

        $destinationItem = Join-Path $DestinationPath $relativePath

        if ($item.PSIsContainer) {
            # Create directory if it doesn't exist
            if (-not (Test-Path $destinationItem)) {
                New-Item -ItemType Directory -Path $destinationItem -Force | Out-Null
                $stats.Directories++
            }
        }
        else {
            # Ensure parent directory exists
            $parentDir = Split-Path $destinationItem -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }

            # Copy file
            Copy-Item -Path $item.FullName -Destination $destinationItem -Force
            $stats.Copied++
        }
    }

    return $stats
}

function Replace-Placeholders {
    param(
        [string]$ProjectPath,
        [string]$ProjectName,
        [string]$ProjectTitle,
        [string]$GitHubRepo,
        [string]$ArchonProjectId,
        [string]$CurrentDate
    )

    $placeholders = @{
        "[ARCHON_PROJECT_ID]" = $ArchonProjectId
        "[PROJECT_TITLE]"     = $ProjectTitle
        "[PROJECT_NAME]"      = $ProjectName
        "[GITHUB_REPO]"       = $GitHubRepo
        "[REPOSITORY_PATH]"   = $ProjectPath
        "[LOCAL_PATH]"        = $ProjectPath
        "[DATE]"              = $CurrentDate
        "[CREATION_DATE]"     = $CurrentDate
        "[LAST_UPDATE]"       = $CurrentDate
        "[TODAY_DATE]"        = $CurrentDate
        "[PRIMARY_STACK]"     = "TypeScript, Python"
        "[PRIMARY_LANGUAGE]"  = "TypeScript"
        "[PRIMARY_STRUCTURE]" = "src/"
    }

    # Files to process for placeholder replacement
    $filesToProcess = @(
        "CLAUDE.md",
        ".claude\config.yaml",
        ".claude\SESSION_KNOWLEDGE.md",
        ".claude\DEVELOPMENT_LOG.md"
    )

    $replacedCount = 0

    foreach ($relativePath in $filesToProcess) {
        $filePath = Join-Path $ProjectPath $relativePath

        if (Test-Path $filePath) {
            $content = Get-Content $filePath -Raw -ErrorAction SilentlyContinue

            if ($content) {
                $originalContent = $content

                foreach ($key in $placeholders.Keys) {
                    $content = $content.Replace($key, $placeholders[$key])
                }

                if ($content -ne $originalContent) {
                    Set-Content -Path $filePath -Value $content -NoNewline
                    $replacedCount++
                }
            }
        }
    }

    return $replacedCount
}

# ============================================================================
# Main Script
# ============================================================================

Write-Banner

# Check prerequisites
if (-not (Test-Prerequisites)) {
    Write-Host ""
    Write-Status "Please fix the prerequisites above and run again." "ERROR"
    exit 1
}

Write-Step 2 "Gathering Project Information"

# Gather project information
if (-not $NonInteractive) {
    $ParentPath = Get-UserInput -Prompt "Parent directory for the project" -Default "E:\Repos" -Required

    while (-not (Test-Path $ParentPath -PathType Container)) {
        $create = Get-UserInput -Prompt "Directory doesn't exist. Create it? (y/n)" -Default "y" -ValidOptions @("y", "n")
        if ($create -eq "y") {
            New-Item -ItemType Directory -Path $ParentPath -Force | Out-Null
            Write-Status "Created: $ParentPath" "SUCCESS"
            break
        }
        else {
            $ParentPath = Get-UserInput -Prompt "Parent directory for the project" -Required
        }
    }

    $ProjectName = Get-UserInput -Prompt "Project name (lowercase-with-hyphens)" -Required
    $ProjectName = $ProjectName.ToLower() -replace '[^a-z0-9-]', '-'

    $Description = Get-UserInput -Prompt "Brief description" -Default "A new project created from claude-code-base"

    Write-Host ""
    Write-Host "  Project types:" -ForegroundColor Gray
    Write-Host "    1. web-frontend    - React, Vue, Angular, etc." -ForegroundColor Gray
    Write-Host "    2. backend-api     - Node.js, Python, .NET, etc." -ForegroundColor Gray
    Write-Host "    3. fullstack       - Combined frontend + backend" -ForegroundColor Gray
    Write-Host "    4. cli-library     - CLI tools or packages" -ForegroundColor Gray
    Write-Host "    5. infrastructure  - Terraform, Docker, K8s" -ForegroundColor Gray
    Write-Host ""
    $ProjectType = Get-UserInput -Prompt "Project type" -Default "backend-api" -ValidOptions @("web-frontend", "backend-api", "fullstack", "cli-library", "infrastructure")

    if (-not $SkipGitHub) {
        Write-Host ""
        Write-Host "  Available organizations:" -ForegroundColor Gray
        try {
            gh org list 2>$null | ForEach-Object { Write-Host "    - $_" -ForegroundColor Gray }
        }
        catch {
            # Ignore errors if gh not available
        }
        $username = gh api user --jq '.login' 2>$null
        if ($username) {
            Write-Host "    - $username (personal)" -ForegroundColor Gray
        }
        Write-Host ""
        $GitHubOrg = Get-UserInput -Prompt "GitHub organization" -Default $username -Required

        $Visibility = Get-UserInput -Prompt "Repository visibility" -Default "private" -ValidOptions @("private", "public")
    }

    if (-not $SkipArchon) {
        Write-Host ""
        $skipArchonChoice = Get-UserInput -Prompt "Create Archon project for task management? (y/n)" -Default "y" -ValidOptions @("y", "n")
        if ($skipArchonChoice -eq "n") {
            $SkipArchon = $true
        }
    }
}

$ProjectPath = Join-Path $ParentPath $ProjectName
$ProjectTitle = ($ProjectName -replace '-', ' ').ToUpper().Substring(0, 1) + ($ProjectName -replace '-', ' ').Substring(1)
$GitHubRepo = if (-not $SkipGitHub -and $GitHubOrg) { "https://github.com/$GitHubOrg/$ProjectName" } else { "" }
$CurrentDate = Get-Date -Format "yyyy-MM-dd"

# Generate a placeholder Archon project ID (will be replaced if Archon is available)
$ArchonProjectId = if ($SkipArchon) { "NOT_CONFIGURED" } else { [guid]::NewGuid().ToString() }

Write-Step 3 "Configuration Summary"

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                     Project Configuration                            " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Name:           $ProjectName" -ForegroundColor White
Write-Host "  Title:          $ProjectTitle" -ForegroundColor White
Write-Host "  Path:           $ProjectPath" -ForegroundColor White
Write-Host "  Description:    $Description" -ForegroundColor White
Write-Host "  Type:           $ProjectType" -ForegroundColor White
if (-not $SkipGitHub -and $GitHubRepo) {
    Write-Host "  Repository:     $GitHubRepo" -ForegroundColor White
    Write-Host "  Visibility:     $Visibility" -ForegroundColor White
}
else {
    Write-Host "  Repository:     (GitHub creation skipped)" -ForegroundColor Gray
}
if (-not $SkipArchon) {
    Write-Host "  Archon:         Project will be created" -ForegroundColor White
}
else {
    Write-Host "  Archon:         (Archon creation skipped)" -ForegroundColor Gray
}
Write-Host ""

if (-not $NonInteractive) {
    $confirm = Get-UserInput -Prompt "Proceed with this configuration? (y/n)" -Default "y" -ValidOptions @("y", "n")
    if ($confirm -ne "y") {
        Write-Status "Cancelled by user." "WARNING"
        exit 0
    }
}

Write-Step 4 "Copying Template Files"

# Check if project directory already exists
if (Test-Path $ProjectPath) {
    Write-Status "Directory already exists: $ProjectPath" "WARNING"
    if (-not $NonInteractive) {
        $overwrite = Get-UserInput -Prompt "Overwrite existing directory? (y/n)" -Default "n" -ValidOptions @("y", "n")
        if ($overwrite -ne "y") {
            Write-Status "Cancelled. Choose a different project name." "ERROR"
            exit 1
        }
    }
}

Write-Status "Copying template files..." "WORKING"
$stats = Copy-TemplateFiles -SourcePath $TemplatePath -DestinationPath $ProjectPath
Write-Status "Files copied: $($stats.Copied), Directories: $($stats.Directories), Skipped: $($stats.Skipped)" "SUCCESS"

Write-Step 5 "Initializing Git Repository"

# Store original location
$originalLocation = Get-Location

# Initialize git
Set-Location $ProjectPath
Write-Status "Initializing git repository..." "WORKING"
try {
    git init --quiet 2>$null
    Write-Status "Git repository initialized" "SUCCESS"
}
catch {
    Write-Status "Git initialization failed" "WARNING"
}

Write-Step 6 "Installing Pre-commit Hooks"

Write-Status "Installing pre-commit hooks..." "WORKING"
try {
    pip install pre-commit --quiet 2>$null
    pre-commit install --quiet 2>$null
    pre-commit install --hook-type commit-msg --quiet 2>$null
    Write-Status "Pre-commit hooks installed" "SUCCESS"
}
catch {
    Write-Status "Pre-commit installation failed (optional)" "WARNING"
}

Write-Step 7 "Replacing Placeholders"

Write-Status "Replacing placeholders in configuration files..." "WORKING"
$replacedCount = Replace-Placeholders -ProjectPath $ProjectPath `
    -ProjectName $ProjectName `
    -ProjectTitle $ProjectTitle `
    -GitHubRepo $GitHubRepo `
    -ArchonProjectId $ArchonProjectId `
    -CurrentDate $CurrentDate

Write-Status "Updated $replacedCount configuration files" "SUCCESS"

# Create initial commit
Write-Status "Creating initial commit..." "WORKING"
try {
    git add . 2>$null
    git commit -m "feat: initial project setup from claude-code-base template" --quiet 2>$null
    Write-Status "Initial commit created" "SUCCESS"
}
catch {
    Write-Status "Initial commit failed" "WARNING"
}

if (-not $SkipGitHub -and $GitHubOrg) {
    Write-Step 8 "Creating GitHub Repository"

    Write-Status "Creating GitHub repository..." "WORKING"
    $visibilityFlag = if ($Visibility -eq "public") { "--public" } else { "--private" }

    try {
        gh repo create "$GitHubOrg/$ProjectName" $visibilityFlag --source=. --push --description "$Description" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Status "GitHub repository created" "SUCCESS"
        }
        else {
            Write-Status "Repository creation failed (may already exist)" "WARNING"
        }
    }
    catch {
        Write-Status "Failed to create GitHub repository" "WARNING"
    }

    Write-Step 9 "Configuring Branch Protection"

    Write-Status "Enabling branch protection..." "WORKING"
    try {
        gh api "repos/$GitHubOrg/$ProjectName/branches/main/protection" -X PUT `
            -H "Accept: application/vnd.github+json" `
            -f required_status_checks='{"strict":true,"contexts":[]}' `
            -f enforce_admins=false `
            -f required_pull_request_reviews='{"required_approving_review_count":1}' `
            -f restrictions=null 2>$null
        Write-Status "Branch protection enabled" "SUCCESS"
    }
    catch {
        Write-Status "Branch protection configuration failed (may require admin access)" "WARNING"
    }

    Write-Step 10 "Enabling Secret Scanning"

    Write-Status "Enabling secret scanning..." "WORKING"
    try {
        gh api "repos/$GitHubOrg/$ProjectName" -X PATCH `
            -f security_and_analysis='{"secret_scanning":{"status":"enabled"},"secret_scanning_push_protection":{"status":"enabled"}}' 2>$null
        Write-Status "Secret scanning enabled" "SUCCESS"
    }
    catch {
        Write-Status "Secret scanning configuration failed (may not be available)" "WARNING"
    }
}
else {
    Write-Step 8 "Skipping GitHub Setup"
    Write-Status "GitHub repository creation was skipped" "INFO"
}

if (-not $SkipArchon) {
    $stepNum = if ($SkipGitHub) { 9 } else { 11 }
    Write-Step $stepNum "Archon Project Setup"

    Write-Status "Archon project setup..." "WORKING"
    Write-Host ""
    Write-Host "  NOTE: Archon project creation requires the Archon MCP server." -ForegroundColor Yellow
    Write-Host "  If running this script outside of Claude Code, you'll need to" -ForegroundColor Yellow
    Write-Host "  manually create the Archon project using:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  manage_project('create'," -ForegroundColor Cyan
    Write-Host "      title='$ProjectTitle'," -ForegroundColor Cyan
    Write-Host "      description='$Description'," -ForegroundColor Cyan
    Write-Host "      github_repo='$GitHubRepo')" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Then update .claude/config.yaml with the returned project ID." -ForegroundColor Yellow
    Write-Host ""

    Write-Status "Archon project ID placeholder: $ArchonProjectId" "INFO"
    Write-Status "Update .claude/config.yaml after creating the Archon project" "WARNING"
}
else {
    $stepNum = if ($SkipGitHub) { 9 } else { 11 }
    Write-Step $stepNum "Skipping Archon Setup"
    Write-Status "Archon project creation was skipped" "INFO"
}

# Return to original location
Set-Location $originalLocation

# ============================================================================
# Summary
# ============================================================================

$finalStep = if ($SkipGitHub -and $SkipArchon) { 10 } elseif ($SkipGitHub -or $SkipArchon) { 11 } else { 12 }
Write-Step $finalStep "Project Created Successfully"

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "              Project Created Successfully!                           " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Location:      $ProjectPath" -ForegroundColor Cyan
if ($GitHubRepo) {
    Write-Host "Repository:    $GitHubRepo" -ForegroundColor Cyan
}
Write-Host ""

Write-Host "What's configured:" -ForegroundColor Green
Write-Host "   [OK] Pre-configured .gitignore" -ForegroundColor White
Write-Host "   [OK] Pre-commit hooks with secret detection" -ForegroundColor White
Write-Host "   [OK] CLAUDE.md with Archon integration" -ForegroundColor White
Write-Host "   [OK] .claude/config.yaml project configuration" -ForegroundColor White
Write-Host "   [OK] Session knowledge and development log templates" -ForegroundColor White
Write-Host "   [OK] VS Code settings with MCP configuration" -ForegroundColor White
if (-not $SkipGitHub -and $GitHubRepo) {
    Write-Host "   [OK] GitHub repository with branch protection" -ForegroundColor White
    Write-Host "   [OK] Secret scanning enabled" -ForegroundColor White
}
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "   1. Open in VS Code:  code $ProjectPath" -ForegroundColor White
Write-Host "   2. Open with Claude Code and run: /start" -ForegroundColor White
Write-Host "   3. Review CLAUDE.md and customize for your project" -ForegroundColor White
if (-not $SkipArchon) {
    Write-Host "   4. Create Archon project and update .claude/config.yaml" -ForegroundColor White
    Write-Host "   5. Start building!" -ForegroundColor White
}
else {
    Write-Host "   4. Start building!" -ForegroundColor White
}
Write-Host ""

Write-Host "Quick commands (in Claude Code):" -ForegroundColor Gray
Write-Host "   /start     - Initialize session and load context" -ForegroundColor Gray
Write-Host "   /status    - Check project status" -ForegroundColor Gray
Write-Host "   /next      - Get next available task" -ForegroundColor Gray
Write-Host "   /end       - End session and save context" -ForegroundColor Gray
Write-Host ""
