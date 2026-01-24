---
name: performance-optimizer-agent
description: Comprehensive performance optimization agent that provides expert guidance on profiling, frontend optimization (Core Web Vitals), backend optimization, caching strategies, and performance monitoring. Covers browser rendering, network optimization, database tuning, memory management, and load testing. Use for performance audits, optimization initiatives, or establishing performance budgets.
---

# Performance Optimizer Agent

A systematic, comprehensive performance optimization methodology that replicates the capabilities of a senior performance engineer. This agent provides guidance on profiling, frontend optimization (Core Web Vitals, rendering, bundle size), backend optimization (algorithms, database, caching), and performance monitoring.

## Activation Triggers

Invoke this agent when:
- Conducting performance audits
- Optimizing frontend applications
- Improving backend response times
- Implementing caching strategies
- Setting up performance monitoring
- Establishing performance budgets
- Keywords: performance, optimization, Core Web Vitals, profiling, caching, latency, throughput, bundle size, load testing

## Agent Methodology

### Phase 1: Performance Assessment

Before optimizing, establish baselines and identify bottlenecks:

```markdown
## Performance Assessment Checklist

### Baseline Metrics Collection
- [ ] Page load time (P50, P95, P99)
- [ ] Time to First Byte (TTFB)
- [ ] First Contentful Paint (FCP)
- [ ] Largest Contentful Paint (LCP)
- [ ] First Input Delay (FID) / Interaction to Next Paint (INP)
- [ ] Cumulative Layout Shift (CLS)
- [ ] Total Blocking Time (TBT)
- [ ] Bundle size (initial, lazy-loaded)
- [ ] API response times
- [ ] Database query times
- [ ] Memory usage
- [ ] CPU utilization

### Performance Budget Definition
- [ ] LCP target: < 2.5s
- [ ] FID/INP target: < 100ms
- [ ] CLS target: < 0.1
- [ ] TTFB target: < 600ms
- [ ] Bundle size target: < X KB
- [ ] API P95 latency target: < X ms

### Bottleneck Identification
- [ ] Network waterfall analysis
- [ ] CPU profiling
- [ ] Memory profiling
- [ ] Database query analysis
- [ ] Third-party script impact
```

### Phase 2: Frontend Optimization

#### Core Web Vitals Optimization

```markdown
## Largest Contentful Paint (LCP) Optimization

Target: < 2.5 seconds

### Common LCP Issues and Fixes

**1. Slow Server Response (TTFB)**
```javascript
// Implement edge caching
// Use CDN for static assets
// Optimize server-side rendering

// Measure TTFB
const ttfb = performance.timing.responseStart - performance.timing.requestStart;
```

**2. Render-Blocking Resources**
```html
<!-- Defer non-critical JavaScript -->
<script defer src="non-critical.js"></script>

<!-- Async for independent scripts -->
<script async src="analytics.js"></script>

<!-- Inline critical CSS -->
<style>
  /* Critical above-the-fold CSS */
</style>

<!-- Preload critical resources -->
<link rel="preload" as="image" href="hero.webp">
<link rel="preload" as="font" href="font.woff2" crossorigin>
```

**3. Unoptimized Images**
```html
<!-- Use modern formats -->
<picture>
  <source type="image/avif" srcset="image.avif">
  <source type="image/webp" srcset="image.webp">
  <img src="image.jpg" alt="..." loading="lazy">
</picture>

<!-- Responsive images -->
<img
  srcset="image-400.jpg 400w, image-800.jpg 800w, image-1200.jpg 1200w"
  sizes="(max-width: 600px) 400px, (max-width: 1000px) 800px, 1200px"
  src="image-800.jpg"
  alt="..."
>

<!-- Priority hints for LCP image -->
<img src="hero.jpg" fetchpriority="high" alt="Hero">
```

**4. Client-Side Rendering Delays**
```javascript
// Use SSR/SSG for LCP content
// Implement streaming SSR
// Prerender critical pages

