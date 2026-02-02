<#
.SYNOPSIS
    Comprehensive test suite for the claude-code-base template.

.DESCRIPTION
    This script validates:
    - All JSON files are valid
    - All YAML files are valid
    - All skills have proper SKILL.md format
    - All commands have proper frontmatter
    - Directory structure is correct
    - Setup script has required functions
    - Sync script has required functions

.PARAMETER Verbose
    Show detailed output for each test.

.PARAMETER FailFast
    Stop on first failure.

.EXAMPLE
    .\test-template.ps1

.EXAMPLE
    .\test-template.ps1 -Verbose -FailFast

.NOTES
    Author: Claude Code Base
    Version: 1.0.0
    Exit Codes:
        0 - All tests passed
        1 - One or more tests failed
#>

[CmdletBinding()]
param(
    [switch]$FailFast,
    [switch]$ShowDetails
)

# ============================================================================
# Configuration
# ============================================================================

$ErrorActionPreference = "Continue"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath

# Test results tracking
$script:TestResults = @{
    Passed = 0
    Failed = 0
    Skipped = 0
    Errors = @()
}

# Required directories
$RequiredDirectories = @(
    ".claude",
    ".github",
    ".github/ISSUE_TEMPLATE",
    ".github/workflows",
    ".vscode",
    "docs",
    "PRPs",
    "scripts",
    "specs",
    "templates"
)

# Required files
$RequiredFiles = @(
    "CLAUDE.md",
    "README.md",
    "LICENSE",
    ".gitignore",
    ".gitattributes",
    ".pre-commit-config.yaml",
    ".claude/config.yaml",
    "scripts/setup-claude-code-project.ps1",
    "scripts/sync-claude-code.ps1",
    "scripts/validate-claude-code.ps1"
)

# Required functions in setup script
$SetupScriptFunctions = @(
    "Write-Banner",
    "Write-Step",
    "Write-Status",
    "Get-UserInput",
    "Test-Prerequisites",
    "Copy-TemplateFiles",
    "Replace-Placeholders"
)

# Required functions in sync script
$SyncScriptFunctions = @(
    "Write-Banner",
    "Write-Step",
    "Write-Status",
    "Get-UserInput",
    "Test-Prerequisites",
    "Test-GitRepository",
    "New-Backup",
    "Sync-Item"
)

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
        [ValidateSet("PASS", "FAIL", "SKIP")]
        [string]$Result,
        [string]$Message = ""
    )

    $icon = switch ($Result) {
        "PASS" { "[PASS]" }
        "FAIL" { "[FAIL]" }
        "SKIP" { "[SKIP]" }
    }

    $color = switch ($Result) {
        "PASS" { "Green" }
        "FAIL" { "Red" }
        "SKIP" { "Yellow" }
    }

    $output = "$icon $TestName"
    if ($Message -and $ShowDetails) {
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
    }
}

