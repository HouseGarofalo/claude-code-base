# {{PROJECT_NAME}}

> {{PROJECT_DESCRIPTION}}

[![npm version](https://badge.fury.io/js/{{PROJECT_NAME}}.svg)](https://badge.fury.io/js/{{PROJECT_NAME}})
[![Build Status](https://github.com/{{ORG}}/{{PROJECT_NAME}}/workflows/CI/badge.svg)](https://github.com/{{ORG}}/{{PROJECT_NAME}}/actions)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Development](#development)
- [Contributing](#contributing)

---

## Overview

{{PROJECT_DESCRIPTION}}

### Features

- Built with {{LANGUAGE}}
- Full test coverage
- Well-documented API
- Minimal dependencies

---

## Installation

```bash
# npm
npm install {{PROJECT_NAME}}

# pnpm
pnpm add {{PROJECT_NAME}}

# yarn
yarn add {{PROJECT_NAME}}
```

### CLI Installation (if applicable)

```bash
# Global installation
npm install -g {{PROJECT_NAME}}

# Or use npx
npx {{PROJECT_NAME}} <command>
```

---

## Usage

### As a Library

```typescript
import { someFunction } from '{{PROJECT_NAME}}';

const result = someFunction({
  option1: 'value',
  option2: true,
});

console.log(result);
```

### As a CLI

```bash
# Basic usage
{{PROJECT_NAME}} <command> [options]

# Examples
{{PROJECT_NAME}} init
{{PROJECT_NAME}} run --config ./config.json
{{PROJECT_NAME}} --help
```

---

## API Reference

### `someFunction(options)`

Description of the function.

**Parameters:**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `option1` | `string` | - | Description |
| `option2` | `boolean` | `false` | Description |

**Returns:** `ResultType`

**Example:**

```typescript
const result = someFunction({
  option1: 'hello',
  option2: true,
});
```

---

## CLI Commands

### `init`

Initialize a new configuration.

```bash
{{PROJECT_NAME}} init [--force]
```

### `run`

Run the main process.

```bash
{{PROJECT_NAME}} run [--config <path>] [--verbose]
```

---

## Development

### Prerequisites

- Node.js 18+
- pnpm (recommended)

### Setup

```bash
# Clone the repository
git clone https://github.com/{{ORG}}/{{PROJECT_NAME}}.git
cd {{PROJECT_NAME}}

# Install dependencies
pnpm install

# Build
pnpm build

# Run tests
pnpm test
```

### Project Structure

```
src/
├── index.ts          # Main entry point
├── cli.ts            # CLI entry point
├── commands/         # CLI commands
├── lib/              # Core library code
├── utils/            # Utility functions
└── types/            # TypeScript types
```

### Available Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Build the package |
| `pnpm dev` | Build in watch mode |
| `pnpm test` | Run tests |
| `pnpm lint` | Run linter |
| `pnpm typecheck` | Check types |

---

## Publishing

```bash
# Bump version
npm version patch|minor|major

# Publish
npm publish
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.
