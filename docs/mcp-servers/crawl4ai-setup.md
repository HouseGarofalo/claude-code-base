# Crawl4AI MCP Server Setup Guide

> **Version**: 2.0 | **Last Updated**: 2026-02-03
> **Location**: `mcp-servers/crawl4ai-rag/`

A step-by-step guide to setting up the Crawl4AI MCP server for Claude Code with Vector RAG (Supabase) and Graph RAG (Neo4j) capabilities.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start (Basic Crawling)](#quick-start-basic-crawling)
- [Full Setup (With RAG)](#full-setup-with-rag)
  - [Step 1: Azure OpenAI Setup](#step-1-azure-openai-setup)
  - [Step 2: Supabase Setup (Vector RAG)](#step-2-supabase-setup-vector-rag)
  - [Step 3: Neo4j Setup (Graph RAG)](#step-3-neo4j-setup-graph-rag)
  - [Step 4: Configure Credentials](#step-4-configure-credentials)
  - [Step 5: Register MCP Server](#step-5-register-mcp-server)
- [Configuration Options](#configuration-options)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Architecture](#architecture)

---

## Overview

The Crawl4AI MCP server provides Claude Code with web crawling capabilities and dual RAG (Retrieval-Augmented Generation) storage:

| Feature | Description |
|---------|-------------|
| **Basic Crawling** | Extract markdown content from any URL |
| **Vector RAG** | Semantic search via Supabase pgvector + Azure OpenAI embeddings |
| **Graph RAG** | Knowledge graph storage and querying via Neo4j |
| **Opt-in Storage** | Data is NOT stored by default - you control when to persist |

### Key Features in v2.0

- **Azure OpenAI**: Uses Azure OpenAI for embeddings (enterprise-ready)
- **Global Credentials**: Loads from `~/.claude/.env` automatically
- **Opt-in Storage**: Use `store_in_db=True` and/or `store_in_graph=True` to save
- **Multi-stage Docker**: Choose your deployment size (basic, vector, graph, full)

---

## Prerequisites

### Required (Basic Crawling)

- Python 3.10+
- Playwright browsers (`crawl4ai-setup` or `playwright install chromium`)

### Optional (Vector RAG)

- Azure OpenAI subscription with embedding model deployment
- Supabase project with pgvector extension

### Optional (Graph RAG)

- Neo4j database (Desktop, Docker, or Aura Cloud)

---

## Quick Start (Basic Crawling)

For basic web crawling without RAG storage:

### 1. Install the Package

```bash
cd mcp-servers/crawl4ai-rag

# Basic installation
pip install -e .

# Install Playwright browsers
crawl4ai-setup
# or: playwright install chromium
```

### 2. Register with Claude Code

Add to your MCP configuration (`~/.claude/mcp.json` or `.vscode/mcp.json`):

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "python",
      "args": ["-m", "src.crawl4ai_mcp_server"],
      "cwd": "E:/Repos/HouseGarofalo/claude-code-base/mcp-servers/crawl4ai-rag"
    }
  }
}
```

### 3. Test It

Ask Claude Code to crawl a page:

```
Crawl https://docs.anthropic.com and summarize the main features
```

---

## Full Setup (With RAG)

### Step 1: Azure OpenAI Setup

1. **Create Azure OpenAI Resource**
   - Go to [Azure Portal](https://portal.azure.com)
   - Create an "Azure OpenAI" resource
   - Note your **Endpoint URL** and **API Key**

2. **Deploy Embedding Model**
   - In Azure AI Studio, go to Deployments
   - Deploy `text-embedding-3-small` (recommended) or `text-embedding-ada-002`
   - Note your **Deployment Name**

3. **Gather Credentials**
   ```
   AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
   AZURE_OPENAI_API_KEY=your-api-key-here
   AZURE_OPENAI_API_VERSION=2024-12-01-preview
   AZURE_EMBEDDING_DEPLOYMENT=text-embedding-3-small
   ```

---

### Step 2: Supabase Setup (Vector RAG)

1. **Create Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Create a new project
   - Note your **Project URL** and **Service Role Key** (Settings > API)

2. **Run Database Setup**
   - Go to SQL Editor in Supabase Dashboard
   - Copy and run the contents of `supabase_setup.sql`:

   ```sql
   -- Enable pgvector extension
   CREATE EXTENSION IF NOT EXISTS vector;

   -- Create table for crawled content
   CREATE TABLE IF NOT EXISTS crawled_content (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       url TEXT NOT NULL,
       title TEXT,
       content TEXT NOT NULL,
       embedding VECTOR(1536),
       metadata JSONB DEFAULT '{}',
       created_at TIMESTAMPTZ DEFAULT NOW(),
       updated_at TIMESTAMPTZ DEFAULT NOW()
   );

   -- Create indexes
   CREATE INDEX IF NOT EXISTS idx_crawled_content_url ON crawled_content(url);
   CREATE INDEX IF NOT EXISTS idx_crawled_content_embedding
       ON crawled_content USING ivfflat (embedding vector_cosine_ops)
       WITH (lists = 100);

   -- Create search function
   CREATE OR REPLACE FUNCTION match_documents(
       query_embedding VECTOR(1536),
       match_count INT DEFAULT 5,
       filter_url TEXT DEFAULT NULL
   )
   RETURNS TABLE (
       id UUID,
       url TEXT,
       title TEXT,
       content TEXT,
       similarity FLOAT
   )
   LANGUAGE plpgsql
   AS $$
   BEGIN
       RETURN QUERY
       SELECT
           c.id,
           c.url,
           c.title,
           c.content,
           1 - (c.embedding <=> query_embedding) AS similarity
       FROM crawled_content c
       WHERE (filter_url IS NULL OR c.url ILIKE '%' || filter_url || '%')
       ORDER BY c.embedding <=> query_embedding
       LIMIT match_count;
   END;
   $$;
   ```

3. **Gather Credentials**
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

---

### Step 3: Neo4j Setup (Graph RAG)

Choose one deployment option:

#### Option A: Neo4j Desktop (Local Development)

1. Download [Neo4j Desktop](https://neo4j.com/download/)
2. Create a new database
3. Start the database
4. Default credentials: `neo4j` / `neo4j` (you'll be prompted to change)

#### Option B: Docker (Recommended for Development)

```bash
docker run \
  --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/your-password \
  -d neo4j:latest
```

#### Option C: Neo4j Aura (Cloud)

1. Go to [neo4j.com/aura](https://neo4j.com/cloud/aura/)
2. Create a free instance
3. Note your connection URI (starts with `neo4j+s://`)

#### Run Database Setup

In Neo4j Browser (http://localhost:7474 for local), run `neo4j_setup.cypher`:

```cypher
-- Create constraints
CREATE CONSTRAINT webpage_url IF NOT EXISTS
FOR (p:WebPage) REQUIRE p.url IS UNIQUE;

CREATE CONSTRAINT domain_name IF NOT EXISTS
FOR (d:Domain) REQUIRE d.name IS UNIQUE;

CREATE CONSTRAINT topic_name IF NOT EXISTS
FOR (t:Topic) REQUIRE t.name IS UNIQUE;

-- Create indexes
CREATE INDEX webpage_title IF NOT EXISTS
FOR (p:WebPage) ON (p.title);

CREATE INDEX webpage_crawled_at IF NOT EXISTS
FOR (p:WebPage) ON (p.crawled_at);
```

#### Gather Credentials

```
NEO4J_URI=bolt://localhost:7687        # or neo4j+s://xxx.databases.neo4j.io
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your-password
```

---

### Step 4: Configure Credentials

Create or update `~/.claude/.env` with your credentials:

```bash
# =============================================================================
# Crawl4AI MCP Server - Global Credentials
# =============================================================================
# These are loaded automatically by the Crawl4AI MCP server

# Azure OpenAI (for embeddings)
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-azure-openai-api-key
AZURE_OPENAI_API_VERSION=2024-12-01-preview
AZURE_EMBEDDING_DEPLOYMENT=text-embedding-3-small

# Supabase (Vector RAG)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Neo4j (Graph RAG)
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your-neo4j-password
```

**Note**: The server loads credentials in this order:
1. Local `.env` file (project-specific overrides)
2. Global `~/.claude/.env` (shared credentials - fallback)

---

### Step 5: Register MCP Server

Add to your Claude Code MCP configuration:

#### Option A: Global Configuration (`~/.claude/mcp.json`)

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "python",
      "args": ["-m", "src.crawl4ai_mcp_server"],
      "cwd": "E:/Repos/HouseGarofalo/claude-code-base/mcp-servers/crawl4ai-rag"
    }
  }
}
```

#### Option B: VS Code Project Configuration (`.vscode/mcp.json`)

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "python",
      "args": ["-m", "src.crawl4ai_mcp_server"],
      "cwd": "${workspaceFolder}/mcp-servers/crawl4ai-rag"
    }
  }
}
```

#### Option C: Using Entry Point (after pip install)

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "crawl4ai-mcp"
    }
  }
}
```

---

## Configuration Options

### Installation Variants

```bash
# Basic (crawling only)
pip install -e .

