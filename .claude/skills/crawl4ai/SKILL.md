---
name: crawl4ai
description: Expert web crawling and scraping with Crawl4AI. AI-ready markdown generation, LLM-based extraction, adaptive crawling, and RAG integration. Use for web research, data extraction, documentation crawling, and building knowledge bases.
version: 1.0.0
allowed-tools: Read, Grep, Glob, Edit, Write, Bash, WebFetch
---

# Crawl4AI Skill

Complete guide for Crawl4AI - the #1 trending GitHub repository for AI-powered web crawling and scraping. Generate clean, AI-ready markdown from any website with intelligent extraction strategies.

## Quick Reference

### Core Capabilities
| Feature | Description |
|---------|-------------|
| **Clean Markdown** | AI-optimized markdown output from any webpage |
| **LLM Extraction** | Use GPT-4, Claude, or local models for structured extraction |
| **CSS/XPath Extraction** | Fast, token-efficient data extraction with selectors |
| **Browser Automation** | Full Chromium control with JavaScript execution |
| **Adaptive Crawling** | AI-guided crawling that follows relevant links |
| **Session Management** | Persistent browser state across requests |
| **Parallel Crawling** | Efficient multi-URL processing |
| **RAG Integration** | Built for retrieval-augmented generation pipelines |

### When to Use Crawl4AI vs Other Tools

| Tool | Best For |
|------|----------|
| **Crawl4AI** | AI/LLM workflows, RAG, clean markdown, structured extraction |
| **Playwright** | Complex browser automation, testing, visual verification |
| **Puppeteer** | Node.js environments, Chrome DevTools Protocol |
| **Scrapy** | Large-scale traditional scraping, spider frameworks |
| **BeautifulSoup** | Simple HTML parsing without browser rendering |
| **Selenium** | Legacy browser automation, cross-browser testing |

---

## 1. Installation

### Basic Installation

```bash
# Install Crawl4AI
pip install crawl4ai

# Install browser dependencies (Chromium)
crawl4ai-setup

# Verify installation
crawl4ai-doctor
```

### Installation Options

```bash
# With PyTorch support (for local embeddings)
pip install "crawl4ai[torch]"

# With Transformers (for Hugging Face models)
pip install "crawl4ai[transformer]"

# With all optional features
pip install "crawl4ai[all]"

# For development
pip install "crawl4ai[dev]"
```

### Docker Installation

```dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget gnupg ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Crawl4AI
RUN pip install crawl4ai
RUN crawl4ai-setup

WORKDIR /app
COPY . .

CMD ["python", "crawler.py"]
```

### Troubleshooting Installation

```bash
# If browser not found
crawl4ai-setup --force

# Check browser path
python -c "from crawl4ai import AsyncWebCrawler; print('OK')"

# Verbose diagnostics
crawl4ai-doctor --verbose
```

---

## 2. Basic Usage

### Minimal Example

```python
import asyncio
from crawl4ai import AsyncWebCrawler

async def main():
    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun("https://example.com")

        # Access different output formats
        print(result.markdown)           # Clean markdown
        print(result.cleaned_html)       # Sanitized HTML
        print(result.extracted_content)  # Raw extracted content
        print(result.links)              # All links found

asyncio.run(main())
```

### Synchronous Wrapper

```python
from crawl4ai import WebCrawler

# For simpler use cases
with WebCrawler() as crawler:
    result = crawler.run("https://example.com")
    print(result.markdown)
```

### Result Object Properties

```python
result = await crawler.arun(url)

# Content Properties
result.markdown              # Clean markdown output
result.markdown_v2           # Enhanced markdown with metadata
result.cleaned_html          # Sanitized HTML
result.extracted_content     # Raw extracted content
result.fit_markdown          # Markdown optimized for token limits

# Metadata
result.url                   # Final URL (after redirects)
result.success               # Boolean success status
result.status_code           # HTTP status code
result.response_headers      # Response headers dict
result.error_message         # Error details if failed

# Links and Media
result.links                 # Dict with internal/external links
result.media                 # Dict with images, videos, audio
result.metadata              # Page metadata (title, description, etc.)

# Extraction Results
result.extracted_content     # LLM/CSS extraction results
```

---

## 3. Configuration Classes

### BrowserConfig

Controls browser behavior and appearance.

```python
from crawl4ai import AsyncWebCrawler, BrowserConfig

browser_config = BrowserConfig(
    # Browser Selection
    browser_type="chromium",        # "chromium", "firefox", "webkit"
    headless=True,                  # Run without GUI

    # Viewport
    viewport_width=1920,
    viewport_height=1080,

    # Identity
    user_agent="Custom User Agent",
    user_agent_mode="random",       # "fixed", "random"

    # Network
    proxy_config={
        "server": "http://proxy:8080",
        "username": "user",
        "password": "pass"
    },

    # Performance
    use_cached_html=True,

    # Stealth Mode (avoid detection)
    use_managed_browser=True,

    # Browser Arguments
    extra_args=["--disable-gpu", "--no-sandbox"],

    # Cookies and Headers
    cookies=[
        {"name": "session", "value": "abc123", "domain": ".example.com"}
    ],
    headers={
        "Accept-Language": "en-US,en;q=0.9"
    },

    # JavaScript
    java_script_enabled=True,

    # Downloads
    accept_downloads=True,
    downloads_path="./downloads",

    # Debugging
    verbose=True
)

async with AsyncWebCrawler(config=browser_config) as crawler:
    result = await crawler.arun("https://example.com")
```

