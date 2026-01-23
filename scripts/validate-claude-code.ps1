<#
.SYNOPSIS
    Validates the Claude Code Base template integrity.

.DESCRIPTION
    This script checks that all required files and directories exist,
    validates configuration files, checks Archon project connection,
    and reports any issues with optimization suggestions.

.PARAMETER ProjectPath
    The path to the Claude Code project to validate.
    Defaults to the current directory.

.PARAMETER Fix
    Attempt to fix issues where possible (create missing directories,
    generate placeholder files).

.PARAMETER ShowDetails
    Show detailed output for each check.

.EXAMPLE
    .\scripts\validate-claude-code.ps1

.EXAMPLE
    .\scripts\validate-claude-code.ps1 -ProjectPath "C:\MyProject" -Fix

.EXAMPLE
    .\scripts\validate-claude-code.ps1 -ShowDetails
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ProjectPath = (Get-Location).Path,

    [Parameter()]
    [switch]$Fix,

    [Parameter()]
    [switch]$ShowDetails
)

$ErrorActionPreference = "Continue"

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Success {
    param($Message)
    Write-Host "[PASS] $Message" -ForegroundColor Green
}

function Write-Failure {
    param($Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Write-Warning {
    param($Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Info {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Test-JsonFile {
    <#
    .SYNOPSIS
        Validates JSON syntax in a file, handling JSONC (JSON with comments).
    #>
    param(
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    if (-not (Test-Path $FilePath)) {
        return @{
            Valid = $false
            Error = "File not found"
        }
    }

    try {
        $content = Get-Content $FilePath -Raw -ErrorAction Stop

        # Process line by line to properly handle comments
        $lines = $content -split "`r?`n"
        $cleanedLines = @()

        foreach ($line in $lines) {
            $trimmed = $line.Trim()

            # Skip lines that are entirely comments
            if ($trimmed -match '^//') {
                $cleanedLines += ''
                continue
            }

            # For lines with content, try to preserve strings while removing inline comments
            # Simple approach: if line has // and it's after a quote that's closed, remove the comment
            $inString = $false
            $result = [System.Text.StringBuilder]::new()
            $i = 0

            while ($i -lt $line.Length) {
                $char = $line[$i]

                # Handle escape sequences in strings
                if ($inString -and $char -eq '\' -and $i + 1 -lt $line.Length) {
                    $null = $result.Append($char)
                    $null = $result.Append($line[$i + 1])
                    $i += 2
                    continue
                }

                # Toggle string state on unescaped quotes
                if ($char -eq '"') {
                    $inString = -not $inString
                    $null = $result.Append($char)
                    $i++
                    continue
                }

                # Check for // outside of strings
                if (-not $inString -and $char -eq '/' -and $i + 1 -lt $line.Length -and $line[$i + 1] -eq '/') {
                    # Found a comment, stop processing this line
                    break
                }

                $null = $result.Append($char)
                $i++
            }

            $cleanedLines += $result.ToString()
        }

        $content = $cleanedLines -join "`n"

        # Remove multi-line comments (/* ... */)
        $content = $content -replace '/\*[\s\S]*?\*/', ''

        # Remove trailing commas before closing braces/brackets (common JSONC pattern)
        $content = $content -replace ',(\s*[\]}])', '$1'

        $null = $content | ConvertFrom-Json -ErrorAction Stop

        return @{
            Valid = $true
            Error = $null
        }
    }
    catch {
        return @{
            Valid = $false
            Error = $_.Exception.Message
        }
    }
}

function Test-YamlBasicSyntax {
    <#
    .SYNOPSIS
        Basic YAML syntax validation (checks for common issues).
    #>
    param(
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    if (-not (Test-Path $FilePath)) {
        return @{
            Valid = $false
            Error = "File not found"
        }
    }

    try {
        $content = Get-Content $FilePath -Raw -ErrorAction Stop

        # Check for tabs (YAML should use spaces)
        if ($content -match "`t") {
            return @{
                Valid = $false
                Error = "YAML contains tabs (should use spaces)"
            }
        }

        # Check for basic structure
        if ([string]::IsNullOrWhiteSpace($content)) {
            return @{
                Valid = $false
                Error = "File is empty"
            }
        }

        return @{
            Valid = $true
            Error = $null
        }
    }
    catch {
        return @{
            Valid = $false
            Error = $_.Exception.Message
        }
    }
}

# ============================================================================
# Initialize
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Claude Code Base Validator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Path: $ProjectPath"
Write-Host "Fix Mode: $Fix"
Write-Host ""

$errors = @()
$warnings = @()
$suggestions = @()

# Verify project path exists
if (-not (Test-Path $ProjectPath -PathType Container)) {
    Write-Failure "Project path does not exist: $ProjectPath"
    exit 1
}

# ============================================================================
# Step 1: Check Required Directories
# ============================================================================

Write-Host ""
Write-Host "[1/8] Checking Required Directories..." -ForegroundColor Yellow
Write-Host "--------------------------------------"

$requiredDirs = @(
    ".claude",
    ".claude/commands",
    ".claude/skills",
    ".vscode",
    "docs",
    "PRPs",
    "PRPs/prds",
    "PRPs/plans",
    "PRPs/templates"
)

foreach ($dir in $requiredDirs) {
    $fullPath = Join-Path $ProjectPath $dir
    if (Test-Path $fullPath -PathType Container) {
        if ($ShowDetails) {
            Write-Success "Directory exists: $dir"
        }
    }
    else {
        if ($Fix) {
            try {
                New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
                Write-Info "Created directory: $dir"
            }
            catch {
                $errors += "Failed to create directory: $dir"
                Write-Failure "Cannot create: $dir"
            }
        }
        else {
            $errors += "Missing directory: $dir"
            Write-Failure "Missing: $dir"
        }
    }
}

$dirCount = $requiredDirs.Count
$existingDirs = ($requiredDirs | Where-Object { Test-Path (Join-Path $ProjectPath $_) -PathType Container }).Count
Write-Info "Directories: $existingDirs/$dirCount present"

# ============================================================================
# Step 2: Check Required Files
# ============================================================================

Write-Host ""
Write-Host "[2/8] Checking Required Files..." -ForegroundColor Yellow
Write-Host "---------------------------------"

$requiredFiles = @(
    "CLAUDE.md",
    ".claude/settings.json",
    ".claude/config.yaml",
    ".vscode/settings.json",
    ".vscode/mcp.json",
    ".gitignore",
    ".gitattributes",
    ".pre-commit-config.yaml",
    "README.md",
    "PRPs/README.md"
)

foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $ProjectPath $file
    if (Test-Path $fullPath -PathType Leaf) {
        if ($ShowDetails) {
            Write-Success "File exists: $file"
        }
    }
    else {
        if ($Fix) {
            # Create placeholder for some files
            $createPlaceholder = $false
            $placeholderContent = ""

            switch -Wildcard ($file) {
                "*.md" {
                    $createPlaceholder = $true
                    $fileName = Split-Path $file -Leaf
                    $placeholderContent = "# $($fileName -replace '\.md$', '')`n`n[PLACEHOLDER] - This file needs to be configured.`n"
                }
                ".gitignore" {
                    $createPlaceholder = $true
                    $placeholderContent = "# Claude Code Base .gitignore`n`n# Environment files`n.env`n.env.*`n!.env.example`n`n# Temporary files`ntemp/`n*.tmp`n"
                }
                ".gitattributes" {
                    $createPlaceholder = $true
                    $placeholderContent = "# Auto detect text files and perform LF normalization`n* text=auto`n"
                }
            }

            if ($createPlaceholder) {
                try {
                    $parentDir = Split-Path $fullPath -Parent
                    if (-not (Test-Path $parentDir)) {
                        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
                    }
                    Set-Content -Path $fullPath -Value $placeholderContent -Force
                    Write-Info "Created placeholder: $file"
                }
                catch {
                    $errors += "Failed to create file: $file"
                    Write-Failure "Cannot create: $file"
                }
            }
            else {
                $warnings += "Cannot auto-create: $file (manual creation required)"
                Write-Warning "Cannot auto-create: $file"
            }
        }
        else {
            $errors += "Missing file: $file"
            Write-Failure "Missing: $file"
        }
    }
}

$fileCount = $requiredFiles.Count
$existingFiles = ($requiredFiles | Where-Object { Test-Path (Join-Path $ProjectPath $_) -PathType Leaf }).Count
Write-Info "Files: $existingFiles/$fileCount present"

# ============================================================================
# Step 3: Count Assets
# ============================================================================

Write-Host ""
Write-Host "[3/8] Counting Assets..." -ForegroundColor Yellow
Write-Host "------------------------"

$skillsPath = Join-Path $ProjectPath ".claude/skills"
$commandsPath = Join-Path $ProjectPath ".claude/commands"

$skillCount = 0
$commandCount = 0

if (Test-Path $skillsPath) {
    # Count skill directories (each skill is a folder with SKILL.md)
    $skillDirs = Get-ChildItem $skillsPath -Directory -Recurse -ErrorAction SilentlyContinue |
                 Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }
    $skillCount = ($skillDirs | Measure-Object).Count

    # If no SKILL.md files, count .md files directly
    if ($skillCount -eq 0) {
        $skillCount = (Get-ChildItem $skillsPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
    }
}

if (Test-Path $commandsPath) {
    # Count command files (.md files in commands directory)
    $commandCount = (Get-ChildItem $commandsPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
}

Write-Info "Skills:   $skillCount"
Write-Info "Commands: $commandCount"

if ($skillCount -eq 0) {
    $warnings += "No skills found in .claude/skills/"
}

if ($commandCount -eq 0) {
    $warnings += "No commands found in .claude/commands/"
}

# ============================================================================
# Step 4: Validate JSON Files
# ============================================================================

Write-Host ""
Write-Host "[4/8] Validating JSON Files..." -ForegroundColor Yellow
Write-Host "-------------------------------"

$jsonFiles = @(
    ".claude/settings.json",
    ".vscode/settings.json",
    ".vscode/mcp.json"
)

foreach ($jsonFile in $jsonFiles) {
    $fullPath = Join-Path $ProjectPath $jsonFile
    if (Test-Path $fullPath) {
        $result = Test-JsonFile -FilePath $fullPath
        if ($result.Valid) {
            Write-Success "Valid JSON: $jsonFile"
        }
        else {
            $errors += "Invalid JSON: $jsonFile - $($result.Error)"
            Write-Failure "Invalid JSON: $jsonFile"
            if ($ShowDetails) {
                Write-Host "   Error: $($result.Error)" -ForegroundColor Red
            }
        }
    }
    else {
        if ($ShowDetails) {
            Write-Info "Skipped (not found): $jsonFile"
        }
    }
}

# ============================================================================
# Step 5: Check Pre-commit Configuration
# ============================================================================

Write-Host ""
Write-Host "[5/8] Checking Pre-commit Configuration..." -ForegroundColor Yellow
Write-Host "------------------------------------------"

$precommitPath = Join-Path $ProjectPath ".pre-commit-config.yaml"
if (Test-Path $precommitPath) {
    $content = Get-Content $precommitPath -Raw -ErrorAction SilentlyContinue

    # Check for gitleaks
    if ($content -match "gitleaks") {
        Write-Success "gitleaks hook configured"
    }
    else {
        $warnings += "gitleaks hook not found in pre-commit config"
        Write-Warning "gitleaks hook not found"
        $suggestions += "Add gitleaks hook for secret detection: https://github.com/gitleaks/gitleaks"
    }

    # Check for detect-secrets
    if ($content -match "detect-secrets") {
        Write-Success "detect-secrets hook configured"
    }
    else {
        $warnings += "detect-secrets hook not found in pre-commit config"
        Write-Warning "detect-secrets hook not found"
        $suggestions += "Add detect-secrets hook for additional secret scanning: https://github.com/Yelp/detect-secrets"
    }

    # Basic YAML validation
    $yamlResult = Test-YamlBasicSyntax -FilePath $precommitPath
    if (-not $yamlResult.Valid) {
        $errors += "Invalid YAML in .pre-commit-config.yaml: $($yamlResult.Error)"
        Write-Failure "Invalid YAML: .pre-commit-config.yaml"
    }
}
else {
    Write-Info "Pre-commit config not found (checked in file validation)"
}

# ============================================================================
# Step 6: Validate CLAUDE.md Placeholders
# ============================================================================

Write-Host ""
Write-Host "[6/8] Validating CLAUDE.md Placeholders..." -ForegroundColor Yellow
Write-Host "------------------------------------------"

$claudeMdPath = Join-Path $ProjectPath "CLAUDE.md"
if (Test-Path $claudeMdPath) {
    $content = Get-Content $claudeMdPath -Raw -ErrorAction SilentlyContinue

    # Check for [PLACEHOLDER] values
    $placeholderMatches = [regex]::Matches($content, '\[PLACEHOLDER[^\]]*\]')
    if ($placeholderMatches.Count -gt 0) {
        $warnings += "CLAUDE.md contains $($placeholderMatches.Count) placeholder(s)"
        Write-Warning "Found $($placeholderMatches.Count) placeholder(s) in CLAUDE.md"

        if ($ShowDetails) {
            foreach ($match in $placeholderMatches) {
                Write-Host "   - $($match.Value)" -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Success "No placeholders found in CLAUDE.md"
    }

    # Check for common unconfigured patterns
    $unconfiguredPatterns = @(
        '\[YOUR[^\]]*\]',
        '\[INSERT[^\]]*\]',
        '\[TODO[^\]]*\]',
        '<YOUR[^>]*>',
        '<INSERT[^>]*>',
        'PROJECT_NAME_HERE',
        'CHANGE_ME'
    )

    foreach ($pattern in $unconfiguredPatterns) {
        $matches = [regex]::Matches($content, $pattern)
        if ($matches.Count -gt 0) {
            $warnings += "CLAUDE.md contains unconfigured values matching: $pattern"
            if ($ShowDetails) {
                Write-Warning "Unconfigured pattern: $pattern ($($matches.Count) occurrences)"
            }
        }
    }
}
else {
    Write-Info "CLAUDE.md not found (checked in file validation)"
}

# ============================================================================
# Step 7: Check Archon Project Connection
# ============================================================================

Write-Host ""
Write-Host "[7/8] Checking Archon Project Connection..." -ForegroundColor Yellow
Write-Host "-------------------------------------------"

$configPath = Join-Path $ProjectPath ".claude/config.yaml"
if (Test-Path $configPath) {
    $configContent = Get-Content $configPath -Raw -ErrorAction SilentlyContinue

    # Check for project_id or archon_project_id
    $hasProjectId = $false
    $projectId = $null

    if ($configContent -match '(?:archon_)?project_id:\s*[''"]?([a-f0-9-]{36})[''"]?') {
        $hasProjectId = $true
        $projectId = $matches[1]
        Write-Success "Archon project ID configured: $projectId"
    }
    elseif ($configContent -match '(?:archon_)?project_id:\s*[''"]?([^''\r\n]+)[''"]?') {
        $value = $matches[1].Trim()
        if ($value -and $value -ne "null" -and $value -ne "~" -and $value -notmatch '\[PLACEHOLDER') {
            $hasProjectId = $true
            $projectId = $value
            Write-Success "Archon project ID configured: $projectId"
        }
    }

    if (-not $hasProjectId) {
        $warnings += "Archon project_id not set in .claude/config.yaml"
        Write-Warning "Archon project_id not configured"
        $suggestions += "Configure Archon project: Set project_id in .claude/config.yaml"
    }

    # Check for project_title
    if ($configContent -match 'project_title:\s*[''"]?([^''\r\n]+)[''"]?') {
        $title = $matches[1].Trim()
        if ($title -and $title -ne "null" -and $title -notmatch '\[PLACEHOLDER') {
            Write-Success "Project title configured: $title"
        }
        else {
            $warnings += "Project title not set in .claude/config.yaml"
            Write-Warning "Project title not configured"
        }
    }
}
else {
    Write-Info "Config file not found (checked in file validation)"
}

# ============================================================================
# Step 8: Generate Optimization Suggestions
# ============================================================================

Write-Host ""
Write-Host "[8/8] Generating Optimization Suggestions..." -ForegroundColor Yellow
Write-Host "--------------------------------------------"

# Check MCP configuration for recommended servers
$mcpPath = Join-Path $ProjectPath ".vscode/mcp.json"
if (Test-Path $mcpPath) {
    $mcpContent = Get-Content $mcpPath -Raw -ErrorAction SilentlyContinue

    $recommendedMcpServers = @(
        @{ Name = "archon"; Description = "Task and project management" },
        @{ Name = "brave-search"; Description = "Web search capabilities" },
        @{ Name = "filesystem"; Description = "File system operations" },
        @{ Name = "github"; Description = "GitHub integration" }
    )

    foreach ($server in $recommendedMcpServers) {
        if ($mcpContent -notmatch $server.Name) {
            $suggestions += "Consider adding MCP server: $($server.Name) - $($server.Description)"
        }
    }
}

# Check for common missing patterns
$docsPath = Join-Path $ProjectPath "docs"
if (Test-Path $docsPath) {
    $recommendedDocs = @(
        "architecture.md",
        "deployment.md",
        "contributing.md"
    )

    foreach ($doc in $recommendedDocs) {
        $docPath = Join-Path $docsPath $doc
        if (-not (Test-Path $docPath)) {
            $suggestions += "Consider adding documentation: docs/$doc"
        }
    }
}

# Check for .env.example
$envExamplePath = Join-Path $ProjectPath ".env.example"
if (-not (Test-Path $envExamplePath)) {
    $suggestions += "Consider adding .env.example for environment variable documentation"
}

# Check for LICENSE
$licensePath = Join-Path $ProjectPath "LICENSE"
if (-not (Test-Path $licensePath)) {
    $suggestions += "Consider adding a LICENSE file"
}

# Output suggestions
if ($suggestions.Count -eq 0) {
    Write-Success "No optimization suggestions"
}
else {
    Write-Info "$($suggestions.Count) optimization suggestion(s):"
    foreach ($suggestion in $suggestions) {
        Write-Host "   - $suggestion" -ForegroundColor Cyan
    }
}

# ============================================================================
# Summary
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Validation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Assets Found:" -ForegroundColor White
Write-Host "   Skills:   $skillCount"
Write-Host "   Commands: $commandCount"
Write-Host ""

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Success "All validation checks passed!"
    Write-Host ""
    exit 0
}

if ($warnings.Count -gt 0) {
    Write-Host "Warnings ($($warnings.Count)):" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "   - $warning" -ForegroundColor Yellow
    }
    Write-Host ""
}

if ($errors.Count -gt 0) {
    Write-Host "Errors ($($errors.Count)):" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "   - $err" -ForegroundColor Red
    }
    Write-Host ""
    Write-Failure "Validation FAILED with $($errors.Count) error(s)"
    Write-Host ""

    if (-not $Fix) {
        Write-Host "Tip: Run with -Fix to attempt automatic fixes" -ForegroundColor Cyan
    }

    exit 1
}

Write-Warning "Validation completed with $($warnings.Count) warning(s)"
Write-Host ""
exit 2
