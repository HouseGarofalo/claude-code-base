<#
.SYNOPSIS
    Updates an existing project with new content from the claude-code-base template.

.DESCRIPTION
    This script provides selective updates from the template to existing projects:
    - Compare versions between template and target
    - Show diff of changes before applying
    - Selective updates (skills only, commands only, etc.)
    - Automatic backup before updates
    - Merge vs overwrite options

.PARAMETER TargetPath
    Path to the target project to update.

.PARAMETER UpdateType
    What to update: all, claude-config, vscode, prps, scripts, docs, github.

.PARAMETER DryRun
    Preview changes without applying them.

.PARAMETER Force
    Skip confirmation prompts.

.PARAMETER Merge
    Attempt to merge changes instead of overwriting.

.PARAMETER NoBackup
    Skip creating backups (not recommended).

.EXAMPLE
    .\update-project.ps1 -TargetPath "E:\Repos\my-project"

.EXAMPLE
    .\update-project.ps1 -TargetPath "E:\Repos\my-project" -UpdateType claude-config -DryRun

.EXAMPLE
    .\update-project.ps1 -TargetPath "E:\Repos\my-project" -UpdateType scripts -Force

.NOTES
    Author: Claude Code Base
    Version: 2.0.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TargetPath,

    [ValidateSet("all", "claude-config", "skills", "commands", "vscode", "prps", "scripts", "docs", "github")]
    [string]$UpdateType = "all",

    [switch]$DryRun,
    [switch]$Force,
    [switch]$Merge,
    [switch]$NoBackup
)

# ============================================================================
# Configuration
# ============================================================================

$ErrorActionPreference = "Continue"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplatePath = Split-Path -Parent $ScriptPath

# Update groups (skills and commands are now separate groups)
$UpdateGroups = @{
    "claude-config" = @(
        @{ Source = ".claude\config.yaml"; Type = "File"; Critical = $true }
        @{ Source = ".claude\settings.json"; Type = "File"; Critical = $true }
        @{ Source = ".claude\context"; Type = "Directory"; Critical = $false }
        @{ Source = ".claude\hooks"; Type = "Directory"; Critical = $false }
        @{ Source = "CLAUDE.md"; Type = "File"; Critical = $true }
    )
    "skills" = @(
        @{ Source = ".claude\skills"; Type = "Directory"; Critical = $false }
    )
    "commands" = @(
        @{ Source = ".claude\commands"; Type = "Directory"; Critical = $false }
    )
    "vscode" = @(
        @{ Source = ".vscode"; Type = "Directory"; Critical = $false }
    )
    "prps" = @(
        @{ Source = "PRPs"; Type = "Directory"; Critical = $false }
    )
    "scripts" = @(
        @{ Source = "scripts\sync-claude-code.ps1"; Type = "File"; Critical = $false }
        @{ Source = "scripts\validate-claude-code.ps1"; Type = "File"; Critical = $false }
        @{ Source = "scripts\update-project.ps1"; Type = "File"; Critical = $false }
    )
    "docs" = @(
        @{ Source = "docs"; Type = "Directory"; Critical = $false }
    )
    "github" = @(
        @{ Source = ".github"; Type = "Directory"; Critical = $false }
        @{ Source = ".gitattributes"; Type = "File"; Critical = $false }
        @{ Source = ".pre-commit-config.yaml"; Type = "File"; Critical = $false }
    )
}

# Version tracking
$TemplateVersion = "2.0.0"

# Statistics
$script:Stats = @{
    Updated = 0
    Created = 0
    Skipped = 0
    Backed = 0
    Conflicts = 0
}

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Banner {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "              Claude Code Base - Project Updater                      " -ForegroundColor Cyan
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
        "ERROR"   { "[ERR]" }
        "WARNING" { "[WARN]" }
        "WORKING" { "[...]" }
        "DRYRUN"  { "[DRY]" }
        "BACKUP"  { "[BAK]" }
        "SKIP"    { "[SKIP]" }
        "NEW"     { "[NEW]" }
        "UPDATE"  { "[UPD]" }
        "MERGE"   { "[MRG]" }
        "CONFLICT"{ "[!!!]" }
        default   { "[i]" }
    }

    $color = switch ($Status) {
        "SUCCESS"  { "Green" }
        "ERROR"    { "Red" }
        "WARNING"  { "Yellow" }
        "WORKING"  { "Cyan" }
        "DRYRUN"   { "Magenta" }
        "BACKUP"   { "Blue" }
        "SKIP"     { "DarkGray" }
        "NEW"      { "Green" }
        "UPDATE"   { "Cyan" }
        "MERGE"    { "Yellow" }
        "CONFLICT" { "Red" }
        default    { "White" }
    }

    Write-Host "$icon $Message" -ForegroundColor $color
}

