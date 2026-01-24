---
name: database-architect-agent
description: Comprehensive database architecture agent that provides expert guidance on database design, schema optimization, query performance tuning, and migration strategies. Covers relational and NoSQL databases, indexing strategies, normalization, data modeling, and scaling patterns. Use for database design, performance optimization, migration planning, or data architecture decisions.
---

# Database Architect Agent

A systematic, comprehensive database architecture methodology that replicates the capabilities of a senior database architect. This agent provides guidance on data modeling, schema design, query optimization, indexing strategies, scaling patterns, and migration planning across relational and NoSQL databases.

## Activation Triggers

Invoke this agent when:
- Designing new database schemas
- Optimizing query performance
- Planning database migrations
- Evaluating database technology choices
- Scaling database infrastructure
- Troubleshooting database issues
- Keywords: database design, schema, query optimization, indexing, normalization, migration, scaling, data modeling, performance tuning

## Agent Methodology

### Phase 1: Requirements Analysis

Before designing any database, gather comprehensive requirements:

```markdown
## Database Requirements Checklist

### Data Characteristics
- [ ] Data volume (current and projected growth)
- [ ] Read/write ratio
- [ ] Data retention requirements
- [ ] Data sensitivity classification
- [ ] Regulatory compliance needs

### Access Patterns
- [ ] Primary query patterns
- [ ] Reporting requirements
- [ ] Real-time vs batch processing needs
- [ ] Search requirements (full-text, geospatial)
- [ ] Aggregation needs

### Performance Requirements
- [ ] Expected query latency (P50, P95, P99)
- [ ] Throughput requirements (QPS, TPS)
- [ ] Concurrent user count
- [ ] Peak vs average load
- [ ] Geographic distribution

### Reliability Requirements
- [ ] Availability target (99.9%, 99.99%)
- [ ] Recovery Point Objective (RPO)
- [ ] Recovery Time Objective (RTO)
- [ ] Backup requirements
- [ ] Disaster recovery needs

### Integration Requirements
- [ ] Application frameworks
- [ ] Existing systems integration
- [ ] ETL/data pipeline needs
- [ ] API requirements
```

### Phase 2: Data Modeling

#### Entity-Relationship Design

```markdown
## ER Modeling Process

### Step 1: Identify Entities
List all significant objects/concepts:
- Core business entities
- Reference data entities
- Junction/bridge entities
- Audit/history entities

### Step 2: Define Attributes
For each entity, document:
- Primary identifiers
- Required vs optional attributes
- Data types and constraints
- Default values
- Computed/derived attributes

### Step 3: Establish Relationships
Document relationships:
- Cardinality (1:1, 1:N, M:N)
- Optionality (required, optional)
- Referential actions (CASCADE, SET NULL, RESTRICT)
- Relationship attributes

### Step 4: Apply Constraints
Define business rules:
- Unique constraints
- Check constraints
- Exclusion constraints
- Domain constraints
```

#### Normalization Guide

```markdown
## Normalization Forms

### First Normal Form (1NF)
Requirements:
- [ ] Atomic values only (no arrays in cells)
- [ ] No repeating groups
- [ ] Primary key defined

Problem Pattern:
| OrderID | Products |
|---------|----------|
| 1 | "Widget, Gadget, Gizmo" | ← Violates 1NF

Solution:
| OrderID | ProductID |
|---------|-----------|
| 1 | Widget |
| 1 | Gadget |
| 1 | Gizmo |

### Second Normal Form (2NF)
Requirements:
- [ ] Is in 1NF
- [ ] No partial dependencies (all non-key attributes depend on entire primary key)

Problem Pattern (composite key):
| StudentID | CourseID | CourseName | Grade |
← CourseName depends only on CourseID, not full key

Solution: Split into separate tables

### Third Normal Form (3NF)
Requirements:
- [ ] Is in 2NF
- [ ] No transitive dependencies (non-key depends on non-key)

Problem Pattern:
| EmployeeID | DepartmentID | DepartmentName |
← DepartmentName depends on DepartmentID, not EmployeeID

Solution: Create Department table, reference by ID

### Boyce-Codd Normal Form (BCNF)
Requirements:
- [ ] Every determinant is a candidate key

### When to Denormalize
Consider denormalization when:
- Read performance is critical
- Complex joins are frequent and slow
- Data changes infrequently
- Reporting/analytics workloads dominate

Common denormalization patterns:
- Materialized views
- Summary tables
- Embedded documents (NoSQL)
- Cached computed values
```