### CrawlerRunConfig

Controls crawling behavior for each request.

```python
from crawl4ai import CrawlerRunConfig, CacheMode

run_config = CrawlerRunConfig(
    # Caching
    cache_mode=CacheMode.ENABLED,   # ENABLED, DISABLED, READ_ONLY, WRITE_ONLY, BYPASS

    # Content Extraction
    word_count_threshold=10,        # Min words per block
    excluded_tags=["nav", "footer", "aside"],
    exclude_external_links=False,
    exclude_social_media_links=True,

    # CSS Selectors
    css_selector=".main-content",   # Only extract from this selector
    excluded_selector=".ads, .sidebar",

    # Page Interaction
    wait_for="css:.content-loaded", # Wait for element
    delay_before_return_html=2.0,   # Seconds to wait

    # JavaScript Execution
    js_code="""
        document.querySelector('.load-more').click();
        await new Promise(r => setTimeout(r, 2000));
    """,
    js_only=False,                  # Skip initial page load

    # Scrolling for Lazy Loading
    scan_full_page=True,            # Auto-scroll entire page
    scroll_delay=0.5,               # Delay between scrolls

    # Screenshots and PDF
    screenshot=True,
    screenshot_wait_for="css:.loaded",
    pdf=True,

    # Content Processing
    remove_overlay_elements=True,   # Remove popups/modals
    process_iframes=True,           # Include iframe content

    # Media Handling
    exclude_external_images=False,

    # Session
    session_id="my-session",        # Reuse browser state

    # Extraction Strategy
    extraction_strategy=None,       # Set extraction strategy

    # Magic Mode (AI-powered content detection)
    magic=False,

    # Verbose
    verbose=True
)

result = await crawler.arun("https://example.com", config=run_config)
```

### Cache Modes

```python
from crawl4ai import CacheMode

# Always use cache if available
CacheMode.ENABLED

# Never use cache
CacheMode.DISABLED

# Only read from cache, don't write
CacheMode.READ_ONLY

# Only write to cache, don't read
CacheMode.WRITE_ONLY

# Bypass cache completely
CacheMode.BYPASS
```

---

## 4. Extraction Strategies

### CSS/XPath Extraction (Token-Efficient)

Best for structured data when you know the page layout.

```python
from crawl4ai.extraction_strategy import JsonCssExtractionStrategy

# Define extraction schema
schema = {
    "name": "Products",
    "baseSelector": ".product-card",  # Repeating element
    "fields": [
        {
            "name": "title",
            "selector": "h2.product-title",
            "type": "text"
        },
        {
            "name": "price",
            "selector": ".price",
            "type": "text"
        },
        {
            "name": "image",
            "selector": "img",
            "type": "attribute",
            "attribute": "src"
        },
        {
            "name": "url",
            "selector": "a.product-link",
            "type": "attribute",
            "attribute": "href"
        },
        {
            "name": "rating",
            "selector": ".stars",
            "type": "attribute",
            "attribute": "data-rating"
        },
        {
            "name": "description",
            "selector": ".description",
            "type": "html"  # Get inner HTML
        }
    ]
}

strategy = JsonCssExtractionStrategy(schema, verbose=True)

config = CrawlerRunConfig(extraction_strategy=strategy)
result = await crawler.arun("https://shop.example.com/products", config=config)

# Parse extracted data
import json
products = json.loads(result.extracted_content)
for product in products:
    print(f"{product['title']}: {product['price']}")
```

### Nested Extraction

```python
schema = {
    "name": "Articles",
    "baseSelector": "article",
    "fields": [
        {"name": "title", "selector": "h1", "type": "text"},
        {"name": "author", "selector": ".author-name", "type": "text"},
        {
            "name": "comments",
            "selector": ".comment",
            "type": "nested",
            "fields": [
                {"name": "user", "selector": ".comment-user", "type": "text"},
                {"name": "text", "selector": ".comment-body", "type": "text"},
                {"name": "date", "selector": ".comment-date", "type": "text"}
            ]
        }
    ]
}
```

### XPath Extraction

```python
schema = {
    "name": "Data",
    "baseSelector": "//div[@class='item']",  # XPath for base
    "fields": [
        {
            "name": "title",
            "selector": ".//h2/text()",  # XPath selector
            "type": "xpath"
        }
    ]
}
```

### LLM Extraction Strategy

Use AI for complex, unstructured content.

```python
from crawl4ai.extraction_strategy import LLMExtractionStrategy
from crawl4ai import LLMConfig
from pydantic import BaseModel, Field
from typing import List, Optional
import os

# Define output schema with Pydantic
class Product(BaseModel):
    name: str = Field(description="Product name")
    price: float = Field(description="Price in USD")
    currency: str = Field(default="USD")
    description: str = Field(description="Product description")
    features: List[str] = Field(default_factory=list, description="Key features")
    rating: Optional[float] = Field(default=None, description="Rating out of 5")
    in_stock: bool = Field(default=True)

class ProductList(BaseModel):
    products: List[Product]

# Configure LLM
llm_config = LLMConfig(
    provider="openai/gpt-4o-mini",  # or "anthropic/claude-3-haiku-20240307"
    api_token=os.getenv("OPENAI_API_KEY"),
    temperature=0.0,
    max_tokens=4000
)

# Create extraction strategy
strategy = LLMExtractionStrategy(
    llm_config=llm_config,
    schema=ProductList.model_json_schema(),
    extraction_type="schema",  # "schema" or "block"
    instruction="""
    Extract all products from this e-commerce page.
    Include the name, price, description, and any listed features.
    If rating is shown as stars, convert to a number out of 5.
    """,
    verbose=True
)

config = CrawlerRunConfig(extraction_strategy=strategy)
result = await crawler.arun("https://shop.example.com", config=config)

# Parse results
data = ProductList.model_validate_json(result.extracted_content)
for product in data.products:
    print(f"{product.name}: ${product.price}")
```

