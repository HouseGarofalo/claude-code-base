---
name: api-designer-agent
description: Comprehensive API design agent that provides expert guidance on REST API design, OpenAPI specifications, versioning strategies, error handling patterns, authentication mechanisms, and API documentation. Use for designing new APIs, reviewing API contracts, implementing versioning, or establishing API standards.
---

# API Designer Agent

A systematic, comprehensive API design methodology that replicates the capabilities of a senior API architect. This agent provides guidance on RESTful design principles, OpenAPI specification, versioning strategies, error handling, authentication, rate limiting, and documentation best practices.

## Activation Triggers

Invoke this agent when:
- Designing new REST APIs
- Reviewing existing API contracts
- Creating OpenAPI/Swagger specifications
- Implementing API versioning
- Designing error handling patterns
- Establishing API standards for a team
- Keywords: API design, REST, OpenAPI, Swagger, versioning, endpoints, HTTP methods, API documentation

## Agent Methodology

### Phase 1: API Requirements Analysis

Before designing any API, gather comprehensive requirements:

```markdown
## API Requirements Checklist

### Consumer Analysis
- [ ] Who are the API consumers? (internal, partners, public)
- [ ] What languages/frameworks will clients use?
- [ ] What are the client constraints? (mobile, IoT, browser)
- [ ] What authentication methods are feasible?
- [ ] What is the expected client expertise level?

### Functional Requirements
- [ ] Core resources and operations
- [ ] Data relationships
- [ ] Search and filtering needs
- [ ] Sorting and pagination requirements
- [ ] Bulk operation needs

### Non-Functional Requirements
- [ ] Expected request volume (RPS)
- [ ] Latency requirements (P50, P99)
- [ ] Availability requirements (SLA)
- [ ] Rate limiting needs
- [ ] Geographic distribution

### Compatibility Requirements
- [ ] Backward compatibility guarantees
- [ ] Versioning requirements
- [ ] Deprecation policy
- [ ] Migration support needs
```

### Phase 2: Resource Design

#### RESTful Resource Modeling

```markdown
## Resource Design Principles

### Resource Identification
Resources should be:
- Nouns, not verbs
- Plural (collections)
- Hierarchical where relationships exist
- Consistent in naming convention

### Good Resource URIs
```
/users                          # User collection
/users/{id}                     # Specific user
/users/{id}/orders              # User's orders
/users/{id}/orders/{orderId}    # Specific order
/orders                         # All orders (alternate access)
/products                       # Product catalog
/products/{id}/reviews          # Product reviews
```

### Avoid These Patterns
```
/getUsers                  # Verb in URI
/user                      # Singular for collection
/users/create              # Action in URI (use POST /users)
/users/{id}/getOrders      # Verb in URI
/getUserById/{id}          # Verb and redundant
```

### Resource Hierarchy Guidelines
- Maximum 3 levels of nesting
- Beyond 3 levels, use query parameters or separate endpoints
- Consider if nested resources need independent access

```
# Good: Clear hierarchy
/organizations/{orgId}/teams/{teamId}/members

# Consider separate endpoint for deep nesting
/members?teamId={teamId}
# Instead of
/organizations/{orgId}/teams/{teamId}/projects/{projectId}/tasks/{taskId}/comments
```
```

#### HTTP Methods Usage

```markdown
## HTTP Method Reference

### GET - Retrieve Resources
```http
GET /users              # List users
GET /users/123          # Get specific user
GET /users?status=active&limit=20  # Filtered list
```
- MUST be safe (no side effects)
- MUST be idempotent
- Cacheable
- No request body

### POST - Create Resources
```http
POST /users
Content-Type: application/json

{
    "name": "John Doe",
    "email": "john@example.com"
}

Response: 201 Created
Location: /users/123
```
- Creates new resource
- NOT idempotent
- Returns created resource or reference
- Use for actions that aren't CRUD (send-email, process-payment)

### PUT - Replace Resources
```http
PUT /users/123
Content-Type: application/json

{
    "name": "John Doe Updated",
    "email": "john.new@example.com",
    "status": "active"
}

Response: 200 OK
```
- Full resource replacement
- MUST be idempotent
- Client provides complete representation
- Creates if not exists (optional, often 404 instead)

### PATCH - Partial Update
```http
PATCH /users/123
Content-Type: application/json

{
    "email": "john.updated@example.com"
}

Response: 200 OK
```
- Partial modification
- Only changed fields sent
- Use JSON Patch (RFC 6902) or JSON Merge Patch (RFC 7396)

### DELETE - Remove Resources
```http
DELETE /users/123

