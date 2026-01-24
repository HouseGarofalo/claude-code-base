# Home Assistant Complete Reference

## REST API Complete Reference

### Authentication

All API requests require a Long-Lived Access Token.

**Creating a Token:**
1. Navigate to Profile (bottom left in HA UI)
2. Scroll to "Long-Lived Access Tokens"
3. Click "Create Token"
4. Copy the token (shown only once)

**Request Headers:**
```
Authorization: Bearer YOUR_LONG_LIVED_ACCESS_TOKEN
Content-Type: application/json
```

---

## API Endpoints

### System & Configuration

#### GET /api/
Check if API is running.

**Response:**
```json
{"message": "API running."}
```

---

#### GET /api/config
Returns current Home Assistant configuration.

**Response:**
```json
{
  "components": ["automation", "light", "sensor", ...],
  "config_dir": "/config",
  "elevation": 100,
  "latitude": 40.7128,
  "longitude": -74.0060,
  "location_name": "Home",
  "time_zone": "America/New_York",
  "unit_system": {
    "length": "mi",
    "mass": "lb",
    "temperature": "°F",
    "volume": "gal"
  },
  "version": "2024.1.0",
  "allowlist_external_dirs": [],
  "allowlist_external_urls": [],
  "currency": "USD",
  "country": "US",
  "language": "en"
}
```

---

#### GET /api/components
Returns list of currently loaded components.

**Response:**
```json
["automation", "binary_sensor", "climate", "light", "sensor", "switch", ...]
```

---

#### POST /api/config/core/check_config
Validates the configuration files.

**Response (Valid):**
```json
{
  "result": "valid",
  "errors": null
}
```

**Response (Invalid):**
```json
{
  "result": "invalid",
  "errors": "Invalid config for [sensor.template]: required key not provided @ data['sensors']"
}
```

---

### States

#### GET /api/states
Returns all entity states.

**Response:**
```json
[
  {
    "entity_id": "light.living_room",
    "state": "on",
    "attributes": {
      "brightness": 255,
      "color_temp": 370,
      "friendly_name": "Living Room Light",
      "supported_features": 63
    },
    "last_changed": "2024-01-15T10:30:00+00:00",
    "last_updated": "2024-01-15T10:30:00+00:00",
    "context": {
      "id": "01HN...",
      "parent_id": null,
      "user_id": null
    }
  },
  ...
]
```

---

#### GET /api/states/{entity_id}
Returns state for a specific entity.

**Example:** `GET /api/states/light.living_room`

**Response:**
```json
{
  "entity_id": "light.living_room",
  "state": "on",
  "attributes": {
    "brightness": 255,
    "friendly_name": "Living Room Light"
  },
  "last_changed": "2024-01-15T10:30:00+00:00",
  "last_updated": "2024-01-15T10:30:00+00:00"
}
```

**Response (Not Found):**
```json
{"message": "Entity not found."}
```

---

#### POST /api/states/{entity_id}
Create or update an entity state.

**Request Body:**
```json
{
  "state": "on",
  "attributes": {
    "brightness": 200,
    "friendly_name": "Living Room Light"
  }
}
```

**Response Codes:**
- `201` - New entity created
- `200` - Existing entity updated

---

#### DELETE /api/states/{entity_id}
Remove an entity from state machine.

**Response:**
```json
{"message": "Entity removed."}
```

---

### Services

#### GET /api/services
Returns available services grouped by domain.

**Response:**
```json
[
  {
    "domain": "light",
    "services": {
      "turn_on": {
        "name": "Turn on",
        "description": "Turn on a light",
        "fields": {
          "entity_id": {
            "description": "Name(s) of entities to turn on",
            "example": "light.kitchen"
          },
          "brightness": {
            "description": "Brightness level (0-255)",
            "example": 200
          },
          "brightness_pct": {
            "description": "Brightness percentage (0-100)",
            "example": 80
          },
          "color_temp": {
            "description": "Color temperature in mireds",
            "example": 300
          },
          "rgb_color": {
            "description": "RGB color [R, G, B]",
            "example": [255, 100, 100]
          },
          "transition": {
            "description": "Transition duration in seconds",
            "example": 2
          }
        }
      },
      "turn_off": {...},
      "toggle": {...}
    }
  },
  ...
]
```

---

#### POST /api/services/{domain}/{service}
Call a service.

**Example:** `POST /api/services/light/turn_on`

**Request Body:**
```json
{
  "entity_id": "light.living_room",
  "brightness_pct": 75,
  "transition": 2
}
```