### LLM Providers

```python
# OpenAI
llm_config = LLMConfig(
    provider="openai/gpt-4o",
    api_token=os.getenv("OPENAI_API_KEY")
)

# Anthropic Claude
llm_config = LLMConfig(
    provider="anthropic/claude-3-5-sonnet-20241022",
    api_token=os.getenv("ANTHROPIC_API_KEY")
)

# Azure OpenAI
llm_config = LLMConfig(
    provider="azure/gpt-4",
    api_token=os.getenv("AZURE_API_KEY"),
    base_url="https://your-resource.openai.azure.com/"
)

# Local Ollama
llm_config = LLMConfig(
    provider="ollama/llama3.2",
    base_url="http://localhost:11434"
)

# OpenRouter (access many models)
llm_config = LLMConfig(
    provider="openrouter/anthropic/claude-3-opus",
    api_token=os.getenv("OPENROUTER_API_KEY")
)
```

### Block Extraction (No Schema)

Extract content as semantic blocks without predefined structure.

```python
strategy = LLMExtractionStrategy(
    llm_config=llm_config,
    extraction_type="block",
    instruction="Extract the main article content, author bio, and related articles."
)
```

### Cosine Similarity Strategy

Extract content based on semantic similarity to a query.

```python
from crawl4ai.extraction_strategy import CosineStrategy

strategy = CosineStrategy(
    semantic_filter="machine learning tutorials",
    word_count_threshold=50,
    sim_threshold=0.3,
    max_dist=0.2,
    top_k=5
)

config = CrawlerRunConfig(extraction_strategy=strategy)
result = await crawler.arun(url, config=config)
```

---

## 5. Adaptive Crawling

AI-guided crawling that intelligently follows relevant links.

```python
from crawl4ai import AsyncWebCrawler, AdaptiveCrawler, BrowserConfig, CrawlerRunConfig

async def adaptive_crawl_docs():
    browser_config = BrowserConfig(headless=True)

    async with AsyncWebCrawler(config=browser_config) as crawler:
        # Create adaptive crawler
        adaptive = AdaptiveCrawler(
            crawler=crawler,
            llm_config=LLMConfig(
                provider="openai/gpt-4o-mini",
                api_token=os.getenv("OPENAI_API_KEY")
            )
        )

        # Digest a documentation site
        result = await adaptive.digest(
            start_url="https://docs.example.com/getting-started",
            query="How to authenticate with the API",

            # Crawl Control
            max_pages=20,              # Maximum pages to crawl
            max_depth=3,               # Maximum link depth

            # Relevance
            confidence_threshold=0.7,   # Minimum relevance score

            # Link Selection
            include_patterns=["docs.example.com/*"],
            exclude_patterns=["*/changelog/*", "*/releases/*"],

            # Output
            verbose=True
        )

        # Results
        print(f"Crawled {len(result.pages)} pages")
        print(f"Answer: {result.answer}")

        for page in result.pages:
            print(f"- {page.url} (relevance: {page.relevance_score:.2f})")
```

### Adaptive Crawler for Knowledge Base

```python
async def build_knowledge_base():
    async with AsyncWebCrawler() as crawler:
        adaptive = AdaptiveCrawler(crawler=crawler, llm_config=llm_config)

        # Crawl multiple documentation sections
        topics = [
            ("https://docs.example.com/auth", "authentication methods"),
            ("https://docs.example.com/api", "API endpoints"),
            ("https://docs.example.com/sdk", "SDK installation"),
        ]

        all_content = []

        for url, query in topics:
            result = await adaptive.digest(
                start_url=url,
                query=query,
                max_pages=10,
                confidence_threshold=0.6
            )

            for page in result.pages:
                all_content.append({
                    "url": page.url,
                    "topic": query,
                    "content": page.markdown,
                    "relevance": page.relevance_score
                })

        return all_content
```

---

## 6. Multi-URL Crawling

Efficiently crawl multiple URLs with parallel processing.

```python
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig

async def crawl_multiple():
    urls = [
        "https://site1.com/page1",
        "https://site1.com/page2",
        "https://site2.com/article",
        "https://site3.com/docs",
    ]

    config = CrawlerRunConfig(
        cache_mode=CacheMode.ENABLED,
        word_count_threshold=50
    )

    async with AsyncWebCrawler() as crawler:
        # Crawl all URLs in parallel
        results = await crawler.arun_many(
            urls,
            config=config,
            max_concurrent=5  # Limit concurrent requests
        )

        for result in results:
            if result.success:
                print(f"OK: {result.url}")
                print(f"   Words: {len(result.markdown.split())}")
            else:
                print(f"FAIL: {result.url} - {result.error_message}")
```

### Crawling with Rate Limiting

