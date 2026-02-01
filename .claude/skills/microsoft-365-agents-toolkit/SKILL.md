---
name: microsoft-365-agents-toolkit
description: Expert guidance for Microsoft 365 and Copilot development using the Teams Toolkit MCP server. Access manifest schemas, knowledge base, code snippets for Teams AI/JS/botbuilder SDKs, and troubleshooting. Use when building Microsoft 365 agents, Teams apps, Copilot extensions, or working with Teams development SDKs.
---

# Microsoft 365 Agents Toolkit Expert

Expert guidance for building Microsoft 365 agents, Teams applications, and Copilot extensions using the Microsoft 365 Agents Toolkit MCP server. Access schemas, documentation, code samples, and troubleshooting resources.

## Core Capabilities

1. **Schema Access** - Retrieve manifest schemas for apps and agents
2. **Knowledge Retrieval** - Access Microsoft 365 and Copilot documentation
3. **Code Snippets** - Get templates and SDK examples
4. **Troubleshooting** - Solutions for common development issues

## Quick Reference - MCP Tools

| Tool | Purpose | Parameters |
|------|---------|------------|
| `get_schema` | Get manifest schemas | schema_name, schema_version |
| `get_knowledge` | Access M365 documentation | question |
| `get_code_snippets` | Get SDK code examples | question |
| `troubleshoot` | Get problem solutions | question |

## Tool 1: get_schema

Access manifest and schema definitions for Microsoft 365 development.

**When to use:**
- Creating or validating app manifests
- Building declarative agents
- Developing API plugins
- Working with Teams Toolkit YAML files

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| schema_name | enum | Yes | Schema type to retrieve |
| schema_version | string | Yes | Version (e.g., "v1.4") or "latest" |

**Schema Types:**
- `App manifest` - Teams app manifest schema
- `Declarative agent manifest` - Copilot declarative agent schema
- `API plugin manifest` - API plugin manifest schema
- `M365 agents yaml` - Teams Toolkit YAML schema

**Schema Versions:**
- App manifest: v1.23 (latest)
- Declarative agent manifest: v1.4 (latest)
- API plugin manifest: v2.3 (latest)
- M365 agents yaml: v1.9 (latest)

## Tool 2: get_knowledge

Search Microsoft 365 and Copilot development documentation.

**When to use:**
- Understanding Microsoft 365 concepts
- Learning Copilot extension development
- Researching Teams platform capabilities
- Finding best practices and guidelines

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| question | string | Yes | Search query or question |

**Topics Covered:**
- Microsoft 365 Copilot development
- Teams app development
- Declarative agents
- Message extensions
- Adaptive cards
- Authentication and SSO
- Bot framework integration
- Microsoft Graph API
- Deployment and distribution

**Example Queries:**
- "How do I create a declarative agent for Copilot?"
- "What are the authentication options for Teams apps?"
- "How to implement SSO in a Teams tab?"
- "Best practices for Adaptive Card design"

## Tool 3: get_code_snippets

Access templates and SDK code examples.

**When to use:**
- Implementing Teams AI SDK features
- Using Teams JavaScript SDK
- Working with Bot Builder SDK
- Creating message extensions
- Building adaptive cards

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| question | string | Yes | Query for code examples |

**SDK Coverage:**
- **@microsoft/teams-ai** - Teams AI Library
- **@microsoft/teams-js** - Teams JavaScript SDK
- **botbuilder** - Bot Framework SDK

**Example Queries:**
- "Teams AI SDK: How to create a simple bot?"
- "Teams JS SDK: Implementing tab authentication"
- "Bot Builder: Creating a dialog flow"
- "Message extension with action commands"

## Tool 4: troubleshoot

Get solutions for common development issues.

**When to use:**
- Encountering errors during development
- Debugging Teams app issues
- Resolving authentication problems
- Fixing manifest validation errors
- Solving deployment issues

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| question | string | Yes | Description of the issue |

**Common Issue Categories:**
- Manifest validation errors
- Authentication failures
- Bot not responding
- Tab loading issues
- Message extension errors
- Deployment failures
- Teams Toolkit errors
- Azure configuration problems

