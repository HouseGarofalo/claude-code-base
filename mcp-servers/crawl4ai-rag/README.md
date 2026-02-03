# Crawl4AI MCP Server

A Model Context Protocol (MCP) server that provides web crawling and dual RAG capabilities for Claude Code using [Crawl4AI](https://github.com/unclecode/crawl4ai).

## Features

- **Single Page Crawling**: Extract clean markdown content from any URL
- **Batch Crawling**: Crawl multiple URLs concurrently with rate limiting
- **Smart Crawling**: Adaptive crawling with query-based content filtering
- **Structured Extraction**: CSS selector and XPath-based data extraction
- **LLM Extraction**: Use Azure OpenAI to extract structured data
- **Screenshots**: Capture full-page or viewport screenshots
- **PDF Generation**: Generate PDFs from web pages
- **Vector RAG**: Semantic search with Supabase pgvector + Azure OpenAI embeddings
- **Graph RAG**: Knowledge graph storage and querying with Neo4j

## Key Changes in v2.0

- **Opt-in storage**: Data is NOT stored by default. Use `store_in_db=True` and/or `store_in_graph=True` to save
- **Azure OpenAI**: Uses Azure OpenAI for embeddings instead of direct OpenAI API
- **Global credentials**: Loads from `~/.claude/.env` automatically (with local `.env` override)
- **Neo4j Graph RAG**: Build and query knowledge graphs from crawled content

## Installation

### Using pip

```bash
# Basic installation (crawling only)
pip install -e .

# With Vector RAG (Supabase + Azure OpenAI)
pip install -e ".[rag]"

# With Graph RAG (Neo4j)
pip install -e ".[graph]"

# Full installation with all features
pip install -e ".[all]"
```

### Using Docker

```bash
# Build the image
docker build -t crawl4ai-mcp .

# Run with stdio transport
docker run -i crawl4ai-mcp

# Run with SSE transport
docker run -p 8000:8000 -e TRANSPORT=sse crawl4ai-mcp
```

## Configuration

### Credential Loading Order

The server loads credentials in this order:
1. **Local `.env`** - Project-specific overrides
2. **Global `~/.claude/.env`** - Shared credentials (fallback)

This means you can set credentials once in `~/.claude/.env` and use them across all projects.

### Environment Variables

| Variable | Required For | Description |
|----------|--------------|-------------|
| `TRANSPORT` | All | Transport mode: `stdio` or `sse` (default: `stdio`) |
| `HEADLESS` | All | Run browser in headless mode (default: `true`) |
| `BROWSER_TYPE` | All | Browser: `chromium`, `firefox`, `webkit` (default: `chromium`) |
| `MEAN_DELAY` | All | Mean delay between requests in seconds (default: `0.5`) |
| `MAX_CONCURRENT` | All | Maximum concurrent crawl operations (default: `5`) |
| `AZURE_OPENAI_ENDPOINT` | RAG | Azure OpenAI endpoint URL |
| `AZURE_OPENAI_API_KEY` | RAG | Azure OpenAI API key |
| `AZURE_OPENAI_API_VERSION` | RAG | API version (default: `2024-12-01-preview`) |
| `AZURE_EMBEDDING_DEPLOYMENT` | RAG | Embedding model deployment name (default: `text-embedding-3-small`) |
| `SUPABASE_URL` | RAG | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | RAG | Supabase service role key |
| `NEO4J_URI` | Graph | Neo4j connection URI (default: `bolt://localhost:7687`) |
| `NEO4J_USERNAME` | Graph | Neo4j username (default: `neo4j`) |
| `NEO4J_PASSWORD` | Graph | Neo4j password |

## Database Setup

### Supabase (Vector RAG)

Run `supabase_setup.sql` in your Supabase SQL Editor:

```bash
# Copy the SQL and run in Supabase Dashboard > SQL Editor
cat supabase_setup.sql
```

This creates:
- `crawled_content` table with vector embeddings
- `match_documents` function for semantic search
- Indexes for URL lookup and vector similarity

### Neo4j (Graph RAG)

Run `neo4j_setup.cypher` in your Neo4j Browser:

```bash
# Copy the Cypher and run in Neo4j Browser
cat neo4j_setup.cypher
```

This creates:
- Constraints for `WebPage`, `Domain`, and `Topic` nodes
- Indexes for efficient querying
- Sample queries for testing

## Available MCP Tools

### 1. `crawl_single_page`

Crawl a single URL and extract content as markdown.

**Parameters:**
- `url` (required): URL to crawl
- `include_images` (optional): Include image descriptions (default: `false`)
- `include_links` (optional): Include links in output (default: `true`)
- `wait_for` (optional): CSS selector to wait for before extraction
- `store_in_db` (optional): Store in Supabase vector DB (default: `false`)
- `store_in_graph` (optional): Store in Neo4j graph DB (default: `false`)

**Example:**
```
Crawl https://docs.anthropic.com and save to both databases
→ crawl_single_page(url="...", store_in_db=true, store_in_graph=true)
```

### 2. `crawl_multiple_pages`

Batch crawl multiple URLs concurrently.

**Parameters:**
- `urls` (required): List of URLs to crawl
- `max_concurrent` (optional): Max concurrent requests (default: `5`)
- `store_in_db` (optional): Store in vector DB (default: `false`)
- `store_in_graph` (optional): Store in graph DB (default: `false`)

### 3. `smart_crawl`

Adaptive crawling with query-based filtering.

**Parameters:**
- `url` (required): URL to crawl
- `query` (required): Query to guide content extraction
- `max_pages` (optional): Maximum pages to follow (default: `1`)
- `store_in_db` (optional): Store in vector DB (default: `false`)
- `store_in_graph` (optional): Store in graph DB (default: `false`)

### 4. `extract_structured_data`

Extract data using CSS selectors.

**Parameters:**
- `url` (required): URL to extract from
- `schema` (required): JSON schema defining extraction rules

### 5. `extract_with_llm`

Use Azure OpenAI to extract structured data.

**Parameters:**
- `url` (required): URL to extract from
- `instruction` (required): What to extract
- `schema` (required): JSON schema for the extracted data

### 6. `get_page_screenshot`

Capture a screenshot of a web page.

**Parameters:**
- `url` (required): URL to screenshot
- `full_page` (optional): Capture full page (default: `false`)
- `selector` (optional): CSS selector to screenshot specific element

### 7. `get_page_pdf`

Generate a PDF from a web page.

**Parameters:**
- `url` (required): URL to convert to PDF
- `format` (optional): Page format (default: `A4`)

### 8. `search_crawled_content`

Search vector database using semantic similarity.

**Parameters:**
- `query` (required): Search query
- `limit` (optional): Maximum results (default: `5`)
- `source_filter` (optional): Filter by source URL pattern

### 9. `search_knowledge_graph`

Search the Neo4j knowledge graph.

**Parameters:**
- `query` (required): Search term
- `search_type` (optional): `topic`, `domain`, or `page` (default: `topic`)
- `limit` (optional): Maximum results (default: `10`)

### 10. `get_rag_status`

Check the status of all RAG integrations.

**Returns:** Configuration status for Azure OpenAI, Supabase, and Neo4j.

## Integration with Claude Code

### Method 1: Direct Configuration

Add to your Claude Code MCP settings (`~/.claude/mcp.json` or project `.mcp.json`):

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "python",
      "args": ["-m", "src.crawl4ai_mcp_server"],
      "cwd": "/path/to/crawl4ai-rag"
    }
  }
}
```

Note: No need to pass environment variables - they're loaded from `~/.claude/.env` automatically.

### Method 2: Using the Entry Point

After `pip install -e ".[all]"`:

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "crawl4ai-mcp"
    }
  }
}
```