function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$Default = "",
        [string[]]$ValidOptions = @()
    )

    $displayPrompt = $Prompt
    if ($Default) { $displayPrompt += " [$Default]" }
    $displayPrompt += ": "

    if ($ValidOptions.Count -gt 0) {
        Write-Host "  Options: $($ValidOptions -join ', ')" -ForegroundColor Gray
    }

    do {
        $input = Read-Host $displayPrompt
        if ([string]::IsNullOrWhiteSpace($input) -and $Default) { $input = $Default }
        if ($ValidOptions.Count -eq 0 -or $input -in $ValidOptions) { break }
        Write-Host "  Please select from: $($ValidOptions -join ', ')" -ForegroundColor Red
    } while ($true)

    return $input
}

function Get-ProjectVersion {
    param([string]$ProjectPath)

    $configPath = Join-Path $ProjectPath ".claude\config.yaml"
    if (Test-Path $configPath) {
        $content = Get-Content $configPath -Raw -ErrorAction SilentlyContinue
        if ($content -match 'template_version:\s*["|'']?([^"''\s]+)') {
            return $Matches[1]
        }
    }
    return "unknown"
}

function Compare-Versions {
    param(
        [string]$SourceVersion,
        [string]$TargetVersion
    )

    if ($TargetVersion -eq "unknown") {
        return "unknown"
    }

    try {
        $source = [Version]$SourceVersion
        $target = [Version]$TargetVersion

        if ($source -gt $target) { return "newer" }
        if ($source -lt $target) { return "older" }
        return "same"
    }
    catch {
        return "unknown"
    }
}

function Get-FileDiff {
    param(
        [string]$SourceFile,
        [string]$TargetFile
    )

    if (-not (Test-Path $SourceFile) -or -not (Test-Path $TargetFile)) {
        return $null
    }

    $sourceHash = (Get-FileHash $SourceFile -Algorithm MD5).Hash
    $targetHash = (Get-FileHash $TargetFile -Algorithm MD5).Hash

    return @{
        Same = $sourceHash -eq $targetHash
        SourceHash = $sourceHash
        TargetHash = $targetHash
    }
}