# With Vector RAG (Supabase + Azure OpenAI)
pip install -e ".[rag]"

# With Graph RAG (Neo4j)
pip install -e ".[graph]"

# Full installation
pip install -e ".[all]"
```

### Docker Build Targets

```bash
# Basic crawling only
docker build --target production -t crawl4ai-mcp:latest .

# With Vector RAG
docker build --target with-vector-rag -t crawl4ai-mcp:vector .

# With Graph RAG
docker build --target with-graph-rag -t crawl4ai-mcp:graph .

# Full (Vector + Graph)
docker build --target full -t crawl4ai-mcp:full .

# Development
docker build --target development -t crawl4ai-mcp:dev .
```

### Environment Variables Reference

| Variable | Required For | Default | Description |
|----------|--------------|---------|-------------|
| `TRANSPORT` | All | `stdio` | Transport mode: `stdio` or `sse` |
| `HEADLESS` | All | `true` | Run browser headless |
| `BROWSER_TYPE` | All | `chromium` | Browser engine |
| `MEAN_DELAY` | All | `0.5` | Delay between requests (seconds) |
| `MAX_CONCURRENT` | All | `5` | Max concurrent crawls |
| `AZURE_OPENAI_ENDPOINT` | Vector RAG | - | Azure OpenAI endpoint |
| `AZURE_OPENAI_API_KEY` | Vector RAG | - | Azure OpenAI API key |
| `AZURE_EMBEDDING_DEPLOYMENT` | Vector RAG | `text-embedding-3-small` | Embedding model deployment |
| `SUPABASE_URL` | Vector RAG | - | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Vector RAG | - | Supabase service key |
| `NEO4J_URI` | Graph RAG | `bolt://localhost:7687` | Neo4j connection URI |
| `NEO4J_USERNAME` | Graph RAG | `neo4j` | Neo4j username |
| `NEO4J_PASSWORD` | Graph RAG | - | Neo4j password |

