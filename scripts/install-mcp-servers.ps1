<#
.SYNOPSIS
    Install and configure common MCP servers for Claude Code.

.DESCRIPTION
    This script installs common Model Context Protocol (MCP) servers
    and configures them in the appropriate mcp.json files.

    Supported MCP servers:
    - Archon (Project/Task management)
    - Brave Search (Web search)
    - Playwright (Browser automation)
    - Serena (Code intelligence)
    - Filesystem (File operations)
    - Memory (Persistent memory)

.PARAMETER Servers
    Comma-separated list of servers to install. Default: all

.PARAMETER SkipInstall
    Only configure mcp.json, skip package installation.

.PARAMETER Global
    Install to global ~/.claude/ instead of project .vscode/

.PARAMETER Force
    Overwrite existing configuration.

.EXAMPLE
    .\install-mcp-servers.ps1
    Install all supported MCP servers.

.EXAMPLE
    .\install-mcp-servers.ps1 -Servers "archon,brave-search"
    Install only Archon and Brave Search servers.

.EXAMPLE
    .\install-mcp-servers.ps1 -Global
    Configure servers in global ~/.claude/mcp.json
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$Servers = "all",

    [Parameter()]
    [switch]$SkipInstall,

    [Parameter()]
    [switch]$Global,

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# =============================================================================
# CONFIGURATION
# =============================================================================

$AllServers = @(
    'archon',
    'brave-search',
    'playwright',
    'serena',
    'filesystem',
    'memory'
)

# MCP Server definitions
$ServerDefinitions = @{
    'archon' = @{
        Name = 'archon'
        Package = 'archon-ai'
        PackageManager = 'pip'
        Command = 'archon'
        Args = @('mcp-server')
        Description = 'Project and task management'
        RequiresEnv = @('ARCHON_API_URL')
    }
    'brave-search' = @{
        Name = 'brave-search'
        Package = '@anthropic/mcp-brave-search'
        PackageManager = 'npm'
        Command = 'npx'
        Args = @('-y', '@anthropic/mcp-brave-search')
        Description = 'Web search via Brave'
        RequiresEnv = @('BRAVE_API_KEY')
    }
    'playwright' = @{
        Name = 'playwright'
        Package = '@anthropic/mcp-playwright'
        PackageManager = 'npm'
        Command = 'npx'
        Args = @('-y', '@anthropic/mcp-playwright')
        Description = 'Browser automation'
        RequiresEnv = @()
    }
    'serena' = @{
        Name = 'serena'
        Package = 'serena-mcp'
        PackageManager = 'pip'
        Command = 'serena'
        Args = @('serve')
        Description = 'Code intelligence and refactoring'
        RequiresEnv = @()
    }
    'filesystem' = @{
        Name = 'filesystem'
        Package = '@modelcontextprotocol/server-filesystem'
        PackageManager = 'npm'
        Command = 'npx'
        Args = @('-y', '@modelcontextprotocol/server-filesystem', '.')
        Description = 'File system operations'
        RequiresEnv = @()
    }
    'memory' = @{
        Name = 'memory'
        Package = '@modelcontextprotocol/server-memory'
        PackageManager = 'npm'
        Command = 'npx'
        Args = @('-y', '@modelcontextprotocol/server-memory')
        Description = 'Persistent memory storage'
        RequiresEnv = @()
    }
}

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

