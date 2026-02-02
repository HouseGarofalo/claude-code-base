# Claude Code Skills Library

A comprehensive collection of **165 skills** for Claude Code, providing specialized capabilities across cloud infrastructure, AI/ML, frontend/backend development, testing, DevOps, smart home automation, web scraping, and more.

**Last Updated:** 2026-02-02

---

## Overview

Skills are markdown files with YAML frontmatter that define reusable instruction sets Claude can invoke automatically based on context. Unlike slash commands (user-invoked), skills are **model-invoked** - Claude automatically activates relevant skills based on the task at hand.

### How Skills Work

1. **Discovery** - Claude discovers skills from:
   - `~/.claude/skills/` - Global skills (available in all projects)
   - `.claude/skills/` - Project skills (this directory)

2. **Matching** - Skills are matched based on their `description` field keywords

3. **Activation** - When a task matches a skill's triggers, Claude loads and follows the skill's instructions

4. **Precedence** - Project skills take precedence over global skills with the same name

---

## Quick Start

### Using Skills

Skills activate automatically when your task matches their trigger keywords. For example:

```
User: "Help me set up a Next.js app with App Router"
```

Claude will automatically load the `nextjs-app-router` skill and follow its best practices.

### Invoking Skills Manually

You can also reference skills directly:

```
User: "Use the react-typescript skill to create a Button component"
```

---

## Skills by Category

### Cloud & Infrastructure (25 skills)

| Skill | Description |
|-------|-------------|
| [aws-lambda](./aws-lambda/) | Build serverless applications with AWS Lambda and TypeScript |
| [azure-ai](./azure-ai/) | Azure AI services: OpenAI, AI Search, Document Intelligence, Cognitive Services |
| [azure-aks](./azure-aks/) | Managed Kubernetes with Azure Kubernetes Service |
| [azure-api-management](./azure-api-management/) | API gateway and management with Azure API Management |
| [azure-container-apps](./azure-container-apps/) | Deploy containerized apps with auto-scaling, Dapr, traffic splitting |
| [azure-cosmos-db](./azure-cosmos-db/) | Globally distributed NoSQL with Cosmos DB |
| [azure-devops-pipelines](./azure-devops-pipelines/) | Build Azure DevOps YAML pipelines for CI/CD |
| [azure-event-grid](./azure-event-grid/) | Event routing with Azure Event Grid |
| [azure-functions](./azure-functions/) | Build serverless apps with HTTP/timer/queue triggers, durable functions |
| [azure-mcp](./azure-mcp/) | Comprehensive Azure CLI management for 40+ services |
| [azure-service-bus](./azure-service-bus/) | Enterprise messaging with queues, topics, subscriptions |
| [azure-static-web-apps](./azure-static-web-apps/) | Deploy static sites with API routes, auth, custom domains |
| [bicep](./bicep/) | Azure Bicep infrastructure-as-code with best practices |
| [cloudflare](./cloudflare/) | DNS, Tunnels, Zero Trust, WAF, CDN, Workers, Pages |
| [codespaces](./codespaces/) | GitHub Codespaces cloud development environments |
| [docker-compose](./docker-compose/) | Multi-container Docker applications with Compose |
| [haproxy](./haproxy/) | HAProxy load balancer configuration and management |
| [kubernetes-helm](./kubernetes-helm/) | Kubernetes deployment and Helm chart management |
| [nginx-proxy](./nginx-proxy/) | Nginx reverse proxy, SSL termination, load balancing |
| [ssh-server-admin](./ssh-server-admin/) | Remote Linux/Unix server management via SSH |
| [terraform](./terraform/) | Infrastructure as code with Terraform |
| [wireguard](./wireguard/) | WireGuard VPN configuration and management |

### AI & Machine Learning (22 skills)