---

## Usage Examples

### Basic Crawling (No Storage)

```
User: Crawl https://docs.anthropic.com and summarize

Claude: [Uses crawl_single_page - content returned but NOT stored]
```

### Crawl and Store in Vector DB

```
User: Crawl https://docs.anthropic.com and save for later

Claude: [Uses crawl_single_page with store_in_db=true]
```

### Crawl and Store in Both Databases

```
User: Crawl the Anthropic docs and save to my knowledge base

Claude: [Uses crawl_single_page with store_in_db=true, store_in_graph=true]
```

### Search Vector Database

```
User: Search my crawled docs for information about rate limits

Claude: [Uses search_crawled_content with query="rate limits"]
```

### Query Knowledge Graph

```
User: What topics are covered by docs I've crawled from Anthropic?

Claude: [Uses search_knowledge_graph with search_type="domain", query="anthropic"]
```

### Check RAG Configuration Status

```
User: Are my databases connected?

Claude: [Uses get_rag_status tool]
```

### Batch Crawl Documentation

```
User: Crawl these pages and store them:
- https://docs.anthropic.com/claude/docs
- https://docs.anthropic.com/claude/reference

Claude: [Uses crawl_multiple_pages with store_in_db=true]
```

---

## Troubleshooting

### Issue: "Browser not found"

```bash
# Solution: Run browser setup
crawl4ai-setup
# or
playwright install chromium
```

### Issue: Azure OpenAI Errors

