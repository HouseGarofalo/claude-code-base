---
description: Generate API endpoint specifications from requirements using RESTful conventions
---

# API Contract Generation

Generate API endpoint specifications from the following requirements:

## Requirements
$ARGUMENTS

## Design Framework

### 1. Resource Identification
- What are the core resources?
- How do they map to entities?
- What are the URL patterns?

### 2. Operations
- What CRUD operations are needed?
- What custom actions are required?
- What are the HTTP methods?

### 3. Request/Response Schemas
- What data is sent in requests?
- What data is returned in responses?
- What are the content types?

### 4. Error Handling
- What error codes are used?
- What error response format?
- What validation errors occur?

### 5. Authentication & Authorization
- What authentication is required?
- What permissions are needed?
- What scopes apply?

## Output Format

```markdown
# API Contracts: [Feature Name]

## Base URL
`/api/v1`

## Authentication
[Authentication requirements]

## Endpoints

### [Resource Name]

#### List [Resources]
- **Method**: GET
- **Path**: `/resources`
- **Query Parameters**:
  - `page`: int (optional, default: 1)
  - `limit`: int (optional, default: 20)
  - `sort`: string (optional)
  - `filter`: string (optional)
- **Response**: 200 OK
  ```json
  {
    "data": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "pages": 5
    }
  }
  ```

#### Get [Resource]
- **Method**: GET
- **Path**: `/resources/{id}`
- **Response**: 200 OK / 404 Not Found
  ```json
  {
    "data": { ... }
  }
  ```

#### Create [Resource]
- **Method**: POST
- **Path**: `/resources`
- **Request Body**:
  ```json
  {
    "field1": "value",
    "field2": "value"
  }
  ```
- **Response**: 201 Created / 400 Bad Request
  ```json
  {
    "data": { ... }
  }
  ```

#### Update [Resource]
- **Method**: PUT/PATCH
- **Path**: `/resources/{id}`
- **Request Body**:
  ```json
  {
    "field1": "updated value"
  }
  ```
- **Response**: 200 OK / 404 Not Found / 400 Bad Request

#### Delete [Resource]
- **Method**: DELETE
- **Path**: `/resources/{id}`
- **Response**: 204 No Content / 404 Not Found

## Error Responses

| Code | Description | Response |
|------|-------------|----------|
| 400 | Bad Request | `{"error": "message", "details": [...]}` |
| 401 | Unauthorized | `{"error": "Authentication required"}` |
| 403 | Forbidden | `{"error": "Insufficient permissions"}` |
| 404 | Not Found | `{"error": "Resource not found"}` |
| 409 | Conflict | `{"error": "Resource already exists"}` |
| 422 | Validation Error | `{"error": "Validation failed", "details": [...]}` |
| 500 | Server Error | `{"error": "Internal server error"}` |

## Data Types

| Type | Format | Example |
|------|--------|---------|
| ID | UUID | `"550e8400-e29b-41d4-a716-446655440000"` |
| Date | ISO 8601 | `"2024-01-15T10:30:00Z"` |
| Money | Integer (cents) | `1999` (for $19.99) |
```

## Best Practices

1. **Consistent naming**: Use plural nouns for resources
2. **Versioning**: Always include version in URL (`/api/v1/`)
3. **Pagination**: Required for list endpoints
4. **HATEOAS**: Consider including links for discoverability
5. **Idempotency**: POST should create, PUT should replace
