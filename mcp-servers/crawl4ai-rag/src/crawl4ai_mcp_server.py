"""
Crawl4AI MCP Server
Web crawling and RAG capabilities for Claude Code

This server provides tools for:
- Single and batch web page crawling
- Structured data extraction (CSS/XPath)
- LLM-based content extraction
- Screenshot and PDF generation
- Optional RAG integration for semantic search (Supabase + pgvector)
- Optional Graph RAG integration (Neo4j knowledge graph)

Credentials are loaded from:
1. Local .env file
2. Global ~/.claude/.env file (fallback)
"""

import os
import json
import asyncio
import base64
import re
from typing import Optional, List, Dict, Any, Tuple
from datetime import datetime
from pathlib import Path
from urllib.parse import urlparse

from mcp.server.fastmcp import FastMCP
from pydantic import BaseModel, Field
from dotenv import load_dotenv

# Crawl4AI imports
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig, CacheMode
from crawl4ai.extraction_strategy import (
    LLMExtractionStrategy,
    JsonCssExtractionStrategy,
)
from crawl4ai.chunking_strategy import RegexChunking

# =============================================================================
# Load Environment Variables (Local first, then Global fallback)
# =============================================================================

# Load local .env first
load_dotenv()

# Load global ~/.claude/.env as fallback (Windows and Unix compatible)
global_env_path = Path.home() / ".claude" / ".env"
if global_env_path.exists():
    load_dotenv(global_env_path, override=False)

# =============================================================================
# Optional RAG imports
# =============================================================================

try:
    from supabase import create_client, Client
    SUPABASE_AVAILABLE = True
except ImportError:
    SUPABASE_AVAILABLE = False

try:
    from openai import AzureOpenAI
    AZURE_OPENAI_AVAILABLE = True
except ImportError:
    AZURE_OPENAI_AVAILABLE = False

try:
    from neo4j import GraphDatabase
    NEO4J_AVAILABLE = True
except ImportError:
    NEO4J_AVAILABLE = False

# =============================================================================
# Configuration
# =============================================================================

# Environment configuration with defaults
TRANSPORT = os.getenv("TRANSPORT", "stdio")
HEADLESS = os.getenv("HEADLESS", "true").lower() == "true"
BROWSER_TYPE = os.getenv("BROWSER_TYPE", "chromium")
MEAN_DELAY = float(os.getenv("MEAN_DELAY", "0.5"))
MAX_CONCURRENT = int(os.getenv("MAX_CONCURRENT", "5"))

# Azure OpenAI configuration (for embeddings)
AZURE_OPENAI_ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT")
AZURE_OPENAI_API_KEY = os.getenv("AZURE_OPENAI_API_KEY")
AZURE_OPENAI_API_VERSION = os.getenv("AZURE_OPENAI_API_VERSION", "2024-12-01-preview")
# Azure embedding deployment name (you may need to adjust this based on your deployment)
AZURE_EMBEDDING_DEPLOYMENT = os.getenv("AZURE_EMBEDDING_DEPLOYMENT", "text-embedding-3-small")

# Supabase configuration (for vector storage)
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY") or os.getenv("SUPABASE_SERVICE_KEY")

# Neo4j configuration (for graph storage)
NEO4J_URI = os.getenv("NEO4J_URI") or os.getenv("NEO4J_ENDPONT1", "bolt://localhost:7687")
NEO4J_USERNAME = os.getenv("NEO4J_USERNAME") or os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD")

# Feature flags
RAG_AVAILABLE = (
    SUPABASE_AVAILABLE
    and AZURE_OPENAI_AVAILABLE
    and SUPABASE_URL
    and SUPABASE_SERVICE_KEY
    and AZURE_OPENAI_ENDPOINT
    and AZURE_OPENAI_API_KEY
)

GRAPH_RAG_AVAILABLE = (
    NEO4J_AVAILABLE
    and NEO4J_URI
    and NEO4J_PASSWORD
)

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
    stored_in_db: bool = False
    stored_in_graph: bool = False


# =============================================================================
# Initialize MCP Server
# =============================================================================