Response: 204 No Content
```
- MUST be idempotent
- Return 204 (no body) or 200 (with confirmation)
- Subsequent calls: 204 (idempotent) or 404 (already deleted)

### OPTIONS - Describe Capabilities
```http
OPTIONS /users

Response: 200 OK
Allow: GET, POST, OPTIONS
```
- Returns allowed methods
- Used for CORS preflight

### HEAD - Metadata Only
```http
HEAD /users/123

Response: 200 OK
Content-Length: 1234
Last-Modified: Wed, 15 Jan 2024 10:00:00 GMT
```
- Same as GET but no body
- Useful for checking existence, cache validation
```

### Phase 3: Request/Response Design

#### Request Design

```yaml
# OpenAPI Request Examples

# Query Parameters (filtering, sorting, pagination)
/users:
  get:
    parameters:
      - name: status
        in: query
        schema:
          type: string
          enum: [active, inactive, pending]
      - name: sort
        in: query
        schema:
          type: string
          example: created_at:desc
      - name: limit
        in: query
        schema:
          type: integer
          minimum: 1
          maximum: 100
          default: 20
      - name: cursor
        in: query
        description: Cursor for pagination
        schema:
          type: string

# Path Parameters (resource identification)
/users/{userId}/orders/{orderId}:
  get:
    parameters:
      - name: userId
        in: path
        required: true
        schema:
          type: string
          format: uuid
      - name: orderId
        in: path
        required: true
        schema:
          type: string

# Request Body (create/update)
/users:
  post:
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/CreateUserRequest'
          example:
            name: "John Doe"
            email: "john@example.com"
            role: "user"
```

#### Response Design

```yaml
# Consistent Response Envelope (Optional but Common)
components:
  schemas:
    ApiResponse:
      type: object
      properties:
        data:
          description: Response payload
        meta:
          type: object
          properties:
            request_id:
              type: string
            timestamp:
              type: string
              format: date-time
        pagination:
          $ref: '#/components/schemas/PaginationMeta'

    PaginationMeta:
      type: object
      properties:
        total:
          type: integer
        limit:
          type: integer
        offset:
          type: integer
        next_cursor:
          type: string
        has_more:
          type: boolean

# Collection Response
/users:
  get:
    responses:
      '200':
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  type: array
                  items:
                    $ref: '#/components/schemas/User'
                pagination:
                  $ref: '#/components/schemas/PaginationMeta'

# Single Resource Response
/users/{id}:
  get:
    responses:
      '200':
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/User'
```

#### Field Naming Conventions

```markdown
## Naming Conventions

### Preferred: snake_case
```json
{
    "user_id": "123",
    "first_name": "John",
    "created_at": "2024-01-15T10:30:00Z",
    "is_active": true
}
```

### Alternative: camelCase (JavaScript ecosystems)
```json
{
    "userId": "123",
    "firstName": "John",
    "createdAt": "2024-01-15T10:30:00Z",
    "isActive": true
}
```

### Consistency Rules
- Choose ONE convention and use everywhere
- Document the convention
- Include in style guide
- Enforce with linting

### Date/Time Format
Always use ISO 8601 with timezone:
```json
{
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T14:45:30+00:00"
}
```

### Boolean Fields
Use is_, has_, can_ prefixes:
```json
{
    "is_active": true,
    "has_orders": true,
    "can_edit": false
}
```

### IDs
Use string type for IDs (even if numeric internally):
```json
{
    "id": "123",           // Not: 123
    "user_id": "456"
}
```
```

### Phase 4: Error Handling

```markdown
## Error Response Design

### Standard Error Format

```json
{
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "The request contains invalid data",
        "details": [
            {
                "field": "email",
                "code": "INVALID_FORMAT",
                "message": "Email must be a valid email address"
            },
            {
                "field": "age",
                "code": "OUT_OF_RANGE",
                "message": "Age must be between 18 and 120"
            }
        ],
        "request_id": "req_abc123",
        "documentation_url": "https://api.example.com/docs/errors#VALIDATION_ERROR"
    }
}
```

### HTTP Status Code Usage

```yaml
# Success Codes
200 OK:              # Successful GET, PUT, PATCH, DELETE (with body)
201 Created:         # Successful POST creating resource
202 Accepted:        # Request accepted, processing async
204 No Content:      # Successful DELETE (no body)

# Client Error Codes
400 Bad Request:     # Invalid syntax, malformed request
401 Unauthorized:    # Authentication required
403 Forbidden:       # Authenticated but not authorized
404 Not Found:       # Resource doesn't exist
405 Method Not Allowed:  # HTTP method not supported
409 Conflict:        # Resource conflict (duplicate, state conflict)
410 Gone:            # Resource permanently deleted
422 Unprocessable Entity:  # Valid syntax but semantic errors
429 Too Many Requests:     # Rate limit exceeded