| Skill | Description |
|-------|-------------|
| [agentic-workflows](./agentic-workflows/) | ReAct agents, planning, tool use, multi-agent orchestration |
| [claude-agent-sdk](./claude-agent-sdk/) | Build custom AI agents using Anthropic Claude API |
| [context-engineering](./context-engineering/) | Optimize prompts, manage tokens, design context windows |
| [crewai](./crewai/) | Multi-agent AI systems with CrewAI |
| [huggingface-transformers](./huggingface-transformers/) | Local model inference, embeddings, fine-tuning |
| [instructor](./instructor/) | Structured outputs with Pydantic models and validation |
| [langchain](./langchain/) | LLM applications with chains, agents, memory, RAG |
| [litellm](./litellm/) | Unified LLM API for 100+ providers |
| [llamaindex](./llamaindex/) | Build indexes, query engines, data connectors for RAG |
| [localai](./localai/) | Self-hosted AI with OpenAI-compatible API |
| [mlflow](./mlflow/) | ML lifecycle management, experiment tracking, model registry |
| [ollama](./ollama/) | Run local LLMs without API costs |
| [openai-api](./openai-api/) | GPT-4, function calling, embeddings, vision, Assistants |
| [openrouter](./openrouter/) | Access 100+ AI models with cost optimization |
| [prompt-engineering](./prompt-engineering/) | Chain-of-thought, few-shot, tree-of-thought prompting |
| [pydantic-ai](./pydantic-ai/) | Type-safe agent framework with structured outputs |
| [rag-patterns](./rag-patterns/) | Chunking, embedding, retrieval, reranking patterns |
| [semantic-kernel](./semantic-kernel/) | Microsoft Semantic Kernel for enterprise AI |
| [text-generation-inference](./text-generation-inference/) | Hugging Face TGI for production LLM serving |

### Frontend Development (24 skills)

| Skill | Description |
|-------|-------------|
| [accessibility-wcag](./accessibility-wcag/) | WCAG 2.1 AA compliance, ARIA, keyboard navigation |
| [animation-motion](./animation-motion/) | Smooth animations with Framer Motion and CSS |
| [component-library](./component-library/) | Design systems, atomic design, Storybook documentation |
| [dashboard-design](./dashboard-design/) | KPI displays, data grids, admin panels, real-time updates |
| [data-visualization](./data-visualization/) | Charts with Recharts, Chart.js, D3.js |
| [form-design](./form-design/) | Accessible forms with react-hook-form, Zod, multi-step |
| [framer-motion](./framer-motion/) | Enter/exit animations, gestures, scroll effects |
| [mobile-pwa](./mobile-pwa/) | PWAs with offline support, push notifications |
| [nextjs-app-router](./nextjs-app-router/) | Next.js 14+ with server/client components, streaming |
| [radix-ui](./radix-ui/) | Accessible React primitives with Radix UI |
| [react-typescript](./react-typescript/) | React 18+ with TypeScript, hooks, state management |
| [responsive-design](./responsive-design/) | Mobile-first, breakpoints, fluid typography, container queries |
| [shadcn-ui](./shadcn-ui/) | Modern React UIs with shadcn/ui and Tailwind |
| [state-management](./state-management/) | Zustand, Redux Toolkit, Jotai, React Query patterns |
| [storybook](./storybook/) | Component documentation and visual testing |
| [svelte-kit](./svelte-kit/) | SvelteKit 2 with Svelte 5 runes and SSR |
| [tailwind-ui](./tailwind-ui/) | Utility-first CSS with Tailwind, dark mode, theming |
| [tanstack-query](./tanstack-query/) | Server state with React Query, caching, mutations |
| [tanstack-router](./tanstack-router/) | Type-safe React routing with loaders |
| [ui-ux-principles](./ui-ux-principles/) | Visual hierarchy, color theory, Gestalt principles |
| [vite](./vite/) | Fast frontend builds with Vite, plugins, optimization |
| [vue-typescript](./vue-typescript/) | Vue 3 with Composition API, Pinia, VueUse |
| [zod-validation](./zod-validation/) | Runtime type validation and schema definition |

### Backend Development (10 skills)

| Skill | Description |
|-------|-------------|
| [api-design-mode](./api-design-mode/) | REST best practices, GraphQL, OpenAPI specifications |
| [dotnet-csharp](./dotnet-csharp/) | .NET 8+ with ASP.NET Core, EF Core, dependency injection |
| [openapi-swagger](./openapi-swagger/) | OpenAPI specs, SDK generation, interactive docs |
| [python-fastapi](./python-fastapi/) | High-performance Python APIs with async, Pydantic |
| [trpc-api](./trpc-api/) | End-to-end typesafe APIs with tRPC |

### Database (7 skills)

