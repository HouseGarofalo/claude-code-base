---
name: homebridge
description: >
  Homebridge server management for Apple HomeKit integration. Install plugins, configure accessories,
  manage bridges, and troubleshoot HomeKit connectivity. Use when working with Homebridge, HomeKit,
  Apple Home app, Siri control, or bridging non-HomeKit devices to Apple ecosystem.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash, WebFetch
---

# Homebridge Skill

Complete guide for managing Homebridge - the HomeKit bridge for non-native devices.

## Quick Reference

### Key Paths
| Path | Purpose |
|------|---------|
| `~/.homebridge/` | Config and plugins (standalone) |
| `/var/lib/homebridge/` | Config (service install) |
| `config.json` | Main configuration file |

### Common Commands
```bash
homebridge                    # Start Homebridge
homebridge -D                 # Debug mode
homebridge -U /path/to/dir    # Custom storage path
hb-service status             # Service status
hb-service restart            # Restart service
```

---

## 1. Installation

### Using hb-service (Recommended)
```bash
# Install Node.js and Homebridge
sudo npm install -g homebridge homebridge-config-ui-x

# Setup as service
sudo hb-service install --user homebridge

# Access UI at http://localhost:8581
# Default: admin / admin
```

### Docker Installation
```yaml
version: "3"
services:
  homebridge:
    image: homebridge/homebridge:latest
    container_name: homebridge
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./homebridge:/homebridge
    environment:
      - HOMEBRIDGE_CONFIG_UI=1
      - HOMEBRIDGE_CONFIG_UI_PORT=8581
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "1"
```

### Manual Installation
```bash
# Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Homebridge
sudo npm install -g homebridge

# Create config directory
mkdir -p ~/.homebridge
```

---

## 2. Configuration

### Basic config.json
```json
{
  "bridge": {
    "name": "Homebridge",
    "username": "CC:22:3D:E3:CE:30",
    "port": 51826,
    "pin": "031-45-154",
    "advertiser": "bonjour-hap"
  },
  "accessories": [],
  "platforms": []
}
```

### Bridge Settings
```json
{
  "bridge": {
    "name": "My Homebridge",
    "username": "0E:95:4E:6D:B5:DA",
    "port": 51826,
    "pin": "123-45-678",
    "advertiser": "bonjour-hap",
    "bind": ["192.168.1.100"]
  }
}
```

### Child Bridges (Isolate Plugins)
```json
{
  "platforms": [
    {
      "platform": "SomePlatform",
      "_bridge": {
        "username": "0E:95:4E:6D:B5:DB",
        "port": 51827
      }
    }
  ]
}
```

---

## 3. Plugin Management

### Install Plugins
```bash
# Via npm
sudo npm install -g homebridge-hue

# Via hb-service
sudo hb-service add homebridge-hue

# Via UI
# Settings > Plugins > Search and Install
```

### Popular Plugins
```bash
# Smart Home Integrations
homebridge-hue              # Philips Hue
homebridge-homeassistant    # Home Assistant
homebridge-smartthings      # SmartThings
homebridge-ring             # Ring cameras/doorbells
homebridge-nest             # Google Nest
homebridge-myq              # MyQ garage doors

# Camera Plugins
homebridge-camera-ffmpeg    # Generic RTSP cameras
homebridge-unifi-protect    # UniFi Protect

# Device Plugins
homebridge-tasmota          # Tasmota devices
homebridge-mqtt             # MQTT devices
homebridge-tuya-web         # Tuya/Smart Life
homebridge-broadlink-rm     # Broadlink IR/RF
```

### Update Plugins
```bash
# Update all plugins
sudo npm update -g

# Update specific plugin
sudo npm update -g homebridge-hue

# Via UI: Settings > Plugins > Update
```

---

## 4. Accessory Configuration

### Static Accessories
```json
{
  "accessories": [
    {
      "accessory": "HTTP-SWITCH",
      "name": "Kitchen Light",
      "switchType": "stateless",
      "onUrl": "http://192.168.1.100/on",
      "offUrl": "http://192.168.1.100/off"
    }
  ]
}
```

### Platform Accessories
```json
{
  "platforms": [
    {
      "platform": "Camera-ffmpeg",
      "cameras": [
        {
          "name": "Front Door",
          "videoConfig": {
            "source": "-i rtsp://user:pass@192.168.1.50:554/stream",
            "stillImageSource": "-i http://192.168.1.50/snapshot.jpg",
            "maxStreams": 2,
            "maxWidth": 1920,
            "maxHeight": 1080,
            "maxFPS": 30
          }
        }
      ]
    }
  ]
}
```

### MQTT Accessories
```json
{
  "platforms": [
    {
      "platform": "mqttthing",
      "accessories": [
        {
          "type": "lightbulb",
          "name": "Living Room Light",
          "topics": {
            "getOn": "home/living/light/status",
            "setOn": "home/living/light/set"
          }
        },
        {
          "type": "temperatureSensor",
          "name": "Bedroom Temperature",
          "topics": {
            "getCurrentTemperature": "home/bedroom/temperature"
          }
        }
      ]
    }
  ]
}
```

---

## 5. Camera Configuration

