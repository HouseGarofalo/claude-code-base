---
name: azure-event-grid
description: Event routing with Azure Event Grid. Configure topics, subscriptions, event handlers, and dead-lettering. Use for event-driven architectures, serverless triggers, and reactive systems on Azure.
---

# Azure Event Grid Skill

Build event-driven architectures with Azure Event Grid for reliable event routing.

## Triggers

Use this skill when you see:
- azure event grid, event grid, event routing
- event subscription, event handler
- system topic, custom topic
- event filtering, dead letter

## Instructions

### Create Custom Topic

```bash
# Create Event Grid topic
az eventgrid topic create \
    --name mytopic \
    --resource-group mygroup \
    --location eastus

# Get topic endpoint and key
az eventgrid topic show \
    --name mytopic \
    --resource-group mygroup \
    --query "endpoint" -o tsv

az eventgrid topic key list \
    --name mytopic \
    --resource-group mygroup \
    --query "key1" -o tsv
```

### Create Event Subscription

```bash
# Subscribe to Azure Function
az eventgrid event-subscription create \
    --name mysubscription \
    --source-resource-id /subscriptions/.../topics/mytopic \
    --endpoint https://myfunc.azurewebsites.net/runtime/webhooks/eventgrid?functionName=EventHandler \
    --endpoint-type azurefunction

# Subscribe to webhook
az eventgrid event-subscription create \
    --name webhook-sub \
    --source-resource-id /subscriptions/.../topics/mytopic \
    --endpoint https://myapi.example.com/webhooks/events \
    --endpoint-type webhook

# Subscribe to Storage Queue
az eventgrid event-subscription create \
    --name queue-sub \
    --source-resource-id /subscriptions/.../topics/mytopic \
    --endpoint /subscriptions/.../storageAccounts/mystorage/queueServices/default/queues/events \
    --endpoint-type storagequeue

# Subscribe to Service Bus
az eventgrid event-subscription create \
    --name servicebus-sub \
    --source-resource-id /subscriptions/.../topics/mytopic \
    --endpoint /subscriptions/.../namespaces/mybus/queues/events \
    --endpoint-type servicebusqueue
```

### Event Filtering

```bash
# Filter by event type
az eventgrid event-subscription create \
    --name filtered-sub \
    --source-resource-id /subscriptions/.../topics/mytopic \
    --endpoint https://myfunc.azurewebsites.net/api/handler \
    --included-event-types Microsoft.Storage.BlobCreated Microsoft.Storage.BlobDeleted

# Advanced filter - string prefix
az eventgrid event-subscription create \
    --name advanced-sub \
    --source-resource-id /subscriptions/.../topics/mytopic \
    --endpoint https://myfunc.azurewebsites.net/api/handler \
    --advanced-filter data.url StringBeginsWith https://myaccount.blob.core.windows.net/images

# Advanced filter - numeric comparison
az eventgrid event-subscription create \
    --name numeric-sub \
    --source-resource-id /subscriptions/.../topics/mytopic \
    --endpoint https://myfunc.azurewebsites.net/api/handler \
    --advanced-filter data.contentLength NumberGreaterThan 1000000
```

### System Topics

```bash
# Create system topic for storage events
az eventgrid system-topic create \
    --name storage-events \
    --resource-group mygroup \
    --source /subscriptions/.../storageAccounts/mystorage \
    --topic-type Microsoft.Storage.StorageAccounts \
    --location eastus

# Create subscription for system topic
az eventgrid system-topic event-subscription create \
    --name blob-created-sub \
    --resource-group mygroup \
    --system-topic-name storage-events \
    --endpoint https://myfunc.azurewebsites.net/api/BlobHandler \
    --included-event-types Microsoft.Storage.BlobCreated
```

### Publish Events

#### Python SDK

