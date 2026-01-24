---
name: azure-api-management
description: API gateway and management with Azure API Management. Configure policies, rate limiting, authentication, and developer portal. Use for API lifecycle management, gateway patterns, and API security on Azure.
---

# Azure API Management Skill

Build and manage APIs with Azure API Management for security, rate limiting, and developer experience.

## Triggers

Use this skill when you see:
- azure api management, apim, api gateway
- api policy, rate limiting, throttling
- api authentication, oauth, jwt validation
- developer portal, api subscription

## Instructions

### Create APIM Instance

```bash
# Create API Management instance
az apim create \
    --name myapim \
    --resource-group mygroup \
    --publisher-name "My Company" \
    --publisher-email admin@mycompany.com \
    --sku-name Developer \
    --location eastus

# List APIs
az apim api list --resource-group mygroup --service-name myapim -o table
```

### Import API

```bash
# Import from OpenAPI specification
az apim api import \
    --resource-group mygroup \
    --service-name myapim \
    --api-id my-api \
    --path /api \
    --specification-format OpenApi \
    --specification-url https://api.example.com/swagger.json

# Import from Azure Function
az apim api import \
    --resource-group mygroup \
    --service-name myapim \
    --api-id func-api \
    --path /func \
    --specification-format OpenApiJson \
    --specification-path ./openapi.json
```

### API Policies

#### Inbound Policies

```xml
<policies>
    <inbound>
        <base />

        <!-- Rate limiting by subscription -->
        <rate-limit-by-key
            calls="100"
            renewal-period="60"
            counter-key="@(context.Subscription.Id)" />

        <!-- Quota by subscription -->
        <quota-by-key
            calls="10000"
            bandwidth="40000"
            renewal-period="86400"
            counter-key="@(context.Subscription.Id)" />

        <!-- JWT validation -->
        <validate-jwt
            header-name="Authorization"
            failed-validation-httpcode="401"
            failed-validation-error-message="Unauthorized">
            <openid-config url="https://login.microsoftonline.com/{tenant}/.well-known/openid-configuration" />
            <required-claims>
                <claim name="aud" match="all">
                    <value>api://my-api</value>
                </claim>
            </required-claims>
        </validate-jwt>

        <!-- Set backend URL -->
        <set-backend-service base-url="https://backend.example.com" />

        <!-- Add headers -->
        <set-header name="X-Request-ID" exists-action="skip">
            <value>@(Guid.NewGuid().ToString())</value>
        </set-header>

        <!-- CORS -->
        <cors allow-credentials="true">
            <allowed-origins>
                <origin>https://app.example.com</origin>
            </allowed-origins>
            <allowed-methods>
                <method>GET</method>
                <method>POST</method>
            </allowed-methods>
            <allowed-headers>
                <header>*</header>
            </allowed-headers>
        </cors>
    </inbound>
</policies>
```

#### Outbound Policies

```xml
<policies>
    <outbound>
        <base />

        <!-- Remove headers -->
        <set-header name="X-Powered-By" exists-action="delete" />

        <!-- Transform response -->
        <set-body>@{
            var response = context.Response.Body.As<JObject>();
            response.Add("timestamp", DateTime.UtcNow);
            return response.ToString();
        }</set-body>

        <!-- Cache response -->
        <cache-store duration="3600" />
    </outbound>
</policies>
```

#### Backend Policies

```xml
<policies>
    <backend>
        <base />

        <!-- Retry on failure -->
        <retry
            condition="@(context.Response.StatusCode == 503)"
            count="3"
            interval="1"
            first-fast-retry="true">
            <forward-request timeout="30" />
        </retry>

        <!-- Circuit breaker -->
        <forward-request timeout="30" />
    </backend>
</policies>
```

#### Error Handling

```xml
<policies>
    <on-error>
        <base />

        <!-- Custom error response -->
        <set-header name="Content-Type" exists-action="override">
            <value>application/json</value>
        </set-header>
        <set-body>@{
            return new JObject(
                new JProperty("error", context.LastError.Message),
                new JProperty("requestId", context.RequestId)
            ).ToString();
        }</set-body>
    </on-error>
</policies>
```

### Authentication

#### OAuth 2.0 Configuration

```bash
# Create OAuth 2.0 authorization server
az apim authorizationserver create \
    --resource-group mygroup \
    --service-name myapim \
    --name oauth2 \
    --client-id <CLIENT_ID> \
    --client-secret <CLIENT_SECRET> \
    --authorization-endpoint https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize \
    --token-endpoint https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token \
    --grant-types authorizationCode
```

#### API Key Authentication

```xml
<policies>
    <inbound>
        <!-- Validate subscription key -->
        <check-header name="Ocp-Apim-Subscription-Key" failed-check-httpcode="401" failed-check-error-message="API key required" />
    </inbound>
</policies>
```

### Products and Subscriptions

```bash
# Create product
az apim product create \
    --resource-group mygroup \
    --service-name myapim \
    --product-id starter \
    --title "Starter" \
    --description "Free tier with rate limits" \
    --subscription-required true \
    --approval-required false \
    --subscriptions-limit 1 \
    --state published

# Add API to product
az apim product api add \
    --resource-group mygroup \
    --service-name myapim \
    --product-id starter \
    --api-id my-api

# Create subscription
az apim subscription create \
    --resource-group mygroup \
    --service-name myapim \
    --subscription-id sub-001 \
    --display-name "Test Subscription" \
    --scope /products/starter
```

### Caching

```xml
<policies>
    <inbound>
        <!-- Cache lookup -->
        <cache-lookup vary-by-developer="false" vary-by-developer-groups="false">
            <vary-by-header>Accept</vary-by-header>
            <vary-by-query-parameter>version</vary-by-query-parameter>
        </cache-lookup>
    </inbound>
    <outbound>
        <!-- Cache store -->
        <cache-store duration="3600" />
    </outbound>
</policies>
```

### Logging and Monitoring

```xml
<policies>
    <inbound>
        <!-- Log to Application Insights -->
        <trace source="API Gateway" severity="information">
            <message>@(context.Request.Url.Path)</message>
            <metadata name="CorrelationId" value="@(context.RequestId)" />
        </trace>
    </inbound>
</policies>
```

```bash
# Enable Application Insights
az apim update \
    --resource-group mygroup \
    --name myapim \
    --set properties.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2"="True"
```

## Best Practices

1. **Security**: Always validate JWT tokens and API keys
2. **Rate Limiting**: Implement rate limiting and quotas
3. **Caching**: Cache responses to reduce backend load
4. **Versioning**: Use API versioning for breaking changes
5. **Monitoring**: Enable Application Insights for diagnostics

## Common Workflows

### Publish New API
1. Import API from OpenAPI specification
2. Configure authentication policies
3. Add rate limiting and caching
4. Create product and assign API
5. Publish to developer portal

### Secure API with OAuth
1. Register application in Azure AD
2. Configure OAuth 2.0 authorization server
3. Add JWT validation policy
4. Test with access token
5. Document in developer portal