function New-Backup {
    param(
        [string]$FilePath,
        [string]$BackupDir,
        [string]$BaseTargetPath
    )

    if (-not (Test-Path $FilePath)) { return $null }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $relativePath = $FilePath.Substring($BaseTargetPath.Length).TrimStart('\')
    $backupPath = Join-Path $BackupDir "$relativePath.$timestamp.backup"

    $backupParent = Split-Path $backupPath -Parent
    if (-not (Test-Path $backupParent)) {
        New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
    }

    Copy-Item -Path $FilePath -Destination $backupPath -Force
    $script:Stats.Backed++
    return $backupPath
}

function Update-SingleFile {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [string]$BackupDir,
        [string]$BaseTargetPath,
        [bool]$Critical
    )

    if (-not (Test-Path $SourcePath)) {
        Write-Status "Source not found: $SourcePath" "SKIP"
        $script:Stats.Skipped++
        return
    }

    $relativePath = $SourcePath.Substring($TemplatePath.Length).TrimStart('\')
    $exists = Test-Path $DestPath

    if ($DryRun) {
        if ($exists) {
            $diff = Get-FileDiff -SourceFile $SourcePath -TargetFile $DestPath
            if ($diff.Same) {
                Write-Status "No changes: $relativePath" "SKIP"
                $script:Stats.Skipped++
            }
            else {
                Write-Status "Would update: $relativePath" "DRYRUN"
                $script:Stats.Updated++
            }
        }
        else {
            Write-Status "Would create: $relativePath" "DRYRUN"
            $script:Stats.Created++
        }
        return
    }

    if ($exists) {
        $diff = Get-FileDiff -SourceFile $SourcePath -TargetFile $DestPath
        if ($diff.Same) {
            Write-Status "Unchanged: $relativePath" "SKIP"
            $script:Stats.Skipped++
            return
        }

        # Backup existing file
        if (-not $NoBackup) {
            $backup = New-Backup -FilePath $DestPath -BackupDir $BackupDir -BaseTargetPath $BaseTargetPath
            if ($backup) {
                Write-Status "Backed up: $relativePath" "BACKUP"
            }
        }

        # Handle merge vs overwrite
        if ($Merge -and $Critical) {
            Write-Status "Conflict (manual merge needed): $relativePath" "CONFLICT"
            $script:Stats.Conflicts++
            return
        }
    }

    # Ensure target directory exists
    $targetDir = Split-Path $DestPath -Parent
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    Copy-Item -Path $SourcePath -Destination $DestPath -Force

    if ($exists) {
        Write-Status "Updated: $relativePath" "UPDATE"
        $script:Stats.Updated++
    }
    else {
        Write-Status "Created: $relativePath" "NEW"
        $script:Stats.Created++
    }
}

function Update-Directory {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [string]$BackupDir,
        [string]$BaseTargetPath,
        [bool]$Critical
    )

    if (-not (Test-Path $SourcePath -PathType Container)) {
        Write-Status "Source directory not found: $SourcePath" "SKIP"
        $script:Stats.Skipped++
        return
    }

    $sourceFiles = Get-ChildItem -Path $SourcePath -Recurse -File

    foreach ($file in $sourceFiles) {
        $relativePath = $file.FullName.Substring($SourcePath.Length).TrimStart('\')
        $targetFile = Join-Path $DestPath $relativePath

        Update-SingleFile `
            -SourcePath $file.FullName `
            -DestPath $targetFile `
            -BackupDir $BackupDir `
            -BaseTargetPath $BaseTargetPath `
            -Critical $Critical
    }
}

function Get-TemplateProfile {
    <#
    .SYNOPSIS
        Reads template_profile from target project's .claude/config.yaml.
    #>
    param([string]$ProjectPath)

    $configPath = Join-Path $ProjectPath ".claude\config.yaml"
    if (-not (Test-Path $configPath)) { return $null }

    $content = Get-Content $configPath -Raw -ErrorAction SilentlyContinue
    if (-not $content -or $content -notmatch 'template_profile:') { return $null }

    $profile = @{}

    if ($content -match 'template_version:\s*[''"]?([^''"}\s,\]]+)') { $profile.template_version = $Matches[1] }
    if ($content -match 'project_type:\s*[''"]?([^''"}\s,\]]+)') { $profile.project_type = $Matches[1] }
    if ($content -match 'primary_language:\s*[''"]?([^''"}\s,\]]+)') { $profile.primary_language = $Matches[1] }
    if ($content -match 'framework:\s*[''"]?([^''"}\s,\]]+)') { $profile.framework = $Matches[1] }

    if ($content -match 'skill_groups:\s*\[([^\]]+)\]') {
        $profile.skill_groups = ($Matches[1] -replace '[''"]', '').Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }
    if ($content -match 'command_groups:\s*\[([^\]]+)\]') {
        $profile.command_groups = ($Matches[1] -replace '[''"]', '').Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }
    if ($content -match 'dev_frameworks:\s*\[([^\]]*)\]') {
        $rawValue = $Matches[1] -replace '[''"]', ''
        $profile.dev_frameworks = if ($rawValue.Trim()) {
            $rawValue.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        } else { @() }
    }

    return $profile
}

function Get-ManifestConfig {
    $manifestPath = Join-Path $TemplatePath "templates\manifest.json"
    if (-not (Test-Path $manifestPath)) { return $null }
    return (Get-Content $manifestPath -Raw | ConvertFrom-Json)
}

function Build-SelectiveUpdateItems {
    <#
    .SYNOPSIS
        Builds selective update items for skills and commands based on template_profile.
    #>
    param(
        [string]$UpdateType,
        $Profile,
        $Manifest
    )

    $items = @()

    # For skills update type, build individual skill items
    if ($UpdateType -eq "skills" -or $UpdateType -eq "all") {
        $selectedSkills = @()
        foreach ($group in $Profile.skill_groups) {
            $groupSkills = $Manifest.skills.$group
            if ($groupSkills) { $selectedSkills += @($groupSkills) }
        }
        $selectedSkills = $selectedSkills | Sort-Object -Unique

        foreach ($skill in $selectedSkills) {
            $items += @{ Source = ".claude\skills\$skill"; Type = "Directory"; Critical = $false }
        }
    }

    # For commands update type, build individual command items
    if ($UpdateType -eq "commands" -or $UpdateType -eq "all") {
        $selectedCommands = @()
        foreach ($group in $Profile.command_groups) {
            $groupCommands = $Manifest.commands.$group
            if ($groupCommands) { $selectedCommands += @($groupCommands) }
        }
        $selectedCommands = $selectedCommands | Sort-Object -Unique

        foreach ($cmd in $selectedCommands) {
            $items += @{ Source = ".claude\commands\$cmd.md"; Type = "File"; Critical = $false }
        }
    }

    return $items
}

# ============================================================================
# Main Script
# ============================================================================

Write-Banner

# Get target path
if (-not $TargetPath) {
    Write-Step 1 "Select Target Project"
    $TargetPath = Get-UserInput -Prompt "Path to the project to update"
}

# Validate target
if (-not (Test-Path $TargetPath -PathType Container)) {
    Write-Status "Target path does not exist: $TargetPath" "ERROR"
    exit 1
}

$gitDir = Join-Path $TargetPath ".git"
if (-not (Test-Path $gitDir)) {
    Write-Status "Target is not a Git repository" "ERROR"
    exit 1
}

Write-Step 2 "Version Comparison"

$targetVersion = Get-ProjectVersion -ProjectPath $TargetPath
$comparison = Compare-Versions -SourceVersion $TemplateVersion -TargetVersion $targetVersion

Write-Host "  Template Version: $TemplateVersion" -ForegroundColor Cyan
Write-Host "  Project Version:  $targetVersion" -ForegroundColor White
Write-Host "  Status:           $comparison" -ForegroundColor $(if ($comparison -eq "newer") { "Green" } else { "Yellow" })
Write-Host ""

if ($comparison -eq "same" -and -not $Force) {
    Write-Status "Project is already up to date" "SUCCESS"
    $continue = Get-UserInput -Prompt "Continue anyway?" -Default "n" -ValidOptions @("y", "n")
    if ($continue -ne "y") { exit 0 }
}

Write-Step 3 "Update Selection"

# Check for template_profile for selective updates
$templateProfile = Get-TemplateProfile -ProjectPath $TargetPath
$manifest = Get-ManifestConfig
$updateMode = "legacy"

if ($templateProfile -and $manifest) {
    $updateMode = "selective"
    Write-Status "Template profile found - selective update mode" "SUCCESS"
    Write-Host "    Project: $($templateProfile.project_type) / $($templateProfile.primary_language)" -ForegroundColor Cyan
} else {
    Write-Status "No template profile - full update mode" "INFO"
}

# Determine what to update
$itemsToUpdate = @()

if ($UpdateType -eq "all") {
    foreach ($group in $UpdateGroups.Keys) {
        # For selective mode, replace skills/commands groups with filtered versions
        if ($updateMode -eq "selective" -and ($group -eq "skills" -or $group -eq "commands")) {
            continue  # Will be added below
        }
        $itemsToUpdate += $UpdateGroups[$group]
    }

    # In selective mode, add filtered skills and commands
    if ($updateMode -eq "selective") {
        $selectiveItems = Build-SelectiveUpdateItems -UpdateType "all" -Profile $templateProfile -Manifest $manifest
        $itemsToUpdate += $selectiveItems
    }
}
elseif ($UpdateType -eq "skills" -or $UpdateType -eq "commands") {
    if ($updateMode -eq "selective") {
        # Use filtered items
        $selectiveItems = Build-SelectiveUpdateItems -UpdateType $UpdateType -Profile $templateProfile -Manifest $manifest
        $itemsToUpdate = $selectiveItems
    } else {
        # Legacy: use full directory
        if ($UpdateGroups.ContainsKey($UpdateType)) {
            $itemsToUpdate = $UpdateGroups[$UpdateType]
        }
    }
}
else {
    if ($UpdateGroups.ContainsKey($UpdateType)) {
        $itemsToUpdate = $UpdateGroups[$UpdateType]
    }
    else {
        Write-Status "Unknown update type: $UpdateType" "ERROR"
        exit 1
    }
}

Write-Host "  Update Type: $UpdateType" -ForegroundColor Cyan
Write-Host "  Update Mode: $updateMode" -ForegroundColor Cyan
Write-Host "  Items:       $($itemsToUpdate.Count)" -ForegroundColor White
Write-Host ""

if ($DryRun) {
    Write-Host "  [!] DRY RUN MODE - No changes will be made" -ForegroundColor Magenta
    Write-Host ""
}

# Confirmation
if (-not $Force -and -not $DryRun) {
    Write-Host "Items to be updated:" -ForegroundColor Yellow
    foreach ($item in $itemsToUpdate) {
        $criticalMark = if ($item.Critical) { " [CRITICAL]" } else { "" }
        Write-Host "  - $($item.Source)$criticalMark" -ForegroundColor White
    }
    Write-Host ""

    $confirm = Get-UserInput -Prompt "Proceed with update?" -Default "y" -ValidOptions @("y", "n")
    if ($confirm -ne "y") {
        Write-Status "Cancelled by user" "WARNING"
        exit 0
    }
}

Write-Step 4 "Applying Updates"

# Create backup directory
$backupDir = Join-Path $TargetPath ".claude-backup"
if (-not $NoBackup -and -not $DryRun) {
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    Write-Status "Backup directory: $backupDir" "INFO"
    Write-Host ""
}

# Process updates
foreach ($item in $itemsToUpdate) {
    $sourcePath = Join-Path $TemplatePath $item.Source
    $destPath = Join-Path $TargetPath $item.Source

    if ($item.Type -eq "File") {
        Update-SingleFile `
            -SourcePath $sourcePath `
            -DestPath $destPath `
            -BackupDir $backupDir `
            -BaseTargetPath $TargetPath `
            -Critical $item.Critical
    }
    else {
        Update-Directory `
            -SourcePath $sourcePath `
            -DestPath $destPath `
            -BackupDir $backupDir `
            -BaseTargetPath $TargetPath `
            -Critical $item.Critical
    }
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
    Write-Host "              Project Update Complete!                                " -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Green
}
Write-Host ""

Write-Host "Statistics:" -ForegroundColor Cyan
Write-Host "   Files created:    $($script:Stats.Created)" -ForegroundColor Green
Write-Host "   Files updated:    $($script:Stats.Updated)" -ForegroundColor Cyan
Write-Host "   Files unchanged:  $($script:Stats.Skipped)" -ForegroundColor Gray
Write-Host "   Files backed up:  $($script:Stats.Backed)" -ForegroundColor Blue
if ($script:Stats.Conflicts -gt 0) {
    Write-Host "   Conflicts:        $($script:Stats.Conflicts)" -ForegroundColor Red
}
Write-Host ""

if (-not $DryRun) {
    Write-Host "Target: $TargetPath" -ForegroundColor Cyan
    if (-not $NoBackup -and $script:Stats.Backed -gt 0) {
        Write-Host "Backups: $backupDir" -ForegroundColor Blue
    }
    Write-Host ""

    if ($script:Stats.Conflicts -gt 0) {
        Write-Host "Manual merge required for $($script:Stats.Conflicts) file(s)" -ForegroundColor Yellow
        Write-Host "Check backup directory for original versions" -ForegroundColor Gray
    }

    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "   1. Review updated files for project-specific customizations" -ForegroundColor White
    Write-Host "   2. Update .claude/config.yaml with template_version: $TemplateVersion" -ForegroundColor White
    Write-Host "   3. Commit changes: git add . && git commit -m 'chore: update from claude-code-base template'" -ForegroundColor White
}
Write-Host ""
