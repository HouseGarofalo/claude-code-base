<#
.SYNOPSIS
    Test suite specifically for validating Claude Code skills.

.DESCRIPTION
    This script validates skill files for:
    - Presence of name and description in frontmatter
    - Description length under 1024 characters
    - No duplicate skill names
    - Valid YAML frontmatter syntax
    - Proper file structure

.PARAMETER SkillsPath
    Path to the skills directory. Defaults to skills/ in the repository root.

.PARAMETER Verbose
    Show detailed output for each test.

.PARAMETER FailFast
    Stop on first failure.

.EXAMPLE
    .\test-skills.ps1

.EXAMPLE
    .\test-skills.ps1 -SkillsPath "E:\Repos\my-project\skills" -Verbose

.NOTES
    Author: Claude Code Base
    Version: 1.0.0
    Exit Codes:
        0 - All tests passed
        1 - One or more tests failed
#>

[CmdletBinding()]
param(
    [string]$SkillsPath,
    [switch]$FailFast,
    [switch]$ShowDetails
)

# ============================================================================
# Configuration
# ============================================================================

$ErrorActionPreference = "Continue"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath

if (-not $SkillsPath) {
    $SkillsPath = Join-Path $BasePath "skills"
    if (-not (Test-Path $SkillsPath)) {
        $SkillsPath = Join-Path $BasePath "templates\skill-template"
    }
}

# Test results tracking
$script:TestResults = @{
    Passed = 0
    Failed = 0
    Skipped = 0
    Errors = @()
}

# Track skill names for duplicate detection
$script:SkillNames = @{}

# ============================================================================
# Helper Functions
# ============================================================================

function Write-TestHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-TestResult {
    param(
        [string]$TestName,
        [ValidateSet("PASS", "FAIL", "SKIP", "WARN")]
        [string]$Result,
        [string]$Message = ""
    )

    $icon = switch ($Result) {
        "PASS" { "[PASS]" }
        "FAIL" { "[FAIL]" }
        "SKIP" { "[SKIP]" }
        "WARN" { "[WARN]" }
    }

    $color = switch ($Result) {
        "PASS" { "Green" }
        "FAIL" { "Red" }
        "SKIP" { "Yellow" }
        "WARN" { "Yellow" }
    }

    $output = "$icon $TestName"
    if ($Message -and ($ShowDetails -or $Result -eq "FAIL")) {
        $output += " - $Message"
    }

    Write-Host $output -ForegroundColor $color

    switch ($Result) {
        "PASS" { $script:TestResults.Passed++ }
        "FAIL" {
            $script:TestResults.Failed++
            $script:TestResults.Errors += "$TestName: $Message"
            if ($FailFast) {
                Write-Host ""
                Write-Host "FailFast enabled - stopping on first failure" -ForegroundColor Red
                Exit-WithCode
            }
        }
        "SKIP" { $script:TestResults.Skipped++ }
        "WARN" { $script:TestResults.Skipped++ }
    }
}

function Get-SkillFrontmatter {
    param([string]$FilePath)

    try {
        $content = Get-Content $FilePath -Raw -ErrorAction Stop

        # Check for YAML frontmatter
        if (-not ($content -match '^---\s*\r?\n')) {
            return @{
                Valid = $false
                Error = "Missing YAML frontmatter (must start with ---)"
                Name = $null
                Description = $null
            }
        }

        # Extract frontmatter
        if ($content -match '^---\s*\r?\n([\s\S]*?)\r?\n---') {
            $frontmatter = $Matches[1]

            # Extract name
            $name = $null
            if ($frontmatter -match 'name:\s*["|'']?([\w-]+)["|'']?') {
                $name = $Matches[1]
            }
            elseif ($frontmatter -match 'name:\s*(\S+)') {
                $name = $Matches[1].Trim('"', "'")
            }

            # Extract description
            $description = $null
            # Multi-line description with quotes
            if ($frontmatter -match 'description:\s*["|'']([\s\S]*?)["|'']') {
                $description = $Matches[1]
            }
            # Multi-line description with | or >
            elseif ($frontmatter -match 'description:\s*[\|>]\s*\r?\n((?:\s+.+\r?\n?)+)') {
                $description = $Matches[1] -replace '\s+', ' '
            }
            # Single line description
            elseif ($frontmatter -match 'description:\s*(.+)') {
                $description = $Matches[1].Trim().Trim('"', "'")
            }

            return @{
                Valid = $true
                Error = $null
                Name = $name
                Description = $description
                Raw = $frontmatter
            }
        }
        else {
            return @{
                Valid = $false
                Error = "Invalid frontmatter format (missing closing ---)"
                Name = $null
                Description = $null
            }
        }
    }
    catch {
        return @{
            Valid = $false
            Error = $_.Exception.Message
            Name = $null
            Description = $null
        }
    }
}