```python
from azure.eventgrid import EventGridPublisherClient
from azure.core.credentials import AzureKeyCredential
from azure.eventgrid import EventGridEvent
import datetime

# Create client
client = EventGridPublisherClient(
    endpoint="https://mytopic.eastus-1.eventgrid.azure.net/api/events",
    credential=AzureKeyCredential("your-key")
)

# Publish Event Grid schema event
event = EventGridEvent(
    subject="myapp/orders/12345",
    event_type="Order.Created",
    data={
        "orderId": "12345",
        "customerId": "C001",
        "total": 99.99
    },
    data_version="1.0"
)

client.send([event])

# Publish Cloud Event schema
from azure.eventgrid import CloudEvent

cloud_event = CloudEvent(
    type="Order.Created",
    source="/myapp/orders",
    data={
        "orderId": "12345",
        "customerId": "C001"
    }
)

client.send([cloud_event])
```

#### TypeScript SDK

```typescript
import { EventGridPublisherClient, AzureKeyCredential } from "@azure/eventgrid";

const client = new EventGridPublisherClient(
  "https://mytopic.eastus-1.eventgrid.azure.net/api/events",
  "EventGrid",
  new AzureKeyCredential("your-key")
);

// Publish events
await client.send([
  {
    eventType: "Order.Created",
    subject: "myapp/orders/12345",
    dataVersion: "1.0",
    data: {
      orderId: "12345",
      customerId: "C001",
      total: 99.99
    }
  }
]);
```

### Event Handler (Azure Function)

```python
import azure.functions as func
import json
import logging

app = func.FunctionApp()

@app.event_grid_trigger(arg_name="event")
def event_grid_handler(event: func.EventGridEvent):
    logging.info(f"Event type: {event.event_type}")
    logging.info(f"Subject: {event.subject}")
    logging.info(f"Data: {event.get_json()}")

    data = event.get_json()

    if event.event_type == "Order.Created":
        process_new_order(data)
    elif event.event_type == "Order.Cancelled":
        process_cancellation(data)
```

```typescript
// TypeScript Azure Function
import { app, EventGridEvent, InvocationContext } from "@azure/functions";

export async function eventGridHandler(
  event: EventGridEvent,
  context: InvocationContext
): Promise<void> {
  context.log(`Event type: ${event.eventType}`);
  context.log(`Subject: ${event.subject}`);
  context.log(`Data: ${JSON.stringify(event.data)}`);

  switch (event.eventType) {
    case "Order.Created":
      await processNewOrder(event.data);
      break;
    case "Order.Cancelled":
      await processCancellation(event.data);
      break;
  }
}

app.eventGrid("eventGridHandler", {
  handler: eventGridHandler,
});
```

### Dead-Lettering

```bash
# Enable dead-lettering to storage
az eventgrid event-subscription create \
    --name mysubscription \
    --source-resource-id /subscriptions/.../topics/mytopic \
    --endpoint https://myfunc.azurewebsites.net/api/handler \
    --deadletter-endpoint /subscriptions/.../storageAccounts/mystorage/blobServices/default/containers/deadletter

# Set retry policy
az eventgrid event-subscription update \
    --name mysubscription \
    --source-resource-id /subscriptions/.../topics/mytopic \
    --max-delivery-attempts 10 \
    --event-ttl 1440
```

### Event Domains

```bash
# Create event domain for multi-tenant scenarios
az eventgrid domain create \
    --name mydomain \
    --resource-group mygroup \
    --location eastus

# Create domain topic
az eventgrid domain topic create \
    --name tenant-001 \
    --domain-name mydomain \
    --resource-group mygroup

# Subscribe to domain topic
az eventgrid event-subscription create \
    --name tenant-sub \
    --source-resource-id /subscriptions/.../domains/mydomain/topics/tenant-001 \
    --endpoint https://myfunc.azurewebsites.net/api/TenantHandler
```

## Best Practices

1. **Event Schema**: Use CloudEvents schema for portability
2. **Filtering**: Filter at subscription level to reduce noise
3. **Dead-Letter**: Always configure dead-lettering
4. **Retry Policy**: Set appropriate retry and TTL values
5. **Domains**: Use domains for multi-tenant applications

## Common Workflows

### Event-Driven Processing
1. Create Event Grid topic
2. Configure event subscriptions with filters
3. Implement event handlers (Functions, webhooks)
4. Set up dead-lettering for failed events
5. Monitor with Event Grid metrics

### React to Azure Events
1. Create system topic for Azure resource
2. Subscribe to specific event types
3. Implement handler function
4. Process events and trigger workflows
5. Configure alerts for delivery failures
