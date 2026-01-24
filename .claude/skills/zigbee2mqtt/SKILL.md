---
name: zigbee2mqtt
description: Configure Zigbee2MQTT for smart home Zigbee device management. Pair devices, configure entities, manage network topology, and integrate with Home Assistant. Use when working with Zigbee devices, mesh networks, or smart home sensors and switches. (project)
---

# Zigbee2MQTT Manager

Expert guidance for Zigbee2MQTT smart home integration.

## When to Use This Skill

- Setting up Zigbee2MQTT with coordinators
- Pairing and configuring Zigbee devices
- Managing Zigbee mesh network
- Home Assistant integration
- Troubleshooting device connectivity
- OTA firmware updates

## Installation

```yaml
# docker-compose.yml
version: '3.8'
services:
  zigbee2mqtt:
    image: koenkk/zigbee2mqtt
    restart: unless-stopped
    volumes:
      - ./zigbee2mqtt-data:/app/data
      - /run/udev:/run/udev:ro
    ports:
      - "8080:8080"  # Frontend
    environment:
      - TZ=America/New_York
    devices:
      - /dev/ttyUSB0:/dev/ttyACM0  # Zigbee adapter
    # For network adapters (Sonoff ZBDongle-E, etc.)
    # network_mode: host

  mosquitto:
    image: eclipse-mosquitto:2
    restart: unless-stopped
    ports:
      - "1883:1883"
    volumes:
      - ./mosquitto:/mosquitto
```

## Configuration

```yaml
# configuration.yaml
homeassistant: true
permit_join: false
mqtt:
  base_topic: zigbee2mqtt
  server: mqtt://localhost:1883
  user: mqtt_user
  password: mqtt_password

serial:
  port: /dev/ttyUSB0
  # For network adapter:
  # port: tcp://192.168.1.100:6638

frontend:
  port: 8080
  host: 0.0.0.0

advanced:
  homeassistant_discovery_topic: homeassistant
  homeassistant_status_topic: homeassistant/status
  last_seen: ISO_8601
  elapsed: false
  log_level: info
  log_output:
    - console
    - file
  network_key: GENERATE
  pan_id: GENERATE
  channel: 15

availability:
  active:
    timeout: 10
  passive:
    timeout: 1500

device_options:
  retain: true

ota:
  update_check_interval: 1440
  disable_automatic_update_check: false
```

## Device Configuration

```yaml
# devices.yaml (in data directory)
'0x00158d0001234567':
  friendly_name: 'living_room_motion'
  retain: true

'0x00158d0007654321':
  friendly_name: 'bedroom_temperature'
  homeassistant:
    temperature:
      device_class: temperature
      unit_of_measurement: '°C'
    humidity:
      device_class: humidity

# Device-specific settings
'0x00124b0012345678':
  friendly_name: 'smart_plug'
  retention: true
  reporting:
    power:
      min_interval: 10
      max_interval: 300
      change: 5
```

## Groups Configuration

```yaml
# groups.yaml
'1':
  friendly_name: living_room_lights
  retain: true
  devices:
    - living_room_bulb_1
    - living_room_bulb_2
    - living_room_bulb_3

'2':
  friendly_name: all_lights
  devices:
    - living_room_bulb_1
    - living_room_bulb_2
    - bedroom_light
    - kitchen_light
```

## MQTT Topics

```bash
# Device state (published by z2m)
zigbee2mqtt/<friendly_name>
zigbee2mqtt/living_room_motion
# {"occupancy":true,"battery":100,"linkquality":120}

# Set device state
zigbee2mqtt/<friendly_name>/set
# {"state": "ON", "brightness": 255}

# Get device state
zigbee2mqtt/<friendly_name>/get
# {"state": ""}

# Bridge topics
zigbee2mqtt/bridge/state          # online/offline
zigbee2mqtt/bridge/info           # Bridge information
zigbee2mqtt/bridge/devices        # All devices
zigbee2mqtt/bridge/groups         # All groups
zigbee2mqtt/bridge/config         # Configuration

# Bridge requests
zigbee2mqtt/bridge/request/permit_join
# {"value": true, "time": 120}

zigbee2mqtt/bridge/request/device/rename
# {"from": "0x00158d0001234567", "to": "kitchen_sensor"}

zigbee2mqtt/bridge/request/device/remove
# {"id": "kitchen_sensor", "force": false}

zigbee2mqtt/bridge/request/device/ota_update/check
# {"id": "bulb_1"}

zigbee2mqtt/bridge/request/device/ota_update/update
# {"id": "bulb_1"}
```

## Common Device Commands

### Lights

