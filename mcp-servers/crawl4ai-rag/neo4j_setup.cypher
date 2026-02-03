// =============================================================================
// Neo4j Setup for Crawl4AI Graph RAG
// =============================================================================
// Run this Cypher script in your Neo4j Browser or via neo4j-admin
// =============================================================================

// -----------------------------------------------------------------------------
// Constraints (ensure uniqueness and improve query performance)
// -----------------------------------------------------------------------------

// WebPage nodes - URL must be unique
CREATE CONSTRAINT webpage_url IF NOT EXISTS
FOR (p:WebPage)
REQUIRE p.url IS UNIQUE;

// Domain nodes - name must be unique
CREATE CONSTRAINT domain_name IF NOT EXISTS
FOR (d:Domain)
REQUIRE d.name IS UNIQUE;

// Topic nodes - name must be unique
CREATE CONSTRAINT topic_name IF NOT EXISTS
FOR (t:Topic)
REQUIRE t.name IS UNIQUE;

// -----------------------------------------------------------------------------
// Indexes (improve query performance)
// -----------------------------------------------------------------------------

// Index for searching pages by title
CREATE INDEX webpage_title IF NOT EXISTS
FOR (p:WebPage) ON (p.title);

// Index for searching pages by crawl time
CREATE INDEX webpage_crawled_at IF NOT EXISTS
FOR (p:WebPage) ON (p.crawled_at);

// Full-text search index for content (optional, requires APOC)
// CALL db.index.fulltext.createNodeIndex("pageContent", ["WebPage"], ["title", "content"]);

// -----------------------------------------------------------------------------
// Sample Queries for Testing
// -----------------------------------------------------------------------------

// Find all pages that cover a specific topic:
// MATCH (p:WebPage)-[:COVERS_TOPIC]->(t:Topic {name: "Authentication"})
// RETURN p.url, p.title

// Find all topics covered by a domain:
// MATCH (p:WebPage)-[:BELONGS_TO]->(d:Domain {name: "docs.anthropic.com"})
// MATCH (p)-[:COVERS_TOPIC]->(t:Topic)
// RETURN DISTINCT t.name

// Find pages that link to each other:
// MATCH path = (p1:WebPage)-[:LINKS_TO*1..2]->(p2:WebPage)
// WHERE p1.url CONTAINS "anthropic"
// RETURN path LIMIT 25

// Get topic statistics:
// MATCH (t:Topic)<-[:COVERS_TOPIC]-(p:WebPage)
// RETURN t.name as topic, count(p) as page_count
// ORDER BY page_count DESC

// Find related pages through topics:
// MATCH (p1:WebPage {url: $url})-[:COVERS_TOPIC]->(t:Topic)<-[:COVERS_TOPIC]-(p2:WebPage)
// WHERE p1 <> p2
// RETURN p2.url, p2.title, collect(t.name) as shared_topics

// Find all pages from recent crawls:
// MATCH (p:WebPage)
// WHERE p.crawled_at > datetime() - duration('P7D')
// RETURN p.url, p.title, p.crawled_at
// ORDER BY p.crawled_at DESC

// -----------------------------------------------------------------------------
// Cleanup Queries (use with caution)
// -----------------------------------------------------------------------------

// Delete all data (DANGEROUS - use only for reset):
// MATCH (n) DETACH DELETE n

// Delete pages older than 30 days:
// MATCH (p:WebPage)
// WHERE p.crawled_at < datetime() - duration('P30D')
// DETACH DELETE p

// Delete orphaned topics (topics with no pages):
// MATCH (t:Topic)
// WHERE NOT (t)<-[:COVERS_TOPIC]-()
// DELETE t

// -----------------------------------------------------------------------------
// Graph Statistics
// -----------------------------------------------------------------------------

// Count all nodes by label:
// MATCH (n)
// RETURN labels(n)[0] as label, count(*) as count
// ORDER BY count DESC

// Count all relationships by type:
// MATCH ()-[r]->()
// RETURN type(r) as relationship, count(*) as count
// ORDER BY count DESC

// =============================================================================
// END OF SETUP
// =============================================================================
