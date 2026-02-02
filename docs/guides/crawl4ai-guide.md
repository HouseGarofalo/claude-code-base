# Crawl4AI Guide: AI-Powered Web Crawling for Claude Code

A comprehensive guide to using Crawl4AI for web crawling, data extraction, and content processing in Claude Code workflows.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Quick Start](#quick-start)
3. [Understanding the Architecture](#understanding-the-architecture)
4. [Using Crawl4AI with Claude Code](#using-crawl4ai-with-claude-code)
5. [Common Use Cases](#common-use-cases)
6. [Best Practices](#best-practices)
7. [Integration Patterns](#integration-patterns)
8. [Configuration Reference](#configuration-reference)
9. [Troubleshooting](#troubleshooting)
10. [Resources](#resources)

---

## Introduction

### What is Crawl4AI?

Crawl4AI is an open-source, LLM-friendly web crawler and scraper designed specifically for AI applications. Unlike traditional web scrapers that focus on raw HTML extraction, Crawl4AI produces clean, well-structured content optimized for large language models, RAG pipelines, and AI agents.

The library transforms web pages into multiple output formats:

- **Clean Markdown** - Accurately formatted markdown preserving document structure
- **Fit Markdown** - Heuristically filtered content eliminating noise and boilerplate
- **Structured JSON** - Schema-based extraction for specific data patterns
- **Raw HTML** - Original and sanitized HTML for custom processing

### Why Use Crawl4AI with Claude Code?

Crawl4AI complements Claude Code workflows in several ways:

1. **Documentation Ingestion** - Crawl technical documentation sites to build knowledge bases
2. **Research Automation** - Gather information from multiple sources for analysis
3. **Data Pipeline Construction** - Extract structured data for processing and storage
4. **Content Monitoring** - Track changes across web properties
5. **RAG System Feeding** - Generate embeddings-ready content for retrieval systems

### Key Capabilities

| Capability | Description |
|------------|-------------|
| **Async-First Design** | Built on asyncio for high-performance concurrent crawling |
| **Multiple Browsers** | Supports Chromium, Firefox, and WebKit via Playwright |
| **Deep Crawling** | BFS, DFS, and Best-First traversal strategies |
| **JavaScript Execution** | Full dynamic content rendering and interaction |
| **Extraction Strategies** | CSS selectors, XPath, and LLM-based parsing |
| **Stealth Mode** | Bot detection evasion for protected sites |
| **Session Persistence** | Maintain authentication across crawl sessions |
| **Media Handling** | Extract images, responsive srcset, and lazy-loaded content |

---

## Quick Start

### Installation Steps

**Basic Installation**

```bash
# Install the core library
pip install crawl4ai

# Run the setup script (installs Playwright browsers)
crawl4ai-setup

# Verify installation
crawl4ai-doctor
```

**Advanced Installation Options**

```bash
# Include PyTorch support for ML features
pip install crawl4ai[torch]

# Include transformer models
pip install crawl4ai[transformer]

# Full installation with all features
pip install crawl4ai[all]

# Pre-download ML models (optional)
crawl4ai-download-models
```

**Docker Installation**

```bash
# Pull the official image
docker pull unclecode/crawl4ai:basic

# Run with default settings (API on port 11235)
docker run -p 11235:11235 unclecode/crawl4ai:basic

# Access the playground at http://localhost:11235/playground
```

### First Crawl Example

```python
import asyncio
from crawl4ai import AsyncWebCrawler

async def main():
    # Create crawler instance (context manager handles browser lifecycle)
    async with AsyncWebCrawler() as crawler:
        # Crawl a URL
        result = await crawler.arun("https://example.com")

        # Check success
        if result.success:
            print(f"Status: {result.status_code}")
            print(f"Title: {result.metadata.get('title', 'N/A')}")
            print(f"Content preview:\n{result.markdown[:500]}")
        else:
            print(f"Crawl failed: {result.error_message}")

# Run the async function
asyncio.run(main())
```

### Verifying It Works

Create a test script to verify your installation:

```python
import asyncio
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig

async def verify_installation():
    """Comprehensive installation verification."""

    print("=" * 50)
    print("Crawl4AI Installation Verification")
    print("=" * 50)

    # Test 1: Basic crawl
    print("\n[Test 1] Basic crawl...")
    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun("https://httpbin.org/html")
        assert result.success, "Basic crawl failed"
        assert len(result.markdown) > 100, "No markdown content"
        print("  PASSED: Basic crawl works")

    # Test 2: Custom configuration
    print("\n[Test 2] Custom configuration...")
    browser_config = BrowserConfig(
        headless=True,
        browser_type="chromium"
    )
    run_config = CrawlerRunConfig(
        word_count_threshold=10,
        page_timeout=30000
    )

    async with AsyncWebCrawler(config=browser_config) as crawler:
        result = await crawler.arun(
            "https://httpbin.org/html",
            config=run_config
        )
        assert result.success, "Configured crawl failed"
        print("  PASSED: Custom configuration works")

    # Test 3: JavaScript rendering
    print("\n[Test 3] JavaScript rendering...")
    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun("https://httpbin.org/html")
        assert result.html is not None, "No HTML captured"
        print("  PASSED: JavaScript rendering works")

    print("\n" + "=" * 50)
    print("All tests passed! Crawl4AI is ready to use.")
    print("=" * 50)

if __name__ == "__main__":
    asyncio.run(verify_installation())
```

---

## Understanding the Architecture

### AsyncWebCrawler

The `AsyncWebCrawler` is the primary interface for all crawling operations. It manages browser instances, handles page navigation, and orchestrates content extraction.

```python
from crawl4ai import AsyncWebCrawler, BrowserConfig

# Basic usage with context manager (recommended)
async with AsyncWebCrawler() as crawler:
    result = await crawler.arun("https://example.com")

# Custom browser configuration
browser_config = BrowserConfig(
    browser_type="chromium",
    headless=True,
    viewport_width=1920,
    viewport_height=1080
)

async with AsyncWebCrawler(config=browser_config) as crawler:
    # Crawler is ready with configured browser
    pass
```

**Key Methods:**

| Method | Purpose |
|--------|---------|
| `arun(url, config)` | Crawl a single URL |
| `arun_many(urls, config)` | Crawl multiple URLs concurrently |
| `crawler.close()` | Explicitly close browser (if not using context manager) |

### BrowserConfig vs CrawlerRunConfig

Crawl4AI separates configuration into two distinct classes to provide flexibility:

**BrowserConfig** - Controls browser-level behavior (set once per crawler instance):

```python
from crawl4ai import BrowserConfig

browser_config = BrowserConfig(
    # Browser selection
    browser_type="chromium",  # "chromium", "firefox", "webkit"
    headless=True,            # Run invisibly

    # Window settings
    viewport_width=1080,
    viewport_height=600,

    # Identity
    user_agent="Custom User Agent",
    user_agent_mode="random",  # Randomize user agent

    # Performance
    text_mode=False,    # Disable images for speed
    light_mode=False,   # Disable background features

    # Stealth
    enable_stealth=True,  # Avoid bot detection

    # Persistence
    use_persistent_context=True,
    user_data_dir="/path/to/profile",

    # Proxy
    proxy_config={
        "server": "http://proxy:8080",
        "username": "user",
        "password": "pass"
    }
)
```

**CrawlerRunConfig** - Controls per-crawl behavior (can vary between requests):

```python
from crawl4ai import CrawlerRunConfig, CacheMode

run_config = CrawlerRunConfig(
    # Caching
    cache_mode=CacheMode.BYPASS,  # ENABLED, BYPASS, DISABLED

    # Content filtering
    word_count_threshold=200,  # Minimum words per block

    # Timing
    page_timeout=60000,           # 60 seconds
    delay_before_return_html=0.5, # Wait before capture

    # JavaScript
    js_code="document.querySelector('.load-more').click();",
    wait_for="css:.content-loaded",

    # Scrolling
    scan_full_page=True,  # Scroll to load all content

    # Captures
    screenshot=True,
    pdf=True,
    capture_mhtml=True,

    # Extraction
    extraction_strategy=my_extraction_strategy,
    markdown_generator=my_markdown_generator
)
```

### Extraction Strategies

Crawl4AI provides multiple strategies for extracting structured data:

**CSS-Based Extraction**

```python
from crawl4ai import JsonCssExtractionStrategy

# Define extraction schema
schema = {
    "name": "Product Listings",
    "baseSelector": "div.product-card",
    "fields": [
        {
            "name": "title",
            "selector": "h2.product-title",
            "type": "text"
        },
        {
            "name": "price",
            "selector": "span.price",
            "type": "text"
        },
        {
            "name": "image",
            "selector": "img",
            "type": "attribute",
            "attribute": "src"
        },
        {
            "name": "link",
            "selector": "a.product-link",
            "type": "attribute",
            "attribute": "href"
        }
    ]
}

strategy = JsonCssExtractionStrategy(schema)
config = CrawlerRunConfig(extraction_strategy=strategy)
```

**LLM-Based Extraction**

```python
from crawl4ai import LLMExtractionStrategy, LLMConfig
from pydantic import BaseModel, Field
from typing import List

# Define data model
class Article(BaseModel):
    title: str = Field(description="Article headline")
    author: str = Field(description="Author name")
    date: str = Field(description="Publication date")
    summary: str = Field(description="Brief summary of content")

class ArticleList(BaseModel):
    articles: List[Article]

# Configure LLM strategy
llm_config = LLMConfig(
    provider="openai/gpt-4o-mini",
    api_token="your-api-key"  # Or use "env:OPENAI_API_KEY"
)

strategy = LLMExtractionStrategy(
    llm_config=llm_config,
    schema=ArticleList.model_json_schema(),
    instruction="Extract all articles from the page content"
)

config = CrawlerRunConfig(extraction_strategy=strategy)
```

### Result Objects

The `CrawlResult` object contains all extracted data:

```python
result = await crawler.arun("https://example.com")

# Navigation info
result.url              # Final URL (after redirects)
result.success          # Boolean success flag
result.status_code      # HTTP status code
result.error_message    # Error details if failed

# Content
result.html             # Raw HTML
result.cleaned_html     # Sanitized HTML
result.markdown         # Generated markdown

# Markdown variants (MarkdownGenerationResult)
result.markdown.raw_markdown       # Full markdown
result.markdown.fit_markdown       # Filtered/cleaned markdown
result.markdown.markdown_with_citations  # With numbered references

# Structured data
result.extracted_content  # JSON from extraction strategy

# Media and links
result.media             # Discovered images
result.links             # Internal and external links

# Optional captures
result.screenshot        # Base64 screenshot (if enabled)
result.pdf               # PDF bytes (if enabled)
result.mhtml             # MHTML archive (if enabled)

# Metadata
result.metadata          # Page title, description, etc.
```

---

## Using Crawl4AI with Claude Code

### Direct Python Usage

Use the Python library directly when you need:

- Full programmatic control over crawling behavior
- Complex extraction logic with custom post-processing
- Integration into larger Python applications
- Batch processing with custom parallelization

**Example: Documentation Site Crawler**

```python
import asyncio
import json
from pathlib import Path
from crawl4ai import (
    AsyncWebCrawler,
    BrowserConfig,
    CrawlerRunConfig,
    CacheMode
)
from crawl4ai.deep_crawling import BFSDeepCrawlStrategy

async def crawl_documentation(base_url: str, output_dir: str):
    """Crawl a documentation site and save as markdown files."""

    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    browser_config = BrowserConfig(
        headless=True,
        browser_type="chromium"
    )

    # Deep crawl strategy for documentation
    deep_strategy = BFSDeepCrawlStrategy(
        max_depth=3,
        max_pages=100,
        include_external=False
    )

    run_config = CrawlerRunConfig(
        cache_mode=CacheMode.ENABLED,
        word_count_threshold=50,
        deep_crawl_strategy=deep_strategy
    )

    results = []

    async with AsyncWebCrawler(config=browser_config) as crawler:
        async for result in await crawler.arun(
            base_url,
            config=run_config
        ):
            if result.success:
                # Generate filename from URL
                safe_name = result.url.replace("/", "_").replace(":", "")[-100:]
                filepath = output_path / f"{safe_name}.md"

                # Write markdown content
                filepath.write_text(result.markdown, encoding="utf-8")

                results.append({
                    "url": result.url,
                    "file": str(filepath),
                    "word_count": len(result.markdown.split())
                })

                print(f"Saved: {result.url}")

    # Save index
    index_path = output_path / "index.json"
    index_path.write_text(json.dumps(results, indent=2))

    return results

# Usage
asyncio.run(crawl_documentation(
    "https://docs.example.com",
    "./crawled_docs"
))
```

### MCP Server Integration

The MCP (Model Context Protocol) server provides an interface for interactive crawling sessions. Use it when you need:

- Real-time crawling during conversations
- Integration with Claude Code's tool ecosystem
- Dynamic URL discovery based on conversation context
- Interactive data exploration

**Starting the MCP Server**

```bash
# Using Docker (recommended for production)
docker run -p 11235:11235 unclecode/crawl4ai:basic

# Or using the Python package
crawl4ai-server --port 11235
```

**MCP Server API Endpoints**

```python
import httpx

BASE_URL = "http://localhost:11235"

# Single page crawl
async def crawl_page(url: str):
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{BASE_URL}/crawl",
            json={
                "url": url,
                "config": {
                    "word_count_threshold": 100,
                    "cache_mode": "bypass"
                }
            }
        )
        return response.json()

# Batch crawl
async def crawl_batch(urls: list):
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{BASE_URL}/crawl/batch",
            json={
                "urls": urls,
                "config": {
                    "cache_mode": "enabled"
                }
            }
        )
        return response.json()
```

---

## Common Use Cases

### Documentation Crawler

Build a knowledge base from technical documentation sites.

```python
import asyncio
from datetime import datetime
from crawl4ai import (
    AsyncWebCrawler,
    BrowserConfig,
    CrawlerRunConfig,
    CacheMode
)
from crawl4ai.deep_crawling import BFSDeepCrawlStrategy
from crawl4ai.markdown_generation_strategy import DefaultMarkdownGenerator
from crawl4ai.content_filter_strategy import PruningContentFilter

class DocumentationCrawler:
    """Crawl documentation sites and produce clean markdown."""

    def __init__(self, base_url: str, max_pages: int = 100):
        self.base_url = base_url
        self.max_pages = max_pages
        self.results = []

    async def crawl(self):
        """Execute the documentation crawl."""

        # Configure markdown generation with content filtering
        md_generator = DefaultMarkdownGenerator(
            content_filter=PruningContentFilter(
                threshold=0.4,
                threshold_type="fixed"
            )
        )

        # Browser configuration
        browser_config = BrowserConfig(
            headless=True,
            browser_type="chromium",
            viewport_width=1920,
            viewport_height=1080
        )

        # Deep crawl strategy
        deep_strategy = BFSDeepCrawlStrategy(
            max_depth=4,
            max_pages=self.max_pages,
            include_external=False
        )

        # Run configuration
        run_config = CrawlerRunConfig(
            cache_mode=CacheMode.ENABLED,
            word_count_threshold=50,
            markdown_generator=md_generator,
            deep_crawl_strategy=deep_strategy,
            scan_full_page=True  # Handle lazy-loaded content
        )

        async with AsyncWebCrawler(config=browser_config) as crawler:
            async for result in await crawler.arun(
                self.base_url,
                config=run_config
            ):
                if result.success:
                    self.results.append({
                        "url": result.url,
                        "title": result.metadata.get("title", "Untitled"),
                        "content": result.markdown,
                        "word_count": len(result.markdown.split()),
                        "crawled_at": datetime.utcnow().isoformat()
                    })

        return self.results

    def export_markdown(self, output_dir: str):
        """Export results as individual markdown files."""
        from pathlib import Path

        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)

        for i, result in enumerate(self.results):
            filename = f"{i:04d}_{self._safe_filename(result['title'])}.md"
            filepath = output_path / filename

            # Add frontmatter
            content = f"""---
title: {result['title']}
url: {result['url']}
crawled_at: {result['crawled_at']}
---

{result['content']}
"""
            filepath.write_text(content, encoding="utf-8")

    def _safe_filename(self, title: str) -> str:
        """Convert title to safe filename."""
        import re
        safe = re.sub(r'[^\w\s-]', '', title.lower())
        return re.sub(r'[-\s]+', '-', safe).strip('-')[:50]

# Usage
async def main():
    crawler = DocumentationCrawler(
        base_url="https://docs.python.org/3/",
        max_pages=50
    )

    results = await crawler.crawl()
    print(f"Crawled {len(results)} pages")

    crawler.export_markdown("./python_docs")

asyncio.run(main())
```

### Product Data Extraction

Extract structured product data from e-commerce sites.

```python
import asyncio
import json
from crawl4ai import (
    AsyncWebCrawler,
    BrowserConfig,
    CrawlerRunConfig,
    JsonCssExtractionStrategy
)

class ProductScraper:
    """Extract product data from e-commerce pages."""

    def __init__(self):
        self.products = []

        # Define extraction schema
        self.schema = {
            "name": "Products",
            "baseSelector": "div.product-item, article.product",
            "fields": [
                {
                    "name": "name",
                    "selector": "h2, h3, .product-title",
                    "type": "text"
                },
                {
                    "name": "price",
                    "selector": ".price, .product-price",
                    "type": "text"
                },
                {
                    "name": "original_price",
                    "selector": ".original-price, .was-price",
                    "type": "text"
                },
                {
                    "name": "image_url",
                    "selector": "img",
                    "type": "attribute",
                    "attribute": "src"
                },
                {
                    "name": "product_url",
                    "selector": "a",
                    "type": "attribute",
                    "attribute": "href"
                },
                {
                    "name": "rating",
                    "selector": ".rating, .stars",
                    "type": "text"
                },
                {
                    "name": "review_count",
                    "selector": ".review-count, .reviews",
                    "type": "text"
                }
            ]
        }

    async def scrape_category(self, url: str, max_pages: int = 5):
        """Scrape products from a category page."""

        browser_config = BrowserConfig(
            headless=True,
            enable_stealth=True  # Avoid bot detection
        )

        extraction_strategy = JsonCssExtractionStrategy(self.schema)

        run_config = CrawlerRunConfig(
            extraction_strategy=extraction_strategy,
            scan_full_page=True,  # Load all products via scroll
            page_timeout=30000
        )

        async with AsyncWebCrawler(config=browser_config) as crawler:
            # Handle pagination
            for page in range(1, max_pages + 1):
                page_url = f"{url}?page={page}"

                result = await crawler.arun(page_url, config=run_config)

                if result.success and result.extracted_content:
                    data = json.loads(result.extracted_content)
                    products = data.get("Products", [])

                    if not products:
                        break  # No more products

                    self.products.extend(products)
                    print(f"Page {page}: Found {len(products)} products")
                else:
                    print(f"Page {page}: Failed or no data")
                    break

                # Respectful delay between pages
                await asyncio.sleep(1)

        return self.products

    def clean_data(self):
        """Clean and normalize extracted data."""
        import re

        for product in self.products:
            # Clean price
            if product.get("price"):
                price_match = re.search(r'[\d,.]+', product["price"])
                if price_match:
                    product["price_numeric"] = float(
                        price_match.group().replace(",", "")
                    )

            # Clean rating
            if product.get("rating"):
                rating_match = re.search(r'[\d.]+', product["rating"])
                if rating_match:
                    product["rating_numeric"] = float(rating_match.group())

        return self.products

    def to_json(self, filepath: str):
        """Export products to JSON file."""
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(self.products, f, indent=2, ensure_ascii=False)

# Usage
async def main():
    scraper = ProductScraper()

    products = await scraper.scrape_category(
        "https://example-shop.com/electronics",
        max_pages=10
    )

    scraper.clean_data()
    scraper.to_json("products.json")

    print(f"Total products: {len(products)}")

asyncio.run(main())
```

### Research Assistant

Adaptive crawling for gathering research information.

```python
import asyncio
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig
from crawl4ai.deep_crawling import BestFirstCrawlingStrategy
from crawl4ai.scoring import KeywordRelevanceScorer

class ResearchAssistant:
    """Adaptive crawler for research tasks."""

    def __init__(self, research_topic: str, keywords: list):
        self.topic = research_topic
        self.keywords = keywords
        self.findings = []

    async def research(
        self,
        starting_urls: list,
        max_pages_per_source: int = 20
    ):
        """Conduct research across multiple sources."""

        browser_config = BrowserConfig(
            headless=True,
            browser_type="chromium"
        )

        # Relevance-based scoring
        scorer = KeywordRelevanceScorer(
            keywords=self.keywords,
            weight=0.7
        )

        # Best-first strategy prioritizes relevant pages
        strategy = BestFirstCrawlingStrategy(
            max_depth=3,
            max_pages=max_pages_per_source,
            url_scorer=scorer,
            score_threshold=0.3  # Only crawl relevant pages
        )

        run_config = CrawlerRunConfig(
            deep_crawl_strategy=strategy,
            word_count_threshold=100
        )

        async with AsyncWebCrawler(config=browser_config) as crawler:
            for start_url in starting_urls:
                print(f"\nResearching: {start_url}")

                async for result in await crawler.arun(
                    start_url,
                    config=run_config
                ):
                    if result.success:
                        relevance = self._calculate_relevance(result.markdown)

                        if relevance > 0.5:  # High relevance threshold
                            self.findings.append({
                                "url": result.url,
                                "source": start_url,
                                "title": result.metadata.get("title", ""),
                                "content": result.markdown,
                                "relevance_score": relevance
                            })
                            print(f"  Found relevant: {result.url[:60]}...")

        # Sort by relevance
        self.findings.sort(key=lambda x: x["relevance_score"], reverse=True)

        return self.findings

    def _calculate_relevance(self, content: str) -> float:
        """Calculate content relevance to research topic."""
        content_lower = content.lower()

        # Count keyword occurrences
        keyword_count = sum(
            content_lower.count(kw.lower())
            for kw in self.keywords
        )

        # Normalize by content length
        word_count = len(content.split())
        if word_count == 0:
            return 0.0

        # Simple relevance score
        score = min(keyword_count / (word_count / 100), 1.0)
        return round(score, 3)

    def generate_summary(self) -> str:
        """Generate a research summary."""
        if not self.findings:
            return "No relevant findings."

        summary_parts = [
            f"# Research Summary: {self.topic}",
            f"\n## Overview",
            f"Found {len(self.findings)} relevant sources.",
            f"\n## Top Sources\n"
        ]

        for i, finding in enumerate(self.findings[:10], 1):
            summary_parts.append(
                f"{i}. [{finding['title']}]({finding['url']})"
                f" (relevance: {finding['relevance_score']:.2f})"
            )

        return "\n".join(summary_parts)

# Usage
async def main():
    assistant = ResearchAssistant(
        research_topic="Machine Learning Best Practices",
        keywords=["machine learning", "ML", "model", "training", "dataset"]
    )

    findings = await assistant.research(
        starting_urls=[
            "https://scikit-learn.org/stable/",
            "https://pytorch.org/tutorials/",
        ],
        max_pages_per_source=30
    )

    print(assistant.generate_summary())

asyncio.run(main())
```

### Knowledge Base Builder

Build a RAG-ready knowledge base from web content.

```python
import asyncio
import hashlib
import json
from datetime import datetime
from typing import List, Dict, Any
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig
from crawl4ai.deep_crawling import BFSDeepCrawlStrategy

class KnowledgeBaseBuilder:
    """Build a knowledge base from web content for RAG systems."""

    def __init__(self, chunk_size: int = 1000, chunk_overlap: int = 200):
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap
        self.documents = []
        self.chunks = []

    async def ingest_sources(self, sources: List[Dict[str, Any]]):
        """Ingest content from multiple sources."""

        browser_config = BrowserConfig(
            headless=True,
            browser_type="chromium"
        )

        async with AsyncWebCrawler(config=browser_config) as crawler:
            for source in sources:
                print(f"\nIngesting: {source['name']}")

                strategy = BFSDeepCrawlStrategy(
                    max_depth=source.get("max_depth", 3),
                    max_pages=source.get("max_pages", 50),
                    include_external=False
                )

                run_config = CrawlerRunConfig(
                    deep_crawl_strategy=strategy,
                    word_count_threshold=50
                )

                async for result in await crawler.arun(
                    source["url"],
                    config=run_config
                ):
                    if result.success:
                        doc = {
                            "id": self._generate_id(result.url),
                            "url": result.url,
                            "source_name": source["name"],
                            "source_type": source.get("type", "web"),
                            "title": result.metadata.get("title", ""),
                            "content": result.markdown,
                            "ingested_at": datetime.utcnow().isoformat()
                        }
                        self.documents.append(doc)
                        print(f"  Added: {result.url[:50]}...")

        return self.documents

    def chunk_documents(self) -> List[Dict[str, Any]]:
        """Split documents into chunks for embedding."""

        for doc in self.documents:
            content = doc["content"]
            doc_chunks = self._split_into_chunks(content)

            for i, chunk_text in enumerate(doc_chunks):
                chunk = {
                    "id": f"{doc['id']}_chunk_{i}",
                    "document_id": doc["id"],
                    "url": doc["url"],
                    "source_name": doc["source_name"],
                    "title": doc["title"],
                    "chunk_index": i,
                    "total_chunks": len(doc_chunks),
                    "content": chunk_text,
                    "word_count": len(chunk_text.split())
                }
                self.chunks.append(chunk)

        return self.chunks

    def _split_into_chunks(self, text: str) -> List[str]:
        """Split text into overlapping chunks."""
        words = text.split()
        chunks = []

        i = 0
        while i < len(words):
            # Get chunk
            chunk_words = words[i:i + self.chunk_size]
            chunks.append(" ".join(chunk_words))

            # Move forward with overlap
            i += self.chunk_size - self.chunk_overlap

        return chunks

    def _generate_id(self, url: str) -> str:
        """Generate deterministic ID from URL."""
        return hashlib.md5(url.encode()).hexdigest()[:16]

    def export_for_embedding(self, filepath: str):
        """Export chunks in format ready for embedding."""
        export_data = {
            "metadata": {
                "total_documents": len(self.documents),
                "total_chunks": len(self.chunks),
                "chunk_size": self.chunk_size,
                "chunk_overlap": self.chunk_overlap,
                "created_at": datetime.utcnow().isoformat()
            },
            "chunks": self.chunks
        }

        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(export_data, f, indent=2, ensure_ascii=False)

        return filepath

    def get_stats(self) -> Dict[str, Any]:
        """Get knowledge base statistics."""
        total_words = sum(c["word_count"] for c in self.chunks)

        return {
            "documents": len(self.documents),
            "chunks": len(self.chunks),
            "total_words": total_words,
            "avg_chunk_words": total_words // max(len(self.chunks), 1),
            "sources": list(set(d["source_name"] for d in self.documents))
        }

# Usage
async def main():
    builder = KnowledgeBaseBuilder(
        chunk_size=500,
        chunk_overlap=100
    )

    sources = [
        {
            "name": "Python Docs",
            "url": "https://docs.python.org/3/tutorial/",
            "type": "documentation",
            "max_depth": 2,
            "max_pages": 30
        },
        {
            "name": "FastAPI Docs",
            "url": "https://fastapi.tiangolo.com/",
            "type": "documentation",
            "max_depth": 2,
            "max_pages": 30
        }
    ]

    # Ingest sources
    await builder.ingest_sources(sources)

    # Create chunks
    builder.chunk_documents()

    # Export
    builder.export_for_embedding("knowledge_base.json")

    # Print stats
    stats = builder.get_stats()
    print(f"\nKnowledge Base Built:")
    print(f"  Documents: {stats['documents']}")
    print(f"  Chunks: {stats['chunks']}")
    print(f"  Total Words: {stats['total_words']:,}")

asyncio.run(main())
```

---

## Best Practices

### Performance

**Caching Strategies**

```python
from crawl4ai import CrawlerRunConfig, CacheMode

# Enable caching for repeated crawls
config = CrawlerRunConfig(cache_mode=CacheMode.ENABLED)

# Bypass cache for fresh content
config = CrawlerRunConfig(cache_mode=CacheMode.BYPASS)

# Read-only (use cache, don't update)
config = CrawlerRunConfig(cache_mode=CacheMode.READ_ONLY)

# Write-only (always crawl, update cache)
config = CrawlerRunConfig(cache_mode=CacheMode.WRITE_ONLY)
```

**Concurrent Crawling Limits**

```python
# Use arun_many for batch crawling with concurrency control
urls = ["https://example.com/page1", "https://example.com/page2", ...]

# Streaming mode for memory efficiency
run_config = CrawlerRunConfig(stream=True)

async with AsyncWebCrawler() as crawler:
    async for result in await crawler.arun_many(urls, config=run_config):
        process(result)  # Process immediately, don't accumulate
```

**Memory Management**

```python
# Text mode disables images for lower memory usage
browser_config = BrowserConfig(text_mode=True)

# Light mode disables background features
browser_config = BrowserConfig(light_mode=True)

# Use context manager to ensure browser cleanup
async with AsyncWebCrawler(config=browser_config) as crawler:
    # Browser is automatically closed after this block
    pass
```

### Reliability

**Error Handling**

```python
async def reliable_crawl(crawler, url, max_retries=3):
    """Crawl with retry logic."""

    for attempt in range(max_retries):
        try:
            result = await crawler.arun(url)

            if result.success:
                return result

            # Handle specific HTTP errors
            if result.status_code == 429:  # Rate limited
                wait_time = 2 ** attempt * 5  # Exponential backoff
                print(f"Rate limited, waiting {wait_time}s...")
                await asyncio.sleep(wait_time)
            elif result.status_code >= 500:  # Server error
                await asyncio.sleep(2 ** attempt)
            else:
                # Client error, don't retry
                return result

        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            if attempt < max_retries - 1:
                await asyncio.sleep(2 ** attempt)

    return None
```

**Retry Strategies**

```python
import asyncio
from functools import wraps

def with_retry(max_attempts=3, backoff_factor=2):
    """Decorator for retry logic."""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            last_exception = None

            for attempt in range(max_attempts):
                try:
                    return await func(*args, **kwargs)
                except Exception as e:
                    last_exception = e
                    if attempt < max_attempts - 1:
                        wait = backoff_factor ** attempt
                        await asyncio.sleep(wait)

            raise last_exception
        return wrapper
    return decorator

@with_retry(max_attempts=3)
async def crawl_with_retry(crawler, url, config):
    result = await crawler.arun(url, config=config)
    if not result.success:
        raise Exception(f"Crawl failed: {result.error_message}")
    return result
```

**Timeout Configuration**

```python
# Page-level timeout
run_config = CrawlerRunConfig(
    page_timeout=60000,  # 60 seconds max per page
    delay_before_return_html=1.0  # Wait for dynamic content
)

# Wait for specific conditions
run_config = CrawlerRunConfig(
    wait_for="css:.content-loaded",  # Wait for CSS selector
    wait_until="networkidle"  # Wait for network to settle
)
```

### Ethics

**Respecting robots.txt**

```python
import httpx
from urllib.parse import urlparse
from urllib.robotparser import RobotFileParser

async def check_robots_txt(url: str, user_agent: str = "*") -> bool:
    """Check if URL is allowed by robots.txt."""

    parsed = urlparse(url)
    robots_url = f"{parsed.scheme}://{parsed.netloc}/robots.txt"

    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(robots_url)

            if response.status_code == 200:
                rp = RobotFileParser()
                rp.parse(response.text.split("\n"))
                return rp.can_fetch(user_agent, url)
    except Exception:
        pass

    return True  # Allow if robots.txt unavailable

# Usage
async def ethical_crawl(crawler, url, config):
    if await check_robots_txt(url):
        return await crawler.arun(url, config=config)
    else:
        print(f"Blocked by robots.txt: {url}")
        return None
```

**Rate Limiting**

```python
import asyncio
from collections import deque
from datetime import datetime, timedelta

class RateLimiter:
    """Token bucket rate limiter."""

    def __init__(self, requests_per_second: float):
        self.rate = requests_per_second
        self.tokens = requests_per_second
        self.last_update = datetime.now()
        self._lock = asyncio.Lock()

    async def acquire(self):
        """Wait until a request token is available."""
        async with self._lock:
            now = datetime.now()
            elapsed = (now - self.last_update).total_seconds()

            # Add tokens based on elapsed time
            self.tokens = min(
                self.rate,
                self.tokens + elapsed * self.rate
            )
            self.last_update = now

            if self.tokens < 1:
                wait_time = (1 - self.tokens) / self.rate
                await asyncio.sleep(wait_time)
                self.tokens = 0
            else:
                self.tokens -= 1

# Usage
limiter = RateLimiter(requests_per_second=2)

async def rate_limited_crawl(crawler, urls, config):
    results = []
    for url in urls:
        await limiter.acquire()
        result = await crawler.arun(url, config=config)
        results.append(result)
    return results
```

**Terms of Service Compliance**

- Always review the target site's Terms of Service before crawling
- Identify your crawler with a descriptive User-Agent string
- Include contact information in your User-Agent for site admins
- Respect `Crawl-delay` directives in robots.txt
- Avoid crawling during peak traffic hours for the target site
- Cache aggressively to minimize repeated requests

```python
# Good practice: Identify your crawler
browser_config = BrowserConfig(
    user_agent="MyResearchBot/1.0 (+https://mysite.com/bot; contact@mysite.com)"
)
```

---

## Integration Patterns

### With Archon

Store crawled content as Archon documents and track crawl tasks.

```python
import asyncio
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig

# Assuming Archon MCP tools are available
async def crawl_and_store_in_archon(
    urls: list,
    project_id: str,
    task_id: str
):
    """Crawl URLs and store results in Archon."""

    # Update task status to "doing"
    # manage_task("update", task_id=task_id, status="doing")

    async with AsyncWebCrawler() as crawler:
        for url in urls:
            result = await crawler.arun(url)

            if result.success:
                # Create document in Archon
                doc_title = result.metadata.get("title", url)
                doc_content = f"""# {doc_title}

**Source URL:** {url}
**Crawled:** {datetime.utcnow().isoformat()}

---

{result.markdown}
"""

                # manage_document(
                #     "create",
                #     project_id=project_id,
                #     title=doc_title,
                #     content=doc_content
                # )

                print(f"Stored: {doc_title}")

    # Update task status to "done"
    # manage_task("update", task_id=task_id, status="done")
```

### With RAG Systems

**Chunking Strategies**

```python
from crawl4ai.chunking_strategy import (
    RegexChunking,
    SentenceChunking,
    FixedLengthWordChunking
)

# Regex-based chunking (default)
chunking = RegexChunking(patterns=[r'\n\n+'])

# Sentence-based chunking
chunking = SentenceChunking()

# Fixed word length chunks
chunking = FixedLengthWordChunking(
    chunk_size=500,
    overlap=100
)

config = CrawlerRunConfig(chunking_strategy=chunking)
```

**Embedding Generation**

```python
import asyncio
from openai import AsyncOpenAI

async def generate_embeddings(chunks: list, model: str = "text-embedding-3-small"):
    """Generate embeddings for chunks."""

    client = AsyncOpenAI()
    embeddings = []

    # Batch processing for efficiency
    batch_size = 100

    for i in range(0, len(chunks), batch_size):
        batch = chunks[i:i + batch_size]
        texts = [c["content"] for c in batch]

        response = await client.embeddings.create(
            model=model,
            input=texts
        )

        for j, embedding in enumerate(response.data):
            chunks[i + j]["embedding"] = embedding.embedding
            embeddings.append(embedding.embedding)

    return chunks
```

**Vector Storage Options**

```python
# Example: Store in Supabase with pgvector
async def store_in_supabase(chunks_with_embeddings: list, supabase_client):
    """Store chunks with embeddings in Supabase."""

    for chunk in chunks_with_embeddings:
        await supabase_client.table("documents").insert({
            "id": chunk["id"],
            "url": chunk["url"],
            "title": chunk["title"],
            "content": chunk["content"],
            "embedding": chunk["embedding"]
        }).execute()

# Example: Store in Pinecone
async def store_in_pinecone(chunks_with_embeddings: list, index):
    """Store chunks with embeddings in Pinecone."""

    vectors = [
        {
            "id": chunk["id"],
            "values": chunk["embedding"],
            "metadata": {
                "url": chunk["url"],
                "title": chunk["title"],
                "content": chunk["content"][:1000]  # Metadata size limit
            }
        }
        for chunk in chunks_with_embeddings
    ]

    # Batch upsert
    index.upsert(vectors=vectors, batch_size=100)
```

---

## Configuration Reference

### BrowserConfig Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `browser_type` | str | `"chromium"` | Browser engine: `"chromium"`, `"firefox"`, `"webkit"` |
| `headless` | bool | `True` | Run browser invisibly |
| `browser_mode` | str | `"dedicated"` | Mode: `"dedicated"`, `"builtin"`, `"custom"`, `"docker"` |
| `use_managed_browser` | bool | `False` | Enable Chrome DevTools Protocol |
| `cdp_url` | str | `None` | CDP endpoint URL |
| `debugging_port` | int | `9222` | Browser debugging port |
| `host` | str | `"localhost"` | Browser connection host |
| `proxy_config` | dict | `None` | Proxy settings: `{server, username, password}` |
| `viewport_width` | int | `1080` | Browser window width (pixels) |
| `viewport_height` | int | `600` | Browser window height (pixels) |
| `verbose` | bool | `True` | Enable diagnostic logging |
| `use_persistent_context` | bool | `False` | Persist cookies/storage across runs |
| `user_data_dir` | str | `None` | Directory for browser profile |
| `cookies` | list | `None` | Initial cookies to set |
| `headers` | dict | `None` | HTTP headers for all requests |
| `user_agent` | str | (Mozilla default) | Custom User-Agent string |
| `user_agent_mode` | str | `""` | Set to `"random"` for randomization |
| `text_mode` | bool | `False` | Disable images (text-only) |
| `light_mode` | bool | `False` | Disable background features |
| `extra_args` | list | `None` | Additional browser launch flags |
| `enable_stealth` | bool | `False` | Apply stealth modifications |

### CrawlerRunConfig Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `word_count_threshold` | int | `200` | Minimum words per content block |
| `extraction_strategy` | object | `None` | Data extraction strategy |
| `chunking_strategy` | object | `RegexChunking()` | Content chunking approach |
| `markdown_generator` | object | `None` | Markdown conversion handler |
| `cache_mode` | CacheMode | `BYPASS` | Caching behavior |
| `js_code` | str/list | `None` | JavaScript to execute |
| `c4a_script` | str | `None` | C4A script (compiles to JS) |
| `wait_for` | str | `None` | CSS/JS condition before extraction |
| `screenshot` | bool | `False` | Capture page screenshot |
| `pdf` | bool | `False` | Generate PDF snapshot |
| `capture_mhtml` | bool | `False` | Capture MHTML archive |
| `locale` | str | `None` | Browser locale (e.g., `"en-US"`) |
| `timezone_id` | str | `None` | Browser timezone |
| `geolocation` | object | `None` | GPS coordinates |
| `proxy_config` | dict | `None` | Per-crawl proxy settings |
| `scan_full_page` | bool | `False` | Scroll entire page |
| `wait_until` | str | `"domcontentloaded"` | Load condition |
| `page_timeout` | int | `60000` | Page timeout (ms) |
| `delay_before_return_html` | float | `0.1` | Delay before capture (seconds) |
| `stream` | bool | `False` | Enable streaming for `arun_many()` |
| `verbose` | bool | `True` | Enable runtime logging |
| `deep_crawl_strategy` | object | `None` | Strategy for multi-page crawling |

### CacheMode Values

| Mode | Description |
|------|-------------|
| `ENABLED` | Use cache if available, update on crawl |
| `DISABLED` | Never use or update cache |
| `BYPASS` | Always crawl, don't check cache |
| `READ_ONLY` | Use cache if available, don't update |
| `WRITE_ONLY` | Always crawl, update cache |

### Deep Crawl Strategy Options

| Parameter | Type | Description |
|-----------|------|-------------|
| `max_depth` | int | Levels beyond starting page |
| `max_pages` | int | Maximum pages to crawl |
| `include_external` | bool | Follow cross-domain links |
| `score_threshold` | float | Minimum URL relevance score |
| `filter_chain` | FilterChain | URL filtering rules |
| `url_scorer` | Scorer | URL relevance evaluator |

---

## Troubleshooting

### Common Issues and Solutions

**Issue: "Browser not found" or Playwright errors**

```bash
# Solution: Run setup again
crawl4ai-setup

# Or manually install Playwright browsers
playwright install chromium
```

**Issue: Timeout errors on complex pages**

```python
# Solution: Increase timeouts and add waits
config = CrawlerRunConfig(
    page_timeout=120000,  # 2 minutes
    wait_until="networkidle",
    delay_before_return_html=2.0
)
```

**Issue: Missing dynamic content**

```python
# Solution: Enable full page scan and add JavaScript waits
config = CrawlerRunConfig(
    scan_full_page=True,
    js_code="await new Promise(r => setTimeout(r, 3000));",
    wait_for="css:.content-loaded"
)
```

**Issue: Bot detection blocking crawls**

```python
# Solution: Enable stealth mode and use realistic settings
browser_config = BrowserConfig(
    enable_stealth=True,
    user_agent_mode="random",
    viewport_width=1920,
    viewport_height=1080
)
```

**Issue: Memory usage growing with large crawls**

```python
# Solution: Use streaming mode and text-only browsing
browser_config = BrowserConfig(
    text_mode=True,
    light_mode=True
)

run_config = CrawlerRunConfig(
    stream=True,
    cache_mode=CacheMode.DISABLED
)

async with AsyncWebCrawler(config=browser_config) as crawler:
    async for result in await crawler.arun_many(urls, config=run_config):
        process_and_discard(result)  # Don't accumulate
```

**Issue: SSL certificate errors**

```python
# Solution: Add browser arguments to ignore SSL (development only)
browser_config = BrowserConfig(
    extra_args=["--ignore-certificate-errors"]
)
```

**Issue: Proxy authentication failing**

```python
# Solution: Use correct proxy config format
browser_config = BrowserConfig(
    proxy_config={
        "server": "http://proxy.example.com:8080",
        "username": "user",
        "password": "pass"
    }
)
```

**Issue: Content not in expected format**

```python
# Solution: Check extraction strategy and markdown generator
from crawl4ai.markdown_generation_strategy import DefaultMarkdownGenerator
from crawl4ai.content_filter_strategy import PruningContentFilter

md_gen = DefaultMarkdownGenerator(
    content_filter=PruningContentFilter(
        threshold=0.3,  # Lower threshold = more content
        threshold_type="fixed"
    )
)

config = CrawlerRunConfig(
    markdown_generator=md_gen,
    word_count_threshold=10  # Lower threshold
)
```

### Debugging Tips

1. **Enable verbose logging**: Set `verbose=True` in both configs
2. **Capture screenshots**: Enable `screenshot=True` to see what the browser sees
3. **Use non-headless mode**: Set `headless=False` to watch the browser
4. **Check the raw HTML**: Inspect `result.html` before markdown conversion
5. **Run diagnostics**: Execute `crawl4ai-doctor` to check environment

---

## Resources

### Official Documentation

- [Crawl4AI Documentation](https://docs.crawl4ai.com/) - Complete official documentation
- [Quick Start Guide](https://docs.crawl4ai.com/core/quickstart/) - Getting started tutorial
- [Installation Guide](https://docs.crawl4ai.com/core/installation/) - Setup instructions
- [Configuration Reference](https://docs.crawl4ai.com/core/browser-crawler-config/) - All config options
- [SDK Reference](https://docs.crawl4ai.com/complete-sdk-reference/) - Complete API reference

### GitHub Repository

- [unclecode/crawl4ai](https://github.com/unclecode/crawl4ai) - Source code and issues
- [CHANGELOG](https://github.com/unclecode/crawl4ai/blob/main/CHANGELOG.md) - Version history

### Community Resources

- [Discord Community](https://discord.gg/jP8KfhDhyN) - Official Discord server
- [PyPI Package](https://pypi.org/project/Crawl4AI/) - Python package page

### Related Tools

- [Playwright](https://playwright.dev/) - Browser automation library used by Crawl4AI
- [httpx](https://www.python-httpx.org/) - Async HTTP client for API calls
- [Pydantic](https://docs.pydantic.dev/) - Data validation for extraction schemas

---

## Version History

| Version | Date | Notable Changes |
|---------|------|-----------------|
| 0.8.0 | Jan 2026 | Crash recovery, prefetch mode, security fixes |
| 0.7.8 | Dec 2025 | Performance improvements |
| 0.7.7 | Nov 2025 | Bug fixes and stability |

---

*This guide was created for Claude Code workflows. For the latest Crawl4AI features, always refer to the [official documentation](https://docs.crawl4ai.com/).*