**"Deployment not found"**
- Verify `AZURE_EMBEDDING_DEPLOYMENT` matches your deployment name exactly
- Check Azure AI Studio > Deployments for the correct name

**"AuthenticationFailed"**
- Verify `AZURE_OPENAI_API_KEY` is correct
- Ensure the key has access to the embedding deployment

### Issue: Supabase Connection Failed

**"Invalid API key"**
- Use the **Service Role Key** (not anon key)
- Find it in Supabase Dashboard > Settings > API

**"relation 'crawled_content' does not exist"**
- Run `supabase_setup.sql` in SQL Editor

### Issue: Neo4j Connection Failed

**"Unable to connect to bolt://localhost:7687"**
- Ensure Neo4j is running
- Check with: `docker ps` or Neo4j Desktop
- For Aura, use `neo4j+s://` protocol

**"Authentication failure"**
- Verify username/password
- Default is `neo4j` / (password you set)

### Issue: Timeout Errors

```
User: The crawl is timing out

Solutions:
1. Increase timeout: Set PAGE_TIMEOUT=120000 in .env
2. Use simpler pages first to verify setup
3. Check if site blocks automated requests
```

### Checking Status

Ask Claude Code:

```
Check my Crawl4AI RAG status
```

This runs `get_rag_status` and shows:
- Azure OpenAI: Connected/Not configured
- Supabase: Connected/Not configured
- Neo4j: Connected/Not configured

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   Crawl4AI MCP Server v2.0                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Claude Code ──► MCP Server ──► Crawl4AI ──► Headless Browser   │
│       │              │                              │           │
│       │              │                              ▼           │
│       │              │                        HTML Content       │
│       │              │                              │           │
│       │              ▼                              ▼           │
│       │    ┌─────────────────┐             Clean Markdown       │
│       │    │ store_in_db?    │                     │            │
│       │    └─────────────────┘                     │            │
│       │              │ Yes                         │            │
│       │              ▼                             │            │
│       │    ┌─────────────────┐                    │            │
│       │    │  Azure OpenAI   │                    │            │
│       │    │  (Embeddings)   │                    │            │
│       │    └─────────────────┘                    │            │
│       │              │                            │            │
│       │              ▼                            │            │
│       │    ┌─────────────────┐                   │            │
│       │    │    Supabase     │                   │            │
│       │    │   (pgvector)    │                   │            │
│       │    └─────────────────┘                   │            │
│       │                                          │            │
│       │    ┌─────────────────┐                   │            │
│       │    │ store_in_graph? │◄──────────────────┘            │
│       │    └─────────────────┘                                │
│       │              │ Yes                                     │
│       │              ▼                                         │
│       │    ┌─────────────────┐                                │
│       │    │     Neo4j       │                                │
│       │    │ (Knowledge Graph)│                                │
│       │    └─────────────────┘                                │
│       │                                                        │
│       ▼                                                        │
│  Markdown Response (always returned to Claude)                 │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### Knowledge Graph Schema

```
(:WebPage {url, title, domain, crawled_at})
    -[:BELONGS_TO]-> (:Domain {name})
    -[:COVERS_TOPIC]-> (:Topic {name})
    -[:LINKS_TO]-> (:WebPage)
```

---

## Available MCP Tools

| Tool | Description | Storage |
|------|-------------|---------|
| `crawl_single_page` | Crawl one URL | Optional |
| `crawl_multiple_pages` | Batch crawl URLs | Optional |
| `smart_crawl` | Query-guided crawling | Optional |
| `extract_structured_data` | CSS-based extraction | No |
| `extract_with_llm` | LLM-based extraction | No |
| `get_page_screenshot` | Capture screenshot | No |
| `get_page_pdf` | Generate PDF | No |
| `search_crawled_content` | Vector search | Read |
| `search_knowledge_graph` | Graph queries | Read |
| `get_rag_status` | Check configuration | Read |

---

## Related Documentation

- [Crawl4AI Library Guide](../guides/crawl4ai-guide.md) - Comprehensive Crawl4AI library usage
- [MCP Dependencies](../mcp-dependencies.md) - General MCP setup
- [Troubleshooting](../troubleshooting.md) - General troubleshooting

---

*For the latest features, see the [Crawl4AI README](../../mcp-servers/crawl4ai-rag/README.md).*
