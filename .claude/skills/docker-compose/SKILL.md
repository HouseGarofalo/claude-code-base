---
name: docker-compose
description: Define and run multi-container Docker applications with Compose. Covers service orchestration, networking, volumes, development environments, and production configurations. Use when setting up local development, multi-service apps, or containerized workflows.
---

# Docker Compose Skill

Define and run multi-container applications using declarative YAML configuration. Covers Compose v2 with file format 3.8+.

## Triggers

Use this skill when you see:
- docker compose, docker-compose, compose.yaml
- multi-container, service orchestration
- container networking, docker volumes
- development environment, local docker setup

## Instructions

### Compose File Structure

#### Basic Template

```yaml
# compose.yaml (preferred) or docker-compose.yml
services:
  app:
    image: node:20-alpine
    ports:
      - "3000:3000"
    volumes:
      - ./src:/app/src
    environment:
      - NODE_ENV=development

networks:
  default:
    driver: bridge

volumes:
  app-data:
```

### Services Configuration

#### Image-Based Service

```yaml
services:
  api:
    image: nginx:alpine
    container_name: my-api
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    labels:
      - "traefik.enable=true"
```

#### Build-Based Service

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        NODE_ENV: development
      target: development
      cache_from:
        - myapp:cache
    image: myapp:latest
```

### Networks

#### Custom Network Configuration

```yaml
services:
  frontend:
    networks:
      - frontend-net

  backend:
    networks:
      - frontend-net
      - backend-net

  database:
    networks:
      - backend-net

networks:
  frontend-net:
    driver: bridge
  backend-net:
    driver: bridge
    internal: true # No external access
```

### Volumes

#### Named Volumes

```yaml
services:
  db:
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro

volumes:
  postgres-data:
    driver: local
```

#### Bind Mounts with Options

```yaml
services:
  app:
    volumes:
      # Read-write bind mount
      - ./src:/app/src:rw
      # Read-only bind mount
      - ./config:/app/config:ro
      # Delegated consistency (macOS performance)
      - ./node_modules:/app/node_modules:delegated
      # Anonymous volume
      - /app/temp
```

### Environment Variables

#### From File

```yaml
services:
  app:
    env_file:
      - .env
      - .env.local
    environment:
      # Override specific vars
      - LOG_LEVEL=debug
```

#### Variable Substitution

```yaml
services:
  app:
    image: myapp:${TAG:-latest}
    environment:
      - DATABASE_URL=postgres://${DB_USER}:${DB_PASS}@db:5432/${DB_NAME}
```

### Health Checks

```yaml
services:
  api:
    image: myapp:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  postgres:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### Dependencies

#### Conditional Dependencies (Recommended)

```yaml
services:
  app:
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
      migrations:
        condition: service_completed_successfully

  db:
    image: postgres:15
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 10

  migrations:
    build: ./migrations
    depends_on:
      db:
        condition: service_healthy
```

### Profiles

```yaml
services:
  app:
    image: myapp:latest
    # Always runs (no profile)

  debug:
    image: myapp:debug
    profiles:
      - debug

  monitoring:
    image: prometheus:latest
    profiles:
      - monitoring
      - production
```

```bash
# Run with specific profile
docker compose --profile debug up

# Run multiple profiles
docker compose --profile debug --profile monitoring up
```

### Development vs Production Configs

#### Base Configuration (compose.yaml)

```yaml
services:
  app:
    image: myapp:${TAG:-latest}
    environment:
      - NODE_ENV=${NODE_ENV:-production}
    restart: unless-stopped

  db:
    image: postgres:15
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

#### Development Override (compose.override.yaml)

```yaml
# Automatically loaded with compose.yaml
services:
  app:
    build:
      context: .
      target: development
    volumes:
      - ./src:/app/src
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DEBUG=*
    ports:
      - "3000:3000"
      - "9229:9229" # Debug port
    command: npm run dev

  db:
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_PASSWORD=devpassword
```

### Common Application Stacks

#### Node.js + PostgreSQL + Redis

```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/app
      - REDIS_URL=redis://redis:6379
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    volumes:
      - ./src:/app/src

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=app
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:alpine
    volumes:
      - redis-data:/data

volumes:
  postgres-data:
  redis-data:
```

### Resource Limits

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 1G
        reservations:
          cpus: "0.5"
          memory: 512M
    # For Compose standalone (non-Swarm)
    mem_limit: 1g
    memswap_limit: 2g
    cpus: 1.0
```

### Secrets Management

```yaml
services:
  app:
    secrets:
      - db_password
      - api_key
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    environment: API_KEY
```

## Best Practices

1. **File Organization**
   - Use `compose.yaml` (preferred) or `docker-compose.yml`
   - Use `compose.override.yaml` for development overrides
   - Use `compose.prod.yaml` for production configuration

2. **Security**
   - Never commit `.env` files with secrets
   - Use secrets for sensitive data in production
   - Use specific image tags, not `latest`
   - Use non-root users in containers
   - Use internal networks for backend services

3. **Performance**
   - Use tmpfs for temporary data
   - Use `:cached` volume option on macOS/Windows
   - Limit logging with max-size options

## Common Commands

| Command | Description |
|---------|-------------|
| `docker compose up -d` | Start in detached mode |
| `docker compose down -v` | Stop and remove volumes |
| `docker compose logs -f` | Follow all logs |
| `docker compose exec <svc> sh` | Shell into container |
| `docker compose build --no-cache` | Rebuild without cache |
| `docker compose pull` | Pull latest images |
| `docker compose config` | Validate configuration |
| `docker compose --profile <p> up` | Start with profile |