| Skill | Description |
|-------|-------------|
| [database-mode](./database-mode/) | Data modeling, query optimization, database architecture |
| [mssql-mcp](./mssql-mcp/) | SQL Server management via MCP natural language |
| [postgresql](./postgresql/) | PostgreSQL with pgvector, JSON, full-text search |
| [prisma-orm](./prisma-orm/) | Type-safe database access with Prisma |
| [supabase](./supabase/) | Auth, real-time, edge functions, PostgreSQL with RLS |

### Testing & Quality (12 skills)

| Skill | Description |
|-------|-------------|
| [cypress](./cypress/) | E2E testing with browser automation, component tests |
| [frontend-testing](./frontend-testing/) | Playwright, Cypress, Jest, React Testing Library |
| [jest](./jest/) | JavaScript/TypeScript unit tests, mocking, snapshots |
| [playwright-mcp](./playwright-mcp/) | Browser automation via Playwright MCP server |
| [pre-commit](./pre-commit/) | Git hooks for linting, formatting, security |
| [puppeteer](./puppeteer/) | Headless Chrome for scraping, testing, screenshots |
| [security-scanner](./security-scanner/) | Trivy, Snyk, OWASP ZAP, SAST/DAST scanning |
| [testing](./testing/) | Unit, integration, E2E with pytest, Jest, Cypress |
| [vitest](./vitest/) | Fast Vite-native testing framework |
| [web-automation](./web-automation/) | Playwright, Puppeteer, Selenium, Scrapy, n8n |

### DevOps & CI/CD (9 skills)

| Skill | Description |
|-------|-------------|
| [github](./github/) | GitHub operations via gh CLI for repos, PRs, issues |
| [github-actions](./github-actions/) | CI/CD workflows, matrix builds, caching |
| [git-workflow](./git-workflow/) | Interactive rebase, cherry-pick, bisect, worktrees |
| [git-worktrees](./git-worktrees/) | Parallel development with multiple branches |
| [monorepo-turborepo](./monorepo-turborepo/) | Turborepo workspace configuration and caching |
| [renovate](./renovate/) | Automated dependency updates with Renovate Bot |
| [semantic-release](./semantic-release/) | Automated versioning and changelog generation |

### Smart Home & IoT (14 skills)

| Skill | Description |
|-------|-------------|
| [adguard-home](./adguard-home/) | AdGuard Home DNS server management and filtering |
| [esphome-devices](./esphome-devices/) | DIY smart home sensors with ESP8266/ESP32 |
| [frigate-nvr](./frigate-nvr/) | Frigate NVR with AI-powered object detection |
| [fully-kiosk](./fully-kiosk/) | Fully Kiosk Browser for Android tablets and dashboards |
| [home-assistant](./home-assistant/) | Complete HA administration, protocols, automations |
| [homebridge](./homebridge/) | Homebridge server for Apple HomeKit integration |
| [matter-thread](./matter-thread/) | Matter and Thread protocol for smart home interoperability |
| [mqtt-iot](./mqtt-iot/) | MQTT brokers (Mosquitto, EMQX) for IoT messaging |
| [node-red-automation](./node-red-automation/) | Flow-based automation with Node-RED |
| [octoprint](./octoprint/) | OctoPrint 3D printer management with Raspberry Pi |
| [scrypted](./scrypted/) | Scrypted video platform with HomeKit Secure Video |
| [tasmota](./tasmota/) | Tasmota firmware for ESP8266/ESP32 devices |
| [zigbee2mqtt](./zigbee2mqtt/) | Zigbee device management with Zigbee2MQTT |

### Agent Skills (20 skills)

Specialized agents for specific tasks:

| Skill | Description |
|-------|-------------|
| [accessibility-auditor-agent](./accessibility-auditor-agent/) | WCAG 2.1 AA compliance audits, screen reader testing |
| [ai-engineer-agent](./ai-engineer-agent/) | Build LLM apps, RAG systems, prompt pipelines |
| [api-designer-agent](./api-designer-agent/) | REST API design, OpenAPI specs, versioning |
| [api-documenter-agent](./api-documenter-agent/) | OpenAPI/Swagger specs, SDK generation |
| [architect-reviewer-agent](./architect-reviewer-agent/) | Review code for architectural consistency |
| [background-researcher-agent](./background-researcher-agent/) | Deep research for technologies and patterns |
| [code-reviewer-agent](./code-reviewer-agent/) | Systematic multi-dimensional code review |
| [code-simplifier-agent](./code-simplifier-agent/) | Code cleanup, reduce complexity, improve readability |
| [data-engineer-agent](./data-engineer-agent/) | ETL pipelines, data warehouses, streaming |
| [database-architect-agent](./database-architect-agent/) | Database design, schema optimization, migrations |
| [devops-engineer-agent](./devops-engineer-agent/) | Docker, Kubernetes, CI/CD, cloud deployments |
| [docs-architect-agent](./docs-architect-agent/) | Comprehensive technical documentation from codebases |
| [documentation-manager-agent](./documentation-manager-agent/) | Keep documentation in sync with code changes |
| [frontend-architect-agent](./frontend-architect-agent/) | Component architecture, design systems, UI patterns |
| [git-wizard-agent](./git-wizard-agent/) | Complex git operations, branching strategies |
| [performance-optimizer-agent](./performance-optimizer-agent/) | Profiling, Core Web Vitals, caching strategies |
| [prp-codebase-explorer-agent](./prp-codebase-explorer-agent/) | Explore codebase structure and extract patterns |
| [prp-orchestrator-agent](./prp-orchestrator-agent/) | End-to-end PRP workflow orchestration |
| [python-pro-agent](./python-pro-agent/) | Idiomatic Python with advanced features |
| [security-auditor-agent](./security-auditor-agent/) | Vulnerability assessment, threat modeling, OWASP |

### Contextual Modes (15 skills)

Activate specialized working modes:

| Skill | Description |
|-------|-------------|
| [accessibility-mode](./accessibility-mode/) | WCAG compliance specialist for auditing and fixing |
| [architecture-mode](./architecture-mode/) | Systems architecture, scalable design, ADRs |
| [code-migration-mode](./code-migration-mode/) | Legacy modernization with strangler fig pattern |
| [code-review-mode](./code-review-mode/) | Senior code reviewer with constructive feedback |
| [compliance-mode](./compliance-mode/) | SOX, GDPR, HIPAA, PCI-DSS requirements |
| [database-mode](./database-mode/) | Data modeling and query optimization specialist |
| [debugging-mode](./debugging-mode/) | Systematic debugging and root cause analysis |
| [documentation-mode](./documentation-mode/) | Technical writing for READMEs, API docs, guides |
| [onboarding-mode](./onboarding-mode/) | Patient mentor for new developer onboarding |
| [pair-programmer-mode](./pair-programmer-mode/) | Collaborative coding partner who thinks aloud |
| [performance-mode](./performance-mode/) | Profiling, bottleneck identification, optimization |
| [refactoring-mode](./refactoring-mode/) | Clean code, SOLID principles, design patterns |
| [security-audit-mode](./security-audit-mode/) | Vulnerability identification and threat modeling |
| [tdd-mode](./tdd-mode/) | Test-driven development with Red-Green-Refactor |

### Microsoft (5 skills)

| Skill | Description |
|-------|-------------|
| [fabric-rti-mcp](./fabric-rti-mcp/) | Microsoft Fabric Real-Time Intelligence with KQL |
| [microsoft-365-agents-toolkit](./microsoft-365-agents-toolkit/) | Teams Toolkit, Copilot extensions, Teams apps |
| [microsoft-fabric](./microsoft-fabric/) | Fabric development with APIs, OneLake, workloads |

### Harness Skills (6 skills)

Autonomous development harness system:

| Skill | Description |
|-------|-------------|
| [autonomous-agent-harness](./autonomous-agent-harness/) | Set up autonomous coding agent projects |
| [harness-coder](./harness-coder/) | Main coding agent for multi-session development |
| [harness-initializer](./harness-initializer/) | First-session agent for project initialization |
| [harness-reviewer](./harness-reviewer/) | Code review before feature completion |
| [harness-tester](./harness-tester/) | Testing orchestrator with Playwright support |
| [harness-wizard](./harness-wizard/) | Interactive setup wizard for harness projects |

### Web Scraping & Data Extraction (1 skill)

| Skill | Description |
|-------|-------------|
| [crawl4ai](./crawl4ai/) | AI-ready web crawling with markdown conversion, LLM extraction, and RAG integration |

### Utilities & Documentation (15 skills)

