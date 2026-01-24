---
name: grafana-dashboards
description: Build monitoring dashboards with Grafana. Covers panel types, queries, variables, alerting, provisioning, and data sources like Prometheus and InfluxDB. Use for infrastructure monitoring, observability, and metrics visualization. Triggers on grafana, dashboard, monitoring, prometheus, metrics, observability, alerting, InfluxDB.
---

# Grafana Dashboards

Build powerful monitoring and observability dashboards.

## Instructions

1. **Start with key metrics** - CPU, memory, latency, error rates
2. **Use consistent time ranges** - All panels should sync
3. **Add context with variables** - Filter by environment, service, host
4. **Set up alerts** - Proactive monitoring, not reactive
5. **Use templates** - Consistent dashboard styling

## Dashboard JSON Structure

```json
{
  "dashboard": {
    "id": null,
    "uid": "my-dashboard",
    "title": "Service Overview",
    "tags": ["production", "service-name"],
    "timezone": "browser",
    "refresh": "30s",
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "templating": { "list": [] },
    "panels": []
  }
}
```

## Panel Types

### Time Series

```json
{
  "type": "timeseries",
  "title": "Request Rate",
  "fieldConfig": {
    "defaults": {
      "unit": "reqps",
      "custom": {
        "lineWidth": 2,
        "fillOpacity": 10
      }
    }
  },
  "targets": [
    {
      "expr": "rate(http_requests_total{job=\"$job\"}[5m])",
      "legendFormat": "{{method}} {{status}}"
    }
  ]
}
```

### Stat Panel

```json
{
  "type": "stat",
  "title": "Total Requests",
  "options": {
    "colorMode": "value",
    "graphMode": "area",
    "reduceOptions": {
      "calcs": ["lastNotNull"]
    }
  }
}
```

### Gauge

```json
{
  "type": "gauge",
  "title": "CPU Usage",
  "fieldConfig": {
    "defaults": {
      "unit": "percent",
      "min": 0,
      "max": 100,
      "thresholds": {
        "steps": [
          { "color": "green", "value": null },
          { "color": "yellow", "value": 70 },
          { "color": "red", "value": 90 }
        ]
      }
    }
  }
}
```

## Prometheus Queries (PromQL)

### Basic Queries

```promql
# Instant rate (requests per second)
rate(http_requests_total[5m])

# Sum by label
sum by (status_code) (rate(http_requests_total[5m]))

# Average latency (95th percentile)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error rate percentage
sum(rate(http_requests_total{status=~"5.."}[5m])) /
sum(rate(http_requests_total[5m])) * 100

# CPU usage percentage
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) /
node_memory_MemTotal_bytes * 100
```

### Aggregation & Filtering

```promql
# Filter by label
http_requests_total{job="api", environment="production"}

# Regex match
http_requests_total{path=~"/api/v[0-9]+/.*"}

# Aggregations
sum(metric)              # Total
avg(metric)              # Average
max(metric)              # Maximum
topk(5, metric)          # Top 5 series

# Group by label
sum by (instance) (metric)
```

## Variables (Templating)

```json
{
  "templating": {
    "list": [
      {
        "name": "datasource",
        "type": "datasource",
        "query": "prometheus"
      },
      {
        "name": "environment",
        "type": "query",
        "datasource": "${datasource}",
        "query": "label_values(up, environment)",
        "refresh": 1,
        "multi": false,
        "includeAll": true
      }
    ]
  }
}
```

Usage in queries:
```promql
rate(http_requests_total{environment=~"$environment"}[$interval])
```

## Alerting

```json
{
  "alert": "HighErrorRate",
  "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m])) > 0.05",
  "for": "5m",
  "labels": {
    "severity": "critical"
  },
  "annotations": {
    "summary": "High error rate detected"
  }
}
```

## Dashboard Provisioning

### File Structure

```
grafana/
+-- provisioning/
|   +-- dashboards/
|   |   +-- dashboards.yaml
|   +-- datasources/
|       +-- datasources.yaml
+-- dashboards/
    +-- overview.json
```

### Datasources Config

```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

## Common Dashboard Patterns

### RED Method (Request, Error, Duration)

```promql
# Request Rate
sum(rate(http_requests_total[5m]))

# Error Rate
sum(rate(http_requests_total{status=~"5.."}[5m])) /
sum(rate(http_requests_total[5m]))

# Duration (95th percentile)
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
```

### USE Method (Utilization, Saturation, Errors)

```promql
# CPU Utilization
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory Saturation
node_memory_SwapCached_bytes / node_memory_SwapTotal_bytes

# Network Errors
rate(node_network_receive_errs_total[5m])
```

## Best Practices

1. **Use consistent colors** - Red for errors, green for success
2. **Add descriptions** - Panel descriptions explain what's shown
3. **Set meaningful thresholds** - Color changes at important values
4. **Link related dashboards** - Drill-down from overview to details
5. **Version control dashboards** - Store JSON in git
6. **Use dashboard folders** - Organize by team or service

## When to Use This Skill

- Infrastructure monitoring
- Application performance monitoring
- Business metrics dashboards
- Real-time operational dashboards
- SLA/SLO tracking
- Building observability platforms