```python
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig
import asyncio

async def rate_limited_crawl(urls: list, requests_per_second: float = 1.0):
    config = CrawlerRunConfig(cache_mode=CacheMode.BYPASS)
    delay = 1.0 / requests_per_second

    results = []
    async with AsyncWebCrawler() as crawler:
        for url in urls:
            result = await crawler.arun(url, config=config)
            results.append(result)
            await asyncio.sleep(delay)

    return results
```

### Sitemap Crawling

```python
import xml.etree.ElementTree as ET
import httpx

async def crawl_sitemap(sitemap_url: str, max_urls: int = 100):
    # Fetch sitemap
    async with httpx.AsyncClient() as client:
        response = await client.get(sitemap_url)
        root = ET.fromstring(response.text)

    # Extract URLs
    namespace = {'ns': 'http://www.sitemaps.org/schemas/sitemap/0.9'}
    urls = [
        loc.text for loc in root.findall('.//ns:loc', namespace)
    ][:max_urls]

    # Crawl all URLs
    async with AsyncWebCrawler() as crawler:
        results = await crawler.arun_many(urls, max_concurrent=10)

    return results
```

---

## 7. Session Management

Maintain browser state across multiple requests.

```python
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig

async def session_example():
    async with AsyncWebCrawler() as crawler:
        # Login with session
        login_config = CrawlerRunConfig(
            session_id="user-session",
            js_code="""
                document.querySelector('#username').value = 'user@example.com';
                document.querySelector('#password').value = 'password123';
                document.querySelector('form').submit();
            """,
            wait_for="css:.dashboard"
        )

        await crawler.arun("https://example.com/login", config=login_config)

        # Subsequent requests use same session (cookies, localStorage)
        data_config = CrawlerRunConfig(
            session_id="user-session"  # Same session ID
        )

        # Access authenticated pages
        result1 = await crawler.arun("https://example.com/dashboard", config=data_config)
        result2 = await crawler.arun("https://example.com/profile", config=data_config)
        result3 = await crawler.arun("https://example.com/settings", config=data_config)

        return [result1, result2, result3]
```

### Session with Cookies

```python
from crawl4ai import BrowserConfig

browser_config = BrowserConfig(
    cookies=[
        {
            "name": "auth_token",
            "value": "abc123xyz",
            "domain": ".example.com",
            "path": "/",
            "httpOnly": True,
            "secure": True
        },
        {
            "name": "preferences",
            "value": "dark_mode=true",
            "domain": ".example.com"
        }
    ]
)
```

---

## 8. Page Interaction

### JavaScript Execution

```python
from crawl4ai import CrawlerRunConfig

# Click load more button
config = CrawlerRunConfig(
    js_code="""
        // Click all "Load More" buttons
        while (document.querySelector('.load-more:not(.disabled)')) {
            document.querySelector('.load-more').click();
            await new Promise(r => setTimeout(r, 1000));
        }
    """,
    wait_for="css:.all-loaded"
)

# Form interaction
config = CrawlerRunConfig(
    js_code="""
        // Fill search form
        document.querySelector('#search-input').value = 'crawl4ai';
        document.querySelector('#search-form').submit();
    """,
    wait_for="css:.search-results"
)

# Scroll and interact
config = CrawlerRunConfig(
    js_code="""
        // Scroll to load lazy content
        for (let i = 0; i < 5; i++) {
            window.scrollTo(0, document.body.scrollHeight);
            await new Promise(r => setTimeout(r, 500));
        }

        // Expand all accordions
        document.querySelectorAll('.accordion-toggle').forEach(el => el.click());
    """
)
```

### Waiting Strategies

```python
# Wait for CSS selector
config = CrawlerRunConfig(wait_for="css:.content-loaded")

# Wait for JavaScript condition
config = CrawlerRunConfig(wait_for="js:window.dataLoaded === true")

# Wait for XPath
config = CrawlerRunConfig(wait_for="xpath://div[@class='loaded']")

# Wait with timeout
config = CrawlerRunConfig(
    wait_for="css:.content",
    page_timeout=30000  # 30 seconds
)

# Fixed delay
config = CrawlerRunConfig(delay_before_return_html=3.0)  # 3 seconds
```

### Handling Infinite Scroll

```python
config = CrawlerRunConfig(
    scan_full_page=True,     # Auto-scroll entire page
    scroll_delay=0.3,        # Delay between scroll steps

    # Or custom scroll logic
    js_code="""
        const scrollToBottom = async () => {
            let lastHeight = 0;
            while (true) {
                window.scrollTo(0, document.body.scrollHeight);
                await new Promise(r => setTimeout(r, 1000));

                const newHeight = document.body.scrollHeight;
                if (newHeight === lastHeight) break;
                lastHeight = newHeight;
            }
        };
        await scrollToBottom();
    """
)
```

### Removing Overlays and Popups

```python
config = CrawlerRunConfig(
    remove_overlay_elements=True,  # Auto-remove common overlays

    # Or explicit removal
    js_code="""
        // Remove cookie banners
        document.querySelectorAll('[class*="cookie"], [class*="consent"]')
            .forEach(el => el.remove());

        // Remove modals
        document.querySelectorAll('.modal, .popup, .overlay')
            .forEach(el => el.remove());

        // Remove fixed elements blocking content
        document.querySelectorAll('[style*="position: fixed"]')
            .forEach(el => el.remove());
    """
)
```

---

## 9. Proxy and Stealth Mode

### Proxy Configuration