function Test-SkillName {
    param(
        [string]$Name,
        [string]$FilePath
    )

    $errors = @()

    if ([string]::IsNullOrWhiteSpace($Name)) {
        return @{ Valid = $false; Errors = @("Name is missing or empty") }
    }

    # Check naming conventions
    if ($Name -cnotmatch '^[a-z][a-z0-9-]*$') {
        $errors += "Name must be lowercase letters, numbers, and hyphens only, starting with a letter"
    }

    if ($Name.Length -gt 64) {
        $errors += "Name exceeds 64 characters (current: $($Name.Length))"
    }

    if ($Name -match '--') {
        $errors += "Name contains consecutive hyphens"
    }

    if ($Name -match '-$') {
        $errors += "Name ends with a hyphen"
    }

    return @{
        Valid = $errors.Count -eq 0
        Errors = $errors
    }
}

function Test-SkillDescription {
    param([string]$Description)

    $errors = @()

    if ([string]::IsNullOrWhiteSpace($Description)) {
        return @{ Valid = $false; Errors = @("Description is missing or empty") }
    }

    if ($Description.Length -gt 1024) {
        $errors += "Description exceeds 1024 characters (current: $($Description.Length))"
    }

    if ($Description.Length -lt 10) {
        $errors += "Description is too short (minimum 10 characters recommended)"
    }

    return @{
        Valid = $errors.Count -eq 0
        Errors = $errors
    }
}

function Exit-WithCode {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "  Skill Test Summary" -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Total Skills: $($script:SkillNames.Count)" -ForegroundColor White
    Write-Host "  Passed:       $($script:TestResults.Passed)" -ForegroundColor Green
    Write-Host "  Failed:       $($script:TestResults.Failed)" -ForegroundColor Red
    Write-Host "  Skipped:      $($script:TestResults.Skipped)" -ForegroundColor Yellow
    Write-Host ""

    if ($script:TestResults.Errors.Count -gt 0) {
        Write-Host "Errors:" -ForegroundColor Red
        foreach ($err in $script:TestResults.Errors) {
            Write-Host "  - $err" -ForegroundColor Red
        }
        Write-Host ""
    }

    $exitCode = if ($script:TestResults.Failed -gt 0) { 1 } else { 0 }
    exit $exitCode
}

# ============================================================================
# Test Functions
# ============================================================================