function Test-CommandExists {
    param([string]$Command)
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-PackageManagers {
    $Results = @{
        npm = Test-CommandExists 'npm'
        pip = Test-CommandExists 'pip'
        uv = Test-CommandExists 'uv'
    }

    Write-Status "Package managers available:" -Type Info
    foreach ($Pm in $Results.Keys) {
        $Status = if ($Results[$Pm]) { "Available" } else { "Not found" }
        $Color = if ($Results[$Pm]) { 'Green' } else { 'Yellow' }
        Write-Host "  - ${Pm}: $Status" -ForegroundColor $Color
    }
    Write-Host ""

    return $Results
}

function Install-McpPackage {
    param(
        [hashtable]$ServerDef,
        [hashtable]$PackageManagers
    )

    $Package = $ServerDef.Package
    $Pm = $ServerDef.PackageManager

    if ($Pm -eq 'npm' -and -not $PackageManagers.npm) {
        Write-Status "npm not available, skipping $Package installation" -Type Warning
        return $false
    }

    if ($Pm -eq 'pip') {
        if ($PackageManagers.uv) {
            # Prefer uv if available
            Write-Status "Installing $Package with uv..." -Type Info
            $Result = & uv pip install $Package 2>&1
        }
        elseif ($PackageManagers.pip) {
            Write-Status "Installing $Package with pip..." -Type Info
            $Result = & pip install $Package 2>&1
        }
        else {
            Write-Status "pip/uv not available, skipping $Package installation" -Type Warning
            return $false
        }
    }
    elseif ($Pm -eq 'npm') {
        Write-Status "Installing $Package with npm..." -Type Info
        $Result = & npm install -g $Package 2>&1
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Status "Installed $Package successfully" -Type Success
        return $true
    }
    else {
        Write-Status "Failed to install ${Package}: $Result" -Type Error
        return $false
    }
}

function Get-McpConfigPath {
    if ($Global) {
        return Join-Path $env:USERPROFILE '.claude\mcp.json'
    }
    else {
        return '.\.vscode\mcp.json'
    }
}

function Get-McpConfig {
    param([string]$ConfigPath)

    if (Test-Path $ConfigPath) {
        try {
            $Content = Get-Content $ConfigPath -Raw
            return $Content | ConvertFrom-Json -AsHashtable
        }
        catch {
            Write-Status "Invalid mcp.json, creating new configuration" -Type Warning
            return @{ mcpServers = @{} }
        }
    }

    return @{ mcpServers = @{} }
}

function Add-McpServerConfig {
    param(
        [hashtable]$Config,
        [hashtable]$ServerDef
    )

    $ServerName = $ServerDef.Name

    if ($Config.mcpServers.ContainsKey($ServerName) -and -not $Force) {
        Write-Status "Server '$ServerName' already configured, use -Force to overwrite" -Type Warning
        return $false
    }

    $ServerConfig = @{
        command = $ServerDef.Command
        args = $ServerDef.Args
    }

    # Add environment variables if required
    if ($ServerDef.RequiresEnv.Count -gt 0) {
        $ServerConfig.env = @{}
        foreach ($EnvVar in $ServerDef.RequiresEnv) {
            $ServerConfig.env[$EnvVar] = "`${env:$EnvVar}"
        }
    }

    $Config.mcpServers[$ServerName] = $ServerConfig
    Write-Status "Added configuration for $ServerName" -Type Success

    return $true
}

function Save-McpConfig {
    param(
        [string]$ConfigPath,
        [hashtable]$Config
    )

    $Dir = Split-Path $ConfigPath -Parent
    if (-not (Test-Path $Dir)) {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    }

    $JsonContent = $Config | ConvertTo-Json -Depth 10
    Set-Content -Path $ConfigPath -Value $JsonContent -Encoding UTF8

    Write-Status "Saved configuration to $ConfigPath" -Type Success
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

function Main {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " MCP Server Installation" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # Determine which servers to install
    $ServersToInstall = if ($Servers -eq 'all') {
        $AllServers
    }
    else {
        $Servers -split ',' | ForEach-Object { $_.Trim().ToLower() }
    }

    # Validate server names
    foreach ($Server in $ServersToInstall) {
        if (-not $ServerDefinitions.ContainsKey($Server)) {
            Write-Status "Unknown server: $Server" -Type Error
            Write-Status "Available servers: $($AllServers -join ', ')" -Type Info
            exit 1
        }
    }

    Write-Status "Servers to install: $($ServersToInstall -join ', ')" -Type Info
    Write-Host ""

    # Check package managers
    $PackageManagers = Test-PackageManagers

    # Install packages
    if (-not $SkipInstall) {
        Write-Host "Installing packages..." -ForegroundColor Cyan
        Write-Host ""

        foreach ($Server in $ServersToInstall) {
            $ServerDef = $ServerDefinitions[$Server]
            $Installed = Install-McpPackage -ServerDef $ServerDef -PackageManagers $PackageManagers
        }

        Write-Host ""
    }
    else {
        Write-Status "Skipping package installation (-SkipInstall)" -Type Info
        Write-Host ""
    }

    # Configure mcp.json
    Write-Host "Configuring mcp.json..." -ForegroundColor Cyan
    Write-Host ""

    $ConfigPath = Get-McpConfigPath
    Write-Status "Configuration file: $ConfigPath" -Type Info

    $Config = Get-McpConfig -ConfigPath $ConfigPath

    $ConfiguredCount = 0
    foreach ($Server in $ServersToInstall) {
        $ServerDef = $ServerDefinitions[$Server]
        $Added = Add-McpServerConfig -Config $Config -ServerDef $ServerDef
        if ($Added) { $ConfiguredCount++ }
    }

    if ($ConfiguredCount -gt 0) {
        Save-McpConfig -ConfigPath $ConfigPath -Config $Config
    }

    # Summary
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " Installation Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Status "Configured $ConfiguredCount server(s)" -Type Success
    Write-Host ""

    # Check for required environment variables
    $RequiredEnvVars = @()
    foreach ($Server in $ServersToInstall) {
        $ServerDef = $ServerDefinitions[$Server]
        $RequiredEnvVars += $ServerDef.RequiresEnv
    }

    if ($RequiredEnvVars.Count -gt 0) {
        Write-Host "Required environment variables:" -ForegroundColor Yellow
        foreach ($EnvVar in ($RequiredEnvVars | Select-Object -Unique)) {
            $Value = [Environment]::GetEnvironmentVariable($EnvVar)
            $Status = if ($Value) { "Set" } else { "NOT SET" }
            $Color = if ($Value) { 'Green' } else { 'Red' }
            Write-Host "  - ${EnvVar}: $Status" -ForegroundColor $Color
        }
        Write-Host ""
    }

    Write-Status "Restart Claude Code to load the MCP servers" -Type Info
    Write-Host ""

    # Show configured servers
    Write-Host "Configured MCP servers:" -ForegroundColor Cyan
    foreach ($ServerName in $Config.mcpServers.Keys) {
        $Def = $ServerDefinitions[$ServerName]
        $Desc = if ($Def) { " - $($Def.Description)" } else { "" }
        Write-Host "  - $ServerName$Desc" -ForegroundColor White
    }
}

# Run main function
Main