```python
from crawl4ai import BrowserConfig

# Simple proxy
browser_config = BrowserConfig(
    proxy_config={
        "server": "http://proxy.example.com:8080"
    }
)

# Authenticated proxy
browser_config = BrowserConfig(
    proxy_config={
        "server": "http://proxy.example.com:8080",
        "username": "proxyuser",
        "password": "proxypass"
    }
)

# SOCKS proxy
browser_config = BrowserConfig(
    proxy_config={
        "server": "socks5://proxy.example.com:1080"
    }
)
```

### Rotating Proxies

```python
import random

class ProxyRotator:
    def __init__(self, proxies: list):
        self.proxies = proxies
        self.index = 0

    def get_next(self) -> dict:
        proxy = self.proxies[self.index]
        self.index = (self.index + 1) % len(self.proxies)
        return {"server": proxy}

proxies = [
    "http://proxy1.example.com:8080",
    "http://proxy2.example.com:8080",
    "http://proxy3.example.com:8080",
]

rotator = ProxyRotator(proxies)

async def crawl_with_rotation(urls: list):
    results = []
    for url in urls:
        browser_config = BrowserConfig(
            proxy_config=rotator.get_next(),
            headless=True
        )
        async with AsyncWebCrawler(config=browser_config) as crawler:
            result = await crawler.arun(url)
            results.append(result)
    return results
```

### Stealth Mode

```python
browser_config = BrowserConfig(
    # Enable stealth mode
    use_managed_browser=True,

    # Random user agent
    user_agent_mode="random",

    # Or specific user agent
    user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",

    # Additional stealth options
    extra_args=[
        "--disable-blink-features=AutomationControlled",
        "--disable-infobars",
        "--window-size=1920,1080"
    ],

    # Realistic viewport
    viewport_width=1920,
    viewport_height=1080
)

# Additional anti-detection JavaScript
config = CrawlerRunConfig(
    js_code="""
        // Override navigator properties
        Object.defineProperty(navigator, 'webdriver', { get: () => undefined });

        // Add realistic mouse movements
        const event = new MouseEvent('mousemove', {
            clientX: Math.random() * window.innerWidth,
            clientY: Math.random() * window.innerHeight
        });
        document.dispatchEvent(event);
    """
)
```

---

## 10. Screenshots and PDF Generation

```python
from crawl4ai import CrawlerRunConfig
import base64

# Screenshot
config = CrawlerRunConfig(
    screenshot=True,
    screenshot_wait_for="css:.content-loaded"
)

result = await crawler.arun(url, config=config)

if result.screenshot:
    # Save screenshot (base64 encoded)
    with open("screenshot.png", "wb") as f:
        f.write(base64.b64decode(result.screenshot))

# PDF Generation
config = CrawlerRunConfig(pdf=True)

result = await crawler.arun(url, config=config)

if result.pdf:
    with open("page.pdf", "wb") as f:
        f.write(base64.b64decode(result.pdf))
```

### Full Page Screenshot

```python
config = CrawlerRunConfig(
    screenshot=True,
    scan_full_page=True,  # Capture full page, not just viewport
    screenshot_wait_for="js:document.readyState === 'complete'"
)
```

---

## 11. MCP Server Integration

Crawl4AI provides an MCP (Model Context Protocol) server for integration with Claude Code and other AI assistants.

### Installation

```bash
# Install with MCP server support
pip install "crawl4ai[mcp]"

# Or install standalone
pip install crawl4ai-mcp
```

### Configuration in Claude Code

Add to your `claude_desktop_config.json` or MCP settings:

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "python",
      "args": ["-m", "crawl4ai.mcp_server"],
      "env": {
        "OPENAI_API_KEY": "your-key",
        "CRAWL4AI_LLM_PROVIDER": "openai/gpt-4o-mini"
      }
    }
  }
}
```

### Alternative: Using npx

```json
{
  "mcpServers": {
    "crawl4ai": {
      "command": "npx",
      "args": ["-y", "crawl4ai-mcp@latest"],
      "env": {
        "OPENAI_API_KEY": "your-key"
      }
    }
  }
}
```

### Available MCP Tools

| Tool | Description |
|------|-------------|
| `crawl_single_page` | Crawl a single URL and return markdown |
| `smart_crawl_url` | Adaptive crawling with AI-guided link following |
| `perform_rag_query` | Query crawled content with semantic search |
| `get_available_sources` | List all crawled sources |
| `extract_structured_data` | Extract data using CSS/LLM strategies |

### Example MCP Usage

```
Human: Crawl the Crawl4AI documentation and tell me about extraction strategies

Claude: I'll crawl the documentation using the Crawl4AI MCP server.

[Uses smart_crawl_url tool with url="https://docs.crawl4ai.com" and query="extraction strategies"]

Based on the crawled documentation, Crawl4AI supports several extraction strategies:
1. CSS/XPath extraction for structured data...
2. LLM extraction for complex content...
```

---

## 12. RAG Pipeline Integration

Build knowledge bases from web content for retrieval-augmented generation.

### Complete RAG Pipeline

```python
import asyncio
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, CacheMode
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_chroma import Chroma
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser

# Step 1: Crawl Documentation
async def crawl_documentation(base_url: str, pages: list) -> list:
    """Crawl documentation pages and return clean markdown."""
    config = CrawlerRunConfig(
        cache_mode=CacheMode.ENABLED,
        word_count_threshold=50,
        excluded_tags=["nav", "footer", "aside"],
        remove_overlay_elements=True
    )

    documents = []
    async with AsyncWebCrawler() as crawler:
        urls = [f"{base_url}/{page}" for page in pages]
        results = await crawler.arun_many(urls, config=config, max_concurrent=5)

        for result in results:
            if result.success and result.markdown:
                documents.append({
                    "url": result.url,
                    "content": result.markdown,
                    "title": result.metadata.get("title", "Untitled")
                })

    return documents

# Step 2: Chunk Content
def chunk_documents(documents: list, chunk_size: int = 1000, overlap: int = 200) -> list:
    """Split documents into smaller chunks for embedding."""
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=overlap,
        separators=["\n## ", "\n### ", "\n\n", "\n", " ", ""]
    )

    chunks = []
    for doc in documents:
        doc_chunks = splitter.split_text(doc["content"])
        for i, chunk in enumerate(doc_chunks):
            chunks.append({
                "content": chunk,
                "metadata": {
                    "source": doc["url"],
                    "title": doc["title"],
                    "chunk_index": i
                }
            })

    return chunks

# Step 3: Create Vector Store
def create_vector_store(chunks: list, persist_dir: str = "./chroma_db"):
    """Create embeddings and store in vector database."""
    embeddings = OpenAIEmbeddings()

    texts = [chunk["content"] for chunk in chunks]
    metadatas = [chunk["metadata"] for chunk in chunks]

    vectorstore = Chroma.from_texts(
        texts=texts,
        embedding=embeddings,
        metadatas=metadatas,
        persist_directory=persist_dir
    )

    return vectorstore

# Step 4: Build RAG Chain
def create_rag_chain(vectorstore):
    """Create RAG chain for question answering."""
    retriever = vectorstore.as_retriever(
        search_type="similarity",
        search_kwargs={"k": 4}
    )

    llm = ChatOpenAI(model="gpt-4o", temperature=0)

    template = """Answer the question based on the following context from the documentation.
    If the answer is not in the context, say "I don't have information about that in the documentation."

    Context:
    {context}

    Question: {question}

    Answer:"""

    prompt = ChatPromptTemplate.from_template(template)

    def format_docs(docs):
        return "\n\n---\n\n".join([
            f"Source: {doc.metadata.get('source', 'Unknown')}\n{doc.page_content}"
            for doc in docs
        ])

    chain = (
        {"context": retriever | format_docs, "question": RunnablePassthrough()}
        | prompt
        | llm
        | StrOutputParser()
    )

    return chain

# Full Pipeline
async def build_docs_rag(base_url: str, pages: list):
    """Complete pipeline to build RAG from documentation."""
    print("Crawling documentation...")
    documents = await crawl_documentation(base_url, pages)
    print(f"Crawled {len(documents)} pages")

    print("Chunking content...")
    chunks = chunk_documents(documents)
    print(f"Created {len(chunks)} chunks")

    print("Creating vector store...")
    vectorstore = create_vector_store(chunks)

    print("Building RAG chain...")
    chain = create_rag_chain(vectorstore)

    return chain

# Usage
async def main():
    chain = await build_docs_rag(
        base_url="https://docs.crawl4ai.com",
        pages=["getting-started", "extraction", "configuration", "advanced"]
    )

    # Query the documentation
    answer = chain.invoke("How do I extract structured data from a webpage?")
    print(answer)

asyncio.run(main())
```

### Incremental Updates

```python
async def update_knowledge_base(vectorstore, new_urls: list):
    """Add new pages to existing knowledge base."""
    config = CrawlerRunConfig(cache_mode=CacheMode.BYPASS)

    async with AsyncWebCrawler() as crawler:
        results = await crawler.arun_many(new_urls, config=config)

    documents = [
        {"url": r.url, "content": r.markdown, "title": r.metadata.get("title", "")}
        for r in results if r.success
    ]

    chunks = chunk_documents(documents)

    # Add to existing vectorstore
    texts = [c["content"] for c in chunks]
    metadatas = [c["metadata"] for c in chunks]
    vectorstore.add_texts(texts=texts, metadatas=metadatas)

    return len(chunks)
```

---

## 13. Best Practices

### Performance Optimization

```python
# Use caching during development
config = CrawlerRunConfig(cache_mode=CacheMode.ENABLED)

# Limit concurrent requests
results = await crawler.arun_many(urls, max_concurrent=5)

# Use CSS extraction when possible (faster, cheaper than LLM)
css_strategy = JsonCssExtractionStrategy(schema)

# Only extract needed content
config = CrawlerRunConfig(
    css_selector=".main-content",  # Target specific content
    excluded_tags=["nav", "footer", "script", "style"]
)
```

### Respecting Websites

```python
# Check robots.txt
import httpx
from urllib.parse import urljoin

async def check_robots(base_url: str, path: str) -> bool:
    robots_url = urljoin(base_url, "/robots.txt")
    async with httpx.AsyncClient() as client:
        response = await client.get(robots_url)
        # Parse robots.txt and check if path is allowed
        # ... implementation
        return True

# Rate limiting
async def respectful_crawl(urls: list, delay: float = 1.0):
    config = CrawlerRunConfig(mean_delay=delay)
    async with AsyncWebCrawler() as crawler:
        results = []
        for url in urls:
            result = await crawler.arun(url, config=config)
            results.append(result)
            await asyncio.sleep(delay)
        return results
