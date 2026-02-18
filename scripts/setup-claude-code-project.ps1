<#
.SYNOPSIS
    Interactive wizard for setting up a new project from claude-code-base template.

.DESCRIPTION
    This script provides an interactive wizard that guides users through creating
    a new project with:
    - Project folder creation with selective file copying
    - Language and framework selection
    - Only relevant skills and commands copied based on project type
    - Git initialization with pre-commit hooks
    - GitHub repository creation with branch protection and secret scanning
    - Archon project creation for task/document management
    - Placeholder replacement in CLAUDE.md and config.yaml
    - Project-specific README generation

.PARAMETER NonInteractive
    Run in non-interactive mode using provided parameters.

.PARAMETER ParentPath
    Parent directory where the project folder will be created.

.PARAMETER ProjectName
    Name of the project (lowercase with hyphens).

.PARAMETER Description
    Brief description of the project.

.PARAMETER ProjectType
    Type of project (web-frontend, backend-api, fullstack, cli-library, infrastructure, power-platform).

.PARAMETER PrimaryLanguage
    Primary programming language (typescript, python, csharp, go, java, rust, javascript).

.PARAMETER Framework
    Framework to use (react, nextjs, fastapi, express, etc.).

.PARAMETER DevFrameworks
    Development frameworks to include (prp, harness, speckit, spark, worktree).

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
    .\setup-claude-code-project.ps1 -NonInteractive -ParentPath "E:\Repos" -ProjectName "my-api" -PrimaryLanguage "python" -Framework "fastapi" -GitHubOrg "MyOrg"

.EXAMPLE
    .\setup-claude-code-project.ps1 -SkipArchon -SkipGitHub

.NOTES
    Author: Claude Code Base
    Version: 2.0.0
#>