**Response:**
```json
[
  {
    "entity_id": "light.living_room",
    "state": "on",
    "attributes": {...}
  }
]
```

**With Response Data:** `POST /api/services/domain/service?return_response`

Some services return data when called with `?return_response`:
```json
{
  "service_response": {
    "entity_id": {...}
  },
  "changed_states": [...]
}
```

---

### Common Service Calls

#### Lights

```bash
# Turn on
curl -X POST "http://HA:8123/api/services/light/turn_on" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "light.living_room"}'

# Turn on with brightness
curl -X POST "http://HA:8123/api/services/light/turn_on" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "light.living_room", "brightness_pct": 50}'

# Turn on with color
curl -X POST "http://HA:8123/api/services/light/turn_on" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "light.living_room", "rgb_color": [255, 0, 0]}'

# Turn off
curl -X POST "http://HA:8123/api/services/light/turn_off" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "light.living_room"}'

# Toggle
curl -X POST "http://HA:8123/api/services/light/toggle" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "light.living_room"}'
```

#### Switches

```bash
# Turn on
curl -X POST "http://HA:8123/api/services/switch/turn_on" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "switch.coffee_maker"}'

# Turn off
curl -X POST "http://HA:8123/api/services/switch/turn_off" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "switch.coffee_maker"}'
```

#### Climate

```bash
# Set temperature
curl -X POST "http://HA:8123/api/services/climate/set_temperature" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "climate.thermostat", "temperature": 72}'

# Set HVAC mode
curl -X POST "http://HA:8123/api/services/climate/set_hvac_mode" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "climate.thermostat", "hvac_mode": "heat"}'

# HVAC modes: off, heat, cool, heat_cool, auto, dry, fan_only
```

#### Covers (Blinds/Garage)

```bash
# Open
curl -X POST "http://HA:8123/api/services/cover/open_cover" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "cover.garage"}'

# Close
curl -X POST "http://HA:8123/api/services/cover/close_cover" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "cover.garage"}'

# Set position (0-100)
curl -X POST "http://HA:8123/api/services/cover/set_cover_position" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "cover.blinds", "position": 50}'
```

#### Automations & Scripts

```bash
# Trigger automation
curl -X POST "http://HA:8123/api/services/automation/trigger" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "automation.morning_routine"}'

# Enable/disable automation
curl -X POST "http://HA:8123/api/services/automation/turn_on" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "automation.morning_routine"}'

# Run script
curl -X POST "http://HA:8123/api/services/script/turn_on" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "script.movie_mode"}'

# Run script with variables
curl -X POST "http://HA:8123/api/services/script/turn_on" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "script.notify_user", "variables": {"message": "Hello!"}}'
```

#### Scenes

```bash
# Activate scene
curl -X POST "http://HA:8123/api/services/scene/turn_on" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "scene.movie_time"}'
```

#### Notifications

```bash
# Mobile app notification
curl -X POST "http://HA:8123/api/services/notify/mobile_app_phone" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Motion detected at front door!",
    "title": "Security Alert",
    "data": {
      "image": "/api/camera_proxy/camera.front_door"
    }
  }'

# Persistent notification (shows in HA UI)
curl -X POST "http://HA:8123/api/services/persistent_notification/create" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Please check the garage door",
    "title": "Reminder",
    "notification_id": "garage_reminder"
  }'
```

#### Input Helpers

```bash
# Set input_boolean
curl -X POST "http://HA:8123/api/services/input_boolean/turn_on" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "input_boolean.vacation_mode"}'

# Set input_number
curl -X POST "http://HA:8123/api/services/input_number/set_value" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "input_number.target_temp", "value": 72}'

# Set input_select
curl -X POST "http://HA:8123/api/services/input_select/select_option" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "input_select.home_mode", "option": "Away"}'

# Set input_text
curl -X POST "http://HA:8123/api/services/input_text/set_value" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "input_text.welcome_message", "value": "Welcome home!"}'

# Set input_datetime
curl -X POST "http://HA:8123/api/services/input_datetime/set_datetime" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "input_datetime.alarm_time", "time": "07:00:00"}'
```

---

### Events

#### GET /api/events
Returns registered event types.

**Response:**
```json
[
  {"event": "state_changed", "listener_count": 45},
  {"event": "time_changed", "listener_count": 12},
  {"event": "homeassistant_start", "listener_count": 5},
  {"event": "call_service", "listener_count": 3},
  ...
]
```

---

#### POST /api/events/{event_type}
Fire an event.

**Example:** `POST /api/events/custom_event`

**Request Body:**
```json
{
  "key": "value",
  "message": "Custom event fired"
}
```