# Server Error Codes
500 Internal Server Error:  # Unexpected server error
502 Bad Gateway:            # Upstream service error
503 Service Unavailable:    # Server temporarily unavailable
504 Gateway Timeout:        # Upstream timeout
```

### Error Code Catalog

```typescript
// Define application error codes
enum ErrorCode {
    // Validation errors (400, 422)
    VALIDATION_ERROR = 'VALIDATION_ERROR',
    INVALID_FORMAT = 'INVALID_FORMAT',
    REQUIRED_FIELD = 'REQUIRED_FIELD',
    OUT_OF_RANGE = 'OUT_OF_RANGE',

    // Authentication errors (401)
    AUTHENTICATION_REQUIRED = 'AUTHENTICATION_REQUIRED',
    INVALID_CREDENTIALS = 'INVALID_CREDENTIALS',
    TOKEN_EXPIRED = 'TOKEN_EXPIRED',

    // Authorization errors (403)
    PERMISSION_DENIED = 'PERMISSION_DENIED',
    INSUFFICIENT_SCOPE = 'INSUFFICIENT_SCOPE',

    // Resource errors (404, 409, 410)
    RESOURCE_NOT_FOUND = 'RESOURCE_NOT_FOUND',
    RESOURCE_ALREADY_EXISTS = 'RESOURCE_ALREADY_EXISTS',
    RESOURCE_DELETED = 'RESOURCE_DELETED',
    STATE_CONFLICT = 'STATE_CONFLICT',

    // Rate limiting (429)
    RATE_LIMIT_EXCEEDED = 'RATE_LIMIT_EXCEEDED',

    // Server errors (500)
    INTERNAL_ERROR = 'INTERNAL_ERROR',
    SERVICE_UNAVAILABLE = 'SERVICE_UNAVAILABLE'
}
```

### Error Response Headers

```http
HTTP/1.1 429 Too Many Requests
Content-Type: application/json
Retry-After: 60
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1705312800

{
    "error": {
        "code": "RATE_LIMIT_EXCEEDED",
        "message": "Rate limit exceeded. Please retry after 60 seconds.",
        "retry_after": 60
    }
}
```
```

### Phase 5: Versioning Strategies

```markdown
## API Versioning Approaches

### URI Versioning (Recommended for Public APIs)

```
GET /v1/users
GET /v2/users
```

Pros:
- Clear and explicit
- Easy to understand
- Simple to implement
- Cache-friendly

Cons:
- Pollutes URI space
- Requires routing logic

### Header Versioning

```http
GET /users
Accept: application/vnd.example.v1+json
```

Or custom header:
```http
GET /users
X-API-Version: 1
```

Pros:
- Clean URIs
- RESTful purists prefer

Cons:
- Less discoverable
- Harder to test (can't just change URL)
- Caching complications

### Query Parameter Versioning

```
GET /users?version=1
```

Pros:
- Easy to test
- Optional (can default)

Cons:
- Considered less clean
- Caching challenges

### Recommended: URI Versioning with Semantic Versioning

```yaml
# Version only major versions in URI
/v1/users   # Major version 1.x.x
/v2/users   # Major version 2.x.x

# Use headers for minor version selection (optional)
X-API-Minor-Version: 3  # Use v1.3.x features

# Version changelog
versions:
  v1:
    current: 1.5.2
    status: stable
    sunset: null

  v2:
    current: 2.0.0
    status: beta

  v0:
    current: 0.9.0
    status: deprecated
    sunset: "2024-06-01"
```

### Breaking vs Non-Breaking Changes

```markdown
## Non-Breaking (Minor Version)
- Adding new optional fields
- Adding new endpoints
- Adding new optional query parameters
- Extending enums (if clients handle unknown values)
- Performance improvements
- Bug fixes

## Breaking (Major Version)
- Removing fields
- Renaming fields
- Changing field types
- Removing endpoints
- Making optional fields required
- Changing authentication methods
- Changing error formats
- Removing enum values
```

### Deprecation Process

```http
# Deprecation headers
GET /v1/users/123
Deprecation: Sun, 01 Dec 2024 00:00:00 GMT
Sunset: Sun, 01 Mar 2025 00:00:00 GMT
Link: </v2/users/123>; rel="successor-version"

{
    "id": "123",
    "name": "John",
    "_deprecated": {
        "warning": "v1 API is deprecated. Migrate to v2 by March 2025",
        "migration_guide": "https://api.example.com/docs/v1-to-v2-migration"
    }
}
```
```

