<#
.SYNOPSIS
    Syncs Claude Code configuration files from claude-code-base to an existing codebase.

.DESCRIPTION
    This script synchronizes all Claude Code-related files (CLAUDE.md, .claude directory,
    PRPs, scripts, etc.) from the claude-code-base template repository to an existing
    codebase. It creates backups of existing files before overwriting.

.PARAMETER TargetPath
    Path to the target codebase to sync Claude Code files to.

.PARAMETER DryRun
    Preview what would be synced without making any changes.

.PARAMETER NoBackup
    Skip creating backups of existing files (not recommended).

.PARAMETER Force
    Suppress confirmation prompts.

.EXAMPLE
    .\sync-claude-code.ps1 -TargetPath "E:\Repos\MyOrg\my-project"

.EXAMPLE
    .\sync-claude-code.ps1 -TargetPath "E:\Repos\MyOrg\my-project" -DryRun

.EXAMPLE
    .\sync-claude-code.ps1 -TargetPath "E:\Repos\MyOrg\my-project" -Force -NoBackup

.NOTES
    Author: Claude Code Base
    Version: 2.0.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TargetPath,

    [switch]$DryRun,
    [switch]$NoBackup,
    [switch]$Force
)

# ============================================================================
# Configuration
# ============================================================================

$ErrorActionPreference = "Stop"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplatePath = Split-Path -Parent $ScriptPath

# Default sync items (used for legacy projects without template_profile)
$DefaultSyncItems = @(
    @{ Source = ".claude"; Type = "Directory" },
    @{ Source = ".vscode"; Type = "Directory" },
    @{ Source = "CLAUDE.md"; Type = "File" },
    @{ Source = "PRPs"; Type = "Directory" },
    @{ Source = ".gitattributes"; Type = "File" },
    @{ Source = ".pre-commit-config.yaml"; Type = "File" },
    @{ Source = "scripts\sync-claude-code.ps1"; Type = "File" },
    @{ Source = "scripts\validate-claude-code.ps1"; Type = "File" },
    @{ Source = "scripts\update-project.ps1"; Type = "File" }
)

# Files to exclude from sync (target-specific files that should not be overwritten)
$ExcludePatterns = @(
    "*.local.*",
    "*.backup.*"
)

# ============================================================================
# Functions
# ============================================================================

