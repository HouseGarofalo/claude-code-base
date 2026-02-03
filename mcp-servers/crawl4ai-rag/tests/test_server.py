"""
Tests for Crawl4AI MCP Server v2.0

Run with: pytest tests/
"""

import pytest
import json
from unittest.mock import AsyncMock, MagicMock, patch

# Import the server module
from src.crawl4ai_mcp_server import (
    crawl_single_page,
    crawl_multiple_pages,
    smart_crawl,
    extract_structured_data,
    truncate_content,
    extract_entities_and_relations,
    RAG_AVAILABLE,
    GRAPH_RAG_AVAILABLE,
)


class TestHelperFunctions:
    """Tests for helper functions."""

    def test_truncate_content_short(self):
        """Test that short content is not truncated."""
        content = "This is short content"
        result = truncate_content(content, max_length=100)
        assert result == content

    def test_truncate_content_long(self):
        """Test that long content is truncated with indicator."""
        content = "A" * 1000
        result = truncate_content(content, max_length=100)
        assert len(result) < 1000
        assert "[Content truncated for length...]" in result

    def test_truncate_content_exact(self):
        """Test content exactly at limit is not truncated."""
        content = "A" * 100
        result = truncate_content(content, max_length=100)
        assert result == content


class TestEntityExtraction:
    """Tests for knowledge graph entity extraction."""

    def test_extract_entities_basic(self):
        """Test basic entity extraction from content."""
        url = "https://docs.example.com/api/auth"
        title = "Authentication Guide"
        content = """
        This is a guide about authentication and authorization.
        It covers API security and integration patterns.
        """

        entities, relations = extract_entities_and_relations(url, title, content)

        # Should have WebPage and Domain entities
        entity_types = [e["type"] for e in entities]
        assert "WebPage" in entity_types
        assert "Domain" in entity_types

        # Should have BELONGS_TO relation
        relation_types = [r["relation"] for r in relations]
        assert "BELONGS_TO" in relation_types

    def test_extract_topics(self):
        """Test topic extraction from content."""
        url = "https://example.com/docs"
        title = "Documentation"
        content = """
        This guide covers authentication, authorization, and API security.
        It also includes deployment and configuration instructions.
        """

        entities, relations = extract_entities_and_relations(url, title, content)

        # Should extract topic entities
        topics = [e for e in entities if e["type"] == "Topic"]
        topic_names = [t["name"].lower() for t in topics]

        assert any("auth" in t for t in topic_names)
        assert any("security" in t for t in topic_names)
        assert any("deployment" in t for t in topic_names)

    def test_extract_links(self):
        """Test link extraction from content."""
        url = "https://example.com/docs"
        title = "Documentation"
        content = """
        See the API docs at https://api.example.com/docs
        Also check https://other-site.com/resources
        """

        entities, relations = extract_entities_and_relations(url, title, content)

        # Should have LINKS_TO relations for external links
        links_to = [r for r in relations if r["relation"] == "LINKS_TO"]
        assert len(links_to) > 0


class TestCrawlSinglePage:
    """Tests for crawl_single_page tool."""

    @pytest.mark.asyncio
    async def test_crawl_single_page_success(self):
        """Test successful single page crawl."""
        mock_result = MagicMock()
        mock_result.success = True
        mock_result.markdown = "# Test Page\n\nThis is test content."
        mock_result.cleaned_html = None
        mock_result.metadata = {"title": "Test Page"}
        mock_result.links = {"internal": [], "external": []}
        mock_result.media = {"images": []}

        mock_crawler = AsyncMock()
        mock_crawler.arun = AsyncMock(return_value=mock_result)

        with patch("src.crawl4ai_mcp_server.get_crawler", return_value=mock_crawler):
            result = await crawl_single_page("https://example.com")

        assert "Test Page" in result
        assert "test content" in result
        assert "https://example.com" in result

    @pytest.mark.asyncio
    async def test_crawl_single_page_error(self):
        """Test single page crawl with error."""
        mock_result = MagicMock()
        mock_result.success = False
        mock_result.error_message = "Connection timeout"

        mock_crawler = AsyncMock()
        mock_crawler.arun = AsyncMock(return_value=mock_result)

        with patch("src.crawl4ai_mcp_server.get_crawler", return_value=mock_crawler):
            result = await crawl_single_page("https://example.com")

        assert "Error" in result
        assert "Connection timeout" in result

    @pytest.mark.asyncio
    async def test_crawl_single_page_no_storage_by_default(self):
        """Test that storage is disabled by default."""
        mock_result = MagicMock()
        mock_result.success = True
        mock_result.markdown = "# Test Page"
        mock_result.cleaned_html = None
        mock_result.metadata = {"title": "Test Page"}
        mock_result.links = {"internal": [], "external": []}
        mock_result.media = {"images": []}

        mock_crawler = AsyncMock()
        mock_crawler.arun = AsyncMock(return_value=mock_result)

        with patch("src.crawl4ai_mcp_server.get_crawler", return_value=mock_crawler):
            with patch("src.crawl4ai_mcp_server.store_in_vector_db") as mock_vector:
                with patch("src.crawl4ai_mcp_server.store_in_graph_db") as mock_graph:
                    result = await crawl_single_page("https://example.com")

                    # Should NOT call storage functions by default
                    mock_vector.assert_not_called()
                    mock_graph.assert_not_called()

    @pytest.mark.asyncio
    async def test_crawl_single_page_with_storage(self):
        """Test crawl with storage enabled."""
        mock_result = MagicMock()
        mock_result.success = True
        mock_result.markdown = "# Test Page"
        mock_result.cleaned_html = None
        mock_result.metadata = {"title": "Test Page"}
        mock_result.links = {"internal": [], "external": []}
        mock_result.media = {"images": []}

        mock_crawler = AsyncMock()
        mock_crawler.arun = AsyncMock(return_value=mock_result)

        with patch("src.crawl4ai_mcp_server.get_crawler", return_value=mock_crawler):
            with patch("src.crawl4ai_mcp_server.store_in_vector_db", return_value=True) as mock_vector:
                with patch("src.crawl4ai_mcp_server.store_in_graph_db", return_value=True) as mock_graph:
                    result = await crawl_single_page(
                        "https://example.com",
                        store_in_db=True,
                        store_in_graph=True
                    )

                    # Should call storage functions when enabled
                    mock_vector.assert_called_once()
                    mock_graph.assert_called_once()

                    # Should show storage status in output
                    assert "Vector DB" in result
                    assert "Graph DB" in result


