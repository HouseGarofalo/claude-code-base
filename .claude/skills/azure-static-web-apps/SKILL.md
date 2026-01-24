---
name: azure-static-web-apps
description: Deploy static sites with Azure Static Web Apps. Configure API routes, authentication, custom domains, and staging environments. Use for JAMstack, SPAs, static sites, and serverless backends on Azure.
---

# Azure Static Web Apps Skill

Deploy and manage static web applications with Azure Static Web Apps.

## Triggers

Use this skill when you see:
- azure static web apps, swa, static site
- jamstack azure, spa deployment
- static web app api, serverless frontend
- swa cli, staticwebapp.config.json

## Instructions

### Create Static Web App

```bash
# Create from GitHub
az staticwebapp create \
    --name mystaticwebapp \
    --resource-group mygroup \
    --source https://github.com/org/repo \
    --location eastus2 \
    --branch main \
    --app-location "/" \
    --api-location "api" \
    --output-location "dist" \
    --login-with-github

# Create from Azure DevOps
az staticwebapp create \
    --name mystaticwebapp \
    --resource-group mygroup \
    --source https://dev.azure.com/org/project/_git/repo \
    --location eastus2 \
    --branch main \
    --app-location "/" \
    --api-location "api" \
    --output-location "build"
```

### Configuration File

```json
// staticwebapp.config.json
{
  "routes": [
    {
      "route": "/api/*",
      "allowedRoles": ["authenticated"]
    },
    {
      "route": "/admin/*",
      "allowedRoles": ["admin"]
    },
    {
      "route": "/login",
      "rewrite": "/.auth/login/aad"
    },
    {
      "route": "/logout",
      "redirect": "/.auth/logout"
    },
    {
      "route": "/*",
      "serve": "/index.html",
      "statusCode": 200
    }
  ],
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/images/*.{png,jpg,gif}", "/css/*", "/api/*"]
  },
  "responseOverrides": {
    "401": {
      "redirect": "/login",
      "statusCode": 302
    },
    "404": {
      "rewrite": "/404.html"
    }
  },
  "globalHeaders": {
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "Content-Security-Policy": "default-src 'self'"
  },
  "mimeTypes": {
    ".json": "application/json",
    ".wasm": "application/wasm"
  },
  "auth": {
    "identityProviders": {
      "azureActiveDirectory": {
        "registration": {
          "openIdIssuer": "https://login.microsoftonline.com/<tenant-id>/v2.0",
          "clientIdSettingName": "AAD_CLIENT_ID",
          "clientSecretSettingName": "AAD_CLIENT_SECRET"
        }
      },
      "github": {
        "registration": {
          "clientIdSettingName": "GITHUB_CLIENT_ID",
          "clientSecretSettingName": "GITHUB_CLIENT_SECRET"
        }
      }
    }
  },
  "platform": {
    "apiRuntime": "node:18"
  }
}
```

### API Functions

```typescript
// api/hello/index.ts
import { AzureFunction, Context, HttpRequest } from "@azure/functions";

const httpTrigger: AzureFunction = async function (
  context: Context,
  req: HttpRequest
): Promise<void> {
  const name = req.query.name || req.body?.name || "World";

  context.res = {
    body: { message: `Hello, ${name}!` },
    headers: { "Content-Type": "application/json" }
  };
};

export default httpTrigger;
```

```json
// api/hello/function.json
{
  "bindings": [
    {
      "authLevel": "anonymous",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": ["get", "post"],
      "route": "hello"
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    }
  ]
}
```

### Authentication

```javascript
// Frontend: Get user info
async function getUserInfo() {
  const response = await fetch('/.auth/me');
  const payload = await response.json();
  const { clientPrincipal } = payload;

  if (clientPrincipal) {
    return {
      userId: clientPrincipal.userId,
      userRoles: clientPrincipal.userRoles,
      claims: clientPrincipal.claims,
      identityProvider: clientPrincipal.identityProvider
    };
  }

  return null;
}

// Login links
const loginLinks = {
  aad: '/.auth/login/aad',
  github: '/.auth/login/github',
  google: '/.auth/login/google',
  twitter: '/.auth/login/twitter'
};

// Logout
const logoutLink = '/.auth/logout';
```

