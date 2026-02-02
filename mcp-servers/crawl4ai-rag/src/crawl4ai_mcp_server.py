"""
Crawl4AI MCP Server
Web crawling and RAG capabilities for Claude Code

This server provides tools for:
- Single and batch web page crawling
- Structured data extraction (CSS/XPath)
- LLM-based content extraction
- Screenshot and PDF generation
- Optional RAG integration for semantic search
"""

import os
import json
import asyncio
import base64
from typing import Optional, List, Dict, Any
from datetime import datetime
from contextlib import asynccontextmanager

from mcp.server.fastmcp import FastMCP
from pydantic import BaseModel, Field

# Crawl4AI imports
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig, CacheMode
from crawl4ai.extraction_strategy import (
    LLMExtractionStrategy,
    JsonCssExtractionStrategy,
)
from crawl4ai.chunking_strategy import RegexChunking

# Optional RAG imports
try:
    from supabase import create_client, Client
    import openai
    RAG_AVAILABLE = True
except ImportError:
    RAG_AVAILABLE = False

# =============================================================================
# Configuration
# =============================================================================

# Environment configuration with defaults
TRANSPORT = os.getenv("TRANSPORT", "stdio")
HEADLESS = os.getenv("HEADLESS", "true").lower() == "true"
BROWSER_TYPE = os.getenv("BROWSER_TYPE", "chromium")
MEAN_DELAY = float(os.getenv("MEAN_DELAY", "0.5"))
MAX_CONCURRENT = int(os.getenv("MAX_CONCURRENT", "5"))

# RAG configuration
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY")

# =============================================================================
# Pydantic Models for Tool Parameters
# =============================================================================

class ExtractionField(BaseModel):
    """Field definition for structured extraction."""
    name: str
    selector: str
    type: str = "text"  # text, attribute, html
    attribute: Optional[str] = None


class ExtractionSchema(BaseModel):
    """Schema for CSS/XPath extraction."""
    name: str
    baseSelector: str
    fields: List[ExtractionField]


class CrawlResult(BaseModel):
    """Result from a crawl operation."""
    url: str
    title: Optional[str] = None
    content: str
    links: Optional[List[str]] = None
    images: Optional[List[str]] = None
    crawled_at: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    success: bool = True
    error: Optional[str] = None


# =============================================================================
# Initialize MCP Server
# =============================================================================

mcp = FastMCP(
    "crawl4ai-rag",
    description="Web crawling and RAG capabilities using Crawl4AI"
)

# Global crawler instance (initialized lazily)
_crawler: Optional[AsyncWebCrawler] = None
_crawler_lock = asyncio.Lock()

# Optional Supabase client for RAG
_supabase: Optional[Any] = None


async def get_crawler() -> AsyncWebCrawler:
    """Get or create the global crawler instance."""
    global _crawler
    async with _crawler_lock:
        if _crawler is None:
            browser_config = BrowserConfig(
                headless=HEADLESS,
                browser_type=BROWSER_TYPE,
            )
            _crawler = AsyncWebCrawler(config=browser_config)
            await _crawler.start()
        return _crawler


def get_supabase() -> Optional[Any]:
    """Get or create Supabase client for RAG features."""
    global _supabase
    if not RAG_AVAILABLE:
        return None
    if _supabase is None and SUPABASE_URL and SUPABASE_SERVICE_KEY:
        _supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    return _supabase


# =============================================================================
# Helper Functions
# =============================================================================

def truncate_content(content: str, max_length: int = 50000) -> str:
    """Truncate content to stay within token limits."""
    if len(content) <= max_length:
        return content
    return content[:max_length] + "\n\n[Content truncated for length...]"


async def store_in_vector_db(url: str, content: str, title: Optional[str] = None) -> bool:
    """Store crawled content in vector database for RAG."""
    if not RAG_AVAILABLE or not OPENAI_API_KEY:
        return False

    supabase = get_supabase()
    if not supabase:
        return False

    try:
        # Generate embedding using OpenAI
        client = openai.OpenAI(api_key=OPENAI_API_KEY)
        response = client.embeddings.create(
            model="text-embedding-3-small",
            input=content[:8000]  # Limit input for embedding
        )
        embedding = response.data[0].embedding

        # Store in Supabase
        supabase.table("crawled_content").upsert({
            "url": url,
            "title": title,
            "content": content,
            "embedding": embedding,
            "crawled_at": datetime.utcnow().isoformat()
        }).execute()

        return True
    except Exception as e:
        print(f"Failed to store in vector DB: {e}")
        return False


# =============================================================================
# MCP Tools
# =============================================================================