| Skill | Description |
|-------|-------------|
| [archon-workflow](./archon-workflow/) | Task management with Archon MCP server |
| [browserless](./browserless/) | Cloud headless Chrome for scraping and screenshots |
| [claude-sync](./claude-sync/) | Synchronize Claude Code configuration files |
| [code-review](./code-review/) | Code review practices and checklists |
| [documentation](./documentation/) | Technical documentation best practices |
| [excalidraw](./excalidraw/) | Hand-drawn architecture diagrams |
| [grafana-dashboards](./grafana-dashboards/) | Monitoring dashboards with Prometheus/InfluxDB |
| [markitdown](./markitdown/) | Convert documents to Markdown with MarkItDown |
| [mcp-development](./mcp-development/) | Build MCP servers and clients |
| [mermaid-diagrams](./mermaid-diagrams/) | Flowcharts, sequences, ERDs in Mermaid |
| [obsidian](./obsidian/) | Obsidian plugins, Dataview queries, PKM systems |
| [prp-framework](./prp-framework/) | Product Requirement Prompts for PRDs |
| [prp-generator](./prp-generator/) | Generate PRD documents and specifications |
| [project-wizard](./project-wizard/) | Interactive project setup with GitHub and Archon |
| [ralph-loop](./ralph-loop/) | Iterative development loops for autonomous work |
| [ralph-monitor](./ralph-monitor/) | Monitor Ralph Wiggum loop progress |
| [speckit-workflow](./speckit-workflow/) | Spec-driven development for feature specifications |
| [streamlit-dashboards](./streamlit-dashboards/) | Python-native dashboards with Streamlit |

---

## Skill Format

Each skill is a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: skill-name
description: |
  Brief description of what this skill does and when to use it.
  Include keywords that would trigger this skill. Maximum 1024 characters.
---

# Skill Name

## Overview
What this skill accomplishes.

## When to Use
- Trigger condition 1
- Trigger condition 2

## Instructions
Detailed step-by-step instructions for Claude to follow.

## Examples
Example inputs and expected outputs.
```

### Naming Conventions

- **Directory name**: `lowercase-with-hyphens`
- **Skill file**: Always named `SKILL.md`
- **Name field**: Must match directory name
- **Max length**: 64 characters for name

---

## Creating Custom Skills

### 1. Create Directory

```bash
mkdir .claude/skills/my-new-skill
```

### 2. Create SKILL.md

```markdown
---
name: my-new-skill
description: Describe what this skill does and when to trigger it. Include relevant keywords.
---

# My New Skill

## When to Use
- When the user asks about X
- When working with Y technology
- Keywords: keyword1, keyword2, keyword3

## Instructions
1. Step one...
2. Step two...
3. Step three...

## Best Practices
- Practice 1
- Practice 2
```

### 3. Best Practices

1. **Descriptive triggers** - Write descriptions that clearly indicate when to activate
2. **Focused scope** - One skill, one capability
3. **Clear instructions** - Unambiguous, step-by-step guidance
4. **Include examples** - Show expected inputs and outputs
5. **Error handling** - What to do when things go wrong

---

## Skill Discovery

Claude discovers skills from two locations:

1. **Global Skills** (`~/.claude/skills/`) - Available in all projects
2. **Project Skills** (`.claude/skills/`) - This directory

### Discovery Process

1. When a task is received, Claude scans skill descriptions
2. Skills with matching keywords are loaded
3. The skill's instructions guide Claude's response
4. Project skills override global skills with the same name

### Manual Activation

You can explicitly activate skills:

```
User: "Use the security-auditor-agent skill to review this code"
```

---

## Documentation

- [Skills Overview](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Creating Skills](https://docs.anthropic.com/en/docs/claude-code/tutorials/skills)
- [Skill Format Reference](https://docs.anthropic.com/en/docs/claude-code/reference/skill-format)

---

## Statistics

| Category | Count |
|----------|-------|
| Cloud & Infrastructure | 22 |
| AI & Machine Learning | 19 |
| Frontend Development | 24 |
| Backend Development | 5 |
| Database | 5 |
| Testing & Quality | 10 |
| DevOps & CI/CD | 7 |
| Smart Home & IoT | 14 |
| Agent Skills | 20 |
| Contextual Modes | 14 |
| Microsoft | 3 |
| Harness Skills | 6 |
| Web Scraping & Data Extraction | 1 |
| Utilities & Documentation | 15 |
| **Total** | **165** |

---

*This library is actively maintained. Add new skills to teach Claude project-specific capabilities.*
