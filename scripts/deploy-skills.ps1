<#
.SYNOPSIS
    Deploy skills from project to global ~/.claude/skills/ directory.

.DESCRIPTION
    This script copies skills from the project's .claude/skills/ directory
    to the global ~/.claude/skills/ directory where Claude Code discovers them.
    It supports dry-run mode, selective deployment by category, and automatic backups.

.PARAMETER SourcePath
    Source directory containing skills. Default: .\.claude\skills

.PARAMETER DestinationPath
    Destination directory for global skills. Default: ~/.claude/skills

.PARAMETER DryRun
    Preview changes without making them.

.PARAMETER Category
    Deploy only skills from a specific category (e.g., "smart-home", "devops").

.PARAMETER Backup
    Create backup of existing skills before deployment. Default: $true

.PARAMETER Force
    Overwrite existing skills without prompting.

.PARAMETER Verbose
    Show detailed output.

.EXAMPLE
    .\deploy-skills.ps1
    Deploy all skills to global directory.

.EXAMPLE
    .\deploy-skills.ps1 -DryRun
    Preview what would be deployed without making changes.

.EXAMPLE
    .\deploy-skills.ps1 -Category "smart-home"
    Deploy only smart-home skills.

.EXAMPLE
    .\deploy-skills.ps1 -Force -NoBackup
    Deploy all skills, overwriting existing ones without backup.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [string]$SourcePath = ".\.claude\skills",

    [Parameter()]
    [string]$DestinationPath = (Join-Path $env:USERPROFILE ".claude\skills"),

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [string]$Category,

    [Parameter()]
    [switch]$NoBackup,

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# =============================================================================
# CONFIGURATION
# =============================================================================

$BackupDir = Join-Path $env:USERPROFILE ".claude\skills-backup"
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )

    $Color = switch ($Type) {
        'Info'    { 'Cyan' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
    }

    $Prefix = switch ($Type) {
        'Info'    { '[INFO]' }
        'Success' { '[OK]' }
        'Warning' { '[WARN]' }
        'Error'   { '[ERROR]' }
    }

    Write-Host "$Prefix $Message" -ForegroundColor $Color
}

function Get-SkillInfo {
    param([string]$SkillPath)

    $SkillFile = Join-Path $SkillPath 'SKILL.md'
    if (-not (Test-Path $SkillFile)) {
        return $null
    }

    $Content = Get-Content $SkillFile -Raw
    $Info = @{
        Path = $SkillPath
        Name = Split-Path $SkillPath -Leaf
        Category = Split-Path (Split-Path $SkillPath -Parent) -Leaf
        HasSkillFile = $true
    }

    # Extract name from frontmatter
    if ($Content -match '(?ms)^---\s*\n.*?name:\s*([^\n]+).*?---') {
        $Info.Name = $Matches[1].Trim()
    }

    # Extract description from frontmatter
    if ($Content -match '(?ms)^---\s*\n.*?description:\s*([^\n]+).*?---') {
        $Info.Description = $Matches[1].Trim()
    }

    return $Info
}

function Backup-ExistingSkills {
    if (-not (Test-Path $DestinationPath)) {
        Write-Status "No existing skills to backup" -Type Info
        return
    }

    $BackupPath = Join-Path $BackupDir "skills-$Timestamp"

    if ($DryRun) {
        Write-Status "[DRY RUN] Would backup existing skills to: $BackupPath" -Type Info
        return
    }

    Write-Status "Backing up existing skills to: $BackupPath" -Type Info

    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }

    Copy-Item -Path $DestinationPath -Destination $BackupPath -Recurse -Force
    Write-Status "Backup created successfully" -Type Success
}