@mcp.tool()
async def crawl_single_page(
    url: str,
    include_images: bool = False,
    include_links: bool = True,
    wait_for: Optional[str] = None
) -> str:
    """
    Crawl a single URL and extract content as clean markdown.

    Args:
        url: The URL to crawl
        include_images: Include image descriptions in output
        include_links: Include links in output
        wait_for: CSS selector to wait for before extraction

    Returns:
        Markdown content extracted from the page
    """
    try:
        crawler = await get_crawler()

        config = CrawlerRunConfig(
            cache_mode=CacheMode.BYPASS,
            wait_for=wait_for,
            mean_delay=MEAN_DELAY,
        )

        result = await crawler.arun(url=url, config=config)

        if not result.success:
            return f"Error crawling {url}: {result.error_message}"

        # Build response
        output_parts = []

        if result.metadata.get("title"):
            output_parts.append(f"# {result.metadata['title']}\n")

        output_parts.append(f"**Source:** {url}\n")
        output_parts.append(f"**Crawled:** {datetime.utcnow().isoformat()}\n")
        output_parts.append("---\n")

        # Add main content (markdown)
        content = result.markdown or result.cleaned_html or ""
        output_parts.append(truncate_content(content))

        # Add links if requested
        if include_links and result.links:
            internal_links = result.links.get("internal", [])[:20]
            external_links = result.links.get("external", [])[:10]

            if internal_links or external_links:
                output_parts.append("\n\n---\n## Links\n")

                if internal_links:
                    output_parts.append("\n### Internal Links\n")
                    for link in internal_links:
                        href = link.get("href", "")
                        text = link.get("text", href)[:50]
                        output_parts.append(f"- [{text}]({href})\n")

                if external_links:
                    output_parts.append("\n### External Links\n")
                    for link in external_links:
                        href = link.get("href", "")
                        text = link.get("text", href)[:50]
                        output_parts.append(f"- [{text}]({href})\n")

        # Add images if requested
        if include_images and result.media:
            images = result.media.get("images", [])[:10]
            if images:
                output_parts.append("\n\n---\n## Images\n")
                for img in images:
                    src = img.get("src", "")
                    alt = img.get("alt", "No description")
                    output_parts.append(f"- ![{alt}]({src})\n")

        full_output = "".join(output_parts)

        # Optionally store in vector DB
        await store_in_vector_db(
            url,
            content,
            result.metadata.get("title")
        )

        return full_output

    except Exception as e:
        return f"Error crawling {url}: {str(e)}"


@mcp.tool()
async def crawl_multiple_pages(
    urls: List[str],
    max_concurrent: int = 5
) -> str:
    """
    Batch crawl multiple URLs concurrently.

    Args:
        urls: List of URLs to crawl
        max_concurrent: Maximum concurrent requests (default: 5)

    Returns:
        Combined markdown content from all pages
    """
    max_concurrent = min(max_concurrent, MAX_CONCURRENT)
    results = []

    try:
        crawler = await get_crawler()

        config = CrawlerRunConfig(
            cache_mode=CacheMode.BYPASS,
            mean_delay=MEAN_DELAY,
        )

        # Use semaphore for concurrency control
        semaphore = asyncio.Semaphore(max_concurrent)

        async def crawl_with_limit(url: str) -> Dict[str, Any]:
            async with semaphore:
                try:
                    result = await crawler.arun(url=url, config=config)
                    return {
                        "url": url,
                        "success": result.success,
                        "title": result.metadata.get("title", ""),
                        "content": result.markdown or result.cleaned_html or "",
                        "error": result.error_message if not result.success else None
                    }
                except Exception as e:
                    return {
                        "url": url,
                        "success": False,
                        "title": "",
                        "content": "",
                        "error": str(e)
                    }

        # Crawl all URLs concurrently
        tasks = [crawl_with_limit(url) for url in urls]
        results = await asyncio.gather(*tasks)

        # Build combined output
        output_parts = [f"# Batch Crawl Results\n"]
        output_parts.append(f"**URLs crawled:** {len(urls)}\n")
        output_parts.append(f"**Successful:** {sum(1 for r in results if r['success'])}\n")
        output_parts.append(f"**Failed:** {sum(1 for r in results if not r['success'])}\n")
        output_parts.append("---\n\n")

        for result in results:
            output_parts.append(f"## {result.get('title') or result['url']}\n")
            output_parts.append(f"**URL:** {result['url']}\n")

            if result["success"]:
                content = truncate_content(result["content"], 10000)
                output_parts.append(f"\n{content}\n")

                # Store in vector DB
                await store_in_vector_db(
                    result["url"],
                    result["content"],
                    result.get("title")
                )
            else:
                output_parts.append(f"\n**Error:** {result['error']}\n")

            output_parts.append("\n---\n\n")

        return "".join(output_parts)

    except Exception as e:
        return f"Error in batch crawl: {str(e)}"