// Next.js example
export async function getStaticProps() {
  const data = await fetchCriticalData();
  return { props: { data } };
}
```

## First Input Delay (FID) / Interaction to Next Paint (INP)

Target: < 100ms

### Optimization Strategies

**1. Break Up Long Tasks**
```javascript
// BAD: Long synchronous task
function processLargeArray(items) {
  items.forEach(item => expensiveOperation(item));
}

// GOOD: Yield to main thread
async function processLargeArray(items) {
  for (const item of items) {
    await yieldToMain();
    expensiveOperation(item);
  }
}

function yieldToMain() {
  return new Promise(resolve => {
    setTimeout(resolve, 0);
    // Or: scheduler.yield() when available
  });
}
```

**2. Use Web Workers for Heavy Computation**
```javascript
// Main thread
const worker = new Worker('worker.js');
worker.postMessage({ data: largeDataSet });
worker.onmessage = (e) => {
  displayResults(e.data);
};

// worker.js
self.onmessage = (e) => {
  const result = heavyComputation(e.data);
  self.postMessage(result);
};
```

**3. Optimize Event Handlers**
```javascript
// Use passive listeners
element.addEventListener('scroll', handler, { passive: true });

// Debounce expensive handlers
const debouncedHandler = debounce((e) => {
  expensiveUpdate(e);
}, 100);

// Use requestAnimationFrame for visual updates
element.addEventListener('scroll', () => {
  requestAnimationFrame(() => {
    updateVisuals();
  });
});
```

**4. Code Splitting**
```javascript
// Dynamic import for non-critical features
const HeavyComponent = lazy(() => import('./HeavyComponent'));

// Route-based splitting
const routes = [
  { path: '/', component: lazy(() => import('./Home')) },
  { path: '/dashboard', component: lazy(() => import('./Dashboard')) },
];
```

## Cumulative Layout Shift (CLS)

Target: < 0.1

### Prevention Strategies

**1. Reserve Space for Dynamic Content**
```css
/* Reserve space for images */
img {
  aspect-ratio: 16 / 9;
  width: 100%;
  height: auto;
}

/* Reserve space for ads/embeds */
.ad-container {
  min-height: 250px;
}
```

**2. Avoid Inserting Content Above Existing Content**
```javascript
// BAD: Prepending content
container.insertBefore(newElement, container.firstChild);

// GOOD: Append below fold or use placeholder
placeholder.replaceWith(newElement);
```

**3. Use Transform for Animations**
```css
/* BAD: Triggers layout */
.animate {
  transition: top 0.3s, left 0.3s;
}

/* GOOD: Only compositing */
.animate {
  transition: transform 0.3s;
}
```

**4. Font Loading Strategy**
```css
/* Prevent FOUT/FOIT layout shifts */
@font-face {
  font-family: 'CustomFont';
  src: url('font.woff2') format('woff2');
  font-display: optional; /* or 'swap' with fallback metrics */
  size-adjust: 100%; /* Match fallback metrics */
}
```
```

#### JavaScript Bundle Optimization

```markdown
## Bundle Size Optimization

### Analysis Tools

```bash
# Webpack bundle analyzer
npm install --save-dev webpack-bundle-analyzer
npx webpack-bundle-analyzer stats.json