**Response:**
```json
{"message": "Event custom_event fired."}
```

---

### History & Logbook

#### GET /api/history/period/{timestamp}
Get state history for entities.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `timestamp` | ISO8601 | Start time (e.g., `2024-01-01T00:00:00`) |
| `filter_entity_id` | string | Comma-separated entity IDs |
| `end_time` | ISO8601 | End time |
| `minimal_response` | bool | Return minimal data |
| `no_attributes` | bool | Exclude attributes |
| `significant_changes_only` | bool | Only significant changes |

**Example:**
```bash
curl -s "http://HA:8123/api/history/period/2024-01-15T00:00:00?filter_entity_id=sensor.temperature&end_time=2024-01-16T00:00:00" \
  -H "Authorization: Bearer TOKEN"
```

**Response:**
```json
[
  [
    {
      "entity_id": "sensor.temperature",
      "state": "72.5",
      "attributes": {"unit_of_measurement": "°F"},
      "last_changed": "2024-01-15T00:00:00+00:00",
      "last_updated": "2024-01-15T00:00:00+00:00"
    },
    ...
  ]
]
```

---

#### GET /api/logbook/{timestamp}
Get logbook entries.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `timestamp` | ISO8601 | Start time |
| `entity` | string | Filter by entity |
| `end_time` | ISO8601 | End time |

**Response:**
```json
[
  {
    "when": "2024-01-15T10:30:00+00:00",
    "name": "Living Room Light",
    "entity_id": "light.living_room",
    "state": "on",
    "message": "turned on"
  },
  ...
]
```

---

### Templates

#### POST /api/template
Render a Jinja2 template.

**Request Body:**
```json
{
  "template": "The temperature is {{ states('sensor.temperature') }}°F"
}
```

**Response:**
```
The temperature is 72.5°F
```

**Complex Template:**
```json
{
  "template": "{% set lights = states.light | selectattr('state', 'eq', 'on') | list %}There are {{ lights | count }} lights on: {{ lights | map(attribute='entity_id') | join(', ') }}"
}
```

---

### Error Log

#### GET /api/error_log
Returns the error log as plain text.

**Response:**
```
2024-01-15 10:30:00 ERROR (MainThread) [homeassistant.core] Error doing job...
2024-01-15 10:31:00 WARNING (MainThread) [homeassistant.components.sensor] ...
```

---

### Cameras

#### GET /api/camera_proxy/{camera_entity_id}
Returns camera image.

**Response:** Binary image data (JPEG/PNG)

**Usage in notifications:**
```json
{
  "message": "Motion detected",
  "data": {
    "image": "/api/camera_proxy/camera.front_door"
  }
}
```

---

### Calendars

#### GET /api/calendars
List all calendar entities.

**Response:**
```json
[
  {
    "entity_id": "calendar.personal",
    "name": "Personal Calendar"
  },
  ...
]
```

---

#### GET /api/calendars/{calendar_entity_id}
Get calendar events.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `start` | ISO8601 | Start datetime |
| `end` | ISO8601 | End datetime |

**Example:**
```bash
curl -s "http://HA:8123/api/calendars/calendar.personal?start=2024-01-15T00:00:00&end=2024-01-16T00:00:00" \
  -H "Authorization: Bearer TOKEN"
```

---

## Jinja2 Template Reference

### State Access

```jinja2
{# Get state value #}
{{ states('sensor.temperature') }}

{# Get state with default #}
{{ states('sensor.temperature') | default('unknown') }}

{# Check if available #}
{{ states('sensor.temperature') not in ['unknown', 'unavailable'] }}

{# Check specific state #}
{{ is_state('light.living_room', 'on') }}

{# Get attribute #}
{{ state_attr('light.living_room', 'brightness') }}

{# Get all attributes #}
{{ states.light.living_room.attributes }}

{# Check if entity exists #}
{{ states('sensor.temperature') is not none }}
```

### Time & Date

```jinja2
{# Current time #}
{{ now() }}
{{ now().hour }}
{{ now().minute }}
{{ now().strftime('%H:%M') }}

{# Today's date #}
{{ now().date() }}
{{ now().strftime('%Y-%m-%d') }}

{# Day of week (0=Monday) #}
{{ now().weekday() }}

{# Time comparisons #}
{{ now().hour >= 6 and now().hour < 22 }}

{# Time since last changed #}
{{ (now() - states.sensor.motion.last_changed).total_seconds() }}

{# Timestamp formatting #}
{{ as_timestamp(states.sensor.motion.last_changed) | timestamp_custom('%H:%M') }}
```

### Filters