### FFmpeg Camera
```json
{
  "platform": "Camera-ffmpeg",
  "cameras": [
    {
      "name": "Backyard",
      "manufacturer": "Generic",
      "model": "RTSP Camera",
      "videoConfig": {
        "source": "-rtsp_transport tcp -i rtsp://user:pass@192.168.1.100:554/stream1",
        "stillImageSource": "-i http://192.168.1.100/snapshot.jpg",
        "maxStreams": 2,
        "maxWidth": 1920,
        "maxHeight": 1080,
        "maxFPS": 30,
        "vcodec": "libx264",
        "audio": true,
        "packetSize": 1316,
        "debug": false
      }
    }
  ]
}
```

### Hardware Transcoding
```json
{
  "videoConfig": {
    "source": "-i rtsp://...",
    "vcodec": "h264_v4l2m2m",
    "encoderOptions": "-preset ultrafast -tune zerolatency"
  }
}
```

---

## 6. Home Assistant Integration

### homebridge-homeassistant Plugin
```json
{
  "platforms": [
    {
      "platform": "HomeAssistant",
      "name": "HomeAssistant",
      "host": "http://192.168.1.10:8123",
      "access_token": "YOUR_LONG_LIVED_ACCESS_TOKEN",
      "filter": {
        "include_domains": ["light", "switch", "sensor", "climate"],
        "exclude_entities": ["light.ignore_this"]
      }
    }
  ]
}
```

### Entity Filtering
```json
{
  "filter": {
    "include_domains": ["light", "switch"],
    "include_entities": ["sensor.temperature"],
    "exclude_domains": ["automation"],
    "exclude_entities": ["light.test"]
  }
}
```

---

## 7. Service Management

### hb-service Commands
```bash
# Install service
sudo hb-service install --user homebridge

# Service control
sudo hb-service start
sudo hb-service stop
sudo hb-service restart
sudo hb-service status

# View logs
sudo hb-service logs

# Uninstall
sudo hb-service uninstall
```

### Systemd (Manual)
```bash
# Service file: /etc/systemd/system/homebridge.service
[Unit]
Description=Homebridge
After=network.target

[Service]
Type=simple
User=homebridge
ExecStart=/usr/bin/homebridge -U /var/lib/homebridge
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target

# Enable and start
sudo systemctl enable homebridge
sudo systemctl start homebridge
```

---

## 8. Pairing with HomeKit

### Initial Pairing
1. Open Apple Home app
2. Tap "+" > "Add Accessory"
3. Scan QR code from Homebridge UI or enter PIN manually
4. Follow prompts to complete pairing

### Reset Pairing
```bash
# Remove accessories cache
rm -rf ~/.homebridge/accessories
rm -rf ~/.homebridge/persist

# Or via UI: Settings > Reset Homebridge Accessory
```

### Multiple Bridges
```json
{
  "bridge": {
    "name": "Main Bridge",
    "username": "CC:22:3D:E3:CE:30",
    "port": 51826,
    "pin": "031-45-154"
  },
  "platforms": [
    {
      "platform": "Camera-ffmpeg",
      "_bridge": {
        "name": "Camera Bridge",
        "username": "CC:22:3D:E3:CE:31",
        "port": 51827
      },
      "cameras": [...]
    }
  ]
}
```

---

## 9. Troubleshooting

### Common Issues

**Device not showing in HomeKit:**
```bash
# Check logs
hb-service logs

# Restart Homebridge
hb-service restart

# Reset accessory cache
rm ~/.homebridge/accessories/*
hb-service restart
```

**Pairing fails:**
```bash
# Reset pairing
rm ~/.homebridge/persist/*
hb-service restart

# Check network
ping -c 4 <homebridge-ip>
```

**Plugin errors:**
```bash
# Reinstall plugin
sudo npm uninstall -g homebridge-plugin-name
sudo npm install -g homebridge-plugin-name

# Check Node version
node -v  # Should be 18+
```

**mDNS/Bonjour issues:**
```bash
# Install avahi
sudo apt install avahi-daemon

# Check status
systemctl status avahi-daemon

# Use ciao advertiser
"advertiser": "ciao"
```

### Debug Mode
```bash
# Run with debug output
homebridge -D

# Enable debug for specific plugin
DEBUG=* homebridge

# In config.json
"debug": true
```

### Log Locations
```bash
# Service logs
journalctl -u homebridge -f

# hb-service logs
hb-service logs

# Manual logs
~/.homebridge/homebridge.log
```

---

## 10. Best Practices

### Performance
1. Use **child bridges** for unstable plugins
2. Enable **hardware transcoding** for cameras
3. Limit camera streams to 2-3 concurrent
4. Use **wired connection** for Homebridge server

### Security
1. Change **default admin password**
2. Use **HTTPS** for Homebridge UI
3. Keep plugins **updated**
4. Use **strong bridge PIN**

### Reliability
1. Run as **system service**
2. Enable **automatic restarts**
3. Use **Docker** for easy updates/backups
4. Monitor with **healthcheck**

### Organization
1. Use **child bridges** to group devices
2. Name devices consistently
3. Document custom configurations
4. Backup config.json regularly

```bash
# Backup command
cp ~/.homebridge/config.json ~/.homebridge/config.json.backup
```