[CmdletBinding()]
param(
    [switch]$NonInteractive,
    [string]$ParentPath,
    [string]$ProjectName,
    [string]$Description = "",
    [ValidateSet("web-frontend", "backend-api", "fullstack", "cli-library", "infrastructure", "power-platform")]
    [string]$ProjectType = "backend-api",
    [string]$PrimaryLanguage,
    [string]$Framework,
    [string[]]$DevFrameworks = @(),
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

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Banner {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "         Claude Code Base - Project Wizard v2.0                       " -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Create a new project with Claude Code best practices," -ForegroundColor Gray
    Write-Host "  selective skills/commands, and Archon integration." -ForegroundColor Gray
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

function Get-ManifestConfig {
    $manifestPath = Join-Path $TemplatePath "templates\manifest.json"
    if (-not (Test-Path $manifestPath)) {
        Write-Status "Manifest not found at: $manifestPath" "ERROR"
        exit 1
    }
    $content = Get-Content $manifestPath -Raw
    return $content | ConvertFrom-Json
}

function Get-SelectedSkills {
    param(
        [object]$Manifest,
        [string]$ProjectType,
        [string]$Language,
        [string]$Framework,
        [string[]]$DevFrameworks
    )

    $selectedSkills = @()

    # 1. Add skills from project type mapping
    $skillGroups = @()
    $mapping = $Manifest.projectTypeMapping
    if ($mapping.PSObject.Properties.Name -contains $ProjectType) {
        $groups = $mapping.$ProjectType
        foreach ($group in $groups) {
            $skillGroups += $group
            if ($Manifest.skills.PSObject.Properties.Name -contains $group) {
                $selectedSkills += @($Manifest.skills.$group)
            }
        }
    }

    # 2. Add language-specific skills
    if ($Language -and $Manifest.languages.PSObject.Properties.Name -contains $Language) {
        $langConfig = $Manifest.languages.$Language
        if ($langConfig.skills) {
            $selectedSkills += @($langConfig.skills)
        }
    }

    # 3. Add framework-specific skills
    if ($Framework -and $Manifest.frameworkSkills.PSObject.Properties.Name -contains $Framework) {
        $selectedSkills += @($Manifest.frameworkSkills.$Framework)
    }

    # 4. Add dev framework skills
    foreach ($df in $DevFrameworks) {
        $groupName = "framework_$df"
        if ($Manifest.skills.PSObject.Properties.Name -contains $groupName) {
            $selectedSkills += @($Manifest.skills.$groupName)
            $skillGroups += $groupName
        }
    }

    # Deduplicate
    $selectedSkills = $selectedSkills | Select-Object -Unique

    return @{
        Skills = $selectedSkills
        Groups = ($skillGroups | Select-Object -Unique)
    }
}

function Get-SelectedCommands {
    param(
        [object]$Manifest,
        [string[]]$DevFrameworks
    )

    $selectedCommands = @()
    $commandGroups = @("core")

    # 1. Start with core commands
    if ($Manifest.commands.PSObject.Properties.Name -contains "core") {
        $selectedCommands += @($Manifest.commands.core)
    }

    # 2. Add dev framework commands
    foreach ($df in $DevFrameworks) {
        if ($Manifest.commands.PSObject.Properties.Name -contains $df) {
            $selectedCommands += @($Manifest.commands.$df)
            $commandGroups += $df
        }
    }

    # Deduplicate
    $selectedCommands = $selectedCommands | Select-Object -Unique

    return @{
        Commands = $selectedCommands
        Groups = ($commandGroups | Select-Object -Unique)
    }
}

function Copy-ProjectFiles {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [string[]]$SkillNames,
        [string[]]$CommandFiles,
        [string]$ProjectType,
        [string]$Language,
        [string[]]$DevFrameworks,
        [object]$Manifest
    )

    $stats = @{
        Copied = 0
        Skipped = 0
        Directories = 0
    }

    # Ensure destination exists
    if (-not (Test-Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    }

    # --- 1. Create directory structure ---
    $directories = @(
        ".claude\skills",
        ".claude\commands",
        ".claude\context",
        ".claude\hooks",
        ".vscode",
        ".github\workflows",
        "src",
        "tests",
        "docs",
        "scripts",
        "temp"
    )

    foreach ($dir in $directories) {
        $fullDir = Join-Path $DestinationPath $dir
        if (-not (Test-Path $fullDir)) {
            New-Item -ItemType Directory -Path $fullDir -Force | Out-Null
            $stats.Directories++
        }
    }

    # --- 2. Copy core .claude config files ---
    $claudeFiles = @(
        "config.yaml",
        "SESSION_KNOWLEDGE.md",
        "DEVELOPMENT_LOG.md",
        "FAILED_ATTEMPTS.md",
        "settings.json"
    )

    foreach ($file in $claudeFiles) {
        $src = Join-Path $SourcePath ".claude\$file"
        $dst = Join-Path $DestinationPath ".claude\$file"
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination $dst -Force
            $stats.Copied++
        }
    }

    # Copy .claude/hooks/ directory
    $hooksSource = Join-Path $SourcePath ".claude\hooks"
    if (Test-Path $hooksSource) {
        $hookFiles = Get-ChildItem -Path $hooksSource -File -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $hookFiles) {
            $relativePath = $file.FullName.Substring($hooksSource.Length).TrimStart('\')
            $dst = Join-Path $DestinationPath ".claude\hooks\$relativePath"
            $parentDir = Split-Path $dst -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            Copy-Item -Path $file.FullName -Destination $dst -Force
            $stats.Copied++
        }
    }

    # Copy .claude/context/ directory
    $contextSource = Join-Path $SourcePath ".claude\context"
    if (Test-Path $contextSource) {
        $contextFiles = Get-ChildItem -Path $contextSource -File -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $contextFiles) {
            $relativePath = $file.FullName.Substring($contextSource.Length).TrimStart('\')
            $dst = Join-Path $DestinationPath ".claude\context\$relativePath"
            $parentDir = Split-Path $dst -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            Copy-Item -Path $file.FullName -Destination $dst -Force
            $stats.Copied++
        }
    }

    # --- 3. Copy .vscode files ---
    $vscodeFiles = @("settings.json", "extensions.json")
    foreach ($file in $vscodeFiles) {
        $src = Join-Path $SourcePath ".vscode\$file"
        $dst = Join-Path $DestinationPath ".vscode\$file"
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination $dst -Force
            $stats.Copied++
        }
    }

    # --- 4. Copy root files ---
    $rootFiles = @(
        ".gitattributes",
        ".pre-commit-config.yaml",
        "CONTRIBUTING.md",
        "SECURITY.md",
        "CODEOWNERS",
        "LICENSE"
    )

    foreach ($file in $rootFiles) {
        $src = Join-Path $SourcePath $file
        $dst = Join-Path $DestinationPath $file
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination $dst -Force
            $stats.Copied++
        }
    }

    # --- 5. Copy .github/ directory ---
    $githubSource = Join-Path $SourcePath ".github"
    if (Test-Path $githubSource) {
        $githubFiles = Get-ChildItem -Path $githubSource -File -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $githubFiles) {
            $relativePath = $file.FullName.Substring($githubSource.Length).TrimStart('\')
            $dst = Join-Path $DestinationPath ".github\$relativePath"
            $parentDir = Split-Path $dst -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            Copy-Item -Path $file.FullName -Destination $dst -Force
            $stats.Copied++
        }
    }

    # --- 6. Build .gitignore ---
    $baseGitignore = Join-Path $SourcePath ".gitignore"
    $gitignoreContent = ""
    if (Test-Path $baseGitignore) {
        $gitignoreContent = Get-Content $baseGitignore -Raw
    }

    # Add language-specific gitignore
    if ($Language -and $Manifest.languages.PSObject.Properties.Name -contains $Language) {
        $langGitignore = $Manifest.languages.$Language.gitignore
        if ($langGitignore) {
            $langGitignorePath = Join-Path $SourcePath $langGitignore
            if (Test-Path $langGitignorePath) {
                $gitignoreContent += "`n`n# Language-specific ($Language)`n"
                $gitignoreContent += Get-Content $langGitignorePath -Raw
            }
        }
    }

    Set-Content -Path (Join-Path $DestinationPath ".gitignore") -Value $gitignoreContent -NoNewline
    $stats.Copied++

    # --- 7. Copy selected skills ---
    $skillsSource = Join-Path $SourcePath ".claude\skills"
    foreach ($skillName in $SkillNames) {
        $srcSkill = Join-Path $skillsSource $skillName
        if (Test-Path $srcSkill -PathType Container) {
            $dstSkill = Join-Path $DestinationPath ".claude\skills\$skillName"
            if (-not (Test-Path $dstSkill)) {
                New-Item -ItemType Directory -Path $dstSkill -Force | Out-Null
                $stats.Directories++
            }
            $skillFiles = Get-ChildItem -Path $srcSkill -File -Recurse -ErrorAction SilentlyContinue
            foreach ($file in $skillFiles) {
                $relativePath = $file.FullName.Substring($srcSkill.Length).TrimStart('\')
                $dst = Join-Path $dstSkill $relativePath
                $parentDir = Split-Path $dst -Parent
                if (-not (Test-Path $parentDir)) {
                    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
                }
                Copy-Item -Path $file.FullName -Destination $dst -Force
                $stats.Copied++
            }
        }
    }

    # Copy skills README
    $skillsReadme = Join-Path $skillsSource "README.md"
    if (Test-Path $skillsReadme) {
        Copy-Item -Path $skillsReadme -Destination (Join-Path $DestinationPath ".claude\skills\README.md") -Force
        $stats.Copied++
    }

    # --- 8. Copy selected commands ---
    $commandsSource = Join-Path $SourcePath ".claude\commands"
    foreach ($cmdFile in $CommandFiles) {
        $src = Join-Path $commandsSource $cmdFile
        $dst = Join-Path $DestinationPath ".claude\commands\$cmdFile"
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination $dst -Force
            $stats.Copied++
        }
    }

    # Copy commands README
    $commandsReadme = Join-Path $commandsSource "README.md"
    if (Test-Path $commandsReadme) {
        Copy-Item -Path $commandsReadme -Destination (Join-Path $DestinationPath ".claude\commands\README.md") -Force
        $stats.Copied++
    }

    # --- 9. Generate README from template ---
    $readmeTemplate = Join-Path $SourcePath "templates\readme\$ProjectType.md"
    if (Test-Path $readmeTemplate) {
        Copy-Item -Path $readmeTemplate -Destination (Join-Path $DestinationPath "README.md") -Force
        $stats.Copied++
    }

    # --- 10. Generate CLAUDE.md from template ---
    $claudeMdTemplate = Join-Path $SourcePath "templates\claude-md\CLAUDE.md.template"
    if (Test-Path $claudeMdTemplate) {
        $claudeMdContent = Get-Content $claudeMdTemplate -Raw

        # Process conditional sections
        $devFrameworkNames = $DevFrameworks

        # PRP section
        if ($devFrameworkNames -contains "prp") {
            $claudeMdContent = $claudeMdContent -replace '<!-- IF PRP -->', ''
            $claudeMdContent = $claudeMdContent -replace '<!-- ENDIF PRP -->', ''
        }
        else {
            $claudeMdContent = $claudeMdContent -replace '(?s)<!-- IF PRP -->.*?<!-- ENDIF PRP -->', ''
        }

        # HARNESS section
        if ($devFrameworkNames -contains "harness") {
            $claudeMdContent = $claudeMdContent -replace '<!-- IF HARNESS -->', ''
            $claudeMdContent = $claudeMdContent -replace '<!-- ENDIF HARNESS -->', ''
        }
        else {
            $claudeMdContent = $claudeMdContent -replace '(?s)<!-- IF HARNESS -->.*?<!-- ENDIF HARNESS -->', ''
        }

        # SPECKIT section
        if ($devFrameworkNames -contains "speckit") {
            $claudeMdContent = $claudeMdContent -replace '<!-- IF SPECKIT -->', ''
            $claudeMdContent = $claudeMdContent -replace '<!-- ENDIF SPECKIT -->', ''
        }
        else {
            $claudeMdContent = $claudeMdContent -replace '(?s)<!-- IF SPECKIT -->.*?<!-- ENDIF SPECKIT -->', ''
        }

        # Clean up multiple blank lines
        $claudeMdContent = $claudeMdContent -replace '(\r?\n){4,}', "`n`n"

        Set-Content -Path (Join-Path $DestinationPath "CLAUDE.md") -Value $claudeMdContent -NoNewline
        $stats.Copied++
    }
    else {
        # Fallback: copy existing CLAUDE.md
        $fallbackClaude = Join-Path $SourcePath "CLAUDE.md"
        if (Test-Path $fallbackClaude) {
            Copy-Item -Path $fallbackClaude -Destination (Join-Path $DestinationPath "CLAUDE.md") -Force
            $stats.Copied++
        }
    }

    # --- 11. Copy PRPs/ only if PRP framework selected ---
    if ($devFrameworkNames -contains "prp") {
        $prpsSource = Join-Path $SourcePath "PRPs"
        if (Test-Path $prpsSource) {
            $prpsDest = Join-Path $DestinationPath "PRPs"
            if (-not (Test-Path $prpsDest)) {
                New-Item -ItemType Directory -Path $prpsDest -Force | Out-Null
                $stats.Directories++
            }
            $prpFiles = Get-ChildItem -Path $prpsSource -File -Recurse -ErrorAction SilentlyContinue
            foreach ($file in $prpFiles) {
                $relativePath = $file.FullName.Substring($prpsSource.Length).TrimStart('\')
                $dst = Join-Path $prpsDest $relativePath
                $parentDir = Split-Path $dst -Parent
                if (-not (Test-Path $parentDir)) {
                    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
                }
                Copy-Item -Path $file.FullName -Destination $dst -Force
                $stats.Copied++
            }
        }
    }

    # --- 12. Copy scripts ---
    $scriptFiles = @(
        "sync-claude-code.ps1",
        "validate-claude-code.ps1",
        "update-project.ps1"
    )

    foreach ($file in $scriptFiles) {
        $src = Join-Path $SourcePath "scripts\$file"
        $dst = Join-Path $DestinationPath "scripts\$file"
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination $dst -Force
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
        [string]$CurrentDate,
        [string]$PrimaryLanguage,
        [string]$Framework,
        [string]$Description,
        [string]$GitHubOrg
    )

    $primaryStack = if ($Framework) { "$PrimaryLanguage, $Framework" } else { $PrimaryLanguage }

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
        "[PRIMARY_STACK]"     = $primaryStack
        "[PRIMARY_LANGUAGE]"  = $PrimaryLanguage
        "[PRIMARY_STRUCTURE]" = "src/"
    }

    # README template placeholders (double curly braces)
    $readmePlaceholders = @{
        "{{PROJECT_NAME}}"        = $ProjectName
        "{{PROJECT_DESCRIPTION}}" = if ($Description) { $Description } else { "A new project created from claude-code-base" }
        "{{ORG}}"                 = if ($GitHubOrg) { $GitHubOrg } else { "MyOrg" }
        "{{LANGUAGE}}"            = $PrimaryLanguage
        "{{FRAMEWORK}}"           = if ($Framework) { $Framework } else { "none" }
    }

    # Files to process for placeholder replacement
    $filesToProcess = @(
        "CLAUDE.md",
        ".claude\config.yaml",
        ".claude\SESSION_KNOWLEDGE.md",
        ".claude\DEVELOPMENT_LOG.md",
        "README.md",
        "CODEOWNERS"
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

                foreach ($key in $readmePlaceholders.Keys) {
                    $content = $content.Replace($key, $readmePlaceholders[$key])
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

function Write-TemplateProfile {
    param(
        [string]$ProjectPath,
        [string]$ProjectType,
        [string]$Language,
        [string]$Framework,
        [string[]]$SkillGroups,
        [string[]]$CommandGroups,
        [string[]]$DevFrameworks
    )

    $configPath = Join-Path $ProjectPath ".claude\config.yaml"
    if (-not (Test-Path $configPath)) {
        return
    }

    $skillGroupsStr = ($SkillGroups | ForEach-Object { "`"$_`"" }) -join ", "
    $commandGroupsStr = ($CommandGroups | ForEach-Object { "`"$_`"" }) -join ", "
    $devFrameworksStr = if ($DevFrameworks.Count -gt 0) {
        ($DevFrameworks | ForEach-Object { "`"$_`"" }) -join ", "
    } else { "" }

    $profileYaml = @"

template_profile:
  template_version: "2.0.0"
  project_type: "$ProjectType"
  primary_language: "$Language"
  framework: "$Framework"
  skill_groups: [$skillGroupsStr]
  command_groups: [$commandGroupsStr]
  dev_frameworks: [$devFrameworksStr]
  created_with: "setup-claude-code-project.ps1"
"@

    Add-Content -Path $configPath -Value $profileYaml
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

# ============================================================================
# Main Script
# ============================================================================

Write-Banner

# Load manifest
$Manifest = Get-ManifestConfig

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
    Write-Host "    6. power-platform  - Power Apps, Automate, Dataverse, PCF" -ForegroundColor Gray
    Write-Host ""
    $ProjectType = Get-UserInput -Prompt "Project type" -Default "backend-api" -ValidOptions @("web-frontend", "backend-api", "fullstack", "cli-library", "infrastructure", "power-platform")

    # --- Language selection ---
    Write-Host ""
    Write-Host "  Primary language:" -ForegroundColor Gray
    if ($Manifest.languageOptions.PSObject.Properties.Name -contains $ProjectType) {
        $langOptions = $Manifest.languageOptions.$ProjectType
        $validLangs = @()
        $idx = 1
        foreach ($opt in $langOptions) {
            Write-Host "    $idx. $($opt.label)" -ForegroundColor Gray
            Write-Host "       $($opt.description)" -ForegroundColor DarkGray
            $validLangs += $opt.value
            $idx++
        }
        $validLangs += "other"
        Write-Host "    $idx. Other (specify)" -ForegroundColor Gray
    }
    else {
        $validLangs = @("typescript", "python", "csharp", "go", "java", "rust", "javascript", "other")
        foreach ($lang in $validLangs) {
            Write-Host "    - $lang" -ForegroundColor Gray
        }
    }
    Write-Host ""

    $defaultLang = switch ($ProjectType) {
        "web-frontend"    { "typescript" }
        "fullstack"       { "typescript" }
        "infrastructure"  { "python" }
        "power-platform"  { "typescript" }
        default           { "typescript" }
    }

    $PrimaryLanguage = Get-UserInput -Prompt "Primary language" -Default $defaultLang -ValidOptions $validLangs
    if ($PrimaryLanguage -eq "other") {
        $PrimaryLanguage = Get-UserInput -Prompt "Enter language name" -Required
    }

    # --- Framework selection ---
    $frameworkOptions = @()
    if ($Manifest.languages.PSObject.Properties.Name -contains $PrimaryLanguage) {
        $langConfig = $Manifest.languages.$PrimaryLanguage
        if ($langConfig.frameworks -and $langConfig.frameworks.PSObject.Properties.Name -contains $ProjectType) {
            $frameworkOptions = @($langConfig.frameworks.$ProjectType)
        }
    }

    if ($frameworkOptions.Count -gt 0) {
        Write-Host ""
        Write-Host "  Framework options:" -ForegroundColor Gray
        $validFrameworks = @()
        $idx = 1
        foreach ($opt in $frameworkOptions) {
            Write-Host "    $idx. $($opt.label)" -ForegroundColor Gray
            $validFrameworks += $opt.value
            $idx++
        }
        $validFrameworks += @("none", "other")
        Write-Host "    $idx. None" -ForegroundColor Gray
        Write-Host "    $($idx + 1). Other (specify)" -ForegroundColor Gray
        Write-Host ""

        $defaultFramework = if ($frameworkOptions.Count -gt 0) { $frameworkOptions[0].value } else { "none" }
        $Framework = Get-UserInput -Prompt "Framework" -Default $defaultFramework -ValidOptions $validFrameworks
        if ($Framework -eq "other") {
            $Framework = Get-UserInput -Prompt "Enter framework name" -Required
        }
        if ($Framework -eq "none") {
            $Framework = ""
        }
    }
    else {
        $Framework = ""
    }

    # --- Development framework selection ---
    Write-Host ""
    Write-Host "  Optional development frameworks:" -ForegroundColor Gray
    Write-Host "    1. prp      - Product Requirement Planning (PRD -> Plan -> Implement)" -ForegroundColor Gray
    Write-Host "    2. harness  - Autonomous Agent pipeline for greenfield projects" -ForegroundColor Gray
    Write-Host "    3. speckit  - Specification-driven with verification checklists" -ForegroundColor Gray
    Write-Host "    4. spark    - Quick prototyping and teaching" -ForegroundColor Gray
    Write-Host "    5. worktree - Git worktree-based parallel experiments" -ForegroundColor Gray
    Write-Host ""
    $dfChoice = Get-UserInput -Prompt "Include frameworks (comma-separated numbers or names, or 'none')" -Default "none"

    if ($dfChoice -ne "none" -and $dfChoice -ne "") {
        $dfMap = @{ "1" = "prp"; "2" = "harness"; "3" = "speckit"; "4" = "spark"; "5" = "worktree" }
        $DevFrameworks = @()
        foreach ($item in ($dfChoice -split ',')) {
            $item = $item.Trim()
            if ($dfMap.ContainsKey($item)) {
                $DevFrameworks += $dfMap[$item]
            }
            elseif ($item -in @("prp", "harness", "speckit", "spark", "worktree")) {
                $DevFrameworks += $item
            }
        }
    }

    # --- GitHub configuration ---
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

# Defaults for non-interactive mode
if (-not $PrimaryLanguage) { $PrimaryLanguage = "typescript" }

$ProjectPath = Join-Path $ParentPath $ProjectName
$ProjectTitle = ($ProjectName -replace '-', ' ').ToUpper().Substring(0, 1) + ($ProjectName -replace '-', ' ').Substring(1)
$GitHubRepo = if (-not $SkipGitHub -and $GitHubOrg) { "https://github.com/$GitHubOrg/$ProjectName" } else { "" }
$CurrentDate = Get-Date -Format "yyyy-MM-dd"

# Generate a placeholder Archon project ID
$ArchonProjectId = if ($SkipArchon) { "NOT_CONFIGURED" } else { [guid]::NewGuid().ToString() }

# Calculate selected skills and commands
$skillResult = Get-SelectedSkills -Manifest $Manifest -ProjectType $ProjectType -Language $PrimaryLanguage -Framework $Framework -DevFrameworks $DevFrameworks
$commandResult = Get-SelectedCommands -Manifest $Manifest -DevFrameworks $DevFrameworks

$selectedSkills = $skillResult.Skills
$skillGroups = $skillResult.Groups
$selectedCommands = $commandResult.Commands
$commandGroups = $commandResult.Groups

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
Write-Host "  Language:       $PrimaryLanguage" -ForegroundColor White
Write-Host "  Framework:      $(if ($Framework) { $Framework } else { '(none)' })" -ForegroundColor White
if ($DevFrameworks.Count -gt 0) {
    Write-Host "  Dev Frameworks: $($DevFrameworks -join ', ')" -ForegroundColor White
}
else {
    Write-Host "  Dev Frameworks: (none)" -ForegroundColor Gray
}
Write-Host "  Skills:         $($selectedSkills.Count) selected" -ForegroundColor White
Write-Host "  Commands:       $($selectedCommands.Count) selected" -ForegroundColor White
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

Write-Step 4 "Copying Project Files (Selective)"

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

Write-Status "Copying selected project files..." "WORKING"
$stats = Copy-ProjectFiles -SourcePath $TemplatePath -DestinationPath $ProjectPath `
    -SkillNames $selectedSkills -CommandFiles $selectedCommands `
    -ProjectType $ProjectType -Language $PrimaryLanguage -DevFrameworks $DevFrameworks `
    -Manifest $Manifest

Write-Status "Files: $($stats.Copied) copied, $($stats.Directories) dirs created" "SUCCESS"
Write-Status "Skills: $($selectedSkills.Count) copied (from groups: $($skillGroups -join ', '))" "SUCCESS"
Write-Status "Commands: $($selectedCommands.Count) copied (from groups: $($commandGroups -join ', '))" "SUCCESS"

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

Write-Step 7 "Replacing Placeholders & Writing Profile"

Write-Status "Replacing placeholders in configuration files..." "WORKING"
$replacedCount = Replace-Placeholders -ProjectPath $ProjectPath `
    -ProjectName $ProjectName `
    -ProjectTitle $ProjectTitle `
    -GitHubRepo $GitHubRepo `
    -ArchonProjectId $ArchonProjectId `
    -CurrentDate $CurrentDate `
    -PrimaryLanguage $PrimaryLanguage `
    -Framework $Framework `
    -Description $Description `
    -GitHubOrg $GitHubOrg

Write-Status "Updated $replacedCount configuration files" "SUCCESS"

Write-Status "Writing template_profile to config.yaml..." "WORKING"
Write-TemplateProfile -ProjectPath $ProjectPath `
    -ProjectType $ProjectType `
    -Language $PrimaryLanguage `
    -Framework $Framework `
    -SkillGroups $skillGroups `
    -CommandGroups $commandGroups `
    -DevFrameworks $DevFrameworks

Write-Status "Template profile written" "SUCCESS"

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
Write-Host "Language:      $PrimaryLanguage" -ForegroundColor Cyan
if ($Framework) {
    Write-Host "Framework:     $Framework" -ForegroundColor Cyan
}
Write-Host ""

Write-Host "What's configured:" -ForegroundColor Green
Write-Host "   [OK] Skills:   $($selectedSkills.Count) (groups: $($skillGroups -join ', '))" -ForegroundColor White
Write-Host "   [OK] Commands:  $($selectedCommands.Count) (groups: $($commandGroups -join ', '))" -ForegroundColor White
Write-Host "   [OK] Project-specific README.md" -ForegroundColor White
Write-Host "   [OK] CLAUDE.md with relevant sections" -ForegroundColor White
Write-Host "   [OK] Pre-configured .gitignore ($PrimaryLanguage)" -ForegroundColor White
Write-Host "   [OK] Pre-commit hooks with secret detection" -ForegroundColor White
Write-Host "   [OK] .claude/config.yaml with template_profile" -ForegroundColor White
Write-Host "   [OK] VS Code settings with MCP configuration" -ForegroundColor White
if ($DevFrameworks.Count -gt 0) {
    Write-Host "   [OK] Dev frameworks: $($DevFrameworks -join ', ')" -ForegroundColor White
}
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
