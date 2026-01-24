---
name: node-red-automation
description: Build flow-based automations with Node-RED for smart home, IoT, and API integration. Create flows, configure nodes, integrate with Home Assistant, MQTT, and external APIs. Use when building visual automation workflows or connecting various services and devices. (project)
---

# Node-RED Automation

Expert guidance for Node-RED flow-based programming and automation.

## When to Use This Skill

- Building smart home automations
- Creating API integrations
- Processing MQTT messages
- Building dashboards
- Connecting services and devices
- Data transformation and routing

## Installation

```yaml
# docker-compose.yml
version: '3.8'
services:
  nodered:
    image: nodered/node-red:latest
    ports:
      - "1880:1880"
    volumes:
      - ./node-red-data:/data
    environment:
      - TZ=America/New_York
    restart: unless-stopped
```

```bash
# Native installation
npm install -g node-red

# Start
node-red

# Access at http://localhost:1880
```

## Settings Configuration

```javascript
// settings.js
module.exports = {
    flowFile: 'flows.json',

    // Admin auth
    adminAuth: {
        type: "credentials",
        users: [{
            username: "admin",
            password: "$2b$08$...", // bcrypt hash
            permissions: "*"
        }]
    },

    // HTTP node auth
    httpNodeAuth: {
        user: "user",
        pass: "$2b$08$..."
    },

    // HTTPS
    https: {
        key: require("fs").readFileSync('privkey.pem'),
        cert: require("fs").readFileSync('cert.pem')
    },

    // Context storage
    contextStorage: {
        default: {
            module: "localfilesystem"
        }
    },

    // Function global context
    functionGlobalContext: {
        moment: require('moment')
    }
}
```

## Core Nodes

### Inject Node

```json
// Triggered flow
{
  "payload": "Hello",
  "topic": "greeting",
  "repeat": "60",  // Every 60 seconds
  "crontab": "0 9 * * 1-5"  // 9 AM weekdays
}
```

### Function Node

```javascript
// Basic transformation
msg.payload = msg.payload.toUpperCase();
return msg;

// Multiple outputs
var msg1 = { payload: msg.payload.value1 };
var msg2 = { payload: msg.payload.value2 };
return [msg1, msg2];

// Conditional routing
if (msg.payload > 100) {
    return [msg, null];  // Output 1
} else {
    return [null, msg];  // Output 2
}

// Access context
var count = context.get('count') || 0;
count++;
context.set('count', count);
msg.payload = count;
return msg;

// Flow context (shared across flow)
var data = flow.get('sharedData');

// Global context (shared across all flows)
var config = global.get('config');

// Async operation
node.send(msg);
return null;  // Don't send twice

// Status
node.status({fill:"green", shape:"dot", text:"OK"});
node.status({fill:"red", shape:"ring", text:"Error"});
```

### Switch Node

```json
// Route based on property
{
  "property": "payload.type",
  "rules": [
    {"t": "eq", "v": "temperature"},
    {"t": "eq", "v": "humidity"},
    {"t": "regex", "v": "^error"},
    {"t": "else"}
  ]
}
```

### Change Node

```json
// Set, change, delete, move properties
{
  "rules": [
    {"t": "set", "p": "payload.processed", "to": true},
    {"t": "change", "p": "payload", "from": "foo", "to": "bar"},
    {"t": "delete", "p": "payload.temp"},
    {"t": "move", "p": "payload.old", "to": "payload.new"}
  ]
}
```

### Template Node

```mustache
Temperature: {{payload.temperature}}°C
Humidity: {{payload.humidity}}%
Time: {{timestamp}}

{{#payload.items}}
  - {{name}}: {{value}}
{{/payload.items}}
```

## MQTT Integration

### MQTT Nodes

```json
// MQTT In
{
  "topic": "sensors/+/temperature",
  "qos": 1,
  "broker": "mqtt-broker-config"
}

// MQTT Out
{
  "topic": "commands/device1",
  "qos": 1,
  "retain": true
}
```

### Flow: MQTT Processing

```javascript
// Function: Parse MQTT message
var topic = msg.topic;
var parts = topic.split('/');
var deviceId = parts[1];
var measurement = parts[2];

msg.payload = {
    device: deviceId,
    type: measurement,
    value: parseFloat(msg.payload),
    timestamp: new Date().toISOString()
};
return msg;
```

## Home Assistant Integration

### Home Assistant Palette

```bash
# Install node-red-contrib-home-assistant-websocket
cd ~/.node-red
npm install node-red-contrib-home-assistant-websocket
```

### HA Nodes