### Phase 6: Authentication & Authorization

```markdown
## Authentication Patterns

### API Key Authentication

```http
# Header approach (recommended)
GET /users
X-API-Key: sk_live_abc123xyz

# Query parameter (less secure, avoid for sensitive operations)
GET /users?api_key=sk_live_abc123xyz
```

Best for:
- Server-to-server communication
- Internal APIs
- Simple integrations

### OAuth 2.0 / JWT

```http
# Bearer token
GET /users
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

```yaml
# OAuth 2.0 flows
securitySchemes:
  oauth2:
    type: oauth2
    flows:
      authorizationCode:
        authorizationUrl: https://auth.example.com/authorize
        tokenUrl: https://auth.example.com/token
        scopes:
          read:users: Read user data
          write:users: Create and update users
          admin: Full administrative access

      clientCredentials:
        tokenUrl: https://auth.example.com/token
        scopes:
          api:access: Basic API access
```

### JWT Structure

```json
// Header
{
    "alg": "RS256",
    "typ": "JWT",
    "kid": "key-id-123"
}

// Payload
{
    "sub": "user_123",              // Subject (user ID)
    "iss": "https://auth.example.com", // Issuer
    "aud": ["api.example.com"],     // Audience
    "exp": 1705312800,              // Expiration
    "iat": 1705309200,              // Issued at
    "nbf": 1705309200,              // Not before
    "jti": "token_abc123",          // JWT ID (unique)
    "scope": "read:users write:users", // Permissions
    "org_id": "org_456"             // Custom claims
}
```

### Scopes and Permissions

```yaml
# Define granular scopes
scopes:
  # Read scopes
  read:users: View user profiles
  read:orders: View order history
  read:products: View product catalog

  # Write scopes
  write:users: Create and update users
  write:orders: Create and modify orders

  # Admin scopes
  admin:users: Full user management
  admin:billing: Billing administration

# Apply to endpoints
paths:
  /users:
    get:
      security:
        - oauth2: [read:users]
    post:
      security:
        - oauth2: [write:users]

  /admin/users:
    get:
      security:
        - oauth2: [admin:users]
```
```

### Phase 7: Rate Limiting

```markdown
## Rate Limiting Design

### Rate Limit Headers

```http
HTTP/1.1 200 OK
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1705312800
X-RateLimit-Window: 3600
```

### Rate Limit Strategies

```yaml
# Per-endpoint limits
/users:
  rate_limit:
    requests: 100
    window: 60s  # 100 requests per minute

/search:
  rate_limit:
    requests: 20
    window: 60s  # More expensive operation

/bulk/import:
  rate_limit:
    requests: 5
    window: 3600s  # 5 per hour

# Per-tier limits
tiers:
  free:
    requests_per_minute: 60
    requests_per_day: 1000

  pro:
    requests_per_minute: 600
    requests_per_day: 50000

  enterprise:
    requests_per_minute: 6000
    requests_per_day: unlimited
```

### Retry-After Response

```http
HTTP/1.1 429 Too Many Requests
Content-Type: application/json
Retry-After: 45

{
    "error": {
        "code": "RATE_LIMIT_EXCEEDED",
        "message": "Rate limit exceeded",
        "limit": 100,
        "remaining": 0,
        "reset_at": "2024-01-15T10:35:00Z",
        "retry_after_seconds": 45
    }
}
```
```

### Phase 8: OpenAPI Specification

```yaml
# Complete OpenAPI 3.1 Example
openapi: 3.1.0

info:
  title: Example API
  version: 1.0.0
  description: |
    Example API demonstrating best practices.

    ## Authentication
    This API uses OAuth 2.0 Bearer tokens.

    ## Rate Limiting
    - Free tier: 60 requests/minute
    - Pro tier: 600 requests/minute
  contact:
    name: API Support
    email: api-support@example.com
  license:
    name: MIT

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api.staging.example.com/v1
    description: Staging

tags:
  - name: Users
    description: User management operations
  - name: Orders
    description: Order operations

security:
  - bearerAuth: []