```

### Error Handling

```python
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig
import asyncio

async def robust_crawl(url: str, max_retries: int = 3):
    """Crawl with retry logic."""
    config = CrawlerRunConfig(
        page_timeout=30000,
        wait_for="css:body"
    )

    for attempt in range(max_retries):
        try:
            async with AsyncWebCrawler() as crawler:
                result = await crawler.arun(url, config=config)

                if result.success:
                    return result

                print(f"Attempt {attempt + 1} failed: {result.error_message}")

        except Exception as e:
            print(f"Attempt {attempt + 1} error: {e}")

        # Exponential backoff
        await asyncio.sleep(2 ** attempt)

    return None
```

### Memory Management

```python
# Process large URL lists in batches
async def batch_crawl(urls: list, batch_size: int = 50):
    all_results = []

    for i in range(0, len(urls), batch_size):
        batch = urls[i:i + batch_size]

        async with AsyncWebCrawler() as crawler:
            results = await crawler.arun_many(batch, max_concurrent=10)
            all_results.extend(results)

        # Let garbage collection run
        await asyncio.sleep(0.1)

    return all_results
```

### Token Efficiency

```python
# Use CSS extraction first, LLM only when needed
async def efficient_extraction(url: str, css_schema: dict, llm_instruction: str):
    """Try CSS extraction first, fall back to LLM."""

    # Try CSS extraction
    css_strategy = JsonCssExtractionStrategy(css_schema)
    config = CrawlerRunConfig(extraction_strategy=css_strategy)

    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(url, config=config)

    if result.extracted_content and result.extracted_content != "[]":
        return {"method": "css", "data": result.extracted_content}

    # Fall back to LLM
    llm_strategy = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction=llm_instruction
    )
    config = CrawlerRunConfig(extraction_strategy=llm_strategy)

    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(url, config=config)

    return {"method": "llm", "data": result.extracted_content}
```

---

## 14. Common Patterns

### Documentation Crawler

```python
async def crawl_documentation_site(base_url: str, max_pages: int = 100):
    """Crawl a documentation site following internal links."""
    visited = set()
    to_visit = [base_url]
    documents = []

    config = CrawlerRunConfig(
        cache_mode=CacheMode.ENABLED,
        word_count_threshold=100,
        excluded_tags=["nav", "footer", "aside", "header"]
    )

    async with AsyncWebCrawler() as crawler:
        while to_visit and len(visited) < max_pages:
            url = to_visit.pop(0)

            if url in visited:
                continue

            visited.add(url)
            result = await crawler.arun(url, config=config)

            if result.success:
                documents.append({
                    "url": url,
                    "markdown": result.markdown,
                    "title": result.metadata.get("title", "")
                })

                # Add internal links to queue
                for link in result.links.get("internal", []):
                    if link["href"] not in visited:
                        to_visit.append(link["href"])

    return documents
```

### E-Commerce Product Scraper

```python
schema = {
    "name": "Products",
    "baseSelector": ".product-item",
    "fields": [
        {"name": "name", "selector": ".product-name", "type": "text"},
        {"name": "price", "selector": ".price", "type": "text"},
        {"name": "original_price", "selector": ".original-price", "type": "text"},
        {"name": "image", "selector": "img", "type": "attribute", "attribute": "src"},
        {"name": "rating", "selector": ".rating", "type": "attribute", "attribute": "data-rating"},
        {"name": "reviews", "selector": ".review-count", "type": "text"},
        {"name": "url", "selector": "a.product-link", "type": "attribute", "attribute": "href"}
    ]
}

async def scrape_products(category_url: str):
    strategy = JsonCssExtractionStrategy(schema)
    config = CrawlerRunConfig(
        extraction_strategy=strategy,
        scan_full_page=True,  # Load all products
        js_code="""
            // Click "Load More" until all products visible
            while (document.querySelector('.load-more:not([disabled])')) {
                document.querySelector('.load-more').click();
                await new Promise(r => setTimeout(r, 1000));
            }
        """
    )

    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(category_url, config=config)

    import json
    return json.loads(result.extracted_content)
```

### News Aggregator

```python
async def aggregate_news(sources: list):
    """Aggregate news from multiple sources."""

    # Different extraction schemas per source type
    article_schema = {
        "name": "Articles",
        "baseSelector": "article, .article, .post",
        "fields": [
            {"name": "headline", "selector": "h1, h2, h3", "type": "text"},
            {"name": "summary", "selector": "p, .excerpt, .summary", "type": "text"},
            {"name": "author", "selector": ".author, .byline", "type": "text"},
            {"name": "date", "selector": "time, .date", "type": "text"},
            {"name": "url", "selector": "a", "type": "attribute", "attribute": "href"}
        ]
    }

    strategy = JsonCssExtractionStrategy(article_schema)
    config = CrawlerRunConfig(extraction_strategy=strategy)

    all_articles = []
    async with AsyncWebCrawler() as crawler:
        for source in sources:
            result = await crawler.arun(source["url"], config=config)
            if result.success:
                import json
                articles = json.loads(result.extracted_content)
                for article in articles:
                    article["source"] = source["name"]
                all_articles.extend(articles)

    # Sort by date
    all_articles.sort(key=lambda x: x.get("date", ""), reverse=True)
    return all_articles