```json
// Turn on
{"state": "ON"}

// Set brightness (0-255)
{"state": "ON", "brightness": 200}

// Set color temperature (Mired)
{"color_temp": 350}

// Set color (RGB)
{"color": {"r": 255, "g": 100, "b": 50}}

// Set color (HSV)
{"color": {"hue": 30, "saturation": 100}}

// Set color (XY)
{"color": {"x": 0.5, "y": 0.4}}

// Transition
{"state": "ON", "brightness": 255, "transition": 2}

// Effect
{"effect": "colorloop"}
```

### Switches/Plugs

```json
// Toggle
{"state": "TOGGLE"}

// ON/OFF
{"state": "ON"}
{"state": "OFF"}

// Power reporting (read)
{"power": ""}
{"energy": ""}
```

### Thermostats

```json
// Set temperature
{"current_heating_setpoint": 22}

// Set mode
{"system_mode": "heat"}
// Options: off, heat, cool, auto

// Away preset
{"away_mode": "ON"}
```

### Covers/Blinds

```json
// Open/Close
{"state": "OPEN"}
{"state": "CLOSE"}
{"state": "STOP"}

// Set position (0-100)
{"position": 50}

// Set tilt
{"tilt": 45}
```

## Home Assistant Integration

```yaml
# Automatic MQTT discovery is enabled by default
# Devices appear automatically when homeassistant: true

# Manual entity customization in HA
mqtt:
  sensor:
    - name: "Living Room Temperature"
      state_topic: "zigbee2mqtt/living_room_sensor"
      value_template: "{{ value_json.temperature }}"
      unit_of_measurement: "°C"
      device_class: temperature

  light:
    - name: "Smart Bulb"
      schema: json
      state_topic: "zigbee2mqtt/smart_bulb"
      command_topic: "zigbee2mqtt/smart_bulb/set"
      brightness: true
      color_temp: true
      xy: true
```

## Network Management

### Coordinator Types

```yaml
# USB Stick (CC2531, CC2652, etc.)
serial:
  port: /dev/ttyUSB0
  adapter: zstack  # or ember, deconz

# Network adapter (Tube ZB, etc.)
serial:
  port: tcp://192.168.1.100:6638
  adapter: zstack

# Sonoff ZBDongle-E (Silicon Labs)
serial:
  port: /dev/ttyUSB0
  adapter: ember

# ConBee II
serial:
  port: /dev/ttyACM0
  adapter: deconz
```

### Channel Selection

```yaml
# Best channels for minimal WiFi interference:
# Channel 11, 15, 20, 25, 26

advanced:
  channel: 15  # Recommended default
  # channel: 25  # Alternative if 15 has issues
```

### Network Map

```bash
# Request network map
mosquitto_pub -t zigbee2mqtt/bridge/request/networkmap -m '{"type":"graphviz","routes":true}'

# Response on zigbee2mqtt/bridge/response/networkmap
```

## Troubleshooting

### Device Not Pairing

```yaml
# Enable pairing
permit_join: true
# Or via MQTT:
# mosquitto_pub -t zigbee2mqtt/bridge/request/permit_join -m '{"value":true}'

# Check coordinator
# Logs should show "Coordinator started"

# Factory reset device (device-specific, usually hold button 5-10 seconds)

# Try removing and re-adding
# mosquitto_pub -t zigbee2mqtt/bridge/request/device/remove -m '{"id":"device_name","force":true}'
```

### Connectivity Issues

```bash
# Check device linkquality
# Values below 30 indicate poor connection

# Check routing
# mosquitto_pub -t zigbee2mqtt/bridge/request/networkmap -m '{"type":"graphviz"}'

# Add router devices (powered devices) between end devices and coordinator

# Check for interference
# - WiFi on same channel
# - USB 3.0 ports (use extension cable)
# - Other 2.4GHz devices
```

### Logs

```bash
# View logs
docker logs -f zigbee2mqtt

# Increase log level for debugging
# configuration.yaml:
advanced:
  log_level: debug
```

## OTA Updates

```yaml
# configuration.yaml
ota:
  update_check_interval: 1440  # Check every 24 hours
  disable_automatic_update_check: false

# Manual check
# mosquitto_pub -t zigbee2mqtt/bridge/request/device/ota_update/check -m '{"id":"bulb_1"}'

# Update device
# mosquitto_pub -t zigbee2mqtt/bridge/request/device/ota_update/update -m '{"id":"bulb_1"}'
```

## Best Practices

1. **Use a dedicated coordinator** (CC2652, Sonoff ZBDongle-E)
2. **Keep coordinator away from USB 3.0** (use extension cable)
3. **Add router devices** for better mesh coverage
4. **Choose optimal channel** (11, 15, 20, 25)
5. **Monitor linkquality** for connectivity issues
6. **Use groups** for synchronized control
7. **Enable OTA updates** for security patches
8. **Backup configuration** regularly
9. **Use descriptive friendly names**
10. **Document device locations** and purposes
