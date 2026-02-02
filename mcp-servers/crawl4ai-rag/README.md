# Crawl4AI MCP Server

A Model Context Protocol (MCP) server that provides web crawling and RAG (Retrieval-Augmented Generation) capabilities for Claude Code using [Crawl4AI](https://github.com/unclecode/crawl4ai).

## Features

- **Single Page Crawling**: Extract clean markdown content from any URL
- **Batch Crawling**: Crawl multiple URLs concurrently with rate limiting
- **Smart Crawling**: Adaptive crawling with query-based content filtering
- **Structured Extraction**: CSS selector and XPath-based data extraction
- **LLM Extraction**: Use LLM to extract structured data based on schemas
- **Screenshots**: Capture full-page or viewport screenshots
- **PDF Generation**: Generate PDFs from web pages
- **RAG Integration**: Optional vector store integration for semantic search

## Installation

### Using pip

```bash
# Basic installation
pip install -e .

# With RAG capabilities
pip install -e ".[rag]"

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

Create a `.env` file based on `.env.example`:

```bash
cp .env.example .env
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TRANSPORT` | `stdio` | Transport mode: `stdio` or `sse` |
| `HEADLESS` | `true` | Run browser in headless mode |
| `BROWSER_TYPE` | `chromium` | Browser: `chromium`, `firefox`, `webkit` |
| `MEAN_DELAY` | `0.5` | Mean delay between requests (seconds) |
| `MAX_CONCURRENT` | `5` | Maximum concurrent crawl operations |
| `OPENAI_API_KEY` | - | Required for LLM extraction |
| `SUPABASE_URL` | - | Required for RAG features |
| `SUPABASE_SERVICE_KEY` | - | Required for RAG features |

## Available MCP Tools

### 1. `crawl_single_page`

Crawl a single URL and extract content as markdown.

**Parameters:**
- `url` (required): URL to crawl
- `include_images` (optional): Include image descriptions (default: false)
- `include_links` (optional): Include links in output (default: true)
- `wait_for` (optional): CSS selector to wait for before extraction

**Example:**
```
Crawl https://example.com and extract the main content
```

### 2. `crawl_multiple_pages`

Batch crawl multiple URLs concurrently.

**Parameters:**
- `urls` (required): List of URLs to crawl
- `max_concurrent` (optional): Max concurrent requests (default: 5)

**Example:**
```
Crawl these pages and summarize each:
- https://example.com/page1
- https://example.com/page2
```

### 3. `smart_crawl`

Adaptive crawling with query-based filtering. Uses the query to focus extraction on relevant content.

**Parameters:**
- `url` (required): URL to crawl
- `query` (required): Query to guide content extraction
- `max_pages` (optional): Maximum pages to follow (default: 1)

**Example:**
```
Find information about pricing on https://example.com
```

### 4. `extract_structured_data`

Extract data using CSS selectors or XPath expressions.

**Parameters:**
- `url` (required): URL to extract from
- `schema` (required): JSON schema defining extraction rules

**Schema Format:**
```json
{
  "name": "products",
  "baseSelector": ".product-card",
  "fields": [
    {"name": "title", "selector": "h2", "type": "text"},
    {"name": "price", "selector": ".price", "type": "text"},
    {"name": "image", "selector": "img", "type": "attribute", "attribute": "src"}
  ]
}
```

### 5. `extract_with_llm`

Use an LLM to extract structured data based on a Pydantic-style schema.

**Parameters:**
- `url` (required): URL to extract from
- `instruction` (required): What to extract
- `schema` (required): JSON schema for the extracted data

**Example:**
```
Extract all product information from https://example.com/products
Schema: {"name": "string", "price": "number", "description": "string"}
```

### 6. `get_page_screenshot`

Capture a screenshot of a web page.

**Parameters:**
- `url` (required): URL to screenshot
- `full_page` (optional): Capture full page (default: false)
- `selector` (optional): CSS selector to screenshot specific element

### 7. `get_page_pdf`

Generate a PDF from a web page.

**Parameters:**
- `url` (required): URL to convert to PDF
- `format` (optional): Page format (default: "A4")

### 8. `search_crawled_content`

Search previously crawled content using semantic similarity (requires RAG configuration).

**Parameters:**
- `query` (required): Search query
- `limit` (optional): Maximum results (default: 5)
- `source_filter` (optional): Filter by source URL pattern

## Integration with Claude Code

### Method 1: Direct Configuration

Add to your Claude Code MCP settings (`~/.claude/mcp.json` or project `.mcp.json`):

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "python",
      "args": ["-m", "src.crawl4ai_mcp_server"],
      "cwd": "/path/to/crawl4ai-rag",
      "env": {
        "TRANSPORT": "stdio",
        "HEADLESS": "true"
      }
    }
  }
}
```

### Method 2: Using the Entry Point

After `pip install -e .`:

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "crawl4ai-mcp",
      "env": {
        "TRANSPORT": "stdio"
      }
    }
  }
}
```

### Method 3: Docker

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "crawl4ai-mcp"]
    }
  }
}
```

## Usage Examples

### Basic Web Crawling

```
User: Crawl https://docs.anthropic.com and summarize the main topics

Claude: I'll crawl that documentation page for you.
[Uses crawl_single_page tool]
```

### Extracting Structured Data

```
User: Extract all the pricing tiers from https://example.com/pricing

Claude: I'll extract the pricing information using structured extraction.
[Uses extract_structured_data with appropriate schema]
```

### Research with Multiple Sources

```
User: Research the latest developments in AI agents from these sources:
- https://blog.langchain.dev
- https://www.anthropic.com/news

Claude: I'll crawl both sources and compile the information.
[Uses crawl_multiple_pages tool]
```

### Smart Content Discovery

```
User: Find information about API rate limits on the Stripe documentation

Claude: I'll search the Stripe docs for rate limit information.
[Uses smart_crawl with query="API rate limits"]
```

## RAG Integration (Optional)

To enable RAG features for semantic search over crawled content:

1. Set up a Supabase project with pgvector extension
2. Configure the environment variables:
   ```
   OPENAI_API_KEY=your-key
   SUPABASE_URL=your-project-url
   SUPABASE_SERVICE_KEY=your-service-key
   ```
3. Install RAG dependencies: `pip install -e ".[rag]"`

The server will automatically store crawled content in the vector database when RAG is configured.

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

## Troubleshooting

### Browser Installation

Crawl4AI requires a browser. Install with:

```bash
crawl4ai-setup
# or
playwright install chromium
```

### Permission Errors

If running in Docker, ensure the container has appropriate permissions:

```bash
docker run --cap-add=SYS_ADMIN crawl4ai-mcp
```

### Rate Limiting

If you're getting blocked, increase `MEAN_DELAY` and decrease `MAX_CONCURRENT`.

## License

MIT License - see LICENSE file for details.

## Credits

- [Crawl4AI](https://github.com/unclecode/crawl4ai) - The underlying crawling library
- [MCP](https://modelcontextprotocol.io/) - Model Context Protocol specification
- [FastMCP](https://github.com/jlowin/fastmcp) - FastAPI-style MCP server framework
