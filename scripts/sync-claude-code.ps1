<#
.SYNOPSIS
    Intelligent wizard-based sync for existing projects from claude-code-base template.

.DESCRIPTION
    This script performs an additive-only, intelligent sync of Claude Code configuration
    from the template repository to an existing project. Key behaviors:
    - NEVER overwrites CLAUDE.md or README.md
    - Only adds missing sections/placeholders to CLAUDE.md (wizard-prompted)
    - Only installs skills/commands relevant to the detected project type
    - Skips skills already covered by global Claude Code plugins or global skills
    - Runs as an interactive wizard for decisions and ambiguous inputs
    - Supports DryRun for previewing changes without modification

.PARAMETER TargetPath
    Path to the target codebase to sync Claude Code files to.

.PARAMETER ProjectType
    Type of project: web-frontend, backend-api, fullstack, cli-library, infrastructure, power-platform.

.PARAMETER PrimaryLanguage
    Primary language: typescript, python, csharp, go, java, rust, javascript.

.PARAMETER Framework
    Framework to use: react, nextjs, fastapi, express, etc.

.PARAMETER DevFrameworks
    Development frameworks to include: prp, harness, speckit, spark, worktree.

.PARAMETER AdditionalSkillGroups
    Extra skill groups to install: ai_ml, smart_home_iot, niche, cloud_infra.

.PARAMETER DryRun
    Preview what would be synced without making any changes.

.PARAMETER Force
    Suppress confirmation prompts (still requires params or existing profile).

.PARAMETER NoBackup
    Skip creating backups of existing files (not recommended).

.EXAMPLE
    .\sync-claude-code.ps1 -TargetPath "E:\Repos\MyOrg\my-project"

.EXAMPLE
    .\sync-claude-code.ps1 -TargetPath "E:\Repos\MyOrg\my-project" -DryRun

.EXAMPLE
    .\sync-claude-code.ps1 -TargetPath "E:\Repos\MyOrg\my-project" -ProjectType "backend-api" -PrimaryLanguage "python" -Framework "fastapi" -Force

.NOTES
    Author: Claude Code Base
    Version: 3.0.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TargetPath,

    [ValidateSet("web-frontend", "backend-api", "fullstack", "cli-library", "infrastructure", "power-platform")]
    [string]$ProjectType,

    [string]$PrimaryLanguage,

    [string]$Framework,

    [string[]]$DevFrameworks = @(),

    [string[]]$AdditionalSkillGroups = @(),

    [switch]$DryRun,
    [switch]$Force,
    [switch]$NoBackup
)

# ============================================================================
# Configuration
# ============================================================================

$ErrorActionPreference = "Stop"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplatePath = Split-Path -Parent $ScriptPath
$ScriptVersion = "3.0.0"

# Canonical CLAUDE.md section ordering (used for insertion position)
$CanonicalSectionOrder = @(
    "Critical Rules",
    "Project Reference",
    "Startup Protocol",
    "Archon Integration",
    "PRP Framework",
    "Autonomous Agent Harness",
    "SpecKit Framework",
    "Code Style Guidelines",
    "Documentation Standards",
    "Testing Requirements",
    "Security Guidelines",
    "Git Workflow",
    "End of Session Protocol",
    "Quick Reference",
    "Project Structure"
)

# ============================================================================
# Display Functions
# ============================================================================

function Write-Banner {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "        Claude Code Intelligent Sync Wizard v$ScriptVersion            " -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Additive-only sync: never overwrites CLAUDE.md or README.md." -ForegroundColor Gray
    Write-Host "  Installs only relevant skills, deduplicates against global plugins." -ForegroundColor Gray
    Write-Host ""
}

