-- =============================================================================
-- Supabase Setup for Crawl4AI RAG Features
-- =============================================================================
-- Run this SQL in your Supabase SQL Editor to enable RAG capabilities
-- =============================================================================

-- Enable the pgvector extension for vector similarity search
CREATE EXTENSION IF NOT EXISTS vector;

-- -----------------------------------------------------------------------------
-- Table: crawled_content
-- Stores crawled web pages with embeddings for semantic search
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS crawled_content (
    id BIGSERIAL PRIMARY KEY,
    url TEXT NOT NULL UNIQUE,
    title TEXT,
    content TEXT NOT NULL,
    embedding vector(1536),  -- OpenAI text-embedding-3-small dimension
    crawled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Index for faster URL lookups
CREATE INDEX IF NOT EXISTS idx_crawled_content_url ON crawled_content(url);

-- Index for vector similarity search
CREATE INDEX IF NOT EXISTS idx_crawled_content_embedding ON crawled_content
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

-- Index for timestamp-based queries
CREATE INDEX IF NOT EXISTS idx_crawled_content_crawled_at ON crawled_content(crawled_at DESC);

-- -----------------------------------------------------------------------------
-- Function: match_documents
-- Semantic search function for finding similar content
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION match_documents(
    query_embedding vector(1536),
    match_count INT DEFAULT 5,
    filter_url TEXT DEFAULT NULL
)
RETURNS TABLE (
    id BIGINT,
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
        cc.id,
        cc.url,
        cc.title,
        cc.content,
        1 - (cc.embedding <=> query_embedding) AS similarity
    FROM crawled_content cc
    WHERE
        cc.embedding IS NOT NULL
        AND (filter_url IS NULL OR cc.url LIKE '%' || filter_url || '%')
    ORDER BY cc.embedding <=> query_embedding
    LIMIT match_count;
END;
$$;

-- -----------------------------------------------------------------------------
-- Function: upsert_crawled_content
-- Insert or update crawled content with embedding
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION upsert_crawled_content(
    p_url TEXT,
    p_title TEXT,
    p_content TEXT,
    p_embedding vector(1536),
    p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    result_id BIGINT;
BEGIN
    INSERT INTO crawled_content (url, title, content, embedding, metadata, updated_at)
    VALUES (p_url, p_title, p_content, p_embedding, p_metadata, NOW())
    ON CONFLICT (url) DO UPDATE
    SET
        title = EXCLUDED.title,
        content = EXCLUDED.content,
        embedding = EXCLUDED.embedding,
        metadata = EXCLUDED.metadata,
        updated_at = NOW()
    RETURNING id INTO result_id;

    RETURN result_id;
END;
$$;

-- -----------------------------------------------------------------------------
-- Function: get_recent_crawls
-- Get recently crawled pages
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_recent_crawls(
    limit_count INT DEFAULT 10
)
RETURNS TABLE (
    id BIGINT,
    url TEXT,
    title TEXT,
    crawled_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE sql
AS $$
    SELECT id, url, title, crawled_at
    FROM crawled_content
    ORDER BY crawled_at DESC
    LIMIT limit_count;
$$;

-- -----------------------------------------------------------------------------
-- Trigger: Update timestamp on modification
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_crawled_content_updated_at ON crawled_content;
CREATE TRIGGER update_crawled_content_updated_at
    BEFORE UPDATE ON crawled_content
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- -----------------------------------------------------------------------------
-- Row Level Security (Optional but recommended)
-- -----------------------------------------------------------------------------
-- Uncomment these lines if you want to enable RLS

-- ALTER TABLE crawled_content ENABLE ROW LEVEL SECURITY;

-- -- Policy for service role (full access)
-- CREATE POLICY "Service role has full access" ON crawled_content
--     FOR ALL
--     USING (auth.role() = 'service_role');

-- -- Policy for authenticated users (read only)
-- CREATE POLICY "Authenticated users can read" ON crawled_content
--     FOR SELECT
--     USING (auth.role() = 'authenticated');

-- -----------------------------------------------------------------------------
-- Cleanup function (optional)
-- Remove old crawled content
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cleanup_old_crawls(
    days_old INT DEFAULT 30
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    deleted_count INT;
BEGIN
    DELETE FROM crawled_content
    WHERE crawled_at < NOW() - (days_old || ' days')::INTERVAL;

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$;

-- =============================================================================
-- Usage Examples
-- =============================================================================
--
-- Search for similar content:
-- SELECT * FROM match_documents(
--     '[0.1, 0.2, ...]'::vector(1536),  -- Your query embedding
--     5,                                  -- Number of results
--     'anthropic.com'                     -- Optional URL filter
-- );
--
-- Get recent crawls:
-- SELECT * FROM get_recent_crawls(10);
--
-- Cleanup old content:
-- SELECT cleanup_old_crawls(30);  -- Remove content older than 30 days
-- =============================================================================