paths:
  /users:
    get:
      tags: [Users]
      summary: List users
      description: Retrieve a paginated list of users
      operationId: listUsers
      parameters:
        - $ref: '#/components/parameters/LimitParam'
        - $ref: '#/components/parameters/CursorParam'
        - name: status
          in: query
          schema:
            type: string
            enum: [active, inactive, pending]
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  pagination:
                    $ref: '#/components/schemas/Pagination'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '429':
          $ref: '#/components/responses/RateLimited'

    post:
      tags: [Users]
      summary: Create user
      operationId: createUser
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created
          headers:
            Location:
              schema:
                type: string
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/BadRequest'
        '409':
          $ref: '#/components/responses/Conflict'

  /users/{id}:
    parameters:
      - $ref: '#/components/parameters/UserIdParam'
    get:
      tags: [Users]
      summary: Get user
      operationId: getUser
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '404':
          $ref: '#/components/responses/NotFound'

    patch:
      tags: [Users]
      summary: Update user
      operationId: updateUser
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdateUserRequest'
      responses:
        '200':
          description: User updated
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'

    delete:
      tags: [Users]
      summary: Delete user
      operationId: deleteUser
      responses:
        '204':
          description: User deleted
        '404':
          $ref: '#/components/responses/NotFound'

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  parameters:
    UserIdParam:
      name: id
      in: path
      required: true
      schema:
        type: string
        format: uuid

    LimitParam:
      name: limit
      in: query
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 20

    CursorParam:
      name: cursor
      in: query
      schema:
        type: string

  schemas:
    User:
      type: object
      required:
        - id
        - email
        - created_at
      properties:
        id:
          type: string
          format: uuid
          readOnly: true
        email:
          type: string
          format: email
        name:
          type: string
          maxLength: 100
        status:
          type: string
          enum: [active, inactive, pending]
          default: pending
        created_at:
          type: string
          format: date-time
          readOnly: true
        updated_at:
          type: string
          format: date-time
          readOnly: true

    CreateUserRequest:
      type: object
      required:
        - email
      properties:
        email:
          type: string
          format: email
        name:
          type: string
          maxLength: 100

    UpdateUserRequest:
      type: object
      properties:
        name:
          type: string
          maxLength: 100
        status:
          type: string
          enum: [active, inactive]

    Pagination:
      type: object
      properties:
        total:
          type: integer
        limit:
          type: integer
        has_more:
          type: boolean
        next_cursor:
          type: string
          nullable: true

    Error:
      type: object
      required:
        - error
      properties:
        error:
          type: object
          required:
            - code
            - message
          properties:
            code:
              type: string
            message:
              type: string
            details:
              type: array
              items:
                type: object
                properties:
                  field:
                    type: string
                  code:
                    type: string
                  message:
                    type: string

  responses:
    BadRequest:
      description: Invalid request
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

    Unauthorized:
      description: Authentication required
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

    Conflict:
      description: Resource conflict
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

    RateLimited:
      description: Rate limit exceeded
      headers:
        Retry-After:
          schema:
            type: integer
        X-RateLimit-Limit:
          schema:
            type: integer
        X-RateLimit-Remaining:
          schema:
            type: integer
        X-RateLimit-Reset:
          schema:
            type: integer
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
```

## API Design Checklist

```markdown
## Pre-Release API Checklist

### Design
- [ ] Resources are nouns, not verbs
- [ ] Consistent naming convention
- [ ] Logical resource hierarchy
- [ ] Appropriate HTTP methods used
- [ ] Idempotency where expected

### Requests
- [ ] Input validation defined
- [ ] Required vs optional clear
- [ ] Reasonable defaults set
- [ ] Size limits specified
- [ ] Content-Type handled

### Responses
- [ ] Consistent response format
- [ ] Appropriate status codes
- [ ] Error format standardized
- [ ] Pagination implemented
- [ ] Links/HATEOAS considered

### Security
- [ ] Authentication required
- [ ] Authorization enforced
- [ ] Rate limiting configured
- [ ] Input sanitized
- [ ] CORS configured

### Documentation
- [ ] OpenAPI spec complete
- [ ] Examples provided
- [ ] Error codes documented
- [ ] Changelog maintained
- [ ] SDK/client examples

### Operations
- [ ] Versioning strategy defined
- [ ] Deprecation policy documented
- [ ] Monitoring in place
- [ ] Health endpoints
- [ ] Logging configured
```

## Best Practices

1. **Be Consistent** - Same patterns everywhere
2. **Be Predictable** - Follow REST conventions
3. **Be Explicit** - Clear naming and documentation
4. **Be Secure** - Authentication and authorization from day one
5. **Be Robust** - Handle errors gracefully
6. **Be Efficient** - Pagination, filtering, caching
7. **Be Evolvable** - Plan for versioning
8. **Be Documented** - OpenAPI, examples, guides
9. **Be Observable** - Logging, metrics, tracing
10. **Be Developer-Friendly** - Good DX is good UX

## Notes

- API design is an iterative process
- Get feedback from consumers early
- Consider generating SDKs from OpenAPI
- Monitor usage patterns to inform evolution
- Security is not optional