```typescript
// API: Get user from request
import { AzureFunction, Context, HttpRequest } from "@azure/functions";

interface ClientPrincipal {
  userId: string;
  userRoles: string[];
  claims: { typ: string; val: string }[];
  identityProvider: string;
  userDetails: string;
}

function getUser(req: HttpRequest): ClientPrincipal | null {
  const header = req.headers.get("x-ms-client-principal");
  if (!header) return null;

  const encoded = Buffer.from(header, "base64");
  const decoded = encoded.toString("utf8");
  return JSON.parse(decoded);
}

const httpTrigger: AzureFunction = async function (
  context: Context,
  req: HttpRequest
): Promise<void> {
  const user = getUser(req);

  if (!user) {
    context.res = { status: 401, body: "Unauthorized" };
    return;
  }

  context.res = {
    body: { message: `Hello, ${user.userDetails}!` }
  };
};
```

### Custom Domains

```bash
# Add custom domain
az staticwebapp hostname set \
    --name mystaticwebapp \
    --resource-group mygroup \
    --hostname www.example.com

# List hostnames
az staticwebapp hostname list \
    --name mystaticwebapp \
    --resource-group mygroup

# Delete hostname
az staticwebapp hostname delete \
    --name mystaticwebapp \
    --resource-group mygroup \
    --hostname www.example.com
```

### Environment Variables

```bash
# Set app settings
az staticwebapp appsettings set \
    --name mystaticwebapp \
    --resource-group mygroup \
    --setting-names "API_KEY=value" "DATABASE_URL=connection-string"

# List app settings
az staticwebapp appsettings list \
    --name mystaticwebapp \
    --resource-group mygroup

# Delete app setting
az staticwebapp appsettings delete \
    --name mystaticwebapp \
    --resource-group mygroup \
    --setting-names "API_KEY"
```

### Staging Environments

```bash
# List environments
az staticwebapp environment list \
    --name mystaticwebapp \
    --resource-group mygroup

# Each PR creates a staging environment automatically
# Environment URL: https://<random>-<app-name>.azurestaticapps.net

# Delete environment
az staticwebapp environment delete \
    --name mystaticwebapp \
    --resource-group mygroup \
    --environment-name <env-name>
```

### SWA CLI (Local Development)

```bash
# Install SWA CLI
npm install -g @azure/static-web-apps-cli

# Start local development
swa start ./dist --api-location ./api

# Start with framework dev server
swa start http://localhost:3000 --api-location ./api

# Build and deploy
swa build
swa deploy --deployment-token <token>

# Login and deploy
swa login
swa deploy ./dist --api-location ./api

# Emulate authentication
swa start ./dist --api-location ./api --auth mock
```

### GitHub Actions Workflow

```yaml
# .github/workflows/azure-static-web-apps.yml
name: Azure Static Web Apps CI/CD

on:
  push:
    branches: [main]
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [main]

jobs:
  build_and_deploy:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build And Deploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/"
          api_location: "api"
          output_location: "dist"

  close_pull_request:
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    steps:
      - name: Close Pull Request
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          action: "close"
```

## Best Practices

1. **Configuration**: Use staticwebapp.config.json for routing and security
2. **Authentication**: Leverage built-in auth providers
3. **APIs**: Keep API functions lightweight and stateless
4. **Staging**: Use PR environments for testing
5. **Security**: Add security headers via config

## Common Workflows

### Deploy Static Site
1. Create Static Web App with GitHub integration
2. Configure build settings in workflow
3. Add staticwebapp.config.json for routing
4. Set up custom domain
5. Configure authentication if needed

### Add API Backend
1. Create api/ folder with Azure Functions
2. Configure routes in staticwebapp.config.json
3. Add environment variables for secrets
4. Test locally with SWA CLI
5. Deploy with CI/CD pipeline
