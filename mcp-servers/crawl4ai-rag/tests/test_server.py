"""
Tests for Crawl4AI MCP Server

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


class TestIntegration:
    """Integration tests (require network access)."""

    @pytest.mark.skip(reason="Requires network access")
    @pytest.mark.asyncio
    async def test_real_crawl(self):
        """Test real crawl (skipped by default)."""
        result = await crawl_single_page("https://example.com")
        assert "Example Domain" in result


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
