---
name: azure-container-apps
description: Deploy containerized apps with Azure Container Apps. Configure auto-scaling, Dapr integration, traffic splitting, and managed identities. Use for microservices, APIs, background jobs, and event-driven applications on Azure.
---

# Azure Container Apps Skill

Deploy and manage containerized applications with Azure Container Apps for serverless containers.

## Triggers

Use this skill when you see:
- azure container apps, container apps, aca
- serverless containers, dapr, keda
- container app environment, revision
- traffic splitting, ingress

## Instructions

### Create Container App Environment

```bash
# Create resource group
az group create --name mygroup --location eastus

# Create Container Apps environment
az containerapp env create \
    --name myenv \
    --resource-group mygroup \
    --location eastus

# Create environment with Log Analytics
az containerapp env create \
    --name myenv \
    --resource-group mygroup \
    --location eastus \
    --logs-destination log-analytics \
    --logs-workspace-id <WORKSPACE_ID>
```

### Deploy Container App

```bash
# Create container app from image
az containerapp create \
    --name myapp \
    --resource-group mygroup \
    --environment myenv \
    --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
    --target-port 80 \
    --ingress external \
    --min-replicas 1 \
    --max-replicas 10

# Create from ACR with managed identity
az containerapp create \
    --name myapp \
    --resource-group mygroup \
    --environment myenv \
    --image myacr.azurecr.io/myapp:latest \
    --registry-server myacr.azurecr.io \
    --registry-identity system \
    --target-port 8080 \
    --ingress external
```

### Container App Configuration

```yaml
# container-app.yaml
properties:
  managedEnvironmentId: /subscriptions/.../managedEnvironments/myenv
  configuration:
    ingress:
      external: true
      targetPort: 8080
      transport: http
      traffic:
        - weight: 100
          latestRevision: true
    registries:
      - server: myacr.azurecr.io
        identity: system
    secrets:
      - name: db-password
        value: secret-value
  template:
    containers:
      - name: myapp
        image: myacr.azurecr.io/myapp:v1
        resources:
          cpu: 0.5
          memory: 1Gi
        env:
          - name: DATABASE_URL
            secretRef: db-password
          - name: LOG_LEVEL
            value: info
        probes:
          - type: liveness
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
          - type: readiness
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
    scale:
      minReplicas: 1
      maxReplicas: 10
      rules:
        - name: http-rule
          http:
            metadata:
              concurrentRequests: "100"
```

```bash
# Deploy from YAML
az containerapp create \
    --name myapp \
    --resource-group mygroup \
    --yaml container-app.yaml
```

### Scaling Rules

```bash
# HTTP scaling
az containerapp update \
    --name myapp \
    --resource-group mygroup \
    --min-replicas 1 \
    --max-replicas 10 \
    --scale-rule-name http-rule \
    --scale-rule-type http \
    --scale-rule-metadata concurrentRequests=100

# Azure Queue scaling
az containerapp update \
    --name myapp \
    --resource-group mygroup \
    --scale-rule-name queue-rule \
    --scale-rule-type azure-queue \
    --scale-rule-metadata "queueName=myqueue" "queueLength=10" \
    --scale-rule-auth "connection=queue-connection-string"

# Custom scaling (KEDA)
az containerapp update \
    --name myapp \
    --resource-group mygroup \
    --scale-rule-name custom-rule \
    --scale-rule-type cpu \
    --scale-rule-metadata "type=Utilization" "value=70"
```

### Traffic Splitting

```bash
# Create new revision
az containerapp update \
    --name myapp \
    --resource-group mygroup \
    --image myacr.azurecr.io/myapp:v2 \
    --revision-suffix v2

# Split traffic between revisions
az containerapp ingress traffic set \
    --name myapp \
    --resource-group mygroup \
    --revision-weight myapp--v1=80 myapp--v2=20

# Route all traffic to new revision
az containerapp ingress traffic set \
    --name myapp \
    --resource-group mygroup \
    --revision-weight myapp--v2=100
```

### Dapr Integration

```bash
# Create container app with Dapr
az containerapp create \
    --name myapp \
    --resource-group mygroup \
    --environment myenv \
    --image myacr.azurecr.io/myapp:latest \
    --target-port 8080 \
    --ingress external \
    --enable-dapr \
    --dapr-app-id myapp \
    --dapr-app-port 8080 \
    --dapr-app-protocol http

# Configure Dapr component (state store)
az containerapp env dapr-component set \
    --name myenv \
    --resource-group mygroup \
    --dapr-component-name statestore \
    --yaml statestore.yaml
```

```yaml
# statestore.yaml
componentType: state.azure.blobstorage
version: v1
metadata:
  - name: accountName
    value: mystorageaccount
  - name: accountKey
    secretRef: storage-key
  - name: containerName
    value: state
scopes:
  - myapp
```

### Environment Variables and Secrets

```bash
# Add secret
az containerapp secret set \
    --name myapp \
    --resource-group mygroup \
    --secrets "db-password=secretvalue"

# Reference secret in environment variable
az containerapp update \
    --name myapp \
    --resource-group mygroup \
    --set-env-vars "DATABASE_URL=secretref:db-password"

# Add regular environment variable
az containerapp update \
    --name myapp \
    --resource-group mygroup \
    --set-env-vars "LOG_LEVEL=debug"
```

### Managed Identity

```bash
# Enable system-assigned identity
az containerapp identity assign \
    --name myapp \
    --resource-group mygroup \
    --system-assigned

# Enable user-assigned identity
az containerapp identity assign \
    --name myapp \
    --resource-group mygroup \
    --user-assigned <IDENTITY_RESOURCE_ID>

# Grant access to Key Vault
az keyvault set-policy \
    --name mykeyvault \
    --object-id <IDENTITY_PRINCIPAL_ID> \
    --secret-permissions get list
```

### Jobs

```bash
# Create scheduled job
az containerapp job create \
    --name myjob \
    --resource-group mygroup \
    --environment myenv \
    --trigger-type Schedule \
    --replica-timeout 300 \
    --replica-retry-limit 1 \
    --replica-completion-count 1 \
    --cron-expression "0 0 * * *" \
    --image myacr.azurecr.io/myjob:latest

# Create event-driven job
az containerapp job create \
    --name myjob \
    --resource-group mygroup \
    --environment myenv \
    --trigger-type Event \
    --min-executions 0 \
    --max-executions 10 \
    --scale-rule-name queue-rule \
    --scale-rule-type azure-queue \
    --scale-rule-metadata "queueName=jobs" "queueLength=1"
```

## Best Practices

1. **Scaling**: Configure appropriate min/max replicas and scaling rules
2. **Health Probes**: Always configure liveness and readiness probes
3. **Secrets**: Use secrets for sensitive configuration
4. **Traffic**: Use traffic splitting for blue/green deployments
5. **Monitoring**: Enable logging to Log Analytics

## Common Workflows

### Deploy Microservice
1. Create Container Apps environment
2. Deploy container app with ingress
3. Configure scaling rules
4. Set up secrets and environment variables
5. Enable managed identity for Azure resources

### Blue/Green Deployment
1. Deploy new revision with new image
2. Test new revision with direct URL
3. Split traffic (90/10, 50/50)
4. Monitor metrics and logs
5. Route 100% to new revision