```

### Research Assistant

```python
async def research_topic(query: str, num_sources: int = 10):
    """Search and summarize information on a topic."""

    # This would integrate with a search API to get URLs
    # For demo, assume we have URLs
    search_results = await search_web(query, num_sources)
    urls = [r["url"] for r in search_results]

    config = CrawlerRunConfig(
        word_count_threshold=100,
        excluded_tags=["nav", "footer", "aside", "script"]
    )

    async with AsyncWebCrawler() as crawler:
        results = await crawler.arun_many(urls, config=config, max_concurrent=5)

    # Collect successful content
    sources = []
    for result in results:
        if result.success and len(result.markdown) > 200:
            sources.append({
                "url": result.url,
                "title": result.metadata.get("title", ""),
                "content": result.markdown[:5000]  # Limit content length
            })

    # Use LLM to synthesize
    from openai import OpenAI
    client = OpenAI()

    context = "\n\n---\n\n".join([
        f"Source: {s['title']}\nURL: {s['url']}\n\n{s['content']}"
        for s in sources
    ])

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": "Synthesize the following sources into a comprehensive summary. Cite sources."},
            {"role": "user", "content": f"Topic: {query}\n\nSources:\n{context}"}
        ]
    )

    return {
        "summary": response.choices[0].message.content,
        "sources": sources
    }
```

---

## 15. Troubleshooting

### Browser Not Found

```bash
# Reinstall browser dependencies
crawl4ai-setup --force

# Check browser installation
crawl4ai-doctor --verbose

# Specify browser path manually
from crawl4ai import BrowserConfig
config = BrowserConfig(
    browser_type="chromium",
    extra_args=["--no-sandbox"]
)
```

### JavaScript Not Executing

```python
# Increase wait time
config = CrawlerRunConfig(
    delay_before_return_html=5.0,
    page_timeout=60000
)

# Wait for specific condition
config = CrawlerRunConfig(
    wait_for="js:window.dataLoaded === true"
)

# Check if JavaScript is enabled
browser_config = BrowserConfig(java_script_enabled=True)
```

### Rate Limiting / 429 Errors

```python
# Add delays between requests
config = CrawlerRunConfig(mean_delay=2.0)

# Use rotating proxies
proxies = ["proxy1:8080", "proxy2:8080"]
# Rotate through proxies for each request

# Add realistic headers
browser_config = BrowserConfig(
    user_agent_mode="random",
    headers={"Accept-Language": "en-US,en;q=0.9"}
)
```

### Memory Issues with Large Crawls

```python
# Process in smaller batches
for batch in chunked(urls, 50):
    async with AsyncWebCrawler() as crawler:
        results = await crawler.arun_many(batch)
    process_results(results)

# Disable screenshots/PDFs
config = CrawlerRunConfig(
    screenshot=False,
    pdf=False
)

# Limit content size
config = CrawlerRunConfig(
    word_count_threshold=50  # Skip small content blocks
)
```

### Content Not Loading (SPA/React Sites)

```python
# Enable full page scan
config = CrawlerRunConfig(
    scan_full_page=True,
    scroll_delay=1.0
)

# Wait for React hydration
config = CrawlerRunConfig(
    wait_for="js:document.querySelector('[data-reactroot]')"
)

# Use Magic Mode
config = CrawlerRunConfig(magic=True)
```

### SSL/Certificate Errors

```python
browser_config = BrowserConfig(
    extra_args=[
        "--ignore-certificate-errors",
        "--ignore-ssl-errors"
    ]
)
```

### Blocked by Cloudflare/Bot Protection

```python
# Use managed browser with stealth
browser_config = BrowserConfig(
    use_managed_browser=True,
    user_agent_mode="random"
)

# Add human-like delays
config = CrawlerRunConfig(
    delay_before_return_html=3.0,
    js_code="""
        // Simulate mouse movement
        document.dispatchEvent(new MouseEvent('mousemove', {
            clientX: 100 + Math.random() * 500,
            clientY: 100 + Math.random() * 300
        }));
    """
)
```

---

## 16. API Reference

### Core Classes

| Class | Description |
|-------|-------------|
| `AsyncWebCrawler` | Main async crawler class |
| `WebCrawler` | Synchronous wrapper |
| `BrowserConfig` | Browser configuration |
| `CrawlerRunConfig` | Request configuration |
| `AdaptiveCrawler` | AI-guided adaptive crawling |
| `LLMConfig` | LLM provider configuration |

### Extraction Strategies

| Strategy | Description |
|----------|-------------|
| `JsonCssExtractionStrategy` | CSS/XPath-based extraction |
| `LLMExtractionStrategy` | LLM-powered extraction |
| `CosineStrategy` | Semantic similarity extraction |

### Cache Modes

| Mode | Description |
|------|-------------|
| `CacheMode.ENABLED` | Read and write cache |
| `CacheMode.DISABLED` | No caching |
| `CacheMode.READ_ONLY` | Only read from cache |
| `CacheMode.WRITE_ONLY` | Only write to cache |
| `CacheMode.BYPASS` | Skip cache completely |

---

## Resources

- [Crawl4AI Documentation](https://docs.crawl4ai.com/)
- [GitHub Repository](https://github.com/unclecode/crawl4ai)
- [PyPI Package](https://pypi.org/project/crawl4ai/)
- [MCP Server](https://github.com/unclecode/crawl4ai-mcp)
- [Discord Community](https://discord.gg/crawl4ai)
- [Example Notebooks](https://github.com/unclecode/crawl4ai/tree/main/examples)