mcp = FastMCP(
    "crawl4ai-rag",
    description="Web crawling with optional RAG (Supabase + pgvector) and Graph RAG (Neo4j)"
)

# Global instances (initialized lazily)
_crawler: Optional[AsyncWebCrawler] = None
_crawler_lock = asyncio.Lock()
_supabase: Optional[Any] = None
_azure_client: Optional[Any] = None
_neo4j_driver: Optional[Any] = None


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
    """Get or create Supabase client for vector RAG."""
    global _supabase
    if not SUPABASE_AVAILABLE:
        return None
    if _supabase is None and SUPABASE_URL and SUPABASE_SERVICE_KEY:
        _supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    return _supabase


def get_azure_openai() -> Optional[Any]:
    """Get or create Azure OpenAI client for embeddings."""
    global _azure_client
    if not AZURE_OPENAI_AVAILABLE:
        return None
    if _azure_client is None and AZURE_OPENAI_ENDPOINT and AZURE_OPENAI_API_KEY:
        _azure_client = AzureOpenAI(
            azure_endpoint=AZURE_OPENAI_ENDPOINT,
            api_key=AZURE_OPENAI_API_KEY,
            api_version=AZURE_OPENAI_API_VERSION,
        )
    return _azure_client


def get_neo4j_driver() -> Optional[Any]:
    """Get or create Neo4j driver for graph RAG."""
    global _neo4j_driver
    if not NEO4J_AVAILABLE:
        return None
    if _neo4j_driver is None and NEO4J_URI and NEO4J_PASSWORD:
        _neo4j_driver = GraphDatabase.driver(
            NEO4J_URI,
            auth=(NEO4J_USERNAME, NEO4J_PASSWORD)
        )
    return _neo4j_driver


# =============================================================================
# Helper Functions
# =============================================================================

def truncate_content(content: str, max_length: int = 50000) -> str:
    """Truncate content to stay within token limits."""
    if len(content) <= max_length:
        return content
    return content[:max_length] + "\n\n[Content truncated for length...]"


def extract_entities_and_relations(
    url: str,
    title: str,
    content: str
) -> Tuple[List[Dict], List[Dict]]:
    """
    Extract entities and relationships from content for knowledge graph.
    Returns (entities, relations) tuples.
    """
    entities = []
    relations = []

    # Parse URL for domain entity
    parsed = urlparse(url)
    domain = parsed.netloc

    # Create page entity
    page_entity = {
        "type": "WebPage",
        "url": url,
        "title": title or url,
        "domain": domain,
        "crawled_at": datetime.utcnow().isoformat()
    }
    entities.append(page_entity)

    # Create domain entity
    domain_entity = {
        "type": "Domain",
        "name": domain
    }
    entities.append(domain_entity)

    # Relation: Page BELONGS_TO Domain
    relations.append({
        "from_type": "WebPage",
        "from_id": url,
        "to_type": "Domain",
        "to_id": domain,
        "relation": "BELONGS_TO"
    })

    # Extract topics from content (simple keyword extraction)
    # You could replace this with an LLM-based extraction for better results
    topic_patterns = [
        r'(?i)\b(api|sdk|authentication|authorization|database|deployment|configuration|'
        r'tutorial|guide|documentation|example|reference|endpoint|webhook|'
        r'integration|security|performance|optimization|testing|debugging)\b'
    ]

    topics_found = set()
    for pattern in topic_patterns:
        matches = re.findall(pattern, content.lower())
        topics_found.update(matches)

    for topic in topics_found:
        topic_entity = {
            "type": "Topic",
            "name": topic.title()
        }
        entities.append(topic_entity)

        relations.append({
            "from_type": "WebPage",
            "from_id": url,
            "to_type": "Topic",
            "to_id": topic.title(),
            "relation": "COVERS_TOPIC"
        })

    # Extract links as relations
    link_pattern = r'https?://[^\s<>"{}|\\^`\[\]]+'
    links = re.findall(link_pattern, content)

    for link in links[:20]:  # Limit to first 20 links
        link_parsed = urlparse(link)
        if link_parsed.netloc and link_parsed.netloc != domain:
            relations.append({
                "from_type": "WebPage",
                "from_id": url,
                "to_type": "WebPage",
                "to_id": link,
                "relation": "LINKS_TO"
            })

    return entities, relations