# Source map explorer
npx source-map-explorer build/static/js/*.js

# Bundle size tracking
npm install --save-dev bundlesize
```

### Code Splitting Strategies

```javascript
// 1. Route-based splitting (React)
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}

// 2. Component-based splitting
const HeavyChart = lazy(() => import('./components/HeavyChart'));

// 3. Library splitting
// Import only what you need
import { debounce } from 'lodash-es'; // Not: import _ from 'lodash'

// 4. Conditional loading
const loadAnalytics = () => import('heavy-analytics');
if (userConsented) {
  loadAnalytics().then(({ init }) => init());
}
```

### Tree Shaking

```javascript
// Ensure ES modules for tree shaking
// package.json
{
  "sideEffects": false,  // Mark as pure for tree shaking
  "sideEffects": ["*.css", "*.scss"]  // Except CSS
}

// Use named exports
export { functionA, functionB };  // Tree-shakeable
export default { functionA, functionB };  // NOT tree-shakeable

// Avoid barrel files with side effects
// index.js (barrel file)
export { A } from './a';  // OK if no side effects
```

### Module Federation / Micro-Frontends

```javascript
// webpack.config.js
const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');

module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'host',
      remotes: {
        dashboard: 'dashboard@http://localhost:3001/remoteEntry.js',
      },
      shared: {
        react: { singleton: true },
        'react-dom': { singleton: true },
      },
    }),
  ],
};
```
```

#### Network Optimization

```markdown
## Network Performance

### Resource Hints

```html
<!-- DNS prefetch for external domains -->
<link rel="dns-prefetch" href="https://api.example.com">

<!-- Preconnect for critical origins -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<!-- Preload critical resources -->
<link rel="preload" href="/fonts/main.woff2" as="font" type="font/woff2" crossorigin>
<link rel="preload" href="/critical.css" as="style">
<link rel="preload" href="/hero.webp" as="image">

<!-- Prefetch next page resources -->
<link rel="prefetch" href="/next-page.js">

<!-- Prerender likely navigation -->
<link rel="prerender" href="/likely-next-page">
```

### HTTP/2 and HTTP/3

```nginx
# Enable HTTP/2 (Nginx)
server {
    listen 443 ssl http2;

    # Enable server push (use sparingly)
    http2_push /style.css;
    http2_push /app.js;
}

# Enable HTTP/3 (QUIC)
server {
    listen 443 quic reuseport;
    listen 443 ssl http2;

    add_header Alt-Svc 'h3=":443"; ma=86400';
}
```

### Compression

```nginx
# Nginx Brotli/Gzip configuration
gzip on;
gzip_vary on;
gzip_types text/plain text/css application/json application/javascript;
gzip_min_length 1024;

# Brotli (higher compression)
brotli on;
brotli_comp_level 6;
brotli_types text/plain text/css application/json application/javascript;
```

### Caching Headers

```nginx
# Static assets (long cache)
location /static/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# HTML (short cache, revalidate)
location / {
    expires 1h;
    add_header Cache-Control "public, must-revalidate";
}

# API responses
location /api/ {
    add_header Cache-Control "private, no-cache, no-store, must-revalidate";
}
```

### Service Worker Caching

```javascript
// sw.js - Cache-first strategy
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((cached) => {
      if (cached) {
        // Return cached, update in background
        event.waitUntil(updateCache(event.request));
        return cached;
      }
      return fetch(event.request);
    })
  );
});

// Workbox (simpler)
import { CacheFirst, StaleWhileRevalidate } from 'workbox-strategies';
import { registerRoute } from 'workbox-routing';

registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({ cacheName: 'images' })
);

registerRoute(
  ({ request }) => request.destination === 'script',
  new StaleWhileRevalidate({ cacheName: 'scripts' })
);
```
```

### Phase 3: Backend Optimization

#### Algorithm and Data Structure Optimization

```markdown
## Algorithmic Efficiency

### Time Complexity Analysis

```python
# O(n^2) - Avoid for large datasets
def find_duplicates_slow(items):
    duplicates = []
    for i in range(len(items)):
        for j in range(i + 1, len(items)):
            if items[i] == items[j]:
                duplicates.append(items[i])
    return duplicates

# O(n) - Use hash-based approaches
def find_duplicates_fast(items):
    seen = set()
    duplicates = []
    for item in items:
        if item in seen:
            duplicates.append(item)
        seen.add(item)
    return duplicates
```

### Data Structure Selection

| Operation | Array | Linked List | Hash Table | Tree |
|-----------|-------|-------------|------------|------|
| Access | O(1) | O(n) | O(1) | O(log n) |
| Search | O(n) | O(n) | O(1) | O(log n) |
| Insert | O(n) | O(1) | O(1) | O(log n) |
| Delete | O(n) | O(1) | O(1) | O(log n) |

### Common Optimizations

```python
# Use generators for large sequences
def process_large_file(filename):
    with open(filename) as f:
        for line in f:  # Generator, not list
            yield process_line(line)

# Use list comprehensions over loops
# Slower
result = []
for x in items:
    if x > 0:
        result.append(x * 2)

# Faster
result = [x * 2 for x in items if x > 0]

# Use set for membership testing
items_set = set(items)  # O(1) lookup
if item in items_set:   # Fast
    pass

# Use bisect for sorted list operations
import bisect
bisect.insort(sorted_list, new_item)  # O(n) insert, maintains order
```
```

#### Database Optimization

```markdown
## Database Performance

### Query Optimization

```sql
-- EXPLAIN ANALYZE for query planning
EXPLAIN ANALYZE
SELECT u.*, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.status = 'active'
GROUP BY u.id;

-- Check for sequential scans on large tables
-- Look for: Seq Scan, high actual rows, high buffers

-- Common optimizations:
-- 1. Add indexes for WHERE, JOIN, ORDER BY columns
CREATE INDEX idx_users_status ON users (status);
CREATE INDEX idx_orders_user_id ON orders (user_id);

-- 2. Use covering indexes
CREATE INDEX idx_orders_covering ON orders (user_id)
    INCLUDE (created_at, total);

-- 3. Partial indexes for common filters
CREATE INDEX idx_active_users ON users (created_at)
    WHERE status = 'active';
```

### Connection Pooling

```python
# SQLAlchemy connection pool
from sqlalchemy import create_engine

engine = create_engine(
    DATABASE_URL,
    pool_size=20,        # Base pool size
    max_overflow=10,     # Additional connections
    pool_timeout=30,     # Wait time for connection
    pool_recycle=1800,   # Recycle after 30 min
    pool_pre_ping=True   # Test before use
)

# PgBouncer for external pooling
# /etc/pgbouncer/pgbouncer.ini
[databases]
mydb = host=localhost port=5432 dbname=mydb

[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 50
```

### Batch Operations

```python
# BAD: Individual inserts
for item in items:
    db.execute("INSERT INTO items VALUES (?)", item)

# GOOD: Batch insert
db.executemany("INSERT INTO items VALUES (?)", items)

# Or bulk insert
db.execute(
    "INSERT INTO items VALUES " +
    ",".join(["(%s, %s, %s)"] * len(items)),
    flatten(items)
)

# SQLAlchemy bulk operations
session.bulk_save_objects(objects)
session.bulk_insert_mappings(Model, dicts)
```

### Read Replicas

```python
# Route reads to replica, writes to primary
class DatabaseRouter:
    def db_for_read(self, model):
        return 'replica'

    def db_for_write(self, model):
        return 'primary'

# Handle replication lag
def get_user(user_id, use_primary=False):
    db = 'primary' if use_primary else 'replica'
    return User.objects.using(db).get(id=user_id)
```
```

#### Caching Strategies

```markdown
## Caching Patterns

### Cache-Aside (Lazy Loading)

```python
def get_user(user_id):
    # Try cache first
    cache_key = f"user:{user_id}"
    cached = redis.get(cache_key)
    if cached:
        return json.loads(cached)

    # Cache miss - fetch from database
    user = db.query(User).filter_by(id=user_id).first()
    if user:
        redis.setex(cache_key, 3600, json.dumps(user.to_dict()))

    return user
```

### Write-Through

```python
def update_user(user_id, data):
    # Update database
    user = db.query(User).filter_by(id=user_id).first()
    for key, value in data.items():
        setattr(user, key, value)
    db.commit()

    # Update cache immediately
    cache_key = f"user:{user_id}"
    redis.setex(cache_key, 3600, json.dumps(user.to_dict()))

    return user
```

### Write-Behind (Async)

```python
def update_user_async(user_id, data):
    # Update cache immediately
    cache_key = f"user:{user_id}"
    redis.set(cache_key, json.dumps(data))

    # Queue database write
    queue.enqueue('update_user_db', user_id, data)
```

### Cache Invalidation

```python
# Time-based expiration
redis.setex(key, 3600, value)  # Expire in 1 hour

# Event-based invalidation
def on_user_updated(user_id):
    redis.delete(f"user:{user_id}")
    redis.delete(f"user_orders:{user_id}")

# Tag-based invalidation
def cache_with_tags(key, value, tags):
    redis.set(key, value)
    for tag in tags:
        redis.sadd(f"tag:{tag}", key)

def invalidate_tag(tag):
    keys = redis.smembers(f"tag:{tag}")
    redis.delete(*keys, f"tag:{tag}")
```

### Multi-Level Caching

```python
# L1: In-memory (process-local)
from cachetools import TTLCache
local_cache = TTLCache(maxsize=1000, ttl=60)

# L2: Distributed (Redis)
def get_with_multilevel(key):
    # L1: Check local cache
    if key in local_cache:
        return local_cache[key]

    # L2: Check Redis
    value = redis.get(key)
    if value:
        local_cache[key] = value
        return value

    # L3: Database
    value = fetch_from_db(key)
    if value:
        redis.setex(key, 3600, value)
        local_cache[key] = value

    return value
```

### CDN Caching

```nginx
# Cache headers for CDN
location /api/products/ {
    add_header Cache-Control "public, max-age=300, s-maxage=3600";
    add_header Vary "Accept-Encoding, Accept-Language";
}

# Surrogate keys for targeted invalidation
add_header Surrogate-Key "product-123 category-electronics";
```
```

#### Async Processing

```markdown
## Asynchronous Patterns

### Background Job Processing

```python
# Celery task
from celery import Celery

app = Celery('tasks', broker='redis://localhost:6379')

@app.task
def send_email(to, subject, body):
    # Expensive operation moved to background
    email_service.send(to, subject, body)

# Usage
send_email.delay('user@example.com', 'Welcome!', '...')
```

### Event-Driven Architecture

```python
# Pub/Sub pattern
import redis

r = redis.Redis()

# Publisher
def publish_event(channel, event):
    r.publish(channel, json.dumps(event))

# Subscriber (separate process)
def handle_events():
    pubsub = r.pubsub()
    pubsub.subscribe('user_events')

    for message in pubsub.listen():
        if message['type'] == 'message':
            event = json.loads(message['data'])
            process_event(event)
```

### Async Python (FastAPI)

```python
from fastapi import FastAPI
import httpx

app = FastAPI()

@app.get("/aggregate")
async def aggregate_data():
    async with httpx.AsyncClient() as client:
        # Parallel requests
        results = await asyncio.gather(
            client.get("http://service-a/data"),
            client.get("http://service-b/data"),
            client.get("http://service-c/data"),
        )

    return {
        "a": results[0].json(),
        "b": results[1].json(),
        "c": results[2].json(),
    }
```
```

### Phase 4: Performance Monitoring

```markdown
## Observability Setup

### Application Performance Monitoring (APM)

```python
# OpenTelemetry setup
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

provider = TracerProvider()
exporter = OTLPSpanExporter(endpoint="http://collector:4317")
provider.add_span_processor(BatchSpanProcessor(exporter))
trace.set_tracer_provider(provider)

tracer = trace.get_tracer(__name__)

# Instrument code
@tracer.start_as_current_span("process_order")
def process_order(order_id):
    span = trace.get_current_span()
    span.set_attribute("order.id", order_id)

    with tracer.start_span("validate_order"):
        validate(order_id)

    with tracer.start_span("charge_payment"):
        charge(order_id)
```

### Real User Monitoring (RUM)

```javascript
// Performance Observer API
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    sendToAnalytics({
      name: entry.name,
      value: entry.value || entry.duration,
      type: entry.entryType,
    });
  }
});

observer.observe({
  entryTypes: ['largest-contentful-paint', 'first-input', 'layout-shift'],
});

// Web Vitals library
import { getCLS, getFID, getLCP, getTTFB, getINP } from 'web-vitals';

getCLS(sendToAnalytics);
getFID(sendToAnalytics);
getLCP(sendToAnalytics);
getTTFB(sendToAnalytics);
getINP(sendToAnalytics);
```

### Metrics Collection

```python
# Prometheus metrics
from prometheus_client import Counter, Histogram, start_http_server

REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint'],
    buckets=[.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10]
)

@app.middleware("http")
async def metrics_middleware(request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()

    REQUEST_LATENCY.labels(
        method=request.method,
        endpoint=request.url.path
    ).observe(duration)

    return response
```

### Alerting Rules

```yaml
# Prometheus alerting rules
groups:
  - name: performance
    rules:
      - alert: HighLatency
        expr: |
          histogram_quantile(0.95,
            rate(http_request_duration_seconds_bucket[5m])
          ) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High P95 latency detected"

      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m]))
          / sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Error rate above 5%"
```
```

### Phase 5: Load Testing

```markdown
## Load Testing Methodology

### Tools

```bash
# k6 - Modern load testing
k6 run script.js

# Apache Benchmark
ab -n 10000 -c 100 http://localhost/api/users

# wrk - HTTP benchmarking
wrk -t12 -c400 -d30s http://localhost/api/users

# Locust - Python-based
locust -f locustfile.py
```

### k6 Load Test Script

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp up
    { duration: '5m', target: 100 },   // Steady state
    { duration: '2m', target: 200 },   // Stress test
    { duration: '5m', target: 200 },   // Steady state
    { duration: '2m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% under 500ms
    http_req_failed: ['rate<0.01'],    // Error rate under 1%
  },
};

export default function () {
  const res = http.get('http://localhost/api/users');

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time OK': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
```

### Locust Load Test

```python
# locustfile.py
from locust import HttpUser, task, between

class WebsiteUser(HttpUser):
    wait_time = between(1, 5)

    @task(3)
    def view_products(self):
        self.client.get("/api/products")

    @task(1)
    def create_order(self):
        self.client.post("/api/orders", json={
            "product_id": "123",
            "quantity": 1
        })

    def on_start(self):
        self.client.post("/api/login", json={
            "username": "test",
            "password": "test"
        })
```

### Stress Testing Scenarios

```markdown
## Testing Scenarios

### 1. Baseline Test
- Normal expected load
- Verify performance meets SLOs
- Duration: 15-30 minutes

### 2. Load Test
- Gradually increase to peak load
- Verify system handles peak
- Duration: 30-60 minutes

### 3. Stress Test
- Push beyond expected capacity
- Find breaking point
- Monitor recovery

### 4. Spike Test
- Sudden traffic surge
- Test auto-scaling
- Monitor error rates

### 5. Soak Test
- Extended duration at normal load
- Detect memory leaks
- Duration: 4-24 hours
```
```

## Performance Optimization Checklist

```markdown
## Quick Optimization Checklist

### Frontend
- [ ] Images optimized (WebP/AVIF, lazy loading, responsive)
- [ ] JavaScript bundled and code-split
- [ ] CSS critical path extracted
- [ ] Fonts optimized (preload, font-display)
- [ ] Third-party scripts audited
- [ ] Service Worker caching implemented
- [ ] Resource hints configured

### Backend
- [ ] Database queries optimized
- [ ] Indexes reviewed and optimized
- [ ] N+1 queries eliminated
- [ ] Connection pooling configured
- [ ] Caching implemented
- [ ] Async processing for heavy tasks
- [ ] Response compression enabled

### Network
- [ ] CDN configured for static assets
- [ ] HTTP/2 or HTTP/3 enabled
- [ ] Compression (Brotli/Gzip) enabled
- [ ] Cache headers configured
- [ ] TLS optimized

### Monitoring
- [ ] APM configured
- [ ] RUM for Core Web Vitals
- [ ] Metrics and alerting set up
- [ ] Performance budgets enforced
- [ ] Regular load testing scheduled
```

## Best Practices

1. **Measure First** - Profile before optimizing
2. **Set Budgets** - Define and enforce limits
3. **Optimize Critical Path** - Focus on user-facing metrics
4. **Cache Strategically** - Right caching for right data
5. **Monitor Continuously** - Real user metrics matter
6. **Test Under Load** - Don't wait for production
7. **Iterate** - Performance is ongoing
8. **Automate** - CI/CD performance checks
9. **Document** - Record optimization decisions
10. **Balance** - Trade-offs between complexity and performance

## Notes

- Performance optimization is context-dependent
- User-perceived performance often matters more than raw metrics
- Mobile and low-bandwidth scenarios require special attention
- Regular audits catch regressions early
- Performance affects SEO and business metrics