function Deploy-Skill {
    param(
        [hashtable]$SkillInfo
    )

    $SourceSkillPath = $SkillInfo.Path
    $DestSkillPath = Join-Path $DestinationPath $SkillInfo.Name

    # Check if skill already exists
    $Exists = Test-Path $DestSkillPath

    if ($Exists -and -not $Force) {
        $Choice = Read-Host "Skill '$($SkillInfo.Name)' already exists. Overwrite? [y/N]"
        if ($Choice -notmatch '^[yY]') {
            Write-Status "Skipped: $($SkillInfo.Name)" -Type Warning
            return @{ Deployed = $false; Skipped = $true }
        }
    }

    if ($DryRun) {
        $Action = if ($Exists) { "Would overwrite" } else { "Would deploy" }
        Write-Status "[DRY RUN] $Action skill: $($SkillInfo.Name)" -Type Info
        return @{ Deployed = $true; Skipped = $false }
    }

    # Deploy the skill
    if ($Exists) {
        Remove-Item -Path $DestSkillPath -Recurse -Force
    }

    Copy-Item -Path $SourceSkillPath -Destination $DestSkillPath -Recurse -Force

    $Action = if ($Exists) { "Updated" } else { "Deployed" }
    Write-Status "$Action skill: $($SkillInfo.Name)" -Type Success

    return @{ Deployed = $true; Skipped = $false }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

function Main {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " Claude Code Skills Deployment" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        Write-Status "Running in DRY RUN mode - no changes will be made" -Type Warning
        Write-Host ""
    }

    # Validate source directory
    if (-not (Test-Path $SourcePath)) {
        Write-Status "Source directory not found: $SourcePath" -Type Error
        exit 1
    }

    # Resolve paths
    $SourcePath = Resolve-Path $SourcePath

    Write-Status "Source: $SourcePath" -Type Info
    Write-Status "Destination: $DestinationPath" -Type Info
    Write-Host ""

    # Find all skills
    $SkillFiles = Get-ChildItem -Path $SourcePath -Filter 'SKILL.md' -Recurse -File

    if ($SkillFiles.Count -eq 0) {
        Write-Status "No skills found in source directory" -Type Warning
        exit 0
    }

    # Filter by category if specified
    if ($Category) {
        $SkillFiles = $SkillFiles | Where-Object {
            $_.DirectoryName -match "[\\/]$Category[\\/]"
        }

        if ($SkillFiles.Count -eq 0) {
            Write-Status "No skills found in category: $Category" -Type Warning
            exit 0
        }

        Write-Status "Filtering by category: $Category" -Type Info
    }

    Write-Status "Found $($SkillFiles.Count) skill(s) to deploy" -Type Info
    Write-Host ""

    # Backup existing skills
    if (-not $NoBackup) {
        Backup-ExistingSkills
        Write-Host ""
    }

    # Ensure destination directory exists
    if (-not $DryRun -and -not (Test-Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        Write-Status "Created destination directory: $DestinationPath" -Type Info
    }

    # Deploy each skill
    $DeployedCount = 0
    $SkippedCount = 0
    $ErrorCount = 0

    foreach ($SkillFile in $SkillFiles) {
        $SkillDir = $SkillFile.DirectoryName
        $SkillInfo = Get-SkillInfo -SkillPath $SkillDir

        if (-not $SkillInfo) {
            Write-Status "Invalid skill (no SKILL.md): $SkillDir" -Type Warning
            $ErrorCount++
            continue
        }

        try {
            $Result = Deploy-Skill -SkillInfo $SkillInfo

            if ($Result.Deployed) {
                $DeployedCount++
            }
            if ($Result.Skipped) {
                $SkippedCount++
            }
        }
        catch {
            Write-Status "Failed to deploy $($SkillInfo.Name): $_" -Type Error
            $ErrorCount++
        }
    }

    # Summary
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " Deployment Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        Write-Status "DRY RUN COMPLETE - No changes were made" -Type Warning
        Write-Status "Would deploy: $DeployedCount skill(s)" -Type Info
    }
    else {
        Write-Status "Deployed: $DeployedCount skill(s)" -Type Success
    }

    if ($SkippedCount -gt 0) {
        Write-Status "Skipped: $SkippedCount skill(s)" -Type Warning
    }

    if ($ErrorCount -gt 0) {
        Write-Status "Errors: $ErrorCount" -Type Error
    }

    Write-Host ""
    Write-Status "Skills are available at: $DestinationPath" -Type Info

    if ($DeployedCount -gt 0 -and -not $DryRun) {
        Write-Host ""
        Write-Status "Restart Claude Code to load the new skills" -Type Info
    }
}

# Run main function
Main
