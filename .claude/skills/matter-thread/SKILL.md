---
name: matter-thread
description: >
  Matter and Thread protocol management for smart home interoperability. Configure Matter controllers,
  Thread border routers, device commissioning, and multi-admin fabric setup. Use when working with
  Matter, Thread, smart home protocols, device pairing, border routers, or cross-platform compatibility.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash, WebFetch
---

# Matter & Thread Skill

Complete guide for Matter smart home protocol and Thread mesh networking.

## Quick Reference

### Protocol Overview
| Protocol | Layer | Purpose |
|----------|-------|---------|
| **Matter** | Application | Device interoperability standard |
| **Thread** | Network | Low-power mesh network (IPv6) |
| **WiFi** | Network | High-bandwidth devices |
| **Bluetooth LE** | Commissioning | Device pairing |

### Key Components
- **Matter Controller**: Hub that manages Matter devices (HomePod, Echo, etc.)
- **Thread Border Router**: Connects Thread mesh to IP network
- **Matter Bridge**: Exposes non-Matter devices to Matter network
- **Fabric**: Logical grouping of controller and devices

---

## 1. Matter Fundamentals

### Device Types
| Device Type | Example Products |
|-------------|------------------|
| Light | Bulbs, strips, fixtures |
| Switch | Wall switches, plugs |
| Sensor | Motion, contact, temperature |
| Lock | Door locks |
| Thermostat | HVAC control |
| Window Covering | Blinds, shades |
| Fan | Ceiling fans |
| Bridge | Protocol bridges |

### Matter Controllers
| Platform | Controller Device |
|----------|------------------|
| Apple Home | HomePod, Apple TV 4K, iPad |
| Google Home | Nest Hub, Nest Hub Max |
| Amazon Alexa | Echo 4th Gen, Eero |
| Samsung SmartThings | SmartThings Hub v3 |
| Home Assistant | Home Assistant Yellow, generic |

---

## 2. Thread Network Setup

### Thread Border Router

**Apple HomePod mini / Apple TV 4K:**
- Automatic Thread border router
- Check: Settings > Home > Home Hubs & Bridges

**Google Nest Hub:**
- Automatic Thread border router
- Check: Google Home app > Settings > Matter

**Home Assistant Yellow:**
```yaml
# configuration.yaml
thread:
  border_router: true
```

**OpenThread Border Router (Docker):**
```yaml
version: '3'
services:
  otbr:
    image: openthread/otbr:latest
    container_name: otbr
    privileged: true
    network_mode: host
    volumes:
      - ./data:/data
    devices:
      - /dev/ttyUSB0:/dev/radio
    environment:
      - RADIO_URL=spinel+hdlc+uart:///dev/radio
      - BACKBONE_IF=eth0
```

### Thread Credentials
```bash
# Get Thread network credentials (OpenThread CLI)
dataset active -x

# Key components:
# - Network Name
# - Extended PAN ID
# - Network Key (secret)
# - PAN ID
# - Channel
```

---

## 3. Matter Commissioning

### Commissioning Methods
| Method | When to Use |
|--------|-------------|
| **QR Code** | Preferred, scan from device/packaging |
| **Manual Code** | 11-digit fallback code |
| **On-network** | Device already on network |

### QR Code Format
```
MT:Y.K9042C00KA0648G00  # Example Matter QR payload

# Contains:
# - Vendor ID
# - Product ID
# - Discriminator
# - Passcode
```

### Commissioning with Home Assistant
```yaml
# configuration.yaml
matter:
  # Uses Matter Server add-on
```

```bash
# Commission device
# Home Assistant > Settings > Devices & Services > Matter > Add Device
# Scan QR code or enter manual code
```

### Commissioning with chip-tool (Development)
```bash
# Install chip-tool
git clone https://github.com/project-chip/connectedhomeip.git
cd connectedhomeip
./scripts/build/build_examples.py --target linux-x64-chip-tool build

# Commission over BLE
./chip-tool pairing ble-wifi <node-id> <ssid> <password> <setup-pin> <discriminator>

# Commission on-network
./chip-tool pairing onnetwork <node-id> <setup-pin>

# Example
./chip-tool pairing ble-wifi 1 "MyWiFi" "password123" 20202021 3840
```

---

## 4. Multi-Admin (Fabrics)

### Understanding Fabrics
- Each controller creates a "fabric" (trust domain)
- Device can be in multiple fabrics (multi-admin)
- Up to 5 fabrics per device typically

### Sharing Device to Additional Fabric
```bash
# Open commissioning window (from existing controller)
# Device will advertise for new pairing

# chip-tool example
./chip-tool pairing open-commissioning-window <node-id> <option> <timeout> <iteration> <discriminator>

# Open window for 300 seconds
./chip-tool pairing open-commissioning-window 1 1 300 1000 3840
```

### Apple Home (Share with Other Platforms)
1. Apple Home app > Device > Settings
2. "Turn On Pairing Mode"
3. Use QR code to pair with Google Home, etc.

### Google Home (Share with Other Platforms)
1. Google Home app > Device > Settings
2. "Linked Matter apps & services"
3. "Link new app"

---

## 5. Home Assistant Matter Integration

### Setup Matter Server
```yaml
# Install Matter Server add-on from Add-on Store

# configuration.yaml
matter:
  # Configuration handled by add-on
```

### Commission Devices
1. Settings > Devices & Services > Matter
2. "Add Device"
3. Scan QR code or enter manual pairing code

