---
name: documentation
description: Technical documentation best practices for READMEs, API docs, inline comments, architecture diagrams, and user guides. Use when creating or improving documentation, writing API references, or establishing documentation standards.
---

# Documentation Skill

## Triggers

Use this skill when you see:
- docs, documentation, readme
- api docs, reference, guide
- comments, docstrings, JSDoc
- diagram, architecture doc

## Instructions

### Documentation Types

| Type | Purpose | Audience |
|------|---------|----------|
| README | Project overview, quick start | New users |
| API Reference | Endpoint/function details | Developers |
| Tutorials | Step-by-step learning | Beginners |
| How-To Guides | Task-oriented instructions | Users with goals |
| Architecture | System design, decisions | Contributors |
| Changelog | Version history | Users, developers |

### README Template

```markdown
# Project Name

Brief description of what this project does and why it exists.

## Features

- Feature 1: Brief description
- Feature 2: Brief description
- Feature 3: Brief description

## Quick Start

### Prerequisites

- Node.js >= 18
- PostgreSQL 15+

### Installation

```bash
# Clone the repository
git clone https://github.com/org/project.git
cd project

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Run migrations
npm run db:migrate

# Start the application
npm run dev
```

## Usage

Basic usage example:

```javascript
import { Client } from 'project';

const client = new Client({ apiKey: 'your-key' });
const result = await client.doSomething();
```

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `API_KEY` | Your API key | Required |
| `DEBUG` | Enable debug mode | `false` |

## Documentation

- [API Reference](./docs/api.md)
- [Configuration Guide](./docs/configuration.md)
- [Contributing](./CONTRIBUTING.md)

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](./LICENSE) for details.
```

### API Documentation Template

```markdown
# API Reference

## Authentication

All API requests require authentication via Bearer token:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" https://api.example.com/v1/resource
```

## Endpoints

### Users

#### Get User

Retrieves a user by ID.

```
GET /v1/users/{id}
```

**Parameters**

| Name | Type | In | Description |
|------|------|-----|-------------|
| `id` | string | path | User ID (required) |
| `include` | string | query | Related data to include |

**Response**

```json
{
  "id": "user_123",
  "email": "user@example.com",
  "name": "John Doe",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Status Codes**

| Code | Description |
|------|-------------|
| 200 | Success |
| 404 | User not found |
| 401 | Unauthorized |

**Example**

```bash
curl https://api.example.com/v1/users/user_123 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Create User

Creates a new user.

```
POST /v1/users
```

**Request Body**

```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "role": "member"
}
```

**Response**

```json
{
  "id": "user_456",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "member",
  "created_at": "2024-01-15T10:30:00Z"
}
```

## Error Handling

All errors return a consistent format:

```json
{
  "error": {
    "code": "invalid_request",
    "message": "Email is required",
    "details": {
      "field": "email"
    }
  }
}
```

## Rate Limiting

- 100 requests per minute per API key
- Headers include: `X-RateLimit-Limit`, `X-RateLimit-Remaining`
```

### Code Comments

#### Python Docstrings

```python
def process_payment(
    amount: Decimal,
    currency: str,
    customer_id: str,
    idempotency_key: str | None = None,
) -> PaymentResult:
    """Process a payment for a customer.

    Charges the customer's default payment method. If the payment fails,
    raises a PaymentError with details about the failure.

    Args:
        amount: Payment amount in smallest currency unit (e.g., cents).
        currency: ISO 4217 currency code (e.g., "USD").
        customer_id: Unique identifier for the customer.
        idempotency_key: Optional key to prevent duplicate charges.

    Returns:
        PaymentResult containing transaction ID and status.

    Raises:
        PaymentError: If the payment fails or is declined.
        ValidationError: If the input parameters are invalid.

    Example:
        >>> result = process_payment(
        ...     amount=Decimal("1999"),
        ...     currency="USD",
        ...     customer_id="cus_123"
        ... )
        >>> print(result.transaction_id)
        'txn_abc123'
    """