function Write-Banner {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "              Claude Code Sync Utility                                " -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([int]$Number, [string]$Title)
    Write-Host ""
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " Step ${Number}: ${Title}" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

function Write-Status {
    param([string]$Message, [string]$Status = "INFO")

    $icon = switch ($Status) {
        "SUCCESS" { "[OK]" }
        "ERROR" { "[ERR]" }
        "WARNING" { "[WARN]" }
        "WORKING" { "[...]" }
        "DRYRUN" { "[DRY]" }
        "BACKUP" { "[BAK]" }
        "SKIP" { "[SKIP]" }
        "NEW" { "[NEW]" }
        default { "[i]" }
    }

    $color = switch ($Status) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "WORKING" { "Cyan" }
        "DRYRUN" { "Magenta" }
        "BACKUP" { "Blue" }
        "SKIP" { "DarkGray" }
        "NEW" { "Green" }
        default { "White" }
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

function Get-TemplateProfile {
    <#
    .SYNOPSIS
        Reads template_profile from target project's .claude/config.yaml.
    .DESCRIPTION
        Returns a hashtable with profile fields, or $null if no profile exists (legacy project).
    #>
    param([string]$TargetPath)

    $configPath = Join-Path $TargetPath ".claude\config.yaml"
    if (-not (Test-Path $configPath)) { return $null }

    $content = Get-Content $configPath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return $null }

    # Check if template_profile section exists
    if ($content -notmatch 'template_profile:') { return $null }

    $profile = @{}

    # Extract template_version
    if ($content -match 'template_version:\s*[''"]?([^''"}\s,\]]+)') {
        $profile.template_version = $Matches[1]
    }

    # Extract project_type
    if ($content -match 'project_type:\s*[''"]?([^''"}\s,\]]+)') {
        $profile.project_type = $Matches[1]
    }

    # Extract primary_language
    if ($content -match 'primary_language:\s*[''"]?([^''"}\s,\]]+)') {
        $profile.primary_language = $Matches[1]
    }

    # Extract framework
    if ($content -match 'framework:\s*[''"]?([^''"}\s,\]]+)') {
        $profile.framework = $Matches[1]
    }

    # Extract skill_groups as array
    if ($content -match 'skill_groups:\s*\[([^\]]+)\]') {
        $profile.skill_groups = ($Matches[1] -replace '[''"]', '').Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }

    # Extract command_groups as array
    if ($content -match 'command_groups:\s*\[([^\]]+)\]') {
        $profile.command_groups = ($Matches[1] -replace '[''"]', '').Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }

    # Extract dev_frameworks as array
    if ($content -match 'dev_frameworks:\s*\[([^\]]*)\]') {
        $rawValue = $Matches[1] -replace '[''"]', ''
        if ($rawValue.Trim()) {
            $profile.dev_frameworks = $rawValue.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        } else {
            $profile.dev_frameworks = @()
        }
    }

    return $profile
}

function Get-ManifestConfig {
    <#
    .SYNOPSIS
        Reads and parses templates/manifest.json from the template repository.
    #>
    $manifestPath = Join-Path $TemplatePath "templates\manifest.json"
    if (-not (Test-Path $manifestPath)) {
        Write-Status "Manifest not found: $manifestPath" "WARNING"
        return $null
    }

    $content = Get-Content $manifestPath -Raw -ErrorAction Stop
    return ($content | ConvertFrom-Json)
}

function Get-ProfileSelectedSkills {
    <#
    .SYNOPSIS
        Returns skill directory names that match the template_profile's skill_groups.
    #>
    param(
        $Manifest,
        [string[]]$SkillGroups
    )

    $selectedSkills = @()

    foreach ($group in $SkillGroups) {
        $groupSkills = $Manifest.skills.$group
        if ($groupSkills) {
            $selectedSkills += @($groupSkills)
        }
    }

    return $selectedSkills | Sort-Object -Unique
}

function Get-ProfileSelectedCommands {
    <#
    .SYNOPSIS
        Returns command filenames that match the template_profile's command_groups.
    #>
    param(
        $Manifest,
        [string[]]$CommandGroups
    )

    $selectedCommands = @()

    foreach ($group in $CommandGroups) {
        $groupCommands = $Manifest.commands.$group
        if ($groupCommands) {
            $selectedCommands += @($groupCommands)
        }
    }

    return $selectedCommands | Sort-Object -Unique
}

function Build-SelectiveSyncItems {
    <#
    .SYNOPSIS
        Builds sync item list based on template_profile, syncing only relevant skills/commands.
    #>
    param(
        $Profile,
        $Manifest
    )

    # Core config files that always sync
    $items = @(
        @{ Source = ".claude\config.yaml"; Type = "File" },
        @{ Source = ".claude\settings.json"; Type = "File" },
        @{ Source = ".claude\SESSION_KNOWLEDGE.md"; Type = "File" },
        @{ Source = ".claude\DEVELOPMENT_LOG.md"; Type = "File" },
        @{ Source = ".claude\FAILED_ATTEMPTS.md"; Type = "File" },
        @{ Source = ".claude\context"; Type = "Directory" },
        @{ Source = ".claude\hooks"; Type = "Directory" },
        @{ Source = ".vscode"; Type = "Directory" },
        @{ Source = ".gitattributes"; Type = "File" },
        @{ Source = ".pre-commit-config.yaml"; Type = "File" },
        @{ Source = "scripts\sync-claude-code.ps1"; Type = "File" },
        @{ Source = "scripts\validate-claude-code.ps1"; Type = "File" },
        @{ Source = "scripts\update-project.ps1"; Type = "File" }
    )

    # Add selected skills individually
    $selectedSkills = Get-ProfileSelectedSkills -Manifest $Manifest -SkillGroups $Profile.skill_groups
    foreach ($skill in $selectedSkills) {
        $skillPath = ".claude\skills\$skill"
        $items += @{ Source = $skillPath; Type = "Directory" }
    }

    # Add selected commands individually
    $selectedCommands = Get-ProfileSelectedCommands -Manifest $Manifest -CommandGroups $Profile.command_groups
    foreach ($cmd in $selectedCommands) {
        $cmdPath = ".claude\commands\$cmd.md"
        $items += @{ Source = $cmdPath; Type = "File" }
    }

    # Add PRPs only if PRP dev framework was selected
    if ($Profile.dev_frameworks -contains "prp") {
        $items += @{ Source = "PRPs"; Type = "Directory" }
    }

    return $items
}

function Test-Prerequisites {
    Write-Step 0 "Checking Prerequisites"

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

    return $allGood
}

function Test-GitRepository {
    param([string]$Path)

    $gitDir = Join-Path $Path ".git"
    return (Test-Path $gitDir -PathType Container)
}

function New-Backup {
    param(
        [string]$FilePath,
        [string]$BackupDir,
        [string]$BaseTargetPath
    )

    if (-not (Test-Path $FilePath)) {
        return $null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $relativePath = $FilePath.Substring($BaseTargetPath.Length).TrimStart('\')
    $backupPath = Join-Path $BackupDir "$relativePath.$timestamp.backup"

    # Ensure backup directory exists
    $backupParent = Split-Path $backupPath -Parent
    if (-not (Test-Path $backupParent)) {
        New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
    }

    Copy-Item -Path $FilePath -Destination $backupPath -Force
    return $backupPath
}

function Sync-Item {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [string]$Type,
        [string]$BackupDir,
        [string]$BaseTargetPath,
        [switch]$DryRun,
        [switch]$NoBackup
    )

    $stats = @{
        Copied  = 0
        Backed  = 0
        New     = 0
        Skipped = 0
    }

    if ($Type -eq "File") {
        # Single file sync
        if (-not (Test-Path $SourcePath)) {
            Write-Status "Source not found: $SourcePath" "SKIP"
            $stats.Skipped++
            return $stats
        }

        $exists = Test-Path $DestPath

        if ($DryRun) {
            if ($exists) {
                Write-Status "Would overwrite: $DestPath" "DRYRUN"
            }
            else {
                Write-Status "Would create: $DestPath" "DRYRUN"
            }
            $stats.Copied++
            return $stats
        }

        # Create backup if exists
        if ($exists -and -not $NoBackup) {
            $backup = New-Backup -FilePath $DestPath -BackupDir $BackupDir -BaseTargetPath $BaseTargetPath
            if ($backup) {
                Write-Status "Backed up: $DestPath" "BACKUP"
                $stats.Backed++
            }
        }

        # Ensure target directory exists
        $targetDir = Split-Path $DestPath -Parent
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        # Copy file
        Copy-Item -Path $SourcePath -Destination $DestPath -Force

        if ($exists) {
            Write-Status "Updated: $DestPath" "SUCCESS"
        }
        else {
            Write-Status "Created: $DestPath" "NEW"
            $stats.New++
        }
        $stats.Copied++
    }
    else {
        # Directory sync
        if (-not (Test-Path $SourcePath -PathType Container)) {
            Write-Status "Source directory not found: $SourcePath" "SKIP"
            $stats.Skipped++
            return $stats
        }

        # Get all files in source directory
        $sourceFiles = Get-ChildItem -Path $SourcePath -Recurse -File

        foreach ($file in $sourceFiles) {
            $relativePath = $file.FullName.Substring($SourcePath.Length).TrimStart('\')
            $targetFile = Join-Path $DestPath $relativePath
            $exists = Test-Path $targetFile

            if ($DryRun) {
                if ($exists) {
                    Write-Status "Would overwrite: $targetFile" "DRYRUN"
                }
                else {
                    Write-Status "Would create: $targetFile" "DRYRUN"
                }
                $stats.Copied++
                continue
            }

            # Create backup if exists
            if ($exists -and -not $NoBackup) {
                $backup = New-Backup -FilePath $targetFile -BackupDir $BackupDir -BaseTargetPath $BaseTargetPath
                if ($backup) {
                    $stats.Backed++
                }
            }

            # Ensure target directory exists
            $targetDir = Split-Path $targetFile -Parent
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }

            # Copy file
            Copy-Item -Path $file.FullName -Destination $targetFile -Force

            if (-not $exists) {
                $stats.New++
            }
            $stats.Copied++
        }

        $itemName = Split-Path $SourcePath -Leaf
        if ($DryRun) {
            Write-Status "Would sync directory: $itemName ($($stats.Copied) files)" "DRYRUN"
        }
        else {
            Write-Status "Synced directory: $itemName ($($stats.Copied) files, $($stats.New) new)" "SUCCESS"
        }
    }

    return $stats
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

# Get target path
if (-not $TargetPath) {
    Write-Step 1 "Target Codebase"
    $TargetPath = Get-UserInput -Prompt "Path to the target codebase" -Required
}

# Validate target path
if (-not (Test-Path $TargetPath -PathType Container)) {
    Write-Status "Target path does not exist: $TargetPath" "ERROR"
    exit 1
}

# Check if target is a git repository
if (-not (Test-GitRepository -Path $TargetPath)) {
    Write-Status "Target is not a Git repository: $TargetPath" "ERROR"
    Write-Host ""
    Write-Host "  The target path must be an existing Git repository." -ForegroundColor Gray
    Write-Host "  Initialize with: git init" -ForegroundColor Gray
    exit 1
}

Write-Status "Target: $TargetPath" "SUCCESS"
Write-Status "Source: $TemplatePath" "INFO"

if ($DryRun) {
    Write-Host ""
    Write-Host "  [!] DRY RUN MODE - No changes will be made" -ForegroundColor Magenta
}

# Check for template_profile to determine sync mode
Write-Step 1.5 "Detecting Sync Mode"

$templateProfile = Get-TemplateProfile -TargetPath $TargetPath
$manifest = Get-ManifestConfig

$SyncItems = $DefaultSyncItems
$syncMode = "legacy"

if ($templateProfile -and $manifest) {
    $syncMode = "selective"
    $SyncItems = Build-SelectiveSyncItems -Profile $templateProfile -Manifest $manifest

    Write-Status "Template profile found - using selective sync" "SUCCESS"
    Write-Host ""
    Write-Host "  Profile Details:" -ForegroundColor White
    Write-Host "    Project Type: $($templateProfile.project_type)" -ForegroundColor Cyan
    Write-Host "    Language:     $($templateProfile.primary_language)" -ForegroundColor Cyan
    Write-Host "    Framework:    $($templateProfile.framework)" -ForegroundColor Cyan
    Write-Host "    Skill Groups: $($templateProfile.skill_groups -join ', ')" -ForegroundColor Cyan
    Write-Host "    Cmd Groups:   $($templateProfile.command_groups -join ', ')" -ForegroundColor Cyan
    if ($templateProfile.dev_frameworks.Count -gt 0) {
        Write-Host "    Dev Fwks:     $($templateProfile.dev_frameworks -join ', ')" -ForegroundColor Cyan
    }
    Write-Host ""

    $selectedSkills = Get-ProfileSelectedSkills -Manifest $manifest -SkillGroups $templateProfile.skill_groups
    $selectedCommands = Get-ProfileSelectedCommands -Manifest $manifest -CommandGroups $templateProfile.command_groups
    Write-Host "    Skills to sync:   $($selectedSkills.Count)" -ForegroundColor White
    Write-Host "    Commands to sync: $($selectedCommands.Count)" -ForegroundColor White
} else {
    Write-Status "No template profile found - using legacy full sync" "WARNING"
    Write-Host "  All skills and commands will be synced." -ForegroundColor Gray
    Write-Host "  Tip: Run setup-claude-code-project.ps1 to generate a template_profile." -ForegroundColor Gray
}

# Confirm sync
if (-not $Force -and -not $DryRun) {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Yellow
    Write-Host "                      Sync Configuration                              " -ForegroundColor Yellow
    Write-Host "======================================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Sync Mode: $syncMode" -ForegroundColor White
    Write-Host "  This will sync the following Claude Code files to your codebase:" -ForegroundColor White
    Write-Host ""
    foreach ($item in $SyncItems) {
        Write-Host "    - $($item.Source)" -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "  Existing files will be backed up before overwriting." -ForegroundColor Gray
    Write-Host ""

    $confirm = Get-UserInput -Prompt "Proceed with sync? (y/n)" -Default "y" -ValidOptions @("y", "n")
    if ($confirm -ne "y") {
        Write-Status "Cancelled by user." "WARNING"
        exit 0
    }
}

Write-Step 2 "Syncing Claude Code Files"

# Create backup directory
$backupDir = Join-Path $TargetPath ".claude-backup"
if (-not $NoBackup -and -not $DryRun) {
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    Write-Status "Backup directory: $backupDir" "INFO"
}

# Track statistics
$totalStats = @{
    Copied  = 0
    Backed  = 0
    New     = 0
    Skipped = 0
}

# Sync each item
foreach ($item in $SyncItems) {
    $sourcePath = Join-Path $TemplatePath $item.Source
    $destPath = Join-Path $TargetPath $item.Source

    Write-Host ""
    Write-Host "  [>] $($item.Source)" -ForegroundColor White

    $stats = Sync-Item `
        -SourcePath $sourcePath `
        -DestPath $destPath `
        -Type $item.Type `
        -BackupDir $backupDir `
        -BaseTargetPath $TargetPath `
        -DryRun:$DryRun `
        -NoBackup:$NoBackup

    $totalStats.Copied += $stats.Copied
    $totalStats.Backed += $stats.Backed
    $totalStats.New += $stats.New
    $totalStats.Skipped += $stats.Skipped
}

# ============================================================================
# Summary
# ============================================================================

Write-Host ""
if ($DryRun) {
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host "              Dry Run Complete - No Changes Made                      " -ForegroundColor Magenta
    Write-Host "======================================================================" -ForegroundColor Magenta
}
else {
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host "              Claude Code Sync Complete!                              " -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Green
}
Write-Host ""

Write-Host "Statistics:" -ForegroundColor Cyan
Write-Host "   Files synced:      $($totalStats.Copied)" -ForegroundColor White
Write-Host "   New files:         $($totalStats.New)" -ForegroundColor Green
Write-Host "   Files backed up:   $($totalStats.Backed)" -ForegroundColor Blue
Write-Host "   Items skipped:     $($totalStats.Skipped)" -ForegroundColor Gray
Write-Host ""

if (-not $DryRun) {
    Write-Host "Target:  $TargetPath" -ForegroundColor Cyan
    Write-Host "Mode:    $syncMode" -ForegroundColor Cyan
    if (-not $NoBackup -and $totalStats.Backed -gt 0) {
        Write-Host "Backups: $backupDir" -ForegroundColor Blue
    }
    Write-Host ""

    if ($syncMode -eq "selective") {
        Write-Host "What was synced (selective):" -ForegroundColor Green
        Write-Host "   - Core Claude configuration (.claude/ config files)" -ForegroundColor White
        Write-Host "   - VS Code settings (.vscode/)" -ForegroundColor White
        Write-Host "   - Selected skills ($($selectedSkills.Count) matching profile)" -ForegroundColor White
        Write-Host "   - Selected commands ($($selectedCommands.Count) matching profile)" -ForegroundColor White
        Write-Host "   - Git attributes (.gitattributes)" -ForegroundColor White
        Write-Host "   - Pre-commit hooks (.pre-commit-config.yaml)" -ForegroundColor White
        Write-Host "   - Maintenance scripts (scripts/)" -ForegroundColor White
        if ($templateProfile.dev_frameworks -contains "prp") {
            Write-Host "   - PRP framework (PRPs/)" -ForegroundColor White
        }
    } else {
        Write-Host "What was synced (full):" -ForegroundColor Green
        Write-Host "   - Claude configuration (.claude/)" -ForegroundColor White
        Write-Host "   - VS Code settings (.vscode/)" -ForegroundColor White
        Write-Host "   - Claude instructions (CLAUDE.md)" -ForegroundColor White
        Write-Host "   - PRP framework (PRPs/)" -ForegroundColor White
        Write-Host "   - Git attributes (.gitattributes)" -ForegroundColor White
        Write-Host "   - Pre-commit hooks (.pre-commit-config.yaml)" -ForegroundColor White
        Write-Host "   - Sync and validation scripts (scripts/)" -ForegroundColor White
    }
    Write-Host ""

    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "   1. Review synced files for any project-specific customizations needed" -ForegroundColor White
    if ($syncMode -eq "legacy") {
        Write-Host "   2. Update CLAUDE.md with project-specific context and instructions" -ForegroundColor White
        Write-Host "   3. Configure .claude/config.yaml with your Archon project ID" -ForegroundColor White
    }
    Write-Host "   $(if ($syncMode -eq 'legacy') { '4' } else { '2' }). Commit the changes:" -ForegroundColor White
    Write-Host "      git add .claude .vscode && git commit -m 'chore: sync Claude Code configuration'" -ForegroundColor DarkGray
    Write-Host ""
}
else {
    Write-Host "To apply these changes, run without -DryRun:" -ForegroundColor Yellow
    Write-Host "   .\sync-claude-code.ps1 -TargetPath `"$TargetPath`"" -ForegroundColor White
    Write-Host ""
}