### Matter Bridge (Expose HA Devices)
```yaml
# Expose Home Assistant devices to Matter
# Uses Matter Bridge integration

matter:
  bridge:
    name: "Home Assistant Bridge"
    entities:
      - light.living_room
      - switch.kitchen_plug
      - climate.thermostat
```

### Thread Integration
```yaml
# Home Assistant Yellow has built-in Thread
# External: Use OpenThread Border Router

thread:
  border_router: true
  network_name: "Home Thread"
  channel: 15
```

---

## 6. Device Management

### chip-tool Commands
```bash
# Read attribute
./chip-tool onoff read on-off <node-id> <endpoint>

# Toggle light
./chip-tool onoff toggle <node-id> <endpoint>

# On/Off
./chip-tool onoff on <node-id> <endpoint>
./chip-tool onoff off <node-id> <endpoint>

# Set brightness (0-254)
./chip-tool levelcontrol move-to-level <level> <transition-time> <option-mask> <option-override> <node-id> <endpoint>

# Read temperature
./chip-tool temperaturemeasurement read measured-value <node-id> <endpoint>

# Subscribe to attribute changes
./chip-tool onoff subscribe on-off <min-interval> <max-interval> <node-id> <endpoint>
```

### Device Information
```bash
# Read basic information
./chip-tool basicinformation read vendor-name <node-id> 0
./chip-tool basicinformation read product-name <node-id> 0
./chip-tool basicinformation read software-version <node-id> 0

# Read node label
./chip-tool basicinformation read node-label <node-id> 0
```

---

## 7. Thread Network Management

### OpenThread CLI Commands
```bash
# Connect to OTBR
ot-ctl

# Network status
state
networkname
channel
panid
extpanid
networkkey

# Routing info
router table
child table
neighbor table

# Diagnostics
ping <ipv6-address>
scan
```

### Thread Network Topology
```bash
# View mesh topology
ot-ctl router table

# Leader info
ot-ctl leader
ot-ctl leaderweight

# Check connectivity
ot-ctl ping ff02::1  # All nodes multicast
```

### Border Router Management
```bash
# OTBR web interface
http://<otbr-ip>:8080

# REST API
curl http://<otbr-ip>:8081/node
curl http://<otbr-ip>:8081/node/dataset/active
```

---

## 8. Troubleshooting

### Matter Issues

**Device not discovered:**
```bash
# Check mDNS/DNS-SD
avahi-browse -rt _matter._tcp
avahi-browse -rt _matterc._udp

# Check network connectivity
ping <device-ip>
```

**Commissioning fails:**
```bash
# Verify WiFi credentials
# Check Thread network connectivity
# Ensure device is in pairing mode
# Try factory reset on device
```

**Device unresponsive:**
```bash
# Check device is powered
# Verify network connectivity
# Check controller logs
# Re-commission if needed
```

### Thread Issues

**No border router:**
```bash
# Check border router status
# Verify Thread credentials shared
# Check for multiple border routers (can cause issues)
```

**Mesh connectivity:**
```bash
# Via OTBR CLI
ot-ctl state
ot-ctl neighbor table
ot-ctl router table
```

**Device won't join Thread:**
```bash
# Factory reset device
# Verify Thread credentials
# Check channel compatibility
# Ensure border router is reachable
```

### Home Assistant Issues
```bash
# Check Matter Server add-on logs
ha addons logs core_matter_server

# Restart Matter Server
ha addons restart core_matter_server

# Check Thread add-on (if using)
ha addons logs core_openthread_border_router
```

---

## 9. Security Best Practices

### Network Security
1. **Separate VLANs** for IoT devices
2. **Firewall rules** to restrict device access
3. **Regular firmware updates**
4. **Disable unused features**

### Matter Security
1. Keep **commissioning codes** secure
2. Limit **fabric administrators**
3. Review **shared fabrics** periodically
4. Use **secure commissioning** (BLE preferred)

### Thread Security
1. **Network key** is sensitive - protect it
2. Use **separate Thread network** if possible
3. Monitor for **unauthorized devices**
4. Regular **security audits**

---

## 10. Development Resources

### SDKs and Tools
| Resource | URL |
|----------|-----|
| Matter SDK | github.com/project-chip/connectedhomeip |
| chip-tool | Built from Matter SDK |
| OpenThread | github.com/openthread/openthread |
| OTBR | github.com/openthread/ot-br-posix |

### Certification
| Program | Organization |
|---------|--------------|
| Matter Certification | Connectivity Standards Alliance (CSA) |
| Thread Certification | Thread Group |

### Build Matter Device (ESP32)
```bash
# Clone Matter SDK
git clone https://github.com/project-chip/connectedhomeip.git
cd connectedhomeip
./scripts/checkout_submodules.py --shallow --platform esp32

# Setup environment
source scripts/activate.sh

# Build lighting example
cd examples/lighting-app/esp32
idf.py set-target esp32
idf.py build
idf.py flash
```

---

## Best Practices

1. **Use Thread** when possible for battery devices (low power)
2. **Use WiFi** for high-bandwidth devices (cameras)
3. **Multiple border routers** for Thread redundancy
4. **Start with one controller** then add multi-admin
5. **Keep devices updated** with firmware
6. **Document your network** - device locations, credentials
7. **Test before production** - commissioning can be finicky
8. **Have backup plan** - not all devices work perfectly with Matter