@mcp.tool()
async def smart_crawl(
    url: str,
    query: str,
    max_pages: int = 1
) -> str:
    """
    Adaptive crawling with query-based content filtering.
    Focuses extraction on content relevant to the query.

    Args:
        url: Starting URL to crawl
        query: Query to guide content extraction
        max_pages: Maximum pages to follow (default: 1)

    Returns:
        Query-relevant content extracted from the page(s)
    """
    try:
        crawler = await get_crawler()

        # Use word boundary matching for query terms
        query_terms = query.lower().split()

        config = CrawlerRunConfig(
            cache_mode=CacheMode.BYPASS,
            mean_delay=MEAN_DELAY,
            word_count_threshold=50,  # Skip very short content blocks
        )

        result = await crawler.arun(url=url, config=config)

        if not result.success:
            return f"Error crawling {url}: {result.error_message}"

        # Filter content based on query relevance
        content = result.markdown or result.cleaned_html or ""

        # Split into paragraphs and score by relevance
        paragraphs = content.split("\n\n")
        scored_paragraphs = []

        for para in paragraphs:
            if len(para.strip()) < 50:
                continue

            para_lower = para.lower()
            score = sum(1 for term in query_terms if term in para_lower)

            if score > 0:
                scored_paragraphs.append((score, para))

        # Sort by relevance score
        scored_paragraphs.sort(key=lambda x: x[0], reverse=True)

        # Build output
        output_parts = [f"# Smart Crawl Results\n"]
        output_parts.append(f"**Query:** {query}\n")
        output_parts.append(f"**Source:** {url}\n")
        output_parts.append(f"**Relevant sections found:** {len(scored_paragraphs)}\n")
        output_parts.append("---\n\n")

        if scored_paragraphs:
            for score, para in scored_paragraphs[:20]:  # Top 20 relevant paragraphs
                output_parts.append(f"{para}\n\n")
        else:
            # If no relevant content found, return full content
            output_parts.append("*No specifically relevant sections found. Full content:*\n\n")
            output_parts.append(truncate_content(content, 30000))

        return "".join(output_parts)

    except Exception as e:
        return f"Error in smart crawl: {str(e)}"


@mcp.tool()
async def extract_structured_data(
    url: str,
    schema: Dict[str, Any]
) -> str:
    """
    Extract structured data using CSS selectors.

    Args:
        url: URL to extract from
        schema: JSON schema defining extraction rules
            Example: {
                "name": "products",
                "baseSelector": ".product-card",
                "fields": [
                    {"name": "title", "selector": "h2", "type": "text"},
                    {"name": "price", "selector": ".price", "type": "text"},
                    {"name": "image", "selector": "img", "type": "attribute", "attribute": "src"}
                ]
            }

    Returns:
        JSON string of extracted data
    """
    try:
        crawler = await get_crawler()

        # Create extraction strategy from schema
        extraction_strategy = JsonCssExtractionStrategy(schema)

        config = CrawlerRunConfig(
            cache_mode=CacheMode.BYPASS,
            extraction_strategy=extraction_strategy,
            mean_delay=MEAN_DELAY,
        )

        result = await crawler.arun(url=url, config=config)

        if not result.success:
            return f"Error extracting from {url}: {result.error_message}"

        # Parse extracted content
        extracted = result.extracted_content

        if extracted:
            try:
                data = json.loads(extracted) if isinstance(extracted, str) else extracted
                return json.dumps(data, indent=2)
            except json.JSONDecodeError:
                return extracted

        return "No data matched the extraction schema"

    except Exception as e:
        return f"Error in structured extraction: {str(e)}"


@mcp.tool()
async def extract_with_llm(
    url: str,
    instruction: str,
    schema: Dict[str, Any]
) -> str:
    """
    Use an LLM to extract structured data based on instructions and schema.
    Requires OPENAI_API_KEY environment variable.

    Args:
        url: URL to extract from
        instruction: Natural language instruction for what to extract
        schema: JSON schema for the expected output format

    Returns:
        JSON string of LLM-extracted data
    """
    if not OPENAI_API_KEY:
        return "Error: OPENAI_API_KEY environment variable is required for LLM extraction"

    try:
        crawler = await get_crawler()

        # Create LLM extraction strategy
        extraction_strategy = LLMExtractionStrategy(
            provider="openai/gpt-4o-mini",
            api_token=OPENAI_API_KEY,
            instruction=instruction,
            schema=schema,
        )

        config = CrawlerRunConfig(
            cache_mode=CacheMode.BYPASS,
            extraction_strategy=extraction_strategy,
            mean_delay=MEAN_DELAY,
        )

        result = await crawler.arun(url=url, config=config)

        if not result.success:
            return f"Error extracting from {url}: {result.error_message}"

        extracted = result.extracted_content

        if extracted:
            try:
                data = json.loads(extracted) if isinstance(extracted, str) else extracted
                return json.dumps(data, indent=2)
            except json.JSONDecodeError:
                return extracted

        return "No data was extracted by the LLM"

    except Exception as e:
        return f"Error in LLM extraction: {str(e)}"