async def generate_embedding(text: str) -> Optional[List[float]]:
    """Generate embedding using Azure OpenAI."""
    client = get_azure_openai()
    if not client:
        return None

    try:
        response = client.embeddings.create(
            model=AZURE_EMBEDDING_DEPLOYMENT,
            input=text[:8000]  # Limit input for embedding
        )
        return response.data[0].embedding
    except Exception as e:
        print(f"Failed to generate embedding: {e}")
        return None


async def store_in_vector_db(
    url: str,
    content: str,
    title: Optional[str] = None
) -> bool:
    """Store crawled content in Supabase vector database."""
    if not RAG_AVAILABLE:
        return False

    supabase = get_supabase()
    if not supabase:
        return False

    try:
        embedding = await generate_embedding(content)
        if not embedding:
            return False

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


async def store_in_graph_db(
    url: str,
    content: str,
    title: Optional[str] = None
) -> bool:
    """Store crawled content in Neo4j knowledge graph."""
    if not GRAPH_RAG_AVAILABLE:
        return False

    driver = get_neo4j_driver()
    if not driver:
        return False

    try:
        entities, relations = extract_entities_and_relations(url, title or "", content)

        with driver.session() as session:
            # Create entities
            for entity in entities:
                if entity["type"] == "WebPage":
                    session.run("""
                        MERGE (p:WebPage {url: $url})
                        SET p.title = $title, p.domain = $domain, p.crawled_at = $crawled_at
                    """, url=entity["url"], title=entity["title"],
                        domain=entity["domain"], crawled_at=entity["crawled_at"])

                elif entity["type"] == "Domain":
                    session.run("""
                        MERGE (d:Domain {name: $name})
                    """, name=entity["name"])

                elif entity["type"] == "Topic":
                    session.run("""
                        MERGE (t:Topic {name: $name})
                    """, name=entity["name"])

            # Create relations
            for rel in relations:
                if rel["relation"] == "BELONGS_TO":
                    session.run("""
                        MATCH (p:WebPage {url: $from_id})
                        MATCH (d:Domain {name: $to_id})
                        MERGE (p)-[:BELONGS_TO]->(d)
                    """, from_id=rel["from_id"], to_id=rel["to_id"])

                elif rel["relation"] == "COVERS_TOPIC":
                    session.run("""
                        MATCH (p:WebPage {url: $from_id})
                        MATCH (t:Topic {name: $to_id})
                        MERGE (p)-[:COVERS_TOPIC]->(t)
                    """, from_id=rel["from_id"], to_id=rel["to_id"])

                elif rel["relation"] == "LINKS_TO":
                    session.run("""
                        MATCH (p1:WebPage {url: $from_id})
                        MERGE (p2:WebPage {url: $to_id})
                        MERGE (p1)-[:LINKS_TO]->(p2)
                    """, from_id=rel["from_id"], to_id=rel["to_id"])

        return True
    except Exception as e:
        print(f"Failed to store in graph DB: {e}")
        return False


# =============================================================================
# MCP Tools
# =============================================================================