function Test-AllSkills {
    Write-TestHeader "Validating Skill Files"

    if (-not (Test-Path $SkillsPath)) {
        Write-TestResult "Skills Directory" "FAIL" "Path not found: $SkillsPath"
        return
    }

    $skillFiles = Get-ChildItem -Path $SkillsPath -Filter "SKILL.md" -Recurse -File -ErrorAction SilentlyContinue

    if ($skillFiles.Count -eq 0) {
        Write-TestResult "Skills" "SKIP" "No SKILL.md files found in $SkillsPath"
        return
    }

    Write-Host "Found $($skillFiles.Count) skill file(s)" -ForegroundColor Gray
    Write-Host ""

    foreach ($file in $skillFiles) {
        $relativePath = $file.FullName.Substring($BasePath.Length).TrimStart('\')
        $skillDir = Split-Path (Split-Path $file.FullName -Parent) -Leaf
        $parentDir = Split-Path (Split-Path (Split-Path $file.FullName -Parent) -Parent) -Leaf

        # Category/skill structure
        $displayName = "$parentDir/$skillDir"

        # Get frontmatter
        $frontmatter = Get-SkillFrontmatter -FilePath $file.FullName

        if (-not $frontmatter.Valid) {
            Write-TestResult $displayName "FAIL" $frontmatter.Error
            continue
        }

        # Test name
        $nameResult = Test-SkillName -Name $frontmatter.Name -FilePath $file.FullName
        if (-not $nameResult.Valid) {
            Write-TestResult "$displayName (name)" "FAIL" ($nameResult.Errors -join "; ")
        }
        else {
            Write-TestResult "$displayName (name: $($frontmatter.Name))" "PASS"
        }

        # Test description
        $descResult = Test-SkillDescription -Description $frontmatter.Description
        if (-not $descResult.Valid) {
            Write-TestResult "$displayName (description)" "FAIL" ($descResult.Errors -join "; ")
        }
        else {
            $descLen = if ($frontmatter.Description) { $frontmatter.Description.Length } else { 0 }
            Write-TestResult "$displayName (description: $descLen chars)" "PASS"
        }

        # Track for duplicate detection
        if ($frontmatter.Name) {
            if ($script:SkillNames.ContainsKey($frontmatter.Name)) {
                $existingPath = $script:SkillNames[$frontmatter.Name]
                Write-TestResult "$displayName (duplicate)" "FAIL" "Duplicate name '$($frontmatter.Name)' - also found in $existingPath"
            }
            else {
                $script:SkillNames[$frontmatter.Name] = $relativePath
            }
        }
    }
}

function Test-DuplicateNames {
    Write-TestHeader "Checking for Duplicate Skill Names"

    $duplicates = $script:SkillNames.GetEnumerator() |
        Group-Object Name |
        Where-Object { $_.Count -gt 1 }

    if ($duplicates.Count -eq 0) {
        Write-TestResult "No duplicate skill names" "PASS"
    }
    else {
        foreach ($dup in $duplicates) {
            Write-TestResult "Duplicate: $($dup.Name)" "FAIL" "Found in: $($dup.Group.Value -join ', ')"
        }
    }
}

function Test-SkillDirectoryStructure {
    Write-TestHeader "Validating Skill Directory Structure"

    if (-not (Test-Path $SkillsPath)) {
        Write-TestResult "Skills Directory" "SKIP" "Not found"
        return
    }

    # Get all directories that contain SKILL.md
    $skillDirs = Get-ChildItem -Path $SkillsPath -Filter "SKILL.md" -Recurse -File |
        ForEach-Object { Split-Path $_.FullName -Parent }

    foreach ($dir in $skillDirs) {
        $dirName = Split-Path $dir -Leaf
        $categoryDir = Split-Path $dir -Parent
        $categoryName = Split-Path $categoryDir -Leaf

        # Check directory naming
        if ($dirName -cnotmatch '^[a-z][a-z0-9-]*$') {
            Write-TestResult "Directory: $categoryName/$dirName" "WARN" "Directory name should be lowercase with hyphens"
        }
    }

    Write-TestResult "Directory structure check" "PASS" "$($skillDirs.Count) skill directories found"
}

# ============================================================================
# Main Execution
# ============================================================================

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         Claude Code Base - Skill Test Suite                          " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Skills Path: $SkillsPath" -ForegroundColor Gray
Write-Host "  Date:        $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# Run tests
Test-AllSkills
Test-DuplicateNames
Test-SkillDirectoryStructure

# Exit with appropriate code
Exit-WithCode