## Usage Examples

### Basic Web Crawling (No Storage)

```
User: Crawl https://docs.anthropic.com and summarize

Claude: I'll crawl that page.
[Uses crawl_single_page with defaults - nothing stored]
```

### Crawl and Store in Both Databases

```
User: Crawl the Anthropic docs and save for future reference

Claude: I'll crawl and store in both vector and graph databases.
[Uses crawl_single_page with store_in_db=true, store_in_graph=true]
```

### Search Previously Crawled Content

```
User: Find information about API rate limits in my crawled docs

Claude: I'll search the vector database.
[Uses search_crawled_content]
```

### Explore Knowledge Graph

```
User: What topics are covered by the Anthropic documentation?

Claude: I'll query the knowledge graph.
[Uses search_knowledge_graph with search_type="domain", query="anthropic"]
```

### Check RAG Status

```
User: Are my databases connected?

Claude: Let me check.
[Uses get_rag_status]
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Crawl4AI MCP Server v2.0                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Claude Code ──► MCP Server ──► Crawl4AI ──► Headless Browser     │
│        │              │                              │              │
│        │              │                              ▼              │
│        │              │                       HTML Content          │
│        │              │                              │              │
│        │              ▼                              ▼              │
│        │    ┌─────────────────────┐          Clean Markdown         │
│        │    │ store_in_db=true?   │                 │               │
│        │    └─────────────────────┘                 │               │
│        │              │ Yes                         │               │
│        │              ▼                             │               │
│        │    ┌─────────────────────┐                │               │
│        │    │   Azure OpenAI      │                │               │
│        │    │   (Embeddings)      │                │               │
│        │    └─────────────────────┘                │               │
│        │              │                            │               │
│        │              ▼                            │               │
│        │    ┌─────────────────────┐               │               │
│        │    │     Supabase        │               │               │
│        │    │   (pgvector)        │               │               │
│        │    └─────────────────────┘               │               │
│        │                                          │               │
│        │    ┌─────────────────────┐               │               │
│        │    │ store_in_graph=true?│◄──────────────┘               │
│        │    └─────────────────────┘                               │
│        │              │ Yes                                        │
│        │              ▼                                            │
│        │    ┌─────────────────────┐                               │
│        │    │      Neo4j          │                               │
│        │    │  (Knowledge Graph)  │                               │
│        │    └─────────────────────┘                               │
│        │                                                          │
│        ▼                                                          │
│   Markdown Response (always returned to Claude)                   │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

## Knowledge Graph Schema

```
(:WebPage {url, title, domain, crawled_at})
    -[:BELONGS_TO]-> (:Domain {name})
    -[:COVERS_TOPIC]-> (:Topic {name})
    -[:LINKS_TO]-> (:WebPage)