@mcp.tool()
async def crawl_single_page(
    url: str,
    include_images: bool = False,
    include_links: bool = True,
    wait_for: Optional[str] = None,
    store_in_db: bool = False,
    store_in_graph: bool = False
) -> str:
    """
    Crawl a single URL and extract content as clean markdown.

    Args:
        url: The URL to crawl
        include_images: Include image descriptions in output
        include_links: Include links in output
        wait_for: CSS selector to wait for before extraction
        store_in_db: Store in Supabase vector DB for RAG (default: False)
        store_in_graph: Store in Neo4j knowledge graph (default: False)

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
        title = result.metadata.get("title")

        if title:
            output_parts.append(f"# {title}\n")

        output_parts.append(f"**Source:** {url}\n")
        output_parts.append(f"**Crawled:** {datetime.utcnow().isoformat()}\n")

        # Add main content (markdown)
        content = result.markdown or result.cleaned_html or ""

        # Storage status
        stored_vector = False
        stored_graph = False

        if store_in_db:
            stored_vector = await store_in_vector_db(url, content, title)
            output_parts.append(f"**Stored in Vector DB:** {'✓ Yes' if stored_vector else '✗ No (check configuration)'}\n")

        if store_in_graph:
            stored_graph = await store_in_graph_db(url, content, title)
            output_parts.append(f"**Stored in Graph DB:** {'✓ Yes' if stored_graph else '✗ No (check configuration)'}\n")

        output_parts.append("---\n")
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

        return "".join(output_parts)

    except Exception as e:
        return f"Error crawling {url}: {str(e)}"


@mcp.tool()
async def crawl_multiple_pages(
    urls: List[str],
    max_concurrent: int = 5,
    store_in_db: bool = False,
    store_in_graph: bool = False
) -> str:
    """
    Batch crawl multiple URLs concurrently.

    Args:
        urls: List of URLs to crawl
        max_concurrent: Maximum concurrent requests (default: 5)
        store_in_db: Store in Supabase vector DB for RAG (default: False)
        store_in_graph: Store in Neo4j knowledge graph (default: False)

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

        if store_in_db:
            output_parts.append(f"**Storing in Vector DB:** Enabled\n")
        if store_in_graph:
            output_parts.append(f"**Storing in Graph DB:** Enabled\n")

        output_parts.append("---\n\n")

        for result in results:
            output_parts.append(f"## {result.get('title') or result['url']}\n")
            output_parts.append(f"**URL:** {result['url']}\n")

            if result["success"]:
                content = truncate_content(result["content"], 10000)
                output_parts.append(f"\n{content}\n")

                # Store in databases if requested
                if store_in_db:
                    stored = await store_in_vector_db(
                        result["url"],
                        result["content"],
                        result.get("title")
                    )
                    output_parts.append(f"*Vector DB: {'✓' if stored else '✗'}*\n")

                if store_in_graph:
                    stored = await store_in_graph_db(
                        result["url"],
                        result["content"],
                        result.get("title")
                    )
                    output_parts.append(f"*Graph DB: {'✓' if stored else '✗'}*\n")
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
    max_pages: int = 1,
    store_in_db: bool = False,
    store_in_graph: bool = False
) -> str:
    """
    Adaptive crawling with query-based content filtering.
    Focuses extraction on content relevant to the query.

    Args:
        url: Starting URL to crawl
        query: Query to guide content extraction
        max_pages: Maximum pages to follow (default: 1)
        store_in_db: Store in Supabase vector DB for RAG (default: False)
        store_in_graph: Store in Neo4j knowledge graph (default: False)

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
        title = result.metadata.get("title", "")

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

        # Store if requested
        if store_in_db:
            stored = await store_in_vector_db(url, content, title)
            output_parts.append(f"**Vector DB:** {'✓ Stored' if stored else '✗ Not stored'}\n")

        if store_in_graph:
            stored = await store_in_graph_db(url, content, title)
            output_parts.append(f"**Graph DB:** {'✓ Stored' if stored else '✗ Not stored'}\n")

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
    Use Azure OpenAI to extract structured data based on instructions and schema.
    Requires Azure OpenAI configuration.

    Args:
        url: URL to extract from
        instruction: Natural language instruction for what to extract
        schema: JSON schema for the expected output format

    Returns:
        JSON string of LLM-extracted data
    """
    if not AZURE_OPENAI_ENDPOINT or not AZURE_OPENAI_API_KEY:
        return "Error: Azure OpenAI configuration is required for LLM extraction"

    try:
        crawler = await get_crawler()

        # Create LLM extraction strategy using Azure OpenAI
        # Note: Crawl4AI's LLMExtractionStrategy may need custom provider configuration
        # This example uses the OpenAI-compatible approach
        extraction_strategy = LLMExtractionStrategy(
            provider=f"azure/{AZURE_EMBEDDING_DEPLOYMENT}",
            api_token=AZURE_OPENAI_API_KEY,
            instruction=instruction,
            schema=schema,
            base_url=AZURE_OPENAI_ENDPOINT,
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
    Requires RAG configuration (Supabase + Azure OpenAI).

    Args:
        query: Search query
        limit: Maximum number of results (default: 5)
        source_filter: Optional URL pattern to filter by

    Returns:
        Matching content from the vector database
    """
    if not RAG_AVAILABLE:
        return "Error: RAG is not available. Check Supabase and Azure OpenAI configuration."

    supabase = get_supabase()
    if not supabase:
        return "Error: Supabase connection not available"

    try:
        # Generate query embedding using Azure OpenAI
        embedding = await generate_embedding(query)
        if not embedding:
            return "Error: Failed to generate query embedding"

        # Search in Supabase using vector similarity
        result = supabase.rpc(
            "match_documents",
            {
                "query_embedding": embedding,
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


@mcp.tool()
async def search_knowledge_graph(
    query: str,
    search_type: str = "topic",
    limit: int = 10
) -> str:
    """
    Search the knowledge graph for related pages and topics.
    Requires Neo4j configuration.

    Args:
        query: Search term (topic name, domain, or URL pattern)
        search_type: Type of search - "topic", "domain", or "page" (default: "topic")
        limit: Maximum number of results (default: 10)

    Returns:
        Related nodes and connections from the knowledge graph
    """
    if not GRAPH_RAG_AVAILABLE:
        return "Error: Graph RAG is not available. Check Neo4j configuration."

    driver = get_neo4j_driver()
    if not driver:
        return "Error: Neo4j connection not available"

    try:
        with driver.session() as session:
            if search_type == "topic":
                result = session.run("""
                    MATCH (t:Topic)
                    WHERE toLower(t.name) CONTAINS toLower($query)
                    OPTIONAL MATCH (p:WebPage)-[:COVERS_TOPIC]->(t)
                    RETURN t.name as topic, collect(DISTINCT {url: p.url, title: p.title})[0..$limit] as pages
                    LIMIT $limit
                """, query=query, limit=limit)

            elif search_type == "domain":
                result = session.run("""
                    MATCH (d:Domain)
                    WHERE toLower(d.name) CONTAINS toLower($query)
                    OPTIONAL MATCH (p:WebPage)-[:BELONGS_TO]->(d)
                    RETURN d.name as domain, collect(DISTINCT {url: p.url, title: p.title})[0..$limit] as pages
                    LIMIT $limit
                """, query=query, limit=limit)

            else:  # page
                result = session.run("""
                    MATCH (p:WebPage)
                    WHERE toLower(p.url) CONTAINS toLower($query)
                       OR toLower(p.title) CONTAINS toLower($query)
                    OPTIONAL MATCH (p)-[:COVERS_TOPIC]->(t:Topic)
                    OPTIONAL MATCH (p)-[:LINKS_TO]->(linked:WebPage)
                    RETURN p.url as url, p.title as title,
                           collect(DISTINCT t.name) as topics,
                           collect(DISTINCT linked.url)[0..5] as links
                    LIMIT $limit
                """, query=query, limit=limit)

            records = list(result)

        # Format results
        output_parts = [f"# Knowledge Graph Search\n"]
        output_parts.append(f"**Query:** {query}\n")
        output_parts.append(f"**Type:** {search_type}\n")
        output_parts.append(f"**Results:** {len(records)}\n")
        output_parts.append("---\n\n")

        if not records:
            return "".join(output_parts) + "No results found."

        for record in records:
            if search_type == "topic":
                output_parts.append(f"## Topic: {record['topic']}\n")
                pages = record['pages']
                if pages:
                    output_parts.append("**Related Pages:**\n")
                    for page in pages:
                        if page['url']:
                            output_parts.append(f"- [{page['title'] or page['url']}]({page['url']})\n")

            elif search_type == "domain":
                output_parts.append(f"## Domain: {record['domain']}\n")
                pages = record['pages']
                if pages:
                    output_parts.append("**Pages:**\n")
                    for page in pages:
                        if page['url']:
                            output_parts.append(f"- [{page['title'] or page['url']}]({page['url']})\n")

            else:  # page
                output_parts.append(f"## {record['title'] or record['url']}\n")
                output_parts.append(f"**URL:** {record['url']}\n")
                if record['topics']:
                    output_parts.append(f"**Topics:** {', '.join(record['topics'])}\n")
                if record['links']:
                    output_parts.append("**Links to:**\n")
                    for link in record['links']:
                        output_parts.append(f"- {link}\n")

            output_parts.append("\n")

        return "".join(output_parts)

    except Exception as e:
        return f"Error in graph search: {str(e)}"


@mcp.tool()
async def get_rag_status() -> str:
    """
    Check the status of RAG integrations (Supabase vector DB and Neo4j graph DB).

    Returns:
        Status information for each RAG component
    """
    output_parts = ["# RAG Integration Status\n\n"]

    # Azure OpenAI Status
    output_parts.append("## Azure OpenAI (Embeddings)\n")
    if AZURE_OPENAI_ENDPOINT and AZURE_OPENAI_API_KEY:
        output_parts.append(f"- **Status:** ✓ Configured\n")
        output_parts.append(f"- **Endpoint:** {AZURE_OPENAI_ENDPOINT[:50]}...\n")
        output_parts.append(f"- **Model:** {AZURE_EMBEDDING_DEPLOYMENT}\n")
    else:
        output_parts.append("- **Status:** ✗ Not configured\n")
        output_parts.append("- **Required:** AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_API_KEY\n")

    output_parts.append("\n")

    # Supabase Status
    output_parts.append("## Supabase (Vector DB)\n")
    if SUPABASE_URL and SUPABASE_SERVICE_KEY:
        supabase = get_supabase()
        if supabase:
            output_parts.append(f"- **Status:** ✓ Connected\n")
            output_parts.append(f"- **URL:** {SUPABASE_URL}\n")
            try:
                # Check if table exists
                result = supabase.table("crawled_content").select("id").limit(1).execute()
                count = len(result.data) if result.data else 0
                output_parts.append(f"- **Table:** crawled_content (accessible)\n")
            except Exception as e:
                output_parts.append(f"- **Table:** Error - {str(e)[:50]}\n")
        else:
            output_parts.append("- **Status:** ✗ Connection failed\n")
    else:
        output_parts.append("- **Status:** ✗ Not configured\n")
        output_parts.append("- **Required:** SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY\n")

    output_parts.append("\n")

    # Neo4j Status
    output_parts.append("## Neo4j (Graph DB)\n")
    if NEO4J_URI and NEO4J_PASSWORD:
        driver = get_neo4j_driver()
        if driver:
            try:
                with driver.session() as session:
                    result = session.run("RETURN 1 as test")
                    result.single()
                output_parts.append(f"- **Status:** ✓ Connected\n")
                output_parts.append(f"- **URI:** {NEO4J_URI}\n")

                # Get node counts
                with driver.session() as session:
                    counts = session.run("""
                        MATCH (n)
                        RETURN labels(n)[0] as label, count(*) as count
                    """)
                    for record in counts:
                        output_parts.append(f"- **{record['label']}:** {record['count']} nodes\n")
            except Exception as e:
                output_parts.append(f"- **Status:** ✗ Connection error - {str(e)[:50]}\n")
        else:
            output_parts.append("- **Status:** ✗ Driver not initialized\n")
    else:
        output_parts.append("- **Status:** ✗ Not configured\n")
        output_parts.append("- **Required:** NEO4J_URI, NEO4J_PASSWORD\n")

    output_parts.append("\n---\n")
    output_parts.append("\n**Credentials loaded from:** Global ~/.claude/.env (with local .env override)\n")

    return "".join(output_parts)


# =============================================================================
# Server Lifecycle
# =============================================================================

@mcp.on_startup()
async def startup():
    """Initialize resources on server startup."""
    print("Crawl4AI MCP Server starting...")
    print(f"  RAG (Supabase + Azure OpenAI): {'Available' if RAG_AVAILABLE else 'Not configured'}")
    print(f"  Graph RAG (Neo4j): {'Available' if GRAPH_RAG_AVAILABLE else 'Not configured'}")


@mcp.on_shutdown()
async def shutdown():
    """Clean up resources on server shutdown."""
    global _crawler, _neo4j_driver

    if _crawler:
        await _crawler.close()
        _crawler = None

    if _neo4j_driver:
        _neo4j_driver.close()
        _neo4j_driver = None

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
