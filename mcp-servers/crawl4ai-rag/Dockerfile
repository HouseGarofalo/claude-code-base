# =============================================================================
# Crawl4AI MCP Server Dockerfile (v2.0)
# =============================================================================
# Multi-stage build for minimal image size
# Includes stages for: base, production, with-vector-rag, with-graph-rag, full
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Base with browser dependencies
# -----------------------------------------------------------------------------
FROM python:3.12-slim as base

# Prevent Python from writing pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies for Playwright/browsers
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Browser dependencies
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libatspi2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libcairo2 \
    # Font support
    fonts-liberation \
    fonts-noto-color-emoji \
    # Utilities
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Stage 2: Builder
# -----------------------------------------------------------------------------
FROM base as builder

WORKDIR /build

# Install build dependencies
RUN pip install --upgrade pip setuptools wheel

# Copy project files
COPY pyproject.toml README.md ./
COPY src/ ./src/

# Build wheel
RUN pip wheel --no-deps --wheel-dir /wheels .

# Install core dependencies
RUN pip wheel --wheel-dir /wheels \
    crawl4ai>=0.4.0 \
    mcp>=1.0.0 \
    fastmcp>=0.1.0 \
    pydantic>=2.0.0 \
    python-dotenv>=1.0.0

# Build RAG dependencies (Vector RAG)
RUN pip wheel --wheel-dir /wheels-rag \
    supabase>=2.0.0 \
    openai>=1.0.0

# Build Graph RAG dependencies
RUN pip wheel --wheel-dir /wheels-graph \
    neo4j>=5.0.0

# -----------------------------------------------------------------------------
# Stage 3: Production (basic crawling only)
# -----------------------------------------------------------------------------
FROM base as production

# Create non-root user for security
RUN groupadd --gid 1000 crawl4ai \
    && useradd --uid 1000 --gid crawl4ai --shell /bin/bash --create-home crawl4ai

WORKDIR /app

# Copy wheels from builder
COPY --from=builder /wheels /wheels

# Install the application
RUN pip install --no-index --find-links=/wheels crawl4ai-mcp-server \
    && rm -rf /wheels

# Install Playwright browsers (chromium only for smaller image)
RUN crawl4ai-setup || playwright install chromium --with-deps

# Copy source for reference
COPY --chown=crawl4ai:crawl4ai src/ ./src/
COPY --chown=crawl4ai:crawl4ai .env.example ./

# Set environment defaults
ENV TRANSPORT=stdio \
    HEADLESS=true \
    BROWSER_TYPE=chromium \
    MEAN_DELAY=0.5 \
    MAX_CONCURRENT=5

# Switch to non-root user
USER crawl4ai

# Health check for SSE mode
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import socket; s=socket.socket(); s.connect(('localhost', 8000)); s.close()" || exit 0

# Expose port for SSE transport
EXPOSE 8000

# Entry point
ENTRYPOINT ["python", "-m", "src.crawl4ai_mcp_server"]

# -----------------------------------------------------------------------------
# Stage 4: With Vector RAG (Supabase + Azure OpenAI)
# -----------------------------------------------------------------------------
FROM production as with-vector-rag

USER root

# Copy and install RAG dependencies
COPY --from=builder /wheels-rag /wheels-rag
RUN pip install --no-index --find-links=/wheels-rag \
    supabase>=2.0.0 \
    openai>=1.0.0 \
    && rm -rf /wheels-rag

USER crawl4ai

# Entry point
ENTRYPOINT ["python", "-m", "src.crawl4ai_mcp_server"]

# -----------------------------------------------------------------------------
# Stage 5: With Graph RAG (Neo4j)
# -----------------------------------------------------------------------------
FROM production as with-graph-rag

USER root

# Copy and install Graph RAG dependencies
COPY --from=builder /wheels-graph /wheels-graph
RUN pip install --no-index --find-links=/wheels-graph \
    neo4j>=5.0.0 \
    && rm -rf /wheels-graph

USER crawl4ai

# Entry point
ENTRYPOINT ["python", "-m", "src.crawl4ai_mcp_server"]

# -----------------------------------------------------------------------------
# Stage 6: Full (Vector RAG + Graph RAG)
# -----------------------------------------------------------------------------
FROM production as full

USER root

# Copy and install all RAG dependencies
COPY --from=builder /wheels-rag /wheels-rag
COPY --from=builder /wheels-graph /wheels-graph

RUN pip install --no-index --find-links=/wheels-rag \
    supabase>=2.0.0 \
    openai>=1.0.0 \
    && pip install --no-index --find-links=/wheels-graph \
    neo4j>=5.0.0 \
    && rm -rf /wheels-rag /wheels-graph

USER crawl4ai

# Entry point
ENTRYPOINT ["python", "-m", "src.crawl4ai_mcp_server"]

# -----------------------------------------------------------------------------
# Stage 7: Development (for local development/testing)
# -----------------------------------------------------------------------------
FROM full as development

USER root

# Install dev dependencies
RUN pip install \
    pytest>=7.0.0 \
    pytest-asyncio>=0.21.0 \
    pytest-cov>=4.0.0 \
    black>=23.0.0 \
    ruff>=0.1.0 \
    mypy>=1.0.0

# Copy test files
COPY --chown=crawl4ai:crawl4ai tests/ ./tests/

USER crawl4ai

# Override entrypoint for development
ENTRYPOINT ["/bin/bash"]

# =============================================================================
# Build Commands:
# =============================================================================
#
# Basic (crawling only):
#   docker build --target production -t crawl4ai-mcp:latest .
#
# With Vector RAG:
#   docker build --target with-vector-rag -t crawl4ai-mcp:vector .
#
# With Graph RAG:
#   docker build --target with-graph-rag -t crawl4ai-mcp:graph .
#
# Full (Vector + Graph RAG):
#   docker build --target full -t crawl4ai-mcp:full .
#
# Development:
#   docker build --target development -t crawl4ai-mcp:dev .
#
# =============================================================================
