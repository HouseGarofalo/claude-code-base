# {{PROJECT_NAME}}

> {{PROJECT_DESCRIPTION}}

[![Build Status](https://github.com/{{ORG}}/{{PROJECT_NAME}}/workflows/CI/badge.svg)](https://github.com/{{ORG}}/{{PROJECT_NAME}}/actions)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Table of Contents

- [Overview](#overview)
- [Solution Architecture](#solution-architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Development](#development)
- [ALM Workflow](#alm-workflow)
- [Directory Structure](#directory-structure)
- [Contributing](#contributing)

---

## Overview

{{PROJECT_DESCRIPTION}}

### Components

- **Solutions**: Dataverse solutions containing customizations
- **PCF Controls**: Custom UI components (TypeScript/React)
- **Plugins**: Server-side business logic (C#/.NET)
- **Flows**: Power Automate cloud flows
- **Copilots**: Conversational agents (Copilot Studio)

---

## Solution Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Power Platform                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ Power Apps  │  │  Power      │  │  Copilot    │         │
│  │ (Canvas &   │  │  Automate   │  │  Studio     │         │
│  │  Model)     │  │  (Flows)    │  │  (Agents)   │         │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘         │
│         │                │                │                  │
│  ┌──────┴────────────────┴────────────────┴──────┐          │
│  │              Dataverse                         │          │
│  │  (Tables, Security, Business Rules, APIs)      │          │
│  └────────────────────────────────────────────────┘          │
│  ┌─────────────┐  ┌─────────────┐                           │
│  │ PCF Controls│  │  Plugins    │                           │
│  │ (TypeScript)│  │  (C#/.NET)  │                           │
│  └─────────────┘  └─────────────┘                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

- [Power Platform CLI (PAC)](https://learn.microsoft.com/power-platform/developer/cli/introduction) >= 1.30
- [Node.js](https://nodejs.org/) >= 18 (for PCF controls)
- [.NET SDK](https://dotnet.microsoft.com/download) >= 8.0 (for plugins)
- Power Platform environment with System Customizer role
- Azure AD app registration (for CI/CD)

### PAC CLI Setup

```bash
# Install PAC CLI (via dotnet tool)
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Authenticate to your environment
pac auth create --environment "https://yourorg.crm.dynamics.com"

# Verify connection
pac env who
```

---

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/{{ORG}}/{{PROJECT_NAME}}.git
cd {{PROJECT_NAME}}
```

### 2. Authenticate to Environment

```bash
pac auth create --environment "https://yourorg.crm.dynamics.com"
```

### 3. Import Solution (First Time)

```bash
# Pack solution from source
pac solution pack --zipfile ./out/Solution.zip --folder ./src/Solution

# Import to your dev environment
pac solution import --path ./out/Solution.zip --publish-changes
```

### 4. Build Components

```bash
# PCF Controls
cd pcf/MyControl
npm install
npm run build

# Plugins
cd plugins/MyPlugin
dotnet build
```

---

## Development

### PCF Controls

```bash
# Start local test harness
cd pcf/MyControl
npm start watch

# Push to dev environment
pac pcf push --publisher-prefix yourprefix
```

### Plugins

```bash
# Build plugin
cd plugins/MyPlugin
dotnet build

# Register with Plugin Registration Tool or PAC CLI
```

### Solution Customizations

```bash
# Export latest from dev environment
pac solution export --path ./out/Solution.zip --name SolutionName --managed false

# Unpack to source control
pac solution unpack --zipfile ./out/Solution.zip --folder ./src/Solution --processCanvasApps
```

---

## ALM Workflow

### Environment Strategy

| Environment | Purpose | Solution Type |
|-------------|---------|---------------|
| **Dev** | Active development | Unmanaged |
| **Test** | QA validation | Managed |
| **Prod** | Production | Managed |

### Deployment Pipeline

```
Dev (Unmanaged) → Export → Pack Managed → Test (Managed) → Prod (Managed)
```

1. Develop in Dev environment (unmanaged)
2. Export and unpack to source control
3. CI pipeline packs managed solution
4. Import managed to Test for validation
5. After approval, import managed to Prod

---

## Directory Structure

```
{{PROJECT_NAME}}/
├── src/                         # Unpacked solution source
│   └── Solution/
│       ├── Entities/            # Table definitions
│       ├── Workflows/           # Cloud flows
│       ├── CanvasApps/          # Canvas app sources
│       ├── WebResources/        # JS, HTML, CSS, images
│       └── Other/               # Other solution components
├── pcf/                         # PCF control projects
│   └── MyControl/
│       ├── ControlManifest.Input.xml
│       ├── index.ts
│       └── package.json
├── plugins/                     # C# plugin projects
│   └── MyPlugin/
│       ├── MyPlugin.csproj
│       └── Plugin1.cs
├── pipelines/                   # CI/CD pipeline definitions
│   ├── azure-pipelines.yml
│   └── .github/workflows/
├── out/                         # Build output (gitignored)
├── docs/                        # Documentation
└── temp/                        # Temporary files (gitignored)
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.