```json
// Events: state
{
  "entity_id": "sensor.temperature",
  "state_type": "str",
  "halt_if": "",
  "halt_if_compare": "is"
}

// Call service
{
  "domain": "light",
  "service": "turn_on",
  "data": {
    "entity_id": "light.living_room",
    "brightness_pct": 80
  }
}

// Get current state
{
  "entity_id": "sensor.temperature",
  "state_type": "num"
}
```

### Flow: Motion Light Automation

```javascript
// When motion detected, turn on light for 5 minutes
// Events: state node -> Function -> Call service

// Function node
if (msg.payload === 'on') {
    msg.payload = {
        domain: 'light',
        service: 'turn_on',
        data: {
            entity_id: 'light.hallway',
            brightness_pct: 100
        }
    };

    // Schedule turn off
    var turnOff = {
        payload: {
            domain: 'light',
            service: 'turn_off',
            data: { entity_id: 'light.hallway' }
        }
    };
    setTimeout(() => node.send([null, turnOff]), 300000);

    return msg;
}
return null;
```

## HTTP Integration

### HTTP Nodes

```javascript
// HTTP In - Create endpoint
// Method: GET, POST, etc.
// URL: /api/data

// HTTP Request - Call external API
{
  "method": "GET",
  "url": "https://api.example.com/data",
  "headers": {
    "Authorization": "Bearer {{flow.token}}"
  }
}

// HTTP Response
msg.statusCode = 200;
msg.headers = { "Content-Type": "application/json" };
msg.payload = { status: "ok" };
return msg;
```

### Flow: REST API Endpoint

```javascript
// HTTP In -> Function -> HTTP Response

// Function: Handle API request
var response = {
    success: true,
    data: [],
    timestamp: new Date().toISOString()
};

switch (msg.req.method) {
    case 'GET':
        response.data = flow.get('items') || [];
        break;
    case 'POST':
        var items = flow.get('items') || [];
        items.push(msg.payload);
        flow.set('items', items);
        response.data = msg.payload;
        break;
}

msg.payload = response;
return msg;
```

## Dashboard (node-red-dashboard)

```bash
npm install node-red-dashboard
```

```json
// Button
{
  "group": "Home",
  "name": "Toggle Light",
  "topic": "light/toggle",
  "payload": "toggle"
}

// Gauge
{
  "group": "Sensors",
  "name": "Temperature",
  "min": 0,
  "max": 50,
  "units": "°C"
}

// Chart
{
  "group": "Sensors",
  "name": "Temperature History",
  "xaxis": "time",
  "yaxis": "value"
}

// Text Input
{
  "group": "Settings",
  "name": "Set Threshold",
  "mode": "number"
}
```

## Common Patterns

### Debounce

```javascript
// Prevent rapid-fire messages
var timeout = context.get('timeout');
if (timeout) {
    clearTimeout(timeout);
}
context.set('timeout', setTimeout(() => {
    node.send(msg);
}, 1000));
return null;
```

### Rate Limiting

```javascript
// Limit to 1 message per 5 seconds
var lastTime = context.get('lastTime') || 0;
var now = Date.now();

if (now - lastTime > 5000) {
    context.set('lastTime', now);
    return msg;
}
return null;
```

### State Machine

```javascript
var state = flow.get('state') || 'idle';
var event = msg.payload;

switch(state) {
    case 'idle':
        if (event === 'start') {
            flow.set('state', 'running');
            msg.payload = 'Started';
            return msg;
        }
        break;
    case 'running':
        if (event === 'stop') {
            flow.set('state', 'idle');
            msg.payload = 'Stopped';
            return msg;
        }
        break;
}
return null;
```

### Aggregation

```javascript
// Collect messages and send batch
var buffer = context.get('buffer') || [];
buffer.push(msg.payload);

if (buffer.length >= 10) {
    msg.payload = buffer;
    context.set('buffer', []);
    return msg;
}

context.set('buffer', buffer);
return null;
```

## Error Handling

```javascript
// Try-catch in function
try {
    var data = JSON.parse(msg.payload);
    msg.payload = data;
    return [msg, null];  // Success output
} catch (e) {
    msg.payload = { error: e.message };
    return [null, msg];  // Error output
}

// Catch node - catches errors from nodes
// Complete node - triggers on node completion
```

## Subflows

```json
// Create reusable flow components
// Right-click -> Subflow -> Create subflow
// Add inputs/outputs
// Set environment variables

// Access subflow env in function:
var threshold = env.get('THRESHOLD') || 100;
```

## Best Practices

1. **Name all nodes** for readability
2. **Use link nodes** to connect distant flows
3. **Add comments** with Comment nodes
4. **Use subflows** for reusable logic
5. **Handle errors** with Catch nodes
6. **Use context storage** for persistence
7. **Organize flows** in tabs
8. **Version control** flows.json
9. **Add status** to function nodes
10. **Test with inject** nodes