function Write-Step {
    param([string]$Number, [string]$Title)
    Write-Host ""
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " Step ${Number}: ${Title}" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

function Write-Status {
    param(
        [string]$Message,
        [string]$Status = "INFO"
    )

    $icon = switch ($Status) {
        "SUCCESS"  { "[OK]" }
        "ERROR"    { "[ERR]" }
        "WARNING"  { "[WARN]" }
        "WORKING"  { "[...]" }
        "DRYRUN"   { "[DRY]" }
        "BACKUP"   { "[BAK]" }
        "SKIP"     { "[SKIP]" }
        "NEW"      { "[NEW]" }
        "ADD"      { "[ADD]" }
        "PLUGIN"   { "[PLG]" }
        "GLOBAL"   { "[GLB]" }
        "PARTIAL"  { "[~OK]" }
        "SECTION"  { "[SEC]" }
        "FILL"     { "[FIL]" }
        default    { "[i]" }
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
        "ADD"      { "Green" }
        "PLUGIN"   { "DarkCyan" }
        "GLOBAL"   { "DarkCyan" }
        "PARTIAL"  { "Yellow" }
        "SECTION"  { "Cyan" }
        "FILL"     { "Cyan" }
        default    { "White" }
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

function Get-MultiSelectInput {
    param(
        [string]$Prompt,
        [hashtable[]]$Options,
        [string[]]$PreSelected = @()
    )

    Write-Host ""
    $idx = 1
    foreach ($opt in $Options) {
        $marker = if ($opt.value -in $PreSelected) { "[x]" } else { "[ ]" }
        Write-Host "    $marker $idx. $($opt.label)" -ForegroundColor $(if ($opt.value -in $PreSelected) { "Green" } else { "White" })
        if ($opt.description) {
            Write-Host "        $($opt.description)" -ForegroundColor DarkGray
        }
        $idx++
    }
    Write-Host ""

    $choice = Read-Host "$Prompt (comma-separated numbers, 'all', or 'none')"

    if ($choice -eq "none" -or [string]::IsNullOrWhiteSpace($choice)) {
        return @()
    }
    if ($choice -eq "all") {
        return @($Options | ForEach-Object { $_.value })
    }

    $selected = @()
    foreach ($item in ($choice -split ',')) {
        $item = $item.Trim()
        $num = 0
        if ([int]::TryParse($item, [ref]$num) -and $num -ge 1 -and $num -le $Options.Count) {
            $selected += $Options[$num - 1].value
        }
        elseif ($item -in ($Options | ForEach-Object { $_.value })) {
            $selected += $item
        }
    }

    return $selected
}

# ============================================================================
# Data Loading Functions
# ============================================================================

function Get-ManifestConfig {
    $manifestPath = Join-Path $TemplatePath "templates\manifest.json"
    if (-not (Test-Path $manifestPath)) {
        Write-Status "Manifest not found: $manifestPath" "ERROR"
        return $null
    }
    return (Get-Content $manifestPath -Raw | ConvertFrom-Json)
}

function Get-PluginSkillMap {
    $mapPath = Join-Path $TemplatePath "templates\plugin-skill-map.json"
    if (-not (Test-Path $mapPath)) {
        Write-Status "Plugin-skill map not found: $mapPath" "WARNING"
        return $null
    }
    return (Get-Content $mapPath -Raw | ConvertFrom-Json)
}

function Get-TemplateProfile {
    param([string]$TargetPath)

    $configPath = Join-Path $TargetPath ".claude\config.yaml"
    if (-not (Test-Path $configPath)) { return $null }

    $content = Get-Content $configPath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return $null }
    if ($content -notmatch 'template_profile:') { return $null }

    $profile = @{}

    if ($content -match 'template_version:\s*[''"]?([^''"}\s,\]]+)') {
        $profile.template_version = $Matches[1]
    }
    if ($content -match 'project_type:\s*[''"]?([^''"}\s,\]]+)') {
        $profile.project_type = $Matches[1]
    }
    if ($content -match 'primary_language:\s*[''"]?([^''"}\s,\]]+)') {
        $profile.primary_language = $Matches[1]
    }
    if ($content -match 'framework:\s*[''"]?([^''"}\s,\]]+)') {
        $profile.framework = $Matches[1]
    }
    if ($content -match 'skill_groups:\s*\[([^\]]+)\]') {
        $profile.skill_groups = ($Matches[1] -replace '[''"]', '').Split(',') |
            ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }
    if ($content -match 'command_groups:\s*\[([^\]]+)\]') {
        $profile.command_groups = ($Matches[1] -replace '[''"]', '').Split(',') |
            ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }
    if ($content -match 'dev_frameworks:\s*\[([^\]]*)\]') {
        $rawValue = $Matches[1] -replace '[''"]', ''
        if ($rawValue.Trim()) {
            $profile.dev_frameworks = $rawValue.Split(',') |
                ForEach-Object { $_.Trim() } | Where-Object { $_ }
        }
        else {
            $profile.dev_frameworks = @()
        }
    }

    return $profile
}

function Get-GlobalSettings {
    <#
    .SYNOPSIS
        Reads ~/.claude/settings.json and returns enabled plugins list.
    #>
    $paths = @()
    if ($env:USERPROFILE) { $paths += Join-Path $env:USERPROFILE ".claude\settings.json" }
    if ($env:HOME -and $env:HOME -ne $env:USERPROFILE) { $paths += Join-Path $env:HOME ".claude\settings.json" }

    foreach ($p in $paths) {
        if ($p -and (Test-Path $p -ErrorAction SilentlyContinue)) {
            try {
                $settings = Get-Content $p -Raw | ConvertFrom-Json
                $plugins = @()

                # Check for enabled plugins in various known formats
                if ($settings.PSObject.Properties.Name -contains "plugins") {
                    foreach ($plugin in $settings.plugins) {
                        if ($null -eq $plugin) { continue }
                        if ($plugin -is [string]) {
                            $plugins += $plugin
                        }
                        elseif ($plugin.PSObject.Properties.Name -contains "name") {
                            if (-not ($plugin.PSObject.Properties.Name -contains "enabled") -or $plugin.enabled) {
                                $plugins += $plugin.name
                            }
                        }
                    }
                }

                # Also check enabledPlugins
                if ($settings.PSObject.Properties.Name -contains "enabledPlugins" -and $settings.enabledPlugins) {
                    $plugins += @($settings.enabledPlugins | Where-Object { $_ })
                }

                $plugins = @($plugins | Where-Object { $_ } | Select-Object -Unique)
                return @{
                    Plugins = $plugins
                    Path    = $p
                }
            }
            catch {
                # Silently continue if parse fails
            }
        }
    }

    return @{ Plugins = @(); Path = $null }
}

function Get-GlobalSkills {
    <#
    .SYNOPSIS
        Scans ~/.claude/skills/ for globally installed skills.
    #>
    $paths = @()
    if ($env:USERPROFILE) { $paths += Join-Path $env:USERPROFILE ".claude\skills" }
    if ($env:HOME -and $env:HOME -ne $env:USERPROFILE) { $paths += Join-Path $env:HOME ".claude\skills" }

    $globalSkills = @()
    foreach ($p in $paths) {
        if ($p -and (Test-Path $p -ErrorAction SilentlyContinue)) {
            $dirs = Get-ChildItem -Path $p -Directory -ErrorAction SilentlyContinue
            foreach ($dir in $dirs) {
                if ($dir.Name) { $globalSkills += $dir.Name }
            }
        }
    }

    return @($globalSkills | Where-Object { $_ } | Select-Object -Unique)
}

function Get-ExistingSkills {
    <#
    .SYNOPSIS
        Scans target project's .claude/skills/ for already installed skills.
    #>
    param([string]$TargetPath)

    if (-not $TargetPath) { return @() }
    $skillsDir = Join-Path $TargetPath ".claude\skills"
    if (-not (Test-Path $skillsDir)) { return @() }

    $dirs = Get-ChildItem -Path $skillsDir -Directory -ErrorAction SilentlyContinue
    return @($dirs | ForEach-Object { $_.Name } | Where-Object { $_ })
}

function Get-ExistingCommands {
    <#
    .SYNOPSIS
        Scans target project's .claude/commands/ for already installed commands.
    #>
    param([string]$TargetPath)

    if (-not $TargetPath) { return @() }
    $cmdsDir = Join-Path $TargetPath ".claude\commands"
    if (-not (Test-Path $cmdsDir)) { return @() }

    $files = Get-ChildItem -Path $cmdsDir -File -Filter "*.md" -ErrorAction SilentlyContinue
    return @($files | ForEach-Object { $_.Name } | Where-Object { $_ })
}

# ============================================================================
# Skill/Command Selection Functions (reused from setup script)
# ============================================================================

function Get-SelectedSkills {
    param(
        [object]$Manifest,
        [string]$ProjectType,
        [string]$Language,
        [string]$Framework,
        [string[]]$DevFrameworks,
        [string[]]$AdditionalGroups
    )

    $selectedSkills = @()
    $skillGroups = @()

    # 1. Project type mapping
    if ($Manifest.projectTypeMapping.PSObject.Properties.Name -contains $ProjectType) {
        $groups = $Manifest.projectTypeMapping.$ProjectType
        foreach ($group in $groups) {
            $skillGroups += $group
            if ($Manifest.skills.PSObject.Properties.Name -contains $group) {
                $selectedSkills += @($Manifest.skills.$group)
            }
        }
    }

    # 2. Language-specific skills
    if ($Language -and $Manifest.languages.PSObject.Properties.Name -contains $Language) {
        $langConfig = $Manifest.languages.$Language
        if ($langConfig.skills) {
            $selectedSkills += @($langConfig.skills)
        }
    }

    # 3. Framework-specific skills
    if ($Framework -and $Manifest.frameworkSkills.PSObject.Properties.Name -contains $Framework) {
        $selectedSkills += @($Manifest.frameworkSkills.$Framework)
    }

    # 4. Dev framework skills
    foreach ($df in $DevFrameworks) {
        $groupName = "framework_$df"
        if ($Manifest.skills.PSObject.Properties.Name -contains $groupName) {
            $selectedSkills += @($Manifest.skills.$groupName)
            $skillGroups += $groupName
        }
    }

    # 5. Additional skill groups
    foreach ($ag in $AdditionalGroups) {
        if ($Manifest.skills.PSObject.Properties.Name -contains $ag) {
            $selectedSkills += @($Manifest.skills.$ag)
            $skillGroups += $ag
        }
    }

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

    if ($Manifest.commands.PSObject.Properties.Name -contains "core") {
        $selectedCommands += @($Manifest.commands.core)
    }

    foreach ($df in $DevFrameworks) {
        if ($Manifest.commands.PSObject.Properties.Name -contains $df) {
            $selectedCommands += @($Manifest.commands.$df)
            $commandGroups += $df
        }
    }

    $selectedCommands = $selectedCommands | Select-Object -Unique

    return @{
        Commands = $selectedCommands
        Groups   = ($commandGroups | Select-Object -Unique)
    }
}

# ============================================================================
# Plugin Deduplication Functions
# ============================================================================

function Get-PluginCoveredSkills {
    <#
    .SYNOPSIS
        Maps enabled plugins to the local skills they cover.
    .OUTPUTS
        Hashtable: skill_name -> @{ CoveredBy = "plugin-name"; Partial = $true/$false; Note = "..." }
    #>
    param(
        [string[]]$EnabledPlugins,
        $PluginSkillMap
    )

    $covered = @{}

    if (-not $PluginSkillMap -or -not $PluginSkillMap.plugins) {
        return $covered
    }

    foreach ($pluginName in $EnabledPlugins) {
        if ($PluginSkillMap.plugins.PSObject.Properties.Name -contains $pluginName) {
            $pluginDef = $PluginSkillMap.plugins.$pluginName
            foreach ($cover in $pluginDef.covers) {
                $covered[$cover.skill] = @{
                    CoveredBy = $pluginName
                    Label     = $pluginDef.label
                    Partial   = [bool]$cover.partial
                    Note      = $cover.note
                }
            }
        }
    }

    return $covered
}

function Get-SkillDisposition {
    <#
    .SYNOPSIS
        Categorizes each candidate skill into: install, skip-plugin, partial-plugin, skip-global, skip-exists.
    #>
    param(
        [string[]]$CandidateSkills,
        [string[]]$ExistingSkills,
        [string[]]$GlobalSkills,
        [hashtable]$PluginCovered
    )

    $result = @{
        ToInstall    = @()
        SkipPlugin   = @()
        PartialPlugin = @()
        SkipGlobal   = @()
        SkipExists   = @()
    }

    foreach ($skill in $CandidateSkills) {
        if ($skill -in $ExistingSkills) {
            $result.SkipExists += @{ Name = $skill; Reason = "Already installed in target" }
        }
        elseif ($PluginCovered.ContainsKey($skill)) {
            $info = $PluginCovered[$skill]
            if ($info.Partial) {
                $result.PartialPlugin += @{
                    Name      = $skill
                    Plugin    = $info.CoveredBy
                    Label     = $info.Label
                    Note      = $info.Note
                }
            }
            else {
                $result.SkipPlugin += @{
                    Name      = $skill
                    Plugin    = $info.CoveredBy
                    Label     = $info.Label
                    Note      = $info.Note
                }
            }
        }
        elseif ($skill -in $GlobalSkills) {
            $result.SkipGlobal += @{ Name = $skill; Reason = "Installed globally in ~/.claude/skills/" }
        }
        else {
            $result.ToInstall += $skill
        }
    }

    return $result
}

function Get-CommandDisposition {
    <#
    .SYNOPSIS
        Categorizes commands into: install or skip-exists.
    #>
    param(
        [string[]]$CandidateCommands,
        [string[]]$ExistingCommands
    )

    $result = @{
        ToInstall  = @()
        SkipExists = @()
    }

    foreach ($cmd in $CandidateCommands) {
        if ($cmd -in $ExistingCommands) {
            $result.SkipExists += $cmd
        }
        else {
            $result.ToInstall += $cmd
        }
    }

    return $result
}

# ============================================================================
# CLAUDE.md Analysis Functions
# ============================================================================

function Get-ClaudeMdSections {
    <#
    .SYNOPSIS
        Parses a CLAUDE.md file into an ordered list of sections split on ## headers.
    .OUTPUTS
        Array of @{ Name = "Section Name"; Content = "full text including header"; Index = N }
    #>
    param([string]$Content)

    if (-not $Content) { return @() }

    $sections = @()
    $lines = $Content -split "`n"
    $currentName = "__preamble__"
    $currentLines = @()
    $idx = 0

    foreach ($line in $lines) {
        if ($line -match '^## (.+)$') {
            # Save previous section
            if ($currentLines.Count -gt 0 -or $currentName -ne "__preamble__") {
                $sections += @{
                    Name    = $currentName
                    Content = ($currentLines -join "`n")
                    Index   = $idx
                }
                $idx++
            }
            $currentName = $Matches[1].Trim()
            $currentLines = @($line)
        }
        else {
            $currentLines += $line
        }
    }

    # Add final section
    if ($currentLines.Count -gt 0) {
        $sections += @{
            Name    = $currentName
            Content = ($currentLines -join "`n")
            Index   = $idx
        }
    }

    return $sections
}

function Get-MissingSections {
    <#
    .SYNOPSIS
        Compares target sections against template sections, returns missing ones.
    #>
    param(
        [array]$TargetSections,
        [array]$TemplateSections,
        [string[]]$DevFrameworks
    )

    $targetNames = @($TargetSections | ForEach-Object { $_.Name })
    $missing = @()

    foreach ($tplSection in $TemplateSections) {
        if ($tplSection.Name -eq "__preamble__") { continue }

        # Check conditional sections
        $isConditional = $false
        if ($tplSection.Content -match '<!-- IF (PRP|HARNESS|SPECKIT) -->') {
            $isConditional = $true
            $conditionFw = $Matches[1].ToLower()
            if ($conditionFw -notin $DevFrameworks) {
                continue  # Skip this section - dev framework not selected
            }
        }

        if ($tplSection.Name -notin $targetNames) {
            # Clean conditional markers from content
            $cleanContent = $tplSection.Content
            $cleanContent = $cleanContent -replace '<!-- IF (PRP|HARNESS|SPECKIT) -->\r?\n?', ''
            $cleanContent = $cleanContent -replace '<!-- ENDIF (PRP|HARNESS|SPECKIT) -->\r?\n?', ''

            $missing += @{
                Name    = $tplSection.Name
                Content = $cleanContent
                IsConditional = $isConditional
            }
        }
    }

    return $missing
}

function Get-InsertPosition {
    <#
    .SYNOPSIS
        Determines where to insert a missing section based on canonical ordering.
    .OUTPUTS
        The index in the target sections array after which to insert, or -1 for beginning.
    #>
    param(
        [string]$SectionName,
        [array]$TargetSections
    )

    $canonicalIdx = $CanonicalSectionOrder.IndexOf($SectionName)
    if ($canonicalIdx -lt 0) {
        # Unknown section, append at end (before last section)
        return ($TargetSections.Count - 1)
    }

    # Find the last existing section that comes before this one canonically
    $bestInsertAfter = -1
    foreach ($target in $TargetSections) {
        $targetCanonIdx = $CanonicalSectionOrder.IndexOf($target.Name)
        if ($targetCanonIdx -ge 0 -and $targetCanonIdx -lt $canonicalIdx) {
            if ($target.Index -gt $bestInsertAfter) {
                $bestInsertAfter = $target.Index
            }
        }
    }

    return $bestInsertAfter
}

function Get-UnfilledPlaceholders {
    <#
    .SYNOPSIS
        Scans content for [PLACEHOLDER] patterns.
    .OUTPUTS
        Array of unique placeholder strings found.
    #>
    param([string]$Content)

    $matches = [regex]::Matches($Content, '\[([A-Z][A-Z0-9_]+)\]')
    $placeholders = @()
    foreach ($m in $matches) {
        $ph = $m.Value
        # Exclude common false positives
        if ($ph -notin @("[OK]", "[X]", "[ERR]", "[WARN]", "[DRY]", "[BAK]", "[SKIP]", "[NEW]", "[ADD]")) {
            $placeholders += $ph
        }
    }
    return ($placeholders | Select-Object -Unique)
}

function Invoke-PlaceholderWizard {
    <#
    .SYNOPSIS
        Auto-detects values for known placeholders, prompts for the rest.
    .OUTPUTS
        Hashtable: placeholder_string -> replacement_value
    #>
    param(
        [string[]]$Placeholders,
        [string]$TargetPath,
        [string]$ProjectType,
        [string]$PrimaryLanguage,
        [string]$Framework
    )

    $values = @{}
    $currentDate = Get-Date -Format "yyyy-MM-dd"
    $projectDirName = Split-Path $TargetPath -Leaf
    $projectTitle = ($projectDirName -replace '-', ' ' -replace '_', ' ')
    # Capitalize first letter
    if ($projectTitle.Length -gt 0) {
        $projectTitle = $projectTitle.Substring(0, 1).ToUpper() + $projectTitle.Substring(1)
    }

    # Auto-detect git remote
    $gitRemote = ""
    try {
        $gitRemote = (git -C $TargetPath remote get-url origin 2>$null)
        if (-not $gitRemote) { $gitRemote = "" }
    }
    catch { }

    $primaryStack = if ($Framework) { "$PrimaryLanguage, $Framework" } else { $PrimaryLanguage }

    # Known auto-detect mappings
    $autoMap = @{
        "[PROJECT_TITLE]"     = $projectTitle
        "[PROJECT_NAME]"      = $projectDirName
        "[GITHUB_REPO]"       = $gitRemote
        "[REPOSITORY_PATH]"   = $TargetPath
        "[LOCAL_PATH]"        = $TargetPath
        "[PRIMARY_STACK]"     = $primaryStack
        "[PRIMARY_LANGUAGE]"  = $PrimaryLanguage
        "[PRIMARY_STRUCTURE]" = "src/"
        "[DATE]"              = $currentDate
        "[CREATION_DATE]"     = $currentDate
        "[LAST_UPDATE]"       = $currentDate
        "[TODAY_DATE]"        = $currentDate
    }

    $needsPrompt = @()

    foreach ($ph in $Placeholders) {
        if ($autoMap.ContainsKey($ph) -and $autoMap[$ph]) {
            $values[$ph] = $autoMap[$ph]
        }
        else {
            $needsPrompt += $ph
        }
    }

    # Show auto-detected values
    if ($values.Count -gt 0) {
        Write-Host ""
        Write-Host "  Auto-detected placeholder values:" -ForegroundColor Cyan
        foreach ($key in ($values.Keys | Sort-Object)) {
            $displayVal = $values[$key]
            if ($displayVal.Length -gt 60) { $displayVal = $displayVal.Substring(0, 57) + "..." }
            Write-Host "    $key = $displayVal" -ForegroundColor Green
        }
    }

    # Prompt for remaining
    if ($needsPrompt.Count -gt 0 -and -not $Force) {
        Write-Host ""
        Write-Host "  The following placeholders need values:" -ForegroundColor Yellow
        foreach ($ph in $needsPrompt) {
            $val = Get-UserInput -Prompt "  Value for $ph" -Default ""
            if ($val) {
                $values[$ph] = $val
            }
        }
    }

    return $values
}

function Build-ClaudeMdContent {
    <#
    .SYNOPSIS
        Performs additive merge of CLAUDE.md: adds missing sections and fills placeholders.
    .OUTPUTS
        Hashtable: @{ Content = "merged content"; AddedSections = @(); FilledPlaceholders = @() }
    #>
    param(
        [string]$TargetContent,
        [string]$TemplateContent,
        [string[]]$DevFrameworks,
        [hashtable]$PlaceholderValues
    )

    $targetSections = Get-ClaudeMdSections -Content $TargetContent
    $templateSections = Get-ClaudeMdSections -Content $TemplateContent

    $missingSections = Get-MissingSections -TargetSections $targetSections -TemplateSections $templateSections -DevFrameworks $DevFrameworks

    $addedSections = @()
    $content = $TargetContent

    # Insert missing sections at correct positions
    # We need to re-parse after each insertion to get correct indices
    foreach ($missing in $missingSections) {
        $currentSections = Get-ClaudeMdSections -Content $content
        $insertAfter = Get-InsertPosition -SectionName $missing.Name -TargetSections $currentSections

        $sectionText = "`n`n---`n`n" + $missing.Content.TrimStart("`n").TrimStart("`r`n")

        if ($insertAfter -lt 0) {
            # Insert at the very beginning after preamble
            $preamble = $currentSections | Where-Object { $_.Name -eq "__preamble__" }
            if ($preamble) {
                $preambleEnd = $preamble.Content.Length
                $content = $content.Substring(0, $preambleEnd) + $sectionText + $content.Substring($preambleEnd)
            }
            else {
                $content = $sectionText + "`n" + $content
            }
        }
        else {
            # Find the end of the section at insertAfter index
            $afterSection = $currentSections | Where-Object { $_.Index -eq $insertAfter }
            if ($afterSection) {
                # Find position in content after this section ends
                $sectionPattern = [regex]::Escape($afterSection.Content)
                $match = [regex]::Match($content, $sectionPattern)
                if ($match.Success) {
                    $insertPos = $match.Index + $match.Length
                    $content = $content.Substring(0, $insertPos) + $sectionText + $content.Substring($insertPos)
                }
                else {
                    # Fallback: append before the last ---
                    $content += $sectionText
                }
            }
            else {
                $content += $sectionText
            }
        }

        $addedSections += $missing.Name
    }

    # Fill placeholders
    $filledPlaceholders = @()
    foreach ($key in $PlaceholderValues.Keys) {
        if ($content.Contains($key)) {
            $content = $content.Replace($key, $PlaceholderValues[$key])
            $filledPlaceholders += $key
        }
    }

    # Clean up excessive blank lines
    $content = $content -replace '(\r?\n){4,}', "`n`n"

    return @{
        Content            = $content
        AddedSections      = $addedSections
        FilledPlaceholders = $filledPlaceholders
    }
}

# ============================================================================
# File Operation Functions
# ============================================================================

function New-Backup {
    param(
        [string]$FilePath,
        [string]$BackupDir,
        [string]$BaseTargetPath
    )

    if (-not (Test-Path $FilePath)) { return $null }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $relativePath = $FilePath.Substring($BaseTargetPath.Length).TrimStart('\', '/')
    $backupPath = Join-Path $BackupDir "$relativePath.$timestamp.backup"

    $backupParent = Split-Path $backupPath -Parent
    if (-not (Test-Path $backupParent)) {
        New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
    }

    Copy-Item -Path $FilePath -Destination $backupPath -Force
    return $backupPath
}

function Copy-SkillDirectory {
    param(
        [string]$SkillName,
        [string]$SourceBase,
        [string]$TargetBase,
        [string]$BackupDir,
        [switch]$DryRun,
        [switch]$NoBackup
    )

    $srcSkill = Join-Path $SourceBase ".claude\skills\$SkillName"
    $dstSkill = Join-Path $TargetBase ".claude\skills\$SkillName"

    if (-not (Test-Path $srcSkill -PathType Container)) {
        Write-Status "Skill not found in template: $SkillName" "WARNING"
        return 0
    }

    if ($DryRun) {
        Write-Status "Would install skill: $SkillName" "DRYRUN"
        return 1
    }

    if (-not (Test-Path $dstSkill)) {
        New-Item -ItemType Directory -Path $dstSkill -Force | Out-Null
    }

    $files = Get-ChildItem -Path $srcSkill -File -Recurse -ErrorAction SilentlyContinue
    $count = 0
    foreach ($file in $files) {
        $rel = $file.FullName.Substring($srcSkill.Length).TrimStart('\', '/')
        $dst = Join-Path $dstSkill $rel
        $parentDir = Split-Path $dst -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        Copy-Item -Path $file.FullName -Destination $dst -Force
        $count++
    }

    return $count
}

function Copy-CommandFile {
    param(
        [string]$CommandName,
        [string]$SourceBase,
        [string]$TargetBase,
        [string]$BackupDir,
        [switch]$DryRun,
        [switch]$NoBackup
    )

    $src = Join-Path $SourceBase ".claude\commands\$CommandName"
    $dst = Join-Path $TargetBase ".claude\commands\$CommandName"

    if (-not (Test-Path $src)) {
        Write-Status "Command not found in template: $CommandName" "WARNING"
        return $false
    }

    if ($DryRun) {
        Write-Status "Would install command: $CommandName" "DRYRUN"
        return $true
    }

    $parentDir = Split-Path $dst -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    Copy-Item -Path $src -Destination $dst -Force
    return $true
}

function Sync-ConfigFile {
    <#
    .SYNOPSIS
        Syncs a config file with create-only or always-update behavior.
    #>
    param(
        [string]$RelativePath,
        [string]$SourceBase,
        [string]$TargetBase,
        [string]$BackupDir,
        [ValidateSet("create-only", "always-update", "never")]
        [string]$Behavior,
        [switch]$DryRun,
        [switch]$NoBackup
    )

    if ($Behavior -eq "never") { return $false }

    $src = Join-Path $SourceBase $RelativePath
    $dst = Join-Path $TargetBase $RelativePath

    if (-not (Test-Path $src)) { return $false }

    $exists = Test-Path $dst

    if ($Behavior -eq "create-only" -and $exists) {
        return $false
    }

    if ($DryRun) {
        if ($exists) {
            Write-Status "Would update: $RelativePath" "DRYRUN"
        }
        else {
            Write-Status "Would create: $RelativePath" "DRYRUN"
        }
        return $true
    }

    # Backup existing
    if ($exists -and -not $NoBackup -and $Behavior -eq "always-update") {
        New-Backup -FilePath $dst -BackupDir $BackupDir -BaseTargetPath $TargetBase | Out-Null
    }

    $parentDir = Split-Path $dst -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    Copy-Item -Path $src -Destination $dst -Force
    return $true
}

function Write-TemplateProfileToConfig {
    <#
    .SYNOPSIS
        Writes or updates the template_profile section in .claude/config.yaml.
    #>
    param(
        [string]$TargetPath,
        [string]$ProjectType,
        [string]$Language,
        [string]$Framework,
        [string[]]$SkillGroups,
        [string[]]$CommandGroups,
        [string[]]$DevFrameworks,
        [switch]$DryRun
    )

    $configPath = Join-Path $TargetPath ".claude\config.yaml"

    if ($DryRun) {
        Write-Status "Would write template_profile to config.yaml" "DRYRUN"
        return
    }

    $skillGroupsStr = ($SkillGroups | ForEach-Object { "`"$_`"" }) -join ", "
    $commandGroupsStr = ($CommandGroups | ForEach-Object { "`"$_`"" }) -join ", "
    $devFrameworksStr = if ($DevFrameworks.Count -gt 0) {
        ($DevFrameworks | ForEach-Object { "`"$_`"" }) -join ", "
    } else { "" }

    $profileYaml = @"

template_profile:
  template_version: "$ScriptVersion"
  project_type: "$ProjectType"
  primary_language: "$Language"
  framework: "$Framework"
  skill_groups: [$skillGroupsStr]
  command_groups: [$commandGroupsStr]
  dev_frameworks: [$devFrameworksStr]
  synced_with: "sync-claude-code.ps1"
  last_synced: "$(Get-Date -Format 'yyyy-MM-dd')"
"@

    if (Test-Path $configPath) {
        $content = Get-Content $configPath -Raw

        if ($content -match '(?s)template_profile:.*') {
            # Replace existing template_profile section
            $content = $content -replace '(?s)\r?\ntemplate_profile:.*$', $profileYaml
        }
        else {
            # Append
            $content += $profileYaml
        }

        Set-Content -Path $configPath -Value $content -NoNewline
    }
    else {
        # Create new config.yaml with minimal content
        $parentDir = Split-Path $configPath -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }

        $newConfig = @"
# Claude Code Project Configuration
# Created by sync-claude-code.ps1
$profileYaml
"@
        Set-Content -Path $configPath -Value $newConfig -NoNewline
    }
}

# ============================================================================
# Prerequisite Check
# ============================================================================

function Initialize-TargetStructure {
    <#
    .SYNOPSIS
        Ensures the target project has all required directories before sync.
        Creates missing directories so that scanning and copying operations
        do not encounter null path errors.
    #>
    param(
        [string]$TargetPath,
        [switch]$DryRun
    )

    $requiredDirs = @(
        ".claude",
        ".claude\skills",
        ".claude\commands",
        ".claude\context",
        ".claude\hooks",
        ".vscode",
        "scripts",
        "temp"
    )

    $created = 0
    foreach ($dir in $requiredDirs) {
        $fullPath = Join-Path $TargetPath $dir
        if (-not (Test-Path $fullPath -PathType Container)) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
            }
            $created++
        }
    }

    return $created
}

function Test-Prerequisites {
    Write-Step "0" "Checking Prerequisites"

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

    # Check template path
    if (-not (Test-Path $TemplatePath)) {
        Write-Status "Template path not found: $TemplatePath" "ERROR"
        $allGood = $false
    }
    else {
        Write-Status "Template: $TemplatePath" "SUCCESS"
    }

    return $allGood
}

function Test-GitRepository {
    param([string]$Path)
    return (Test-Path (Join-Path $Path ".git") -PathType Container)
}

# ============================================================================
# Wizard Functions
# ============================================================================

function Invoke-ProjectTypeWizard {
    param($Manifest)

    Write-Host ""
    Write-Host "  Project types:" -ForegroundColor Gray
    Write-Host "    1. web-frontend    - React, Vue, Angular, etc." -ForegroundColor Gray
    Write-Host "    2. backend-api     - Node.js, Python, .NET, etc." -ForegroundColor Gray
    Write-Host "    3. fullstack       - Combined frontend + backend" -ForegroundColor Gray
    Write-Host "    4. cli-library     - CLI tools or packages" -ForegroundColor Gray
    Write-Host "    5. infrastructure  - Terraform, Docker, K8s" -ForegroundColor Gray
    Write-Host "    6. power-platform  - Power Apps, Automate, Dataverse, PCF" -ForegroundColor Gray
    Write-Host ""

    return Get-UserInput -Prompt "Project type" -Default "backend-api" -ValidOptions @("web-frontend", "backend-api", "fullstack", "cli-library", "infrastructure", "power-platform")
}

function Invoke-LanguageWizard {
    param($Manifest, [string]$ProjectType)

    Write-Host ""
    Write-Host "  Primary language:" -ForegroundColor Gray

    $validLangs = @()
    if ($Manifest.languageOptions.PSObject.Properties.Name -contains $ProjectType) {
        $langOptions = $Manifest.languageOptions.$ProjectType
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

    $lang = Get-UserInput -Prompt "Primary language" -Default $defaultLang -ValidOptions $validLangs
    if ($lang -eq "other") {
        $lang = Get-UserInput -Prompt "Enter language name" -Required
    }
    return $lang
}

function Invoke-FrameworkWizard {
    param($Manifest, [string]$PrimaryLanguage, [string]$ProjectType)

    $frameworkOptions = @()
    if ($Manifest.languages.PSObject.Properties.Name -contains $PrimaryLanguage) {
        $langConfig = $Manifest.languages.$PrimaryLanguage
        if ($langConfig.frameworks -and $langConfig.frameworks.PSObject.Properties.Name -contains $ProjectType) {
            $frameworkOptions = @($langConfig.frameworks.$ProjectType)
        }
    }

    if ($frameworkOptions.Count -eq 0) { return "" }

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
    $fw = Get-UserInput -Prompt "Framework" -Default $defaultFramework -ValidOptions $validFrameworks

    if ($fw -eq "other") {
        $fw = Get-UserInput -Prompt "Enter framework name" -Required
    }
    if ($fw -eq "none") { $fw = "" }

    return $fw
}

function Invoke-DevFrameworkWizard {
    Write-Host ""
    Write-Host "  Optional development frameworks:" -ForegroundColor Gray
    Write-Host "    1. prp      - Product Requirement Planning (PRD -> Plan -> Implement)" -ForegroundColor Gray
    Write-Host "    2. harness  - Autonomous Agent pipeline for greenfield projects" -ForegroundColor Gray
    Write-Host "    3. speckit  - Specification-driven with verification checklists" -ForegroundColor Gray
    Write-Host "    4. spark    - Quick prototyping and teaching" -ForegroundColor Gray
    Write-Host "    5. worktree - Git worktree-based parallel experiments" -ForegroundColor Gray
    Write-Host ""

    $dfChoice = Get-UserInput -Prompt "Include frameworks (comma-separated numbers or names, or 'none')" -Default "none"

    if ($dfChoice -eq "none" -or $dfChoice -eq "") { return @() }

    $dfMap = @{ "1" = "prp"; "2" = "harness"; "3" = "speckit"; "4" = "spark"; "5" = "worktree" }
    $selected = @()
    foreach ($item in ($dfChoice -split ',')) {
        $item = $item.Trim()
        if ($dfMap.ContainsKey($item)) {
            $selected += $dfMap[$item]
        }
        elseif ($item -in @("prp", "harness", "speckit", "spark", "worktree")) {
            $selected += $item
        }
    }

    return $selected
}

function Invoke-AdditionalSkillGroupsWizard {
    param($Manifest)

    $options = @(
        @{ value = "ai_ml"; label = "AI / Machine Learning"; description = "LangChain, LlamaIndex, CrewAI, PydanticAI, Ollama, etc." }
        @{ value = "smart_home_iot"; label = "Smart Home / IoT"; description = "Home Assistant, MQTT, ESPHome, Zigbee, etc." }
        @{ value = "niche"; label = "Niche / Specialty"; description = "Ralph Loop, audio/video, Obsidian, Markitdown" }
        @{ value = "cloud_infra"; label = "Cloud Infrastructure"; description = "Azure, Docker, Kubernetes, Helm, Grafana, etc." }
    )

    Write-Host ""
    Write-Host "  Additional skill groups (beyond project-type defaults):" -ForegroundColor Gray

    return Get-MultiSelectInput -Prompt "  Select additional groups" -Options $options
}

# ============================================================================
# Main Script
# ============================================================================

Write-Banner

# --- Step 0: Prerequisites ---
if (-not (Test-Prerequisites)) {
    Write-Host ""
    Write-Status "Please fix the prerequisites above and run again." "ERROR"
    exit 1
}

# Load manifest and plugin map
$Manifest = Get-ManifestConfig
if (-not $Manifest) {
    Write-Status "Cannot proceed without manifest.json" "ERROR"
    exit 1
}

$PluginSkillMap = Get-PluginSkillMap

# --- Get target path ---
if (-not $TargetPath) {
    Write-Step "1" "Target Codebase"
    $TargetPath = Get-UserInput -Prompt "Path to the target codebase" -Required
}

# Validate target
$TargetPath = (Resolve-Path $TargetPath -ErrorAction SilentlyContinue).Path
if (-not $TargetPath -or -not (Test-Path $TargetPath -PathType Container)) {
    Write-Status "Target path does not exist: $TargetPath" "ERROR"
    exit 1
}

if (-not (Test-GitRepository -Path $TargetPath)) {
    Write-Status "Target is not a Git repository: $TargetPath" "ERROR"
    Write-Host "  Initialize with: git init" -ForegroundColor Gray
    exit 1
}

Write-Status "Target: $TargetPath" "SUCCESS"
Write-Status "Source: $TemplatePath" "INFO"

if ($DryRun) {
    Write-Host ""
    Write-Host "  [!] DRY RUN MODE - No changes will be made" -ForegroundColor Magenta
}

# --- Initialize target directory structure ---
$dirsCreated = Initialize-TargetStructure -TargetPath $TargetPath -DryRun:$DryRun
if ($dirsCreated -gt 0) {
    Write-Status "Initialized $dirsCreated missing directories in target" "ADD"
}

# --- Step 1: Load Target State ---
Write-Step "1" "Loading Target State"

$templateProfile = Get-TemplateProfile -TargetPath $TargetPath
$existingSkills = Get-ExistingSkills -TargetPath $TargetPath
$existingCommands = Get-ExistingCommands -TargetPath $TargetPath

$targetClaudeMdPath = Join-Path $TargetPath "CLAUDE.md"
$targetClaudeMdExists = Test-Path $targetClaudeMdPath
$targetClaudeMdContent = if ($targetClaudeMdExists) {
    Get-Content $targetClaudeMdPath -Raw -ErrorAction SilentlyContinue
} else { $null }

Write-Status "Existing skills:   $($existingSkills.Count)" "INFO"
Write-Status "Existing commands:  $($existingCommands.Count)" "INFO"
Write-Status "CLAUDE.md exists:   $targetClaudeMdExists" "INFO"

if ($templateProfile) {
    Write-Status "Template profile found" "SUCCESS"
    Write-Host ""
    Write-Host "  Detected Profile:" -ForegroundColor White
    Write-Host "    Project Type: $($templateProfile.project_type)" -ForegroundColor Cyan
    Write-Host "    Language:     $($templateProfile.primary_language)" -ForegroundColor Cyan
    Write-Host "    Framework:    $($templateProfile.framework)" -ForegroundColor Cyan
    Write-Host "    Skill Groups: $($templateProfile.skill_groups -join ', ')" -ForegroundColor Cyan
    Write-Host "    Cmd Groups:   $($templateProfile.command_groups -join ', ')" -ForegroundColor Cyan
    if ($templateProfile.dev_frameworks.Count -gt 0) {
        Write-Host "    Dev Fwks:     $($templateProfile.dev_frameworks -join ', ')" -ForegroundColor Cyan
    }
}
else {
    Write-Status "No template profile found - will run configuration wizard" "WARNING"
}

# --- Step 2: Detect / Confirm Configuration ---
Write-Step "2" "Confirming Configuration"

$useProfile = $false
if ($templateProfile -and -not $Force) {
    Write-Host ""
    $accept = Get-UserInput -Prompt "Use detected profile settings? (y/n/edit)" -Default "y" -ValidOptions @("y", "n", "edit")
    if ($accept -eq "y") {
        $useProfile = $true
        # Copy profile values to params
        if (-not $ProjectType)       { $ProjectType = $templateProfile.project_type }
        if (-not $PrimaryLanguage)   { $PrimaryLanguage = $templateProfile.primary_language }
        if (-not $Framework)         { $Framework = $templateProfile.framework }
        if ($DevFrameworks.Count -eq 0 -and $templateProfile.dev_frameworks) {
            $DevFrameworks = @($templateProfile.dev_frameworks)
        }
    }
    elseif ($accept -eq "edit") {
        # Pre-fill from profile but allow editing
        if (-not $ProjectType) { $ProjectType = $templateProfile.project_type }
        if (-not $PrimaryLanguage) { $PrimaryLanguage = $templateProfile.primary_language }
        # Fall through to wizard
    }
}
elseif ($templateProfile -and $Force) {
    # Force mode with profile: use profile values for unset params
    $useProfile = $true
    if (-not $ProjectType)       { $ProjectType = $templateProfile.project_type }
    if (-not $PrimaryLanguage)   { $PrimaryLanguage = $templateProfile.primary_language }
    if (-not $Framework)         { $Framework = $templateProfile.framework }
    if ($DevFrameworks.Count -eq 0 -and $templateProfile.dev_frameworks) {
        $DevFrameworks = @($templateProfile.dev_frameworks)
    }
}

# --- Step 3: Wizard (when params still missing) ---
if (-not $ProjectType -or -not $PrimaryLanguage) {
    Write-Step "3" "Configuration Wizard"

    if (-not $ProjectType) {
        $ProjectType = Invoke-ProjectTypeWizard -Manifest $Manifest
    }

    if (-not $PrimaryLanguage) {
        $PrimaryLanguage = Invoke-LanguageWizard -Manifest $Manifest -ProjectType $ProjectType
    }

    if (-not $Framework) {
        $Framework = Invoke-FrameworkWizard -Manifest $Manifest -PrimaryLanguage $PrimaryLanguage -ProjectType $ProjectType
    }

    if ($DevFrameworks.Count -eq 0) {
        $DevFrameworks = Invoke-DevFrameworkWizard
    }

    if ($AdditionalSkillGroups.Count -eq 0 -and -not $Force) {
        $AdditionalSkillGroups = Invoke-AdditionalSkillGroupsWizard -Manifest $Manifest
    }
}
else {
    Write-Status "Configuration: $ProjectType / $PrimaryLanguage / $(if ($Framework) { $Framework } else { 'none' })" "SUCCESS"
}

# --- Step 4: Calculate Delta ---
Write-Step "4" "Calculating Changes"

$skillResult = Get-SelectedSkills -Manifest $Manifest -ProjectType $ProjectType `
    -Language $PrimaryLanguage -Framework $Framework `
    -DevFrameworks $DevFrameworks -AdditionalGroups $AdditionalSkillGroups

$commandResult = Get-SelectedCommands -Manifest $Manifest -DevFrameworks $DevFrameworks

$candidateSkills = @($skillResult.Skills | Where-Object { $_ })
$skillGroups = @($skillResult.Groups | Where-Object { $_ })
$candidateCommands = @($commandResult.Commands | Where-Object { $_ })
$commandGroups = @($commandResult.Groups | Where-Object { $_ })

Write-Status "Candidate skills:  $($candidateSkills.Count) (from groups: $($skillGroups -join ', '))" "INFO"
Write-Status "Candidate commands: $($candidateCommands.Count) (from groups: $($commandGroups -join ', '))" "INFO"

# --- Step 5: Global Dedup ---
Write-Step "5" "Global Plugin & Skill Deduplication"

$globalSettings = Get-GlobalSettings
$globalSkills = Get-GlobalSkills

if ($globalSettings.Plugins.Count -gt 0) {
    Write-Status "Global plugins detected: $($globalSettings.Plugins -join ', ')" "INFO"
}
else {
    Write-Status "No global plugins detected" "INFO"
}

if ($globalSkills.Count -gt 0) {
    Write-Status "Global skills detected: $($globalSkills.Count)" "INFO"
}

$pluginCovered = Get-PluginCoveredSkills -EnabledPlugins $globalSettings.Plugins -PluginSkillMap $PluginSkillMap
$skillDisposition = Get-SkillDisposition -CandidateSkills $candidateSkills `
    -ExistingSkills $existingSkills -GlobalSkills $globalSkills -PluginCovered $pluginCovered

$commandDisposition = Get-CommandDisposition -CandidateCommands $candidateCommands `
    -ExistingCommands $existingCommands

Write-Host ""
Write-Host "  Skill Disposition:" -ForegroundColor White
Write-Status "  To install:          $($skillDisposition.ToInstall.Count)" "ADD"
Write-Status "  Already installed:   $($skillDisposition.SkipExists.Count)" "SKIP"
Write-Status "  Covered by plugin:   $($skillDisposition.SkipPlugin.Count)" "PLUGIN"
Write-Status "  Partial (plugin):    $($skillDisposition.PartialPlugin.Count)" "PARTIAL"
Write-Status "  Covered globally:    $($skillDisposition.SkipGlobal.Count)" "GLOBAL"

Write-Host ""
Write-Host "  Command Disposition:" -ForegroundColor White
Write-Status "  To install:          $($commandDisposition.ToInstall.Count)" "ADD"
Write-Status "  Already installed:   $($commandDisposition.SkipExists.Count)" "SKIP"

# --- Step 6: CLAUDE.md Analysis ---
Write-Step "6" "CLAUDE.md Analysis"

$claudeMdChanges = @{
    CreateNew          = $false
    AddedSections      = @()
    FilledPlaceholders = @()
    MergedContent      = $null
}

# Load template CLAUDE.md
$templateClaudeMdPath = Join-Path $TemplatePath "templates\claude-md\CLAUDE.md.template"
$templateClaudeMdContent = if (Test-Path $templateClaudeMdPath) {
    Get-Content $templateClaudeMdPath -Raw
} else { $null }

if (-not $targetClaudeMdExists) {
    Write-Status "No CLAUDE.md found in target" "WARNING"

    if (-not $Force) {
        $createChoice = Get-UserInput -Prompt "Create CLAUDE.md from template? (y/n)" -Default "y" -ValidOptions @("y", "n")
    }
    else {
        $createChoice = "y"
    }

    if ($createChoice -eq "y" -and $templateClaudeMdContent) {
        $claudeMdChanges.CreateNew = $true

        # Process conditional sections
        $processedContent = $templateClaudeMdContent
        foreach ($fw in @("prp", "harness", "speckit")) {
            $tag = $fw.ToUpper()
            if ($DevFrameworks -contains $fw) {
                $processedContent = $processedContent -replace "<!-- IF $tag -->", ''
                $processedContent = $processedContent -replace "<!-- ENDIF $tag -->", ''
            }
            else {
                $processedContent = $processedContent -replace "(?s)<!-- IF $tag -->.*?<!-- ENDIF $tag -->", ''
            }
        }
        $processedContent = $processedContent -replace '(\r?\n){4,}', "`n`n"

        # Scan and fill placeholders
        $placeholders = Get-UnfilledPlaceholders -Content $processedContent
        if ($placeholders.Count -gt 0) {
            Write-Status "Found $($placeholders.Count) placeholders to fill" "FILL"
            $phValues = Invoke-PlaceholderWizard -Placeholders $placeholders `
                -TargetPath $TargetPath -ProjectType $ProjectType `
                -PrimaryLanguage $PrimaryLanguage -Framework $Framework

            foreach ($key in $phValues.Keys) {
                $processedContent = $processedContent.Replace($key, $phValues[$key])
                $claudeMdChanges.FilledPlaceholders += $key
            }
        }

        $claudeMdChanges.MergedContent = $processedContent
        Write-Status "CLAUDE.md will be created from template" "NEW"
    }
}
elseif ($templateClaudeMdContent) {
    Write-Status "Analyzing existing CLAUDE.md for missing sections..." "WORKING"

    # Process template conditionals first
    $processedTemplate = $templateClaudeMdContent
    foreach ($fw in @("prp", "harness", "speckit")) {
        $tag = $fw.ToUpper()
        if ($DevFrameworks -contains $fw) {
            $processedTemplate = $processedTemplate -replace "<!-- IF $tag -->", ''
            $processedTemplate = $processedTemplate -replace "<!-- ENDIF $tag -->", ''
        }
        else {
            $processedTemplate = $processedTemplate -replace "(?s)<!-- IF $tag -->.*?<!-- ENDIF $tag -->", ''
        }
    }

    # Scan target for unfilled placeholders
    $targetPlaceholders = Get-UnfilledPlaceholders -Content $targetClaudeMdContent
    $phValues = @{}
    if ($targetPlaceholders.Count -gt 0) {
        Write-Status "Found $($targetPlaceholders.Count) unfilled placeholders in existing CLAUDE.md" "FILL"
        $phValues = Invoke-PlaceholderWizard -Placeholders $targetPlaceholders `
            -TargetPath $TargetPath -ProjectType $ProjectType `
            -PrimaryLanguage $PrimaryLanguage -Framework $Framework
    }

    # Perform additive merge
    $mergeResult = Build-ClaudeMdContent -TargetContent $targetClaudeMdContent `
        -TemplateContent $processedTemplate `
        -DevFrameworks $DevFrameworks `
        -PlaceholderValues $phValues

    $claudeMdChanges.AddedSections = $mergeResult.AddedSections
    $claudeMdChanges.FilledPlaceholders = $mergeResult.FilledPlaceholders
    $claudeMdChanges.MergedContent = $mergeResult.Content

    if ($claudeMdChanges.AddedSections.Count -gt 0) {
        Write-Status "Missing sections found:" "SECTION"
        foreach ($sec in $claudeMdChanges.AddedSections) {
            Write-Status "  + $sec" "ADD"
        }
    }
    else {
        Write-Status "All template sections already present" "SUCCESS"
    }

    if ($claudeMdChanges.FilledPlaceholders.Count -gt 0) {
        Write-Status "Placeholders to fill: $($claudeMdChanges.FilledPlaceholders.Count)" "FILL"
    }
}
else {
    Write-Status "No CLAUDE.md template found - skipping analysis" "WARNING"
}

# --- Determine config file actions ---
$configFileActions = @(
    @{ Path = ".claude\SESSION_KNOWLEDGE.md"; Behavior = "create-only" }
    @{ Path = ".claude\DEVELOPMENT_LOG.md"; Behavior = "create-only" }
    @{ Path = ".claude\FAILED_ATTEMPTS.md"; Behavior = "create-only" }
    @{ Path = ".claude\settings.json"; Behavior = "never" }
    @{ Path = ".vscode\extensions.json"; Behavior = "create-only" }
    @{ Path = ".vscode\settings.json"; Behavior = "never" }
    @{ Path = ".gitattributes"; Behavior = "create-only" }
    @{ Path = ".pre-commit-config.yaml"; Behavior = "create-only" }
    @{ Path = "scripts\sync-claude-code.ps1"; Behavior = "always-update" }
    @{ Path = "scripts\validate-claude-code.ps1"; Behavior = "always-update" }
    @{ Path = "scripts\update-project.ps1"; Behavior = "always-update" }
)

# Hooks and context: create-only per file
$hooksSource = Join-Path $TemplatePath ".claude\hooks"
$contextSource = Join-Path $TemplatePath ".claude\context"

$hooksToCreate = @()
if (Test-Path $hooksSource) {
    $hookFiles = Get-ChildItem -Path $hooksSource -File -Recurse -ErrorAction SilentlyContinue
    foreach ($f in $hookFiles) {
        $rel = ".claude\hooks\" + $f.FullName.Substring($hooksSource.Length).TrimStart('\', '/')
        $targetFile = Join-Path $TargetPath $rel
        if (-not (Test-Path $targetFile)) {
            $hooksToCreate += $rel
        }
    }
}

$contextToCreate = @()
if (Test-Path $contextSource) {
    $contextFiles = Get-ChildItem -Path $contextSource -File -Recurse -ErrorAction SilentlyContinue
    foreach ($f in $contextFiles) {
        $rel = ".claude\context\" + $f.FullName.Substring($contextSource.Length).TrimStart('\', '/')
        $targetFile = Join-Path $TargetPath $rel
        if (-not (Test-Path $targetFile)) {
            $contextToCreate += $rel
        }
    }
}

# PRPs directory
$prpAction = "none"
if ($DevFrameworks -contains "prp") {
    $prpTarget = Join-Path $TargetPath "PRPs"
    if (-not (Test-Path $prpTarget)) {
        $prpAction = "create"
    }
}

# --- Step 7: Preview ---
Write-Step "7" "Sync Preview"

$hasChanges = $false

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                      Proposed Changes                                " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Skills to install
if ($skillDisposition.ToInstall.Count -gt 0) {
    $hasChanges = $true
    Write-Host "  SKILLS TO INSTALL ($($skillDisposition.ToInstall.Count)):" -ForegroundColor Green
    foreach ($skill in $skillDisposition.ToInstall) {
        Write-Host "    + $skill" -ForegroundColor Green
    }
    Write-Host ""
}

# Partial skills (recommended despite plugin)
if ($skillDisposition.PartialPlugin.Count -gt 0) {
    $hasChanges = $true
    Write-Host "  SKILLS TO INSTALL (partial plugin overlap, still recommended):" -ForegroundColor Yellow
    foreach ($item in $skillDisposition.PartialPlugin) {
        Write-Host "    + $($item.Name)  (overlaps with: $($item.Label))" -ForegroundColor Yellow
        Write-Host "      $($item.Note)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# Skills skipped
if ($skillDisposition.SkipPlugin.Count -gt 0) {
    Write-Host "  SKILLS SKIPPED (covered by global plugin):" -ForegroundColor DarkCyan
    foreach ($item in $skillDisposition.SkipPlugin) {
        Write-Host "    - $($item.Name)  (covered by: $($item.Label))" -ForegroundColor DarkCyan
    }
    Write-Host ""
}

if ($skillDisposition.SkipGlobal.Count -gt 0) {
    Write-Host "  SKILLS SKIPPED (installed globally):" -ForegroundColor DarkCyan
    foreach ($item in $skillDisposition.SkipGlobal) {
        Write-Host "    - $($item.Name)" -ForegroundColor DarkCyan
    }
    Write-Host ""
}

if ($skillDisposition.SkipExists.Count -gt 0) {
    Write-Host "  SKILLS SKIPPED (already in project):" -ForegroundColor DarkGray
    foreach ($item in $skillDisposition.SkipExists) {
        Write-Host "    - $($item.Name)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# Commands
if ($commandDisposition.ToInstall.Count -gt 0) {
    $hasChanges = $true
    Write-Host "  COMMANDS TO INSTALL ($($commandDisposition.ToInstall.Count)):" -ForegroundColor Green
    foreach ($cmd in $commandDisposition.ToInstall) {
        Write-Host "    + $cmd" -ForegroundColor Green
    }
    Write-Host ""
}

if ($commandDisposition.SkipExists.Count -gt 0) {
    Write-Host "  COMMANDS SKIPPED (already in project):" -ForegroundColor DarkGray
    foreach ($cmd in $commandDisposition.SkipExists) {
        Write-Host "    - $cmd" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# CLAUDE.md changes
if ($claudeMdChanges.CreateNew) {
    $hasChanges = $true
    Write-Host "  CLAUDE.MD: Will be CREATED from template" -ForegroundColor Green
    if ($claudeMdChanges.FilledPlaceholders.Count -gt 0) {
        Write-Host "    Placeholders filled: $($claudeMdChanges.FilledPlaceholders.Count)" -ForegroundColor Cyan
    }
    Write-Host ""
}
elseif ($claudeMdChanges.AddedSections.Count -gt 0 -or $claudeMdChanges.FilledPlaceholders.Count -gt 0) {
    $hasChanges = $true
    Write-Host "  CLAUDE.MD UPDATES (additive only, existing content preserved):" -ForegroundColor Green
    foreach ($sec in $claudeMdChanges.AddedSections) {
        Write-Host "    + Section: $sec" -ForegroundColor Green
    }
    foreach ($ph in $claudeMdChanges.FilledPlaceholders) {
        Write-Host "    ~ Placeholder filled: $ph" -ForegroundColor Cyan
    }
    Write-Host ""
}
else {
    Write-Host "  CLAUDE.MD: No changes needed" -ForegroundColor DarkGray
    Write-Host ""
}

# Config files
$configToSync = @()
foreach ($cf in $configFileActions) {
    $src = Join-Path $TemplatePath $cf.Path
    $dst = Join-Path $TargetPath $cf.Path
    if ($cf.Behavior -eq "never") { continue }
    if (-not (Test-Path $src)) { continue }

    $exists = Test-Path $dst
    if ($cf.Behavior -eq "create-only" -and $exists) { continue }

    $configToSync += $cf
    $hasChanges = $true
}

if ($configToSync.Count -gt 0 -or $hooksToCreate.Count -gt 0 -or $contextToCreate.Count -gt 0) {
    Write-Host "  CONFIG FILES:" -ForegroundColor Green
    foreach ($cf in $configToSync) {
        $dst = Join-Path $TargetPath $cf.Path
        $exists = Test-Path $dst
        if ($exists) {
            Write-Host "    ~ $($cf.Path) (update)" -ForegroundColor Yellow
        }
        else {
            Write-Host "    + $($cf.Path) (create)" -ForegroundColor Green
        }
    }
    foreach ($h in $hooksToCreate) {
        Write-Host "    + $h (create)" -ForegroundColor Green
        $hasChanges = $true
    }
    foreach ($c in $contextToCreate) {
        Write-Host "    + $c (create)" -ForegroundColor Green
        $hasChanges = $true
    }
    Write-Host ""
}

if ($prpAction -eq "create") {
    $hasChanges = $true
    Write-Host "  PRP FRAMEWORK: PRPs/ directory will be created" -ForegroundColor Green
    Write-Host ""
}

# Template profile
Write-Host "  TEMPLATE PROFILE: Will be written/updated in .claude/config.yaml" -ForegroundColor Cyan
Write-Host ""
$hasChanges = $true

if (-not $hasChanges) {
    Write-Host ""
    Write-Host "  No changes needed - project is already in sync!" -ForegroundColor Green
    Write-Host ""
    exit 0
}

# --- Step 8: Approval ---
Write-Step "8" "Approval"

if ($DryRun) {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host "              Dry Run Complete - No Changes Made                       " -ForegroundColor Magenta
    Write-Host "======================================================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  To apply these changes, run without -DryRun:" -ForegroundColor Yellow
    Write-Host "    .\sync-claude-code.ps1 -TargetPath `"$TargetPath`"" -ForegroundColor White
    Write-Host ""
    exit 0
}

if (-not $Force) {
    $confirm = Get-UserInput -Prompt "Apply these changes? (y/n)" -Default "y" -ValidOptions @("y", "n")
    if ($confirm -ne "y") {
        Write-Status "Cancelled by user." "WARNING"
        exit 0
    }
}

# --- Step 9: Execute ---
Write-Step "9" "Applying Changes"

# Create backup directory
$backupDir = Join-Path $TargetPath ".claude-backup"
if (-not $NoBackup) {
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    Write-Status "Backup directory: $backupDir" "INFO"
}

$stats = @{
    SkillsInstalled   = 0
    CommandsInstalled = 0
    ConfigsCreated    = 0
    ConfigsUpdated    = 0
    SectionsAdded     = 0
    PlaceholdersFilled = 0
    FilesCount        = 0
}

# 9a. Install skills
Write-Host ""
Write-Host "  Installing skills..." -ForegroundColor Cyan
foreach ($skill in $skillDisposition.ToInstall) {
    $count = Copy-SkillDirectory -SkillName $skill -SourceBase $TemplatePath -TargetBase $TargetPath `
        -BackupDir $backupDir -DryRun:$DryRun -NoBackup:$NoBackup
    if ($count -gt 0) {
        Write-Status "Installed skill: $skill ($count files)" "ADD"
        $stats.SkillsInstalled++
        $stats.FilesCount += $count
    }
}

# 9b. Install partial-plugin skills (recommended)
foreach ($item in $skillDisposition.PartialPlugin) {
    $count = Copy-SkillDirectory -SkillName $item.Name -SourceBase $TemplatePath -TargetBase $TargetPath `
        -BackupDir $backupDir -DryRun:$DryRun -NoBackup:$NoBackup
    if ($count -gt 0) {
        Write-Status "Installed skill (partial overlap): $($item.Name) ($count files)" "PARTIAL"
        $stats.SkillsInstalled++
        $stats.FilesCount += $count
    }
}

# Copy skills README
$skillsReadmeSrc = Join-Path $TemplatePath ".claude\skills\README.md"
$skillsReadmeDst = Join-Path $TargetPath ".claude\skills\README.md"
if ((Test-Path $skillsReadmeSrc) -and -not (Test-Path $skillsReadmeDst)) {
    $parentDir = Split-Path $skillsReadmeDst -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    Copy-Item -Path $skillsReadmeSrc -Destination $skillsReadmeDst -Force
}

# 9c. Install commands
Write-Host ""
Write-Host "  Installing commands..." -ForegroundColor Cyan
foreach ($cmd in $commandDisposition.ToInstall) {
    $result = Copy-CommandFile -CommandName $cmd -SourceBase $TemplatePath -TargetBase $TargetPath `
        -BackupDir $backupDir -DryRun:$DryRun -NoBackup:$NoBackup
    if ($result) {
        Write-Status "Installed command: $cmd" "ADD"
        $stats.CommandsInstalled++
        $stats.FilesCount++
    }
}

# Copy commands README
$cmdsReadmeSrc = Join-Path $TemplatePath ".claude\commands\README.md"
$cmdsReadmeDst = Join-Path $TargetPath ".claude\commands\README.md"
if ((Test-Path $cmdsReadmeSrc) -and -not (Test-Path $cmdsReadmeDst)) {
    $parentDir = Split-Path $cmdsReadmeDst -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    Copy-Item -Path $cmdsReadmeSrc -Destination $cmdsReadmeDst -Force
}

# 9d. CLAUDE.md
Write-Host ""
Write-Host "  Updating CLAUDE.md..." -ForegroundColor Cyan
if ($claudeMdChanges.MergedContent) {
    if ($claudeMdChanges.CreateNew) {
        # Create new CLAUDE.md
        $parentDir = Split-Path $targetClaudeMdPath -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        Set-Content -Path $targetClaudeMdPath -Value $claudeMdChanges.MergedContent -NoNewline
        Write-Status "Created CLAUDE.md from template" "NEW"
        $stats.SectionsAdded = $claudeMdChanges.AddedSections.Count
        $stats.PlaceholdersFilled = $claudeMdChanges.FilledPlaceholders.Count
    }
    elseif ($claudeMdChanges.AddedSections.Count -gt 0 -or $claudeMdChanges.FilledPlaceholders.Count -gt 0) {
        # Backup existing
        if (-not $NoBackup) {
            New-Backup -FilePath $targetClaudeMdPath -BackupDir $backupDir -BaseTargetPath $TargetPath | Out-Null
            Write-Status "Backed up existing CLAUDE.md" "BACKUP"
        }
        Set-Content -Path $targetClaudeMdPath -Value $claudeMdChanges.MergedContent -NoNewline
        Write-Status "Updated CLAUDE.md (additive merge)" "SUCCESS"
        $stats.SectionsAdded = $claudeMdChanges.AddedSections.Count
        $stats.PlaceholdersFilled = $claudeMdChanges.FilledPlaceholders.Count
    }
    else {
        Write-Status "CLAUDE.md: no changes needed" "SKIP"
    }
}

# 9e. Config files
Write-Host ""
Write-Host "  Syncing config files..." -ForegroundColor Cyan
foreach ($cf in $configToSync) {
    $synced = Sync-ConfigFile -RelativePath $cf.Path -SourceBase $TemplatePath -TargetBase $TargetPath `
        -BackupDir $backupDir -Behavior $cf.Behavior -DryRun:$false -NoBackup:$NoBackup
    if ($synced) {
        $dst = Join-Path $TargetPath $cf.Path
        if ($cf.Behavior -eq "always-update") {
            Write-Status "Updated: $($cf.Path)" "SUCCESS"
            $stats.ConfigsUpdated++
        }
        else {
            Write-Status "Created: $($cf.Path)" "NEW"
            $stats.ConfigsCreated++
        }
        $stats.FilesCount++
    }
}

# 9f. Hooks (create-only)
foreach ($h in $hooksToCreate) {
    $src = Join-Path $TemplatePath $h
    $dst = Join-Path $TargetPath $h
    $parentDir = Split-Path $dst -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    Copy-Item -Path $src -Destination $dst -Force
    Write-Status "Created: $h" "NEW"
    $stats.ConfigsCreated++
    $stats.FilesCount++
}

# 9g. Context files (create-only)
foreach ($c in $contextToCreate) {
    $src = Join-Path $TemplatePath $c
    $dst = Join-Path $TargetPath $c
    $parentDir = Split-Path $dst -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    Copy-Item -Path $src -Destination $dst -Force
    Write-Status "Created: $c" "NEW"
    $stats.ConfigsCreated++
    $stats.FilesCount++
}

# 9h. PRPs directory
if ($prpAction -eq "create") {
    $prpsSource = Join-Path $TemplatePath "PRPs"
    $prpsDest = Join-Path $TargetPath "PRPs"
    if (Test-Path $prpsSource) {
        if (-not (Test-Path $prpsDest)) {
            New-Item -ItemType Directory -Path $prpsDest -Force | Out-Null
        }
        $prpFiles = Get-ChildItem -Path $prpsSource -File -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $prpFiles) {
            $rel = $file.FullName.Substring($prpsSource.Length).TrimStart('\', '/')
            $dst = Join-Path $prpsDest $rel
            $parentDir = Split-Path $dst -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            Copy-Item -Path $file.FullName -Destination $dst -Force
            $stats.FilesCount++
        }
        Write-Status "Created PRPs/ directory" "NEW"
    }
}

# 9i. Write template profile
Write-Host ""
Write-Host "  Writing template profile..." -ForegroundColor Cyan
Write-TemplateProfileToConfig -TargetPath $TargetPath `
    -ProjectType $ProjectType -Language $PrimaryLanguage -Framework $Framework `
    -SkillGroups $skillGroups -CommandGroups $commandGroups -DevFrameworks $DevFrameworks `
    -DryRun:$false
Write-Status "Template profile written to .claude/config.yaml" "SUCCESS"

# --- Step 10: Summary ---
Write-Step "10" "Sync Complete"

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "              Claude Code Sync Complete!                              " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""

Write-Host "  Target:  $TargetPath" -ForegroundColor Cyan
Write-Host "  Profile: $ProjectType / $PrimaryLanguage / $(if ($Framework) { $Framework } else { 'none' })" -ForegroundColor Cyan
Write-Host ""

Write-Host "  Statistics:" -ForegroundColor White
Write-Host "    Skills installed:      $($stats.SkillsInstalled)" -ForegroundColor $(if ($stats.SkillsInstalled -gt 0) { "Green" } else { "Gray" })
Write-Host "    Commands installed:    $($stats.CommandsInstalled)" -ForegroundColor $(if ($stats.CommandsInstalled -gt 0) { "Green" } else { "Gray" })
Write-Host "    Configs created:       $($stats.ConfigsCreated)" -ForegroundColor $(if ($stats.ConfigsCreated -gt 0) { "Green" } else { "Gray" })
Write-Host "    Configs updated:       $($stats.ConfigsUpdated)" -ForegroundColor $(if ($stats.ConfigsUpdated -gt 0) { "Yellow" } else { "Gray" })
Write-Host "    CLAUDE.md sections:    $($stats.SectionsAdded)" -ForegroundColor $(if ($stats.SectionsAdded -gt 0) { "Green" } else { "Gray" })
Write-Host "    Placeholders filled:   $($stats.PlaceholdersFilled)" -ForegroundColor $(if ($stats.PlaceholdersFilled -gt 0) { "Cyan" } else { "Gray" })
Write-Host "    Total files touched:   $($stats.FilesCount)" -ForegroundColor White
Write-Host ""

if ($skillDisposition.SkipPlugin.Count -gt 0 -or $skillDisposition.SkipGlobal.Count -gt 0) {
    Write-Host "  Deduplication savings:" -ForegroundColor DarkCyan
    if ($skillDisposition.SkipPlugin.Count -gt 0) {
        Write-Host "    $($skillDisposition.SkipPlugin.Count) skills skipped (covered by global plugins)" -ForegroundColor DarkCyan
    }
    if ($skillDisposition.SkipGlobal.Count -gt 0) {
        Write-Host "    $($skillDisposition.SkipGlobal.Count) skills skipped (installed globally)" -ForegroundColor DarkCyan
    }
    Write-Host ""
}

if (-not $NoBackup -and (Test-Path $backupDir)) {
    $backupCount = (Get-ChildItem -Path $backupDir -File -Recurse -ErrorAction SilentlyContinue).Count
    if ($backupCount -gt 0) {
        Write-Host "  Backups: $backupDir ($backupCount files)" -ForegroundColor Blue
        Write-Host ""
    }
}

Write-Host "  Next steps:" -ForegroundColor Yellow
Write-Host "    1. Review synced files for any project-specific customizations" -ForegroundColor White
Write-Host "    2. Open project with Claude Code and run: /start" -ForegroundColor White
Write-Host "    3. Commit the changes:" -ForegroundColor White
Write-Host "       git add .claude .vscode scripts && git commit -m 'chore: sync Claude Code configuration'" -ForegroundColor DarkGray
Write-Host ""