```

#### TypeScript/JSDoc

```typescript
/**
 * Processes a payment for a customer.
 *
 * Charges the customer's default payment method. If the payment fails,
 * throws a PaymentError with details about the failure.
 *
 * @param options - Payment options
 * @param options.amount - Payment amount in smallest currency unit (e.g., cents)
 * @param options.currency - ISO 4217 currency code (e.g., "USD")
 * @param options.customerId - Unique identifier for the customer
 * @param options.idempotencyKey - Optional key to prevent duplicate charges
 * @returns Promise resolving to PaymentResult with transaction ID and status
 * @throws {PaymentError} If the payment fails or is declined
 * @throws {ValidationError} If the input parameters are invalid
 *
 * @example
 * const result = await processPayment({
 *   amount: 1999,
 *   currency: 'USD',
 *   customerId: 'cus_123'
 * });
 * console.log(result.transactionId); // 'txn_abc123'
 */
async function processPayment(options: PaymentOptions): Promise<PaymentResult> {
```

#### Inline Comments

**Good Comments:**
```python
# Use binary search since items are sorted by timestamp
index = bisect_left(events, target_time, key=lambda e: e.timestamp)

# HACK: API returns dates in local time without timezone info.
# Assume UTC until they fix it (see issue #123).
timestamp = datetime.fromisoformat(raw_date).replace(tzinfo=timezone.utc)

# NOTE: This must happen before the database transaction commits,
# otherwise webhooks may fire with stale data.
cache.invalidate(user_id)
```

**Bad Comments:**
```python
# Increment counter by 1
counter += 1  # Obvious from code

# Loop through items
for item in items:  # Adds no information

# TODO: Fix this later  # What needs fixing? When?
```

### Architecture Documentation

```markdown
# Architecture Overview

## System Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│   API GW    │────▶│  Services   │
│   (React)   │     │  (Kong)     │     │  (K8s)      │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                    ┌─────────────┐     ┌──────▼──────┐
                    │   Cache     │◀────│  Database   │
                    │  (Redis)    │     │ (Postgres)  │
                    └─────────────┘     └─────────────┘
```

## Components

### API Gateway
- **Technology**: Kong
- **Purpose**: Rate limiting, auth, routing
- **Scaling**: 3 replicas minimum

### Services Layer
- **Technology**: Python/FastAPI
- **Deployment**: Kubernetes
- **Communication**: REST + gRPC internal

## Data Flow

1. Client makes request to API Gateway
2. Gateway validates JWT, applies rate limits
3. Request routed to appropriate service
4. Service checks Redis cache
5. On cache miss, queries PostgreSQL
6. Response cached and returned

## Key Decisions

### Decision: PostgreSQL over MongoDB
**Date**: 2024-01-15
**Context**: Need reliable transactions for payments
**Decision**: Use PostgreSQL for ACID compliance
**Consequences**: More complex queries, but data integrity guaranteed

### Decision: Event-Driven Architecture
**Date**: 2024-02-01
**Context**: Services need loose coupling
**Decision**: Use RabbitMQ for async communication
**Consequences**: Added complexity, but better scalability
```

### Writing Guidelines

1. **Know Your Audience**: Technical level varies
2. **Be Concise**: Say more with less
3. **Use Examples**: Show, don't just tell
4. **Keep Updated**: Outdated docs are worse than none
5. **Structure Consistently**: Predictable format aids scanning
6. **Test Instructions**: Follow your own guides
7. **Link Related Content**: Help readers navigate
8. **Use Visuals**: Diagrams for complex concepts

### Tools for Documentation

- **Markdown**: Universal, version-controlled
- **Mermaid**: Diagrams as code
- **OpenAPI/Swagger**: API specification
- **Docusaurus**: Documentation sites
- **Storybook**: Component documentation
- **JSDoc/Sphinx**: Auto-generated API docs

### Documentation Review Checklist

- [ ] Accurate and up-to-date
- [ ] Clear and concise
- [ ] Proper formatting and structure
- [ ] Code examples work
- [ ] Links are valid
- [ ] Spelling and grammar checked
- [ ] Covers edge cases and errors
- [ ] Accessible to target audience