class TestCrawlMultiplePages:
    """Tests for crawl_multiple_pages tool."""

    @pytest.mark.asyncio
    async def test_crawl_multiple_pages_success(self):
        """Test successful batch crawl."""
        mock_result = MagicMock()
        mock_result.success = True
        mock_result.markdown = "Page content"
        mock_result.metadata = {"title": "Page Title"}

        mock_crawler = AsyncMock()
        mock_crawler.arun = AsyncMock(return_value=mock_result)

        urls = ["https://example.com/page1", "https://example.com/page2"]

        with patch("src.crawl4ai_mcp_server.get_crawler", return_value=mock_crawler):
            result = await crawl_multiple_pages(urls, max_concurrent=2)

        assert "Batch Crawl Results" in result
        assert "URLs crawled: 2" in result
        assert "Successful: 2" in result


class TestSmartCrawl:
    """Tests for smart_crawl tool."""

    @pytest.mark.asyncio
    async def test_smart_crawl_with_matches(self):
        """Test smart crawl with matching content."""
        mock_result = MagicMock()
        mock_result.success = True
        mock_result.markdown = """
        Introduction paragraph.

        Pricing information starts here. Our basic plan costs $10/month.

        Features section with details.

        More pricing details for enterprise customers.
        """
        mock_result.metadata = {}

        mock_crawler = AsyncMock()
        mock_crawler.arun = AsyncMock(return_value=mock_result)

        with patch("src.crawl4ai_mcp_server.get_crawler", return_value=mock_crawler):
            result = await smart_crawl("https://example.com", "pricing")

        assert "Smart Crawl Results" in result
        assert "pricing" in result.lower()


class TestExtractStructuredData:
    """Tests for extract_structured_data tool."""

    @pytest.mark.asyncio
    async def test_extract_structured_data_success(self):
        """Test successful structured extraction."""
        mock_result = MagicMock()
        mock_result.success = True
        mock_result.extracted_content = json.dumps([
            {"title": "Product 1", "price": "$10"},
            {"title": "Product 2", "price": "$20"}
        ])

        mock_crawler = AsyncMock()
        mock_crawler.arun = AsyncMock(return_value=mock_result)

        schema = {
            "name": "products",
            "baseSelector": ".product",
            "fields": [
                {"name": "title", "selector": "h2", "type": "text"},
                {"name": "price", "selector": ".price", "type": "text"}
            ]
        }

        with patch("src.crawl4ai_mcp_server.get_crawler", return_value=mock_crawler):
            result = await extract_structured_data("https://example.com", schema)

        data = json.loads(result)
        assert len(data) == 2
        assert data[0]["title"] == "Product 1"


class TestRAGStatus:
    """Tests for RAG availability checks."""

    def test_rag_available_flag(self):
        """Test that RAG_AVAILABLE is properly set based on config."""
        # This will depend on environment variables
        assert isinstance(RAG_AVAILABLE, bool)

    def test_graph_rag_available_flag(self):
        """Test that GRAPH_RAG_AVAILABLE is properly set based on config."""
        # This will depend on environment variables
        assert isinstance(GRAPH_RAG_AVAILABLE, bool)


class TestIntegration:
    """Integration tests (require network access)."""

    @pytest.mark.skip(reason="Requires network access")
    @pytest.mark.asyncio
    async def test_real_crawl(self):
        """Test real crawl (skipped by default)."""
        result = await crawl_single_page("https://example.com")
        assert "Example Domain" in result

    @pytest.mark.skip(reason="Requires Supabase and Azure OpenAI")
    @pytest.mark.asyncio
    async def test_real_crawl_with_vector_storage(self):
        """Test real crawl with vector storage (skipped by default)."""
        result = await crawl_single_page(
            "https://example.com",
            store_in_db=True
        )
        assert "Vector DB: ✓" in result

    @pytest.mark.skip(reason="Requires Neo4j")
    @pytest.mark.asyncio
    async def test_real_crawl_with_graph_storage(self):
        """Test real crawl with graph storage (skipped by default)."""
        result = await crawl_single_page(
            "https://example.com",
            store_in_graph=True
        )
        assert "Graph DB: ✓" in result


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