```

## Troubleshooting

### Check Configuration

```
User: Check my RAG status

Claude: [Uses get_rag_status tool]
```

### Browser Installation

```bash
crawl4ai-setup
# or
playwright install chromium
```

### Neo4j Connection Issues

Ensure Neo4j is running:
```bash
# Docker
docker run -p 7474:7474 -p 7687:7687 neo4j:latest

# Or check local installation
neo4j status
```

### Azure OpenAI Errors

Verify your deployment name matches `AZURE_EMBEDDING_DEPLOYMENT`. Common names:
- `text-embedding-3-small`
- `text-embedding-ada-002`
- Check your Azure AI Studio for exact deployment name

## Development

### Running Tests

```bash
pytest tests/
```

### Running Locally

```bash
# stdio mode (for Claude Code integration)
python -m src.crawl4ai_mcp_server

# SSE mode (for debugging/testing)
TRANSPORT=sse python -m src.crawl4ai_mcp_server
```

## License

MIT License - see LICENSE file for details.

## Credits

- [Crawl4AI](https://github.com/unclecode/crawl4ai) - Web crawling library
- [MCP](https://modelcontextprotocol.io/) - Model Context Protocol
- [FastMCP](https://github.com/jlowin/fastmcp) - MCP server framework
- [Supabase](https://supabase.com/) - Vector database with pgvector
- [Neo4j](https://neo4j.com/) - Graph database