@mcp.tool()
async def get_page_screenshot(
    url: str,
    full_page: bool = False,
    selector: Optional[str] = None
) -> str:
    """
    Capture a screenshot of a web page.

    Args:
        url: URL to screenshot
        full_page: Capture the full scrollable page (default: false)
        selector: CSS selector to screenshot a specific element

    Returns:
        Base64-encoded PNG image data with data URI prefix
    """
    try:
        crawler = await get_crawler()

        config = CrawlerRunConfig(
            cache_mode=CacheMode.BYPASS,
            screenshot=True,
            screenshot_wait_for=selector,
            mean_delay=MEAN_DELAY,
        )

        result = await crawler.arun(url=url, config=config)

        if not result.success:
            return f"Error capturing screenshot of {url}: {result.error_message}"

        if result.screenshot:
            # Return as data URI for easy use
            return f"data:image/png;base64,{result.screenshot}"

        return "No screenshot was captured"

    except Exception as e:
        return f"Error capturing screenshot: {str(e)}"


@mcp.tool()
async def get_page_pdf(
    url: str,
    format: str = "A4"
) -> str:
    """
    Generate a PDF from a web page.

    Args:
        url: URL to convert to PDF
        format: Page format (default: "A4", options: "A4", "Letter", "Legal")

    Returns:
        Base64-encoded PDF data with data URI prefix
    """
    try:
        crawler = await get_crawler()

        config = CrawlerRunConfig(
            cache_mode=CacheMode.BYPASS,
            pdf=True,
            pdf_options={"format": format},
            mean_delay=MEAN_DELAY,
        )

        result = await crawler.arun(url=url, config=config)

        if not result.success:
            return f"Error generating PDF of {url}: {result.error_message}"

        if result.pdf:
            return f"data:application/pdf;base64,{result.pdf}"

        return "No PDF was generated"

    except Exception as e:
        return f"Error generating PDF: {str(e)}"


@mcp.tool()
async def search_crawled_content(
    query: str,
    limit: int = 5,
    source_filter: Optional[str] = None
) -> str:
    """
    Search previously crawled content using semantic similarity.
    Requires RAG configuration (Supabase + OpenAI).

    Args:
        query: Search query
        limit: Maximum number of results (default: 5)
        source_filter: Optional URL pattern to filter by

    Returns:
        Matching content from the vector database
    """
    if not RAG_AVAILABLE:
        return "Error: RAG dependencies not installed. Install with: pip install -e '.[rag]'"

    if not OPENAI_API_KEY:
        return "Error: OPENAI_API_KEY environment variable is required for RAG search"

    supabase = get_supabase()
    if not supabase:
        return "Error: Supabase configuration is required for RAG search"

    try:
        # Generate query embedding
        client = openai.OpenAI(api_key=OPENAI_API_KEY)
        response = client.embeddings.create(
            model="text-embedding-3-small",
            input=query
        )
        query_embedding = response.data[0].embedding

        # Search in Supabase using vector similarity
        # This assumes you have a match_documents function in Supabase
        result = supabase.rpc(
            "match_documents",
            {
                "query_embedding": query_embedding,
                "match_count": limit,
                "filter_url": source_filter
            }
        ).execute()

        if not result.data:
            return "No matching content found"

        # Format results
        output_parts = [f"# Search Results for: {query}\n\n"]

        for i, doc in enumerate(result.data, 1):
            output_parts.append(f"## Result {i}\n")
            output_parts.append(f"**URL:** {doc.get('url', 'Unknown')}\n")
            output_parts.append(f"**Title:** {doc.get('title', 'Untitled')}\n")
            output_parts.append(f"**Similarity:** {doc.get('similarity', 0):.3f}\n\n")

            content = doc.get('content', '')[:2000]
            output_parts.append(f"{content}\n\n---\n\n")

        return "".join(output_parts)

    except Exception as e:
        return f"Error in RAG search: {str(e)}"


# =============================================================================
# Server Lifecycle
# =============================================================================

@mcp.on_startup()
async def startup():
    """Initialize resources on server startup."""
    print("Crawl4AI MCP Server starting...")


@mcp.on_shutdown()
async def shutdown():
    """Clean up resources on server shutdown."""
    global _crawler
    if _crawler:
        await _crawler.close()
        _crawler = None
    print("Crawl4AI MCP Server stopped")


# =============================================================================
# Main Entry Point
# =============================================================================

def main():
    """Run the MCP server."""
    if TRANSPORT == "sse":
        mcp.run(transport="sse")
    else:
        mcp.run(transport="stdio")


if __name__ == "__main__":
    main()