```jinja2
{# Math #}
{{ states('sensor.temp') | float }}
{{ states('sensor.temp') | int }}
{{ states('sensor.temp') | round(1) }}
{{ states('sensor.temp') | abs }}

{# String manipulation #}
{{ states('sensor.status') | lower }}
{{ states('sensor.status') | upper }}
{{ states('sensor.status') | title }}
{{ states('sensor.status') | replace('_', ' ') }}

{# Lists #}
{{ [1, 2, 3] | sum }}
{{ [1, 2, 3] | min }}
{{ [1, 2, 3] | max }}
{{ [1, 2, 3] | avg }}
{{ [1, 2, 3] | join(', ') }}

{# Entity filtering #}
{{ states.light | selectattr('state', 'eq', 'on') | list | count }}
{{ states.sensor | selectattr('entity_id', 'search', 'temperature') | list }}
```

### Conditions

```jinja2
{# If/else #}
{% if is_state('light.living_room', 'on') %}
  Light is on
{% else %}
  Light is off
{% endif %}

{# Ternary #}
{{ 'Home' if is_state('person.john', 'home') else 'Away' }}

{# Multiple conditions #}
{% if is_state('light.living_room', 'on') and is_state('light.kitchen', 'on') %}
  Both lights are on
{% endif %}
```

### Loops

```jinja2
{# Loop through entities #}
{% for light in states.light %}
  {{ light.entity_id }}: {{ light.state }}
{% endfor %}

{# Loop with filter #}
{% for light in states.light | selectattr('state', 'eq', 'on') %}
  {{ light.name }} is on
{% endfor %}
```

---

## YAML Configuration Reference

### configuration.yaml Structure

```yaml
# Core configuration
homeassistant:
  name: Home
  latitude: 40.7128
  longitude: -74.0060
  elevation: 10
  unit_system: imperial
  time_zone: America/New_York
  currency: USD
  country: US

  # Entity customization
  customize:
    light.living_room:
      friendly_name: "Living Room Lights"
      icon: mdi:ceiling-light
    sensor.temperature:
      device_class: temperature

# Includes
automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml

# Split configuration
sensor: !include_dir_merge_list sensors/
binary_sensor: !include_dir_merge_list binary_sensors/

# Packages (self-contained features)
homeassistant:
  packages: !include_dir_named packages/
```

### Include Directives

| Directive | Description | Result |
|-----------|-------------|--------|
| `!include file.yaml` | Include single file | Contents merged |
| `!include_dir_list dir/` | Include all files as list | List of file contents |
| `!include_dir_named dir/` | Include files as dict | Dict keyed by filename |
| `!include_dir_merge_list dir/` | Merge files into list | Combined list |
| `!include_dir_merge_named dir/` | Merge files into dict | Combined dict |

### Logger Configuration

```yaml
logger:
  default: warning
  logs:
    homeassistant.core: info
    homeassistant.components.automation: debug
    homeassistant.components.script: debug
    homeassistant.components.template: debug
    custom_components.my_integration: debug
    # External libraries
    aiohttp.server: warning
    async_upnp_client: warning
```

### Recorder Configuration

```yaml
recorder:
  db_url: sqlite:////config/home-assistant_v2.db
  purge_keep_days: 10
  commit_interval: 1
  exclude:
    domains:
      - automation
      - updater
    entity_globs:
      - sensor.weather_*
    entities:
      - sun.sun
```

### HTTP Configuration

```yaml
http:
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
  ip_ban_enabled: true
  login_attempts_threshold: 5
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.33.0/24
```

---

## Response Codes Reference

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created (new entity/resource) |
| 400 | Bad Request (invalid JSON or parameters) |
| 401 | Unauthorized (missing/invalid token) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found (entity/endpoint doesn't exist) |
| 405 | Method Not Allowed |
| 500 | Internal Server Error |

---

## WebSocket API (Brief)

For real-time updates, Home Assistant also supports WebSocket connections:

**Endpoint:** `ws://HA:8123/api/websocket`

**Authentication:**
```json
{"type": "auth", "access_token": "YOUR_TOKEN"}
```

**Subscribe to state changes:**
```json
{"id": 1, "type": "subscribe_events", "event_type": "state_changed"}
```

The WebSocket API is more efficient for dashboards and real-time monitoring but requires maintaining a connection.

---

## Rate Limits & Best Practices

1. **No official rate limits** but be respectful
2. **Cache frequently accessed states** when possible
3. **Use WebSocket** for real-time updates instead of polling
4. **Batch operations** when modifying multiple entities
5. **Use `minimal_response`** for history queries when attributes aren't needed
