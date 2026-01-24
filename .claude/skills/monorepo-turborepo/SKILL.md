---
name: monorepo-turborepo
description: Manage monorepos with Turborepo for workspace configuration, task caching, and CI optimization. Use when building multi-package projects, shared libraries, or optimizing large codebases. Triggers on turborepo, monorepo, workspace, pnpm workspace, npm workspace, multi-package, task caching.
---

# Turborepo Monorepo Management

Expert guidance for building and managing monorepos with Turborepo.

## Quick Start

```bash
# Create new Turborepo monorepo
npx create-turbo@latest my-monorepo

# Add Turborepo to existing monorepo
npm install turbo --save-dev

# Run all build tasks
turbo run build

# Run with cache bypass
turbo run build --force
```

## Workspace Configuration

### pnpm Workspaces (Recommended)

```yaml
# pnpm-workspace.yaml
packages:
  - "apps/*"
  - "packages/*"
  - "tools/*"
```

```json
// package.json (root)
{
  "name": "my-monorepo",
  "private": true,
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "test": "turbo run test"
  },
  "devDependencies": {
    "turbo": "^2.0.0"
  },
  "packageManager": "pnpm@9.0.0"
}
```

## turbo.json Configuration

### Basic Configuration

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": [".env", "tsconfig.json"],
  "globalEnv": ["NODE_ENV", "CI"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "build/**"],
      "env": ["API_URL", "DATABASE_URL"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"]
    }
  }
}
```

## Task Dependencies

### Dependency Types

```json
{
  "tasks": {
    // Depends on own package's dependencies' build first
    "build": {
      "dependsOn": ["^build"]
    },

    // Depends on same package's other tasks
    "test": {
      "dependsOn": ["build", "lint"]
    },

    // Depends on specific package's task
    "deploy": {
      "dependsOn": ["@repo/api#build", "@repo/web#build"]
    },

    // No dependencies - runs in parallel
    "lint": {
      "dependsOn": []
    }
  }
}
```

### Task Graph Visualization

```bash
# Visualize task graph
turbo run build --graph

# Output to file
turbo run build --graph=graph.html

# Dry run to see what would execute
turbo run build --dry-run
```

## Filtering and Scopes

### Filter Syntax

```bash
# Run in specific package
turbo run build --filter=@repo/web

# Run in package and dependencies
turbo run build --filter=@repo/web...

# Run in package and dependents
turbo run build --filter=...@repo/ui

# Run in changed packages (since main)
turbo run build --filter=[main]

# Run in changed packages and dependents
turbo run build --filter=...[main]

# Exclude packages
turbo run build --filter=!@repo/docs

# Multiple filters
turbo run build --filter=@repo/web --filter=@repo/api

# Directory-based filter
turbo run build --filter="./apps/*"
```

## Remote Caching

### Vercel Remote Cache

```bash
# Login to Vercel
npx turbo login

# Link to Vercel project
npx turbo link
```

### Self-Hosted Remote Cache

```bash
TURBO_API="https://cache.mycompany.com" \
TURBO_TOKEN="your-token" \
TURBO_TEAM="my-team" \
turbo run build
```

## CI/CD Optimization

### GitHub Actions

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
  TURBO_TEAM: ${{ vars.TURBO_TEAM }}

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 2

      - uses: pnpm/action-setup@v3

      - uses: actions/setup-node@v4
        with:
          cache: "pnpm"

      - run: pnpm install --frozen-lockfile

      - name: Build
        run: pnpm turbo run build --filter="...[HEAD^1]"

      - name: Test
        run: pnpm turbo run test --filter="...[HEAD^1]"
```

## Repository Structure

```
my-monorepo/
+-- apps/
|   +-- web/              # Next.js frontend
|   +-- api/              # Express/Fastify backend
|   +-- docs/             # Documentation site
+-- packages/
|   +-- ui/               # Shared React components
|   +-- utils/            # Shared utilities
|   +-- types/            # Shared TypeScript types
|   +-- config/
|       +-- eslint/       # Shared ESLint config
|       +-- typescript/   # Shared TS config
+-- turbo.json
+-- pnpm-workspace.yaml
+-- package.json
```

## Internal Packages

### Package Configuration

```json
// packages/ui/package.json
{
  "name": "@repo/ui",
  "version": "0.0.0",
  "private": true,
  "exports": {
    ".": "./src/index.ts",
    "./button": "./src/Button.tsx"
  },
  "scripts": {
    "build": "tsup src/index.ts --format cjs,esm --dts",
    "dev": "tsup src/index.ts --format cjs,esm --dts --watch"
  }
}
```

### Consuming Internal Packages

```json
// apps/web/package.json
{
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/utils": "workspace:*"
  }
}
```

## Quick Reference

| Command | Description |
|---------|-------------|
| `turbo run build` | Run build in all packages |
| `turbo run build --filter=web` | Run in specific package |
| `turbo run build --filter=...[main]` | Run in changed packages |
| `turbo run build --force` | Skip cache |
| `turbo run build --dry-run` | Show what would run |
| `turbo run build --graph` | Visualize task graph |
| `turbo prune --docker` | Prune for Docker |
| `turbo login` | Authenticate for remote cache |

## When to Use This Skill

- Setting up new monorepo projects
- Configuring task pipelines
- Optimizing CI/CD build times
- Managing internal packages
- Setting up remote caching
- Filtering builds to affected packages