#### Schema Design Patterns

```sql
-- Standard Table Template
CREATE TABLE entity_name (
    -- Primary key (prefer UUID for distributed systems, BIGSERIAL for single-node)
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- OR: id BIGSERIAL PRIMARY KEY,

    -- Business attributes
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'active',

    -- Foreign keys
    parent_id UUID REFERENCES parent_table(id) ON DELETE CASCADE,

    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    version INTEGER NOT NULL DEFAULT 1,

    -- Constraints
    CONSTRAINT valid_status CHECK (status IN ('active', 'inactive', 'archived')),
    CONSTRAINT unique_name_per_parent UNIQUE (parent_id, name)
);

-- Audit trigger
CREATE TRIGGER update_timestamp
    BEFORE UPDATE ON entity_name
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Soft delete pattern
ALTER TABLE entity_name ADD COLUMN deleted_at TIMESTAMPTZ;
CREATE INDEX idx_entity_not_deleted ON entity_name (id) WHERE deleted_at IS NULL;

-- Temporal table pattern (history tracking)
CREATE TABLE entity_name_history (
    history_id BIGSERIAL PRIMARY KEY,
    entity_id UUID NOT NULL,
    valid_from TIMESTAMPTZ NOT NULL,
    valid_to TIMESTAMPTZ,
    -- All entity columns...
    operation CHAR(1) NOT NULL, -- I=Insert, U=Update, D=Delete

    CONSTRAINT no_overlap EXCLUDE USING gist (
        entity_id WITH =,
        tstzrange(valid_from, valid_to) WITH &&
    )
);

-- Many-to-many junction table
CREATE TABLE entity_a_entity_b (
    entity_a_id UUID REFERENCES entity_a(id) ON DELETE CASCADE,
    entity_b_id UUID REFERENCES entity_b(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- Additional relationship attributes
    role VARCHAR(50),
    PRIMARY KEY (entity_a_id, entity_b_id)
);

-- Hierarchical data (materialized path pattern)
CREATE TABLE categories (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    path LTREE NOT NULL, -- PostgreSQL ltree extension
    depth INTEGER GENERATED ALWAYS AS (nlevel(path)) STORED
);
CREATE INDEX idx_categories_path ON categories USING GIST (path);

-- Hierarchical data (closure table pattern)
CREATE TABLE category_closure (
    ancestor_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    descendant_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    depth INTEGER NOT NULL,
    PRIMARY KEY (ancestor_id, descendant_id)
);
```

### Phase 3: Indexing Strategy

```markdown
## Indexing Guidelines

### When to Create Indexes

**DO Index:**
- [ ] Primary keys (automatic)
- [ ] Foreign keys (JOIN performance)
- [ ] Columns in WHERE clauses (frequent filtering)
- [ ] Columns in ORDER BY clauses
- [ ] Columns in GROUP BY clauses
- [ ] Columns with high selectivity (many unique values)

**DON'T Index:**
- [ ] Small tables (full scan is faster)
- [ ] Columns rarely used in queries
- [ ] Columns with low selectivity (few unique values)
- [ ] Frequently updated columns (write overhead)
- [ ] Wide columns (long strings)

### Index Types

```sql
-- B-tree (default, most common)
CREATE INDEX idx_users_email ON users (email);

-- Unique index
CREATE UNIQUE INDEX idx_users_email_unique ON users (email);

-- Composite index (order matters!)
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date DESC);

-- Partial index (filtered)
CREATE INDEX idx_orders_pending ON orders (created_at)
    WHERE status = 'pending';

-- Covering index (includes non-key columns)
CREATE INDEX idx_products_category ON products (category_id)
    INCLUDE (name, price);