## Development Workflows

### Creating a Teams App

```
1. get_knowledge: "How to create a Teams app with Teams Toolkit?"
2. get_schema: App manifest (latest) - understand required fields
3. get_code_snippets: "Teams app starter template"
4. Implement app based on guidance
5. troubleshoot: Any issues encountered
```

### Building a Declarative Agent

```
1. get_knowledge: "What is a declarative agent for Copilot?"
2. get_schema: Declarative agent manifest (latest)
3. get_code_snippets: "Declarative agent example"
4. Create agent manifest
5. get_knowledge: "How to test declarative agents?"
```

### Implementing Bot Functionality

```
1. get_code_snippets: "Bot Builder basic bot example"
2. get_knowledge: "Bot Framework best practices"
3. get_code_snippets: "Handling conversation updates"
4. Implement bot logic
5. get_code_snippets: "Adaptive Card examples"
```

### Adding Authentication

```
1. get_knowledge: "SSO authentication in Teams apps"
2. get_code_snippets: "Teams tab SSO implementation"
3. get_knowledge: "Microsoft Graph API authentication"
4. Implement auth flow
```

## Manifest Types Reference

### App Manifest (Teams App)

**Key Sections:**
- `$schema` - Schema URL for validation
- `manifestVersion` - Version of manifest format
- `id` - Unique app identifier (GUID)
- `version` - App version (semantic versioning)
- `bots` - Bot capabilities
- `composeExtensions` - Message extensions
- `staticTabs` - Tab configurations
- `permissions` - Required permissions
- `validDomains` - Allowed domains

### Declarative Agent Manifest

**Key Sections:**
- `$schema` - Schema validation URL
- `id` - Unique agent identifier
- `name` - Agent name
- `instructions` - System prompt and behavior
- `conversation_starters` - Suggested prompts
- `actions` - API actions agent can perform
- `capabilities` - Agent capabilities (web_search, etc.)

### API Plugin Manifest

**Key Sections:**
- `$schema` - Schema URL
- `name_for_human` - Human-readable name
- `name_for_model` - Model-facing name
- `description_for_model` - Model instruction
- `auth` - Authentication configuration
- `api` - OpenAPI specification reference

## SDK Reference

### @microsoft/teams-ai

**Key Features:**
- AI prompt management
- Action planning
- Conversation handling
- State management
- Authentication

### @microsoft/teams-js

**Key Features:**
- Teams context access
- Authentication flows
- Deep linking
- Task modules
- Navigation

### botbuilder

**Key Features:**
- Dialog management
- Activity handling
- Middleware
- State management
- Adaptive Cards

## Best Practices

### Schema Usage

1. **Always use "latest"** for new projects unless specific version required
2. **Validate manifests** against schemas before deployment
3. **Reference schemas** in IDEs for autocomplete and validation

### Knowledge Queries

1. **Be specific** - Include platform and technology name
2. **Start broad** - Get overview before deep-diving
3. **Verify versions** - Check if guidance applies to your SDK version

### Code Snippets

1. **Understand before copying** - Review code carefully
2. **Adapt to context** - Modify examples for your use case
3. **Check dependencies** - Ensure required packages installed

### Troubleshooting

1. **Include error details** - Provide complete error messages
2. **Describe context** - What were you doing when error occurred?
3. **Try solutions incrementally** - Test one fix at a time

## When to Use This Skill

- Building Microsoft 365 agents and Copilot extensions
- Developing Teams applications (bots, tabs, message extensions)
- Working with Teams AI, Teams JS, or Bot Builder SDKs
- Creating declarative agents for Copilot
- Implementing API plugins
- Troubleshooting Teams development issues
- Validating app manifests
- Learning Microsoft 365 development concepts

## Keywords

microsoft 365, teams, copilot, agents, teams toolkit, bot framework, teams ai sdk, teams js sdk, bot builder, declarative agent, message extension, adaptive cards, manifest, api plugin, sso, authentication, microsoft graph, teams app, copilot extension, m365 development