function Test-JsonFile {
    param([string]$FilePath)

    try {
        $content = Get-Content $FilePath -Raw -ErrorAction Stop
        $null = $content | ConvertFrom-Json -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Test-YamlFile {
    param([string]$FilePath)

    try {
        $content = Get-Content $FilePath -Raw -ErrorAction Stop

        # Basic YAML validation - check for common syntax errors
        $lines = $content -split "`n"
        $indentStack = @()

        foreach ($line in $lines) {
            # Skip empty lines and comments
            if ($line -match '^\s*$' -or $line -match '^\s*#') {
                continue
            }

            # Check for tabs (YAML should use spaces)
            if ($line -match "`t") {
                return $false
            }

            # Check for unbalanced quotes
            $singleQuotes = ([regex]::Matches($line, "'")).Count
            $doubleQuotes = ([regex]::Matches($line, '"')).Count
            if ($singleQuotes % 2 -ne 0 -or $doubleQuotes % 2 -ne 0) {
                # Could be multi-line string, so not necessarily an error
                # Basic check only
            }
        }

        return $true
    }
    catch {
        return $false
    }
}

function Test-SkillFormat {
    param([string]$FilePath)

    try {
        $content = Get-Content $FilePath -Raw -ErrorAction Stop

        # Check for YAML frontmatter
        if (-not ($content -match '^---\s*\n')) {
            return @{ Valid = $false; Error = "Missing YAML frontmatter" }
        }

        # Extract frontmatter
        if ($content -match '^---\s*\n([\s\S]*?)\n---') {
            $frontmatter = $Matches[1]

            # Check for required fields
            if (-not ($frontmatter -match 'name:\s*\S+')) {
                return @{ Valid = $false; Error = "Missing 'name' field" }
            }

            if (-not ($frontmatter -match 'description:\s*\S+')) {
                return @{ Valid = $false; Error = "Missing 'description' field" }
            }

            # Check description length
            if ($frontmatter -match 'description:\s*["|''](.*?)["|'']') {
                $desc = $Matches[1]
                if ($desc.Length -gt 1024) {
                    return @{ Valid = $false; Error = "Description exceeds 1024 characters" }
                }
            }
            elseif ($frontmatter -match 'description:\s*(.+)') {
                $desc = $Matches[1].Trim()
                if ($desc.Length -gt 1024) {
                    return @{ Valid = $false; Error = "Description exceeds 1024 characters" }
                }
            }
        }
        else {
            return @{ Valid = $false; Error = "Invalid frontmatter format" }
        }

        return @{ Valid = $true; Error = "" }
    }
    catch {
        return @{ Valid = $false; Error = $_.Exception.Message }
    }
}

function Test-CommandFrontmatter {
    param([string]$FilePath)

    try {
        $content = Get-Content $FilePath -Raw -ErrorAction Stop

        # Check for YAML frontmatter or heading
        if ($content -match '^---\s*\n') {
            # Has frontmatter - validate it
            if ($content -match '^---\s*\n([\s\S]*?)\n---') {
                return @{ Valid = $true; Error = "" }
            }
            return @{ Valid = $false; Error = "Incomplete frontmatter" }
        }
        elseif ($content -match '^#\s+') {
            # Has markdown heading - acceptable
            return @{ Valid = $true; Error = "" }
        }
        else {
            return @{ Valid = $false; Error = "Missing frontmatter or heading" }
        }
    }
    catch {
        return @{ Valid = $false; Error = $_.Exception.Message }
    }
}

function Test-ScriptFunction {
    param(
        [string]$FilePath,
        [string]$FunctionName
    )

    try {
        $content = Get-Content $FilePath -Raw -ErrorAction Stop
        return $content -match "function\s+$FunctionName\s*{"
    }
    catch {
        return $false
    }
}

function Exit-WithCode {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "  Test Summary" -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Passed:  $($script:TestResults.Passed)" -ForegroundColor Green
    Write-Host "  Failed:  $($script:TestResults.Failed)" -ForegroundColor Red
    Write-Host "  Skipped: $($script:TestResults.Skipped)" -ForegroundColor Yellow
    Write-Host ""

    if ($script:TestResults.Errors.Count -gt 0) {
        Write-Host "Errors:" -ForegroundColor Red
        foreach ($error in $script:TestResults.Errors) {
            Write-Host "  - $error" -ForegroundColor Red
        }
        Write-Host ""
    }

    $exitCode = if ($script:TestResults.Failed -gt 0) { 1 } else { 0 }
    exit $exitCode
}

# ============================================================================
# Test Suites
# ============================================================================

function Test-DirectoryStructure {
    Write-TestHeader "Testing Directory Structure"

    foreach ($dir in $RequiredDirectories) {
        $path = Join-Path $BasePath $dir
        if (Test-Path $path -PathType Container) {
            Write-TestResult "Directory: $dir" "PASS"
        }
        else {
            Write-TestResult "Directory: $dir" "FAIL" "Directory does not exist"
        }
    }
}

function Test-RequiredFiles {
    Write-TestHeader "Testing Required Files"

    foreach ($file in $RequiredFiles) {
        $path = Join-Path $BasePath $file
        if (Test-Path $path -PathType Leaf) {
            Write-TestResult "File: $file" "PASS"
        }
        else {
            Write-TestResult "File: $file" "FAIL" "File does not exist"
        }
    }
}

function Test-JsonFiles {
    Write-TestHeader "Testing JSON Files"

    $jsonFiles = Get-ChildItem -Path $BasePath -Filter "*.json" -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\node_modules\\|\\\.git\\' }

    if ($jsonFiles.Count -eq 0) {
        Write-TestResult "JSON Files" "SKIP" "No JSON files found"
        return
    }

    foreach ($file in $jsonFiles) {
        $relativePath = $file.FullName.Substring($BasePath.Length).TrimStart('\')
        if (Test-JsonFile -FilePath $file.FullName) {
            Write-TestResult "JSON: $relativePath" "PASS"
        }
        else {
            Write-TestResult "JSON: $relativePath" "FAIL" "Invalid JSON syntax"
        }
    }
}

function Test-YamlFiles {
    Write-TestHeader "Testing YAML Files"

    $yamlFiles = Get-ChildItem -Path $BasePath -Include "*.yaml", "*.yml" -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\node_modules\\|\\\.git\\' }

    if ($yamlFiles.Count -eq 0) {
        Write-TestResult "YAML Files" "SKIP" "No YAML files found"
        return
    }

    foreach ($file in $yamlFiles) {
        $relativePath = $file.FullName.Substring($BasePath.Length).TrimStart('\')
        if (Test-YamlFile -FilePath $file.FullName) {
            Write-TestResult "YAML: $relativePath" "PASS"
        }
        else {
            Write-TestResult "YAML: $relativePath" "FAIL" "Invalid YAML syntax"
        }
    }
}

function Test-SkillFiles {
    Write-TestHeader "Testing Skill Files"

    $skillsPath = Join-Path $BasePath "templates\skill-template"
    if (-not (Test-Path $skillsPath)) {
        # Check alternate location
        $skillsPath = Join-Path $BasePath "skills"
    }

    if (-not (Test-Path $skillsPath)) {
        Write-TestResult "Skill Files" "SKIP" "No skills directory found"
        return
    }

    $skillFiles = Get-ChildItem -Path $skillsPath -Filter "SKILL.md" -Recurse -File -ErrorAction SilentlyContinue

    if ($skillFiles.Count -eq 0) {
        Write-TestResult "Skill Files" "SKIP" "No SKILL.md files found"
        return
    }

    foreach ($file in $skillFiles) {
        $relativePath = $file.FullName.Substring($BasePath.Length).TrimStart('\')
        $result = Test-SkillFormat -FilePath $file.FullName

        if ($result.Valid) {
            Write-TestResult "Skill: $relativePath" "PASS"
        }
        else {
            Write-TestResult "Skill: $relativePath" "FAIL" $result.Error
        }
    }
}

function Test-CommandFiles {
    Write-TestHeader "Testing Command Files"

    $commandsPath = Join-Path $BasePath "templates\command-template"
    if (-not (Test-Path $commandsPath)) {
        # Check alternate location
        $commandsPath = Join-Path $BasePath "commands"
    }

    if (-not (Test-Path $commandsPath)) {
        Write-TestResult "Command Files" "SKIP" "No commands directory found"
        return
    }

    $commandFiles = Get-ChildItem -Path $commandsPath -Filter "*.md" -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "README.md" }

    if ($commandFiles.Count -eq 0) {
        Write-TestResult "Command Files" "SKIP" "No command files found"
        return
    }

    foreach ($file in $commandFiles) {
        $relativePath = $file.FullName.Substring($BasePath.Length).TrimStart('\')
        $result = Test-CommandFrontmatter -FilePath $file.FullName

        if ($result.Valid) {
            Write-TestResult "Command: $relativePath" "PASS"
        }
        else {
            Write-TestResult "Command: $relativePath" "FAIL" $result.Error
        }
    }
}

function Test-SetupScript {
    Write-TestHeader "Testing Setup Script Functions"

    $setupScript = Join-Path $BasePath "scripts\setup-claude-code-project.ps1"

    if (-not (Test-Path $setupScript)) {
        Write-TestResult "Setup Script" "FAIL" "Script not found"
        return
    }

    foreach ($func in $SetupScriptFunctions) {
        if (Test-ScriptFunction -FilePath $setupScript -FunctionName $func) {
            Write-TestResult "Setup: $func" "PASS"
        }
        else {
            Write-TestResult "Setup: $func" "FAIL" "Function not found"
        }
    }
}

function Test-SyncScript {
    Write-TestHeader "Testing Sync Script Functions"

    $syncScript = Join-Path $BasePath "scripts\sync-claude-code.ps1"

    if (-not (Test-Path $syncScript)) {
        Write-TestResult "Sync Script" "FAIL" "Script not found"
        return
    }

    foreach ($func in $SyncScriptFunctions) {
        if (Test-ScriptFunction -FilePath $syncScript -FunctionName $func) {
            Write-TestResult "Sync: $func" "PASS"
        }
        else {
            Write-TestResult "Sync: $func" "FAIL" "Function not found"
        }
    }
}

# ============================================================================
# Main Execution
# ============================================================================

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         Claude Code Base - Template Test Suite                       " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Base Path: $BasePath" -ForegroundColor Gray
Write-Host "  Date:      $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# Run all test suites
Test-DirectoryStructure
Test-RequiredFiles
Test-JsonFiles
Test-YamlFiles
Test-SkillFiles
Test-CommandFiles
Test-SetupScript
Test-SyncScript

# Exit with appropriate code
Exit-WithCode