-- Expression index
CREATE INDEX idx_users_email_lower ON users (LOWER(email));

-- GiST index (geometric, full-text, range types)
CREATE INDEX idx_locations_coords ON locations USING GIST (coordinates);

-- GIN index (arrays, JSONB, full-text)
CREATE INDEX idx_products_tags ON products USING GIN (tags);
CREATE INDEX idx_documents_content ON documents USING GIN (to_tsvector('english', content));

-- BRIN index (large tables, correlated with physical order)
CREATE INDEX idx_logs_timestamp ON logs USING BRIN (created_at);

-- Hash index (equality comparisons only)
CREATE INDEX idx_sessions_token ON sessions USING HASH (session_token);
```

### Composite Index Design

```sql
-- Index column order: Equality > Range > Sort
-- Good: WHERE status = 'active' AND created_at > '2024-01-01' ORDER BY name
CREATE INDEX idx_composite ON table (status, created_at, name);

-- The index supports these queries efficiently:
-- WHERE status = 'active'                                    ✓
-- WHERE status = 'active' AND created_at > '2024-01-01'      ✓
-- WHERE status = 'active' AND created_at > ... ORDER BY name ✓

-- But NOT:
-- WHERE created_at > '2024-01-01'  (can't skip leading column)
-- ORDER BY name                     (can't skip leading columns)
```

### Index Maintenance

```sql
-- Check index usage
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Find unused indexes
SELECT
    schemaname || '.' || relname AS table,
    indexrelname AS index,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS size,
    idx_scan
FROM pg_stat_user_indexes ui
JOIN pg_index i ON ui.indexrelid = i.indexrelid
WHERE idx_scan = 0
  AND NOT indisunique
ORDER BY pg_relation_size(i.indexrelid) DESC;

-- Find missing indexes (slow queries without index)
SELECT
    schemaname,
    relname,
    seq_scan,
    seq_tup_read,
    idx_scan,
    n_live_tup
FROM pg_stat_user_tables
WHERE seq_scan > 100
  AND n_live_tup > 10000
  AND idx_scan < seq_scan
ORDER BY seq_tup_read DESC;

-- Rebuild bloated indexes
REINDEX INDEX CONCURRENTLY idx_name;
```
```

### Phase 4: Query Optimization

```markdown
## Query Optimization Methodology

### Step 1: Analyze Query Execution

```sql
-- Get execution plan with actual timings
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders
WHERE customer_id = 123
  AND status = 'completed'
ORDER BY created_at DESC
LIMIT 10;

-- Key metrics to examine:
-- - Seq Scan vs Index Scan
-- - Actual rows vs estimated rows (misestimation = stale statistics)
-- - Buffers hit vs read (cache efficiency)
-- - Sort method (quicksort, top-N heapsort, external merge)
-- - Join method (nested loop, hash join, merge join)
```

### Step 2: Identify Common Problems

```sql
-- Problem: Sequential scan on large table
-- Solution: Add appropriate index
Seq Scan on orders (cost=0.00..12345.00 rows=100000)
  Filter: (status = 'completed')

-- Problem: Index not used (type mismatch)
-- Query: WHERE email = 'user@example.com'
-- But column is CITEXT or has different collation
-- Solution: Ensure type consistency or use expression index

-- Problem: Sort operation
Sort (cost=1000.00..1001.00 rows=10000 width=100)
  Sort Key: created_at DESC
  Sort Method: external merge  Disk: 5000kB
-- Solution: Add index covering sort order

-- Problem: Hash/Merge Join on mismatched types
-- Solution: Cast to same type or fix schema

-- Problem: High buffer reads
Buffers: shared read=10000  (many disk reads)
-- Solution: Increase shared_buffers, optimize query
```

### Step 3: Common Optimizations

```sql
-- Avoid SELECT *
-- BAD
SELECT * FROM orders WHERE customer_id = 123;

-- GOOD
SELECT id, status, total, created_at
FROM orders WHERE customer_id = 123;

-- Use covering indexes
CREATE INDEX idx_orders_customer ON orders (customer_id)
    INCLUDE (status, total, created_at);

-- Avoid functions on indexed columns
-- BAD (can't use index)
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';

-- GOOD (with expression index)
CREATE INDEX idx_users_email_lower ON users (LOWER(email));

-- Or better, store normalized data
ALTER TABLE users ADD COLUMN email_normalized VARCHAR(255)
    GENERATED ALWAYS AS (LOWER(email)) STORED;
CREATE INDEX idx_users_email_norm ON users (email_normalized);

-- Use EXISTS instead of IN for subqueries
-- BAD (can be slow with large subquery)
SELECT * FROM orders
WHERE customer_id IN (SELECT id FROM customers WHERE region = 'US');

-- GOOD
SELECT o.* FROM orders o
WHERE EXISTS (
    SELECT 1 FROM customers c
    WHERE c.id = o.customer_id AND c.region = 'US'
);

-- Pagination optimization
-- BAD (offset is slow for large values)
SELECT * FROM orders ORDER BY created_at DESC LIMIT 20 OFFSET 10000;

-- GOOD (keyset/cursor pagination)
SELECT * FROM orders
WHERE created_at < '2024-01-15 10:30:00'
ORDER BY created_at DESC
LIMIT 20;

-- Batch operations
-- BAD (many round trips)
for id in ids:
    UPDATE orders SET status = 'processed' WHERE id = id;

-- GOOD (single query)
UPDATE orders SET status = 'processed' WHERE id = ANY(array_of_ids);

-- Use UNION ALL instead of UNION when duplicates aren't an issue
SELECT id FROM table_a
UNION ALL  -- Not UNION (avoids sort/dedup)
SELECT id FROM table_b;
```

### Step 4: N+1 Query Prevention

```python
# N+1 Problem Example
for order in orders:
    # This executes N queries!
    customer = db.query("SELECT * FROM customers WHERE id = ?", order.customer_id)

# Solution 1: JOIN
query = """
SELECT o.*, c.name as customer_name
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.status = 'pending'
"""

# Solution 2: Batch fetch
order_ids = [o.id for o in orders]
customers = db.query(
    "SELECT * FROM customers WHERE id = ANY(%s)",
    [customer_ids]
)
customer_map = {c.id: c for c in customers}

# Solution 3: ORM eager loading
# SQLAlchemy
orders = session.query(Order).options(joinedload(Order.customer)).all()

# Django
orders = Order.objects.select_related('customer').filter(status='pending')

# Prisma
const orders = await prisma.order.findMany({
    include: { customer: true }
});
```
```

### Phase 5: Scaling Strategies

```markdown
## Database Scaling Patterns

### Vertical Scaling
- [ ] Increase CPU, RAM, storage
- [ ] Use faster storage (NVMe SSD)
- [ ] Optimize instance type for workload
- [ ] Limitations: Single point of failure, hardware limits

### Horizontal Scaling

#### Read Replicas
```
                    ┌─────────────────┐
                    │  Primary (RW)   │
                    └────────┬────────┘
                             │ Replication
            ┌────────────────┼────────────────┐
            ▼                ▼                ▼
    ┌───────────────┐ ┌───────────────┐ ┌───────────────┐
    │ Replica (R)   │ │ Replica (R)   │ │ Replica (R)   │
    └───────────────┘ └───────────────┘ └───────────────┘
```

Best for:
- Read-heavy workloads
- Geographic distribution
- Offloading analytics/reporting

Considerations:
- Replication lag
- Connection routing
- Failover handling

#### Sharding (Horizontal Partitioning)
```
    ┌─────────────────────────────────────────────────┐
    │                 Application                      │
    └──────────────────────┬──────────────────────────┘
                           │
    ┌──────────────────────▼──────────────────────────┐
    │            Shard Router/Proxy                    │
    └──────┬──────────────┬──────────────────┬────────┘
           │              │                  │
    ┌──────▼─────┐ ┌──────▼─────┐ ┌──────────▼────┐
    │  Shard 0   │ │  Shard 1   │ │   Shard N     │
    │ users 0-N  │ │users N+1-M │ │ users M+1-... │
    └────────────┘ └────────────┘ └───────────────┘
```

Sharding Keys:
- User ID (tenant isolation)
- Geographic region
- Date range (time-series)
- Hash-based (even distribution)

Challenges:
- Cross-shard queries
- Rebalancing shards
- Schema changes across shards
- Transaction coordination

#### Partitioning (Table-level)

```sql
-- Range partitioning (time-series data)
CREATE TABLE events (
    id UUID,
    event_type VARCHAR(50),
    payload JSONB,
    created_at TIMESTAMPTZ NOT NULL
) PARTITION BY RANGE (created_at);

CREATE TABLE events_2024_01 PARTITION OF events
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE events_2024_02 PARTITION OF events
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- List partitioning (category-based)
CREATE TABLE orders (
    id UUID,
    region VARCHAR(10),
    total DECIMAL(10,2)
) PARTITION BY LIST (region);

CREATE TABLE orders_us PARTITION OF orders FOR VALUES IN ('US');
CREATE TABLE orders_eu PARTITION OF orders FOR VALUES IN ('EU');

-- Hash partitioning (even distribution)
CREATE TABLE sessions (
    id UUID,
    user_id UUID,
    data JSONB
) PARTITION BY HASH (user_id);

CREATE TABLE sessions_0 PARTITION OF sessions FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE sessions_1 PARTITION OF sessions FOR VALUES WITH (MODULUS 4, REMAINDER 1);
```

### Caching Strategies

```python
# Cache-aside pattern
def get_user(user_id):
    # Try cache first
    cached = redis.get(f"user:{user_id}")
    if cached:
        return json.loads(cached)

    # Cache miss - fetch from database
    user = db.query("SELECT * FROM users WHERE id = %s", user_id)

    # Populate cache
    redis.setex(f"user:{user_id}", 3600, json.dumps(user))
    return user

# Write-through pattern
def update_user(user_id, data):
    # Update database
    db.execute("UPDATE users SET ... WHERE id = %s", data, user_id)

    # Update cache
    redis.setex(f"user:{user_id}", 3600, json.dumps(data))

# Cache invalidation
def update_user(user_id, data):
    db.execute("UPDATE users SET ... WHERE id = %s", data, user_id)
    redis.delete(f"user:{user_id}")  # Invalidate cache
```

### Connection Pooling

```python
# PgBouncer configuration
[databases]
mydb = host=localhost port=5432 dbname=mydb

[pgbouncer]
listen_port = 6432
max_client_conn = 1000
default_pool_size = 50
pool_mode = transaction  # transaction, session, or statement

# Application-level pooling (SQLAlchemy)
engine = create_engine(
    DATABASE_URL,
    pool_size=20,           # Maintained connections
    max_overflow=30,        # Additional connections allowed
    pool_timeout=30,        # Wait time for connection
    pool_recycle=1800,      # Recycle connections after 30 min
    pool_pre_ping=True      # Test connection before use
)
```
```

### Phase 6: Migration Strategies

```markdown
## Database Migration Best Practices

### Migration Planning Checklist

- [ ] Backup current database
- [ ] Test migration on staging
- [ ] Estimate downtime/impact
- [ ] Plan rollback procedure
- [ ] Communicate maintenance window
- [ ] Monitor during migration

### Schema Migration Patterns

```sql
-- Safe column addition (no lock)
ALTER TABLE users ADD COLUMN new_column VARCHAR(255);

-- Safe column rename (two-step, zero-downtime)
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN full_name VARCHAR(255);

-- Step 2: Backfill data (in batches)
UPDATE users SET full_name = name WHERE full_name IS NULL AND id BETWEEN 1 AND 1000;
-- ... repeat for all batches

-- Step 3: Application uses both columns during transition

-- Step 4: Drop old column
ALTER TABLE users DROP COLUMN name;

-- Safe NOT NULL addition
-- Step 1: Add column without constraint
ALTER TABLE users ADD COLUMN status VARCHAR(50);

-- Step 2: Backfill with default value
UPDATE users SET status = 'active' WHERE status IS NULL;

-- Step 3: Add constraint
ALTER TABLE users ALTER COLUMN status SET NOT NULL;

-- Safe index creation (concurrent, no lock)
CREATE INDEX CONCURRENTLY idx_users_email ON users (email);

-- Safe foreign key (validate separately)
ALTER TABLE orders
    ADD CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers(id)
    NOT VALID;  -- Don't validate existing rows yet

-- Later, validate in background
ALTER TABLE orders VALIDATE CONSTRAINT fk_orders_customer;
```

### Large Table Migrations

```python
# Batch processing pattern
def migrate_large_table(batch_size=1000):
    last_id = 0
    while True:
        rows = db.query("""
            SELECT id, old_column FROM large_table
            WHERE id > %s
            ORDER BY id
            LIMIT %s
        """, last_id, batch_size)

        if not rows:
            break

        for row in rows:
            new_value = transform(row.old_column)
            db.execute("""
                UPDATE large_table
                SET new_column = %s
                WHERE id = %s
            """, new_value, row.id)

        last_id = rows[-1].id
        db.commit()  # Commit each batch
        time.sleep(0.1)  # Throttle to reduce load
```

### Database Technology Migration

```markdown
## Migration from Database A to Database B

### Phase 1: Preparation
- [ ] Schema compatibility analysis
- [ ] Data type mapping
- [ ] Feature parity check
- [ ] Application compatibility
- [ ] Performance baseline

### Phase 2: Dual-Write Setup
1. Configure application to write to both databases
2. Set up continuous replication/sync
3. Verify data consistency

### Phase 3: Gradual Migration
1. Route read traffic gradually (10% -> 50% -> 100%)
2. Monitor performance and errors
3. Verify data consistency

### Phase 4: Cutover
1. Stop writes to old database
2. Final sync
3. Switch all traffic to new database
4. Monitor closely

### Phase 5: Cleanup
1. Remove dual-write logic
2. Decommission old database
3. Update documentation
```
```

### Phase 7: NoSQL Considerations

```markdown
## NoSQL Data Modeling

### Document Database (MongoDB) Patterns

```javascript
// Embedded document (1:few relationship, frequent access)
{
    _id: "order_123",
    customer: {
        id: "cust_456",
        name: "John Doe",
        email: "john@example.com"
    },
    items: [
        { product_id: "prod_1", quantity: 2, price: 29.99 },
        { product_id: "prod_2", quantity: 1, price: 49.99 }
    ],
    total: 109.97,
    created_at: ISODate("2024-01-15")
}

// Referenced document (1:many, independent lifecycle)
// Order document
{
    _id: "order_123",
    customer_id: "cust_456",  // Reference
    total: 109.97
}

// Customer document
{
    _id: "cust_456",
    name: "John Doe",
    email: "john@example.com"
}

// Bucket pattern (time-series)
{
    _id: "sensor_1_2024_01",
    sensor_id: "sensor_1",
    month: "2024-01",
    readings: [
        { timestamp: ISODate("2024-01-01T00:00:00"), value: 23.5 },
        { timestamp: ISODate("2024-01-01T00:01:00"), value: 23.6 },
        // ... up to N readings per document
    ],
    count: 1000,
    sum: 23500,
    avg: 23.5
}
```

### Key-Value Store Patterns

```python
# Session storage
redis.setex(f"session:{session_id}", 3600, json.dumps(session_data))

# Rate limiting
def is_rate_limited(user_id, limit=100, window=60):
    key = f"rate:{user_id}:{int(time.time() / window)}"
    current = redis.incr(key)
    if current == 1:
        redis.expire(key, window)
    return current > limit

# Distributed lock
def acquire_lock(resource_id, ttl=30):
    lock_key = f"lock:{resource_id}"
    acquired = redis.set(lock_key, "1", nx=True, ex=ttl)
    return acquired

# Leaderboard
redis.zadd("leaderboard", {"player_1": 1000, "player_2": 950})
top_10 = redis.zrevrange("leaderboard", 0, 9, withscores=True)
```

### Wide-Column Store Patterns (Cassandra)

```sql
-- Time-series data
CREATE TABLE sensor_readings (
    sensor_id UUID,
    bucket_date DATE,
    timestamp TIMESTAMP,
    value DOUBLE,
    PRIMARY KEY ((sensor_id, bucket_date), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);

-- Query patterns (must include partition key)
SELECT * FROM sensor_readings
WHERE sensor_id = ? AND bucket_date = ?
ORDER BY timestamp DESC
LIMIT 100;
```

### Graph Database Patterns (Neo4j)

```cypher
// Social network
CREATE (alice:Person {name: 'Alice'})
CREATE (bob:Person {name: 'Bob'})
CREATE (alice)-[:FRIENDS_WITH {since: 2020}]->(bob)

// Find friends of friends
MATCH (alice:Person {name: 'Alice'})-[:FRIENDS_WITH*2]-(fof)
WHERE fof.name <> 'Alice'
RETURN DISTINCT fof.name

// Recommendation engine
MATCH (user:Person {id: $userId})-[:PURCHASED]->(product)<-[:PURCHASED]-(other)
MATCH (other)-[:PURCHASED]->(recommended)
WHERE NOT (user)-[:PURCHASED]->(recommended)
RETURN recommended, COUNT(*) as score
ORDER BY score DESC
LIMIT 10
```
```

## Database Selection Guide

```markdown
## Technology Selection Matrix

| Requirement | PostgreSQL | MySQL | MongoDB | Cassandra | Redis |
|-------------|------------|-------|---------|-----------|-------|
| ACID Transactions | ✓✓✓ | ✓✓ | ✓ | ✓ | ✓ |
| Complex Queries | ✓✓✓ | ✓✓ | ✓ | ✗ | ✗ |
| JSON Support | ✓✓✓ | ✓✓ | ✓✓✓ | ✓ | ✓✓ |
| Horizontal Scale | ✓ | ✓ | ✓✓ | ✓✓✓ | ✓✓ |
| Write Throughput | ✓✓ | ✓✓ | ✓✓ | ✓✓✓ | ✓✓✓ |
| Read Latency | ✓✓ | ✓✓ | ✓✓ | ✓✓ | ✓✓✓ |
| Full-Text Search | ✓✓ | ✓ | ✓✓ | ✗ | ✗ |
| Geospatial | ✓✓✓ | ✓✓ | ✓✓ | ✗ | ✓ |

### When to Use What

**PostgreSQL:**
- Complex queries and reporting
- Strong consistency requirements
- JSONB for flexible schemas
- Geospatial data (PostGIS)

**MySQL:**
- High-volume OLTP
- Web applications
- Broad hosting support

**MongoDB:**
- Flexible schemas
- Document-oriented data
- Rapid prototyping
- Horizontal scaling needs

**Cassandra:**
- Time-series data
- Write-heavy workloads
- Multi-datacenter replication
- Extreme scale requirements

**Redis:**
- Caching
- Session storage
- Real-time leaderboards
- Pub/sub messaging
- Rate limiting

**Graph Databases (Neo4j):**
- Social networks
- Recommendation engines
- Fraud detection
- Knowledge graphs
```

## Best Practices

1. **Design for queries** - Model data based on access patterns
2. **Index strategically** - Don't over-index, monitor usage
3. **Normalize first** - Denormalize only when necessary
4. **Use constraints** - Let the database enforce integrity
5. **Plan for growth** - Design with scaling in mind
6. **Monitor continuously** - Track query performance
7. **Test migrations** - Always test on staging first
8. **Backup regularly** - Test your restore process
9. **Document decisions** - Record why choices were made
10. **Review regularly** - Reassess as requirements evolve

## Notes

- This guide covers patterns applicable to most database systems
- Adapt recommendations based on specific database capabilities
- Performance characteristics vary by database version and configuration
- Always benchmark with production-like data volumes
- Consult database-specific documentation for detailed tuning
