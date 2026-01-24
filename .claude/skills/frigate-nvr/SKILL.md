---
name: frigate-nvr
description: >
  Frigate NVR management with AI-powered object detection. Configure cameras, zones, detection settings,
  recording policies, and Home Assistant integration. Use when working with Frigate, security cameras,
  NVR setup, object detection, person/car/animal detection, RTSP streams, or video surveillance.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash, WebFetch
---

# Frigate NVR Skill

Complete guide for managing Frigate Network Video Recorder with AI object detection.

## Quick Reference

### Core Components
| Component | Purpose |
|-----------|---------|
| **Frigate Server** | Main NVR processing and recording |
| **Detector** | AI inference (Coral TPU, OpenVINO, CPU) |
| **go2rtc** | RTSP/WebRTC streaming |
| **MQTT** | Event publishing to Home Assistant |

### Configuration File Location
```
/config/frigate.yml  # Main configuration
/media/frigate/      # Recording storage
```

---

## 1. Installation

### Docker Compose
```yaml
version: "3.9"
services:
  frigate:
    container_name: frigate
    image: ghcr.io/blakeblackshear/frigate:stable
    restart: unless-stopped
    privileged: true
    shm_size: "256mb"
    devices:
      - /dev/bus/usb:/dev/bus/usb  # Coral USB
      # - /dev/apex_0:/dev/apex_0  # Coral PCIe
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./config:/config
      - ./media:/media/frigate
    ports:
      - "5000:5000"   # Web UI
      - "8554:8554"   # RTSP
      - "8555:8555"   # WebRTC
    environment:
      FRIGATE_RTSP_PASSWORD: "password"
```

### With Coral TPU
```yaml
devices:
  - /dev/bus/usb:/dev/bus/usb  # USB Coral
  # OR for PCIe Coral:
  - /dev/apex_0:/dev/apex_0
```

---

## 2. Configuration

### Basic Camera Setup
```yaml
# frigate.yml
mqtt:
  enabled: true
  host: mqtt-broker
  port: 1883
  user: frigate
  password: "{FRIGATE_MQTT_PASSWORD}"

detectors:
  coral:
    type: edgetpu
    device: usb

cameras:
  front_door:
    ffmpeg:
      inputs:
        - path: rtsp://user:pass@192.168.1.100:554/stream1
          roles:
            - detect
            - record
    detect:
      width: 1280
      height: 720
      fps: 5
    objects:
      track:
        - person
        - car
        - dog
        - cat
    record:
      enabled: true
      retain:
        days: 7
        mode: motion
    snapshots:
      enabled: true
      retain:
        default: 14
```

### Detection Zones
```yaml
cameras:
  front_door:
    zones:
      driveway:
        coordinates: 0,500,400,500,400,0,0,0
        objects:
          - car
        filters:
          car:
            min_area: 5000
      porch:
        coordinates: 400,500,640,500,640,0,400,0
        objects:
          - person
          - package
```

### Motion Masks (Ignore Areas)
```yaml
cameras:
  front_door:
    motion:
      mask:
        - 0,0,200,0,200,100,0,100  # Top-left corner
```

### Object Filters
```yaml
cameras:
  front_door:
    objects:
      track:
        - person
        - car
      filters:
        person:
          min_area: 1000
          max_area: 100000
          min_score: 0.6
          threshold: 0.7
        car:
          min_area: 5000
          min_score: 0.5
```

---

## 3. Recording Configuration

### Recording Modes
```yaml
record:
  enabled: true
  retain:
    days: 7           # Keep all recordings for 7 days
    mode: motion      # all, motion, active_objects
  events:
    pre_capture: 5    # Seconds before event
    post_capture: 5   # Seconds after event
    retain:
      default: 30     # Keep events for 30 days
      mode: motion
```

### Storage Management
```yaml
record:
  retain:
    days: 3
    mode: motion
  events:
    retain:
      default: 14
      objects:
        person: 30    # Keep person events longer
        car: 7
```

---

## 4. Detector Configuration

### Google Coral USB
```yaml
detectors:
  coral:
    type: edgetpu
    device: usb
```

### Google Coral PCIe
```yaml
detectors:
  coral:
    type: edgetpu
    device: pci
```

### Multiple Corals
```yaml
detectors:
  coral1:
    type: edgetpu
    device: usb:0
  coral2:
    type: edgetpu
    device: usb:1
```

### OpenVINO (Intel CPU/GPU)
```yaml
detectors:
  ov:
    type: openvino
    device: AUTO
    model:
      path: /openvino-model/ssdlite_mobilenet_v2.xml
```

### CPU (Fallback)
```yaml
detectors:
  cpu:
    type: cpu
    num_threads: 4
```

---

## 5. go2rtc Streaming

### Stream Configuration
```yaml
go2rtc:
  streams:
    front_door:
      - rtsp://user:pass@192.168.1.100:554/stream1
    front_door_sub:
      - rtsp://user:pass@192.168.1.100:554/stream2

cameras:
  front_door:
    ffmpeg:
      inputs:
        - path: rtsp://127.0.0.1:8554/front_door
          input_args: preset-rtsp-restream
          roles:
            - record
        - path: rtsp://127.0.0.1:8554/front_door_sub
          input_args: preset-rtsp-restream
          roles:
            - detect
```

### WebRTC for Low Latency
```yaml
go2rtc:
  webrtc:
    candidates:
      - 192.168.1.50:8555  # Your Frigate IP
      - stun:8555
```

---

## 6. Home Assistant Integration

### MQTT Configuration
```yaml
mqtt:
  enabled: true
  host: 192.168.1.10
  port: 1883
  topic_prefix: frigate
  client_id: frigate
  user: mqtt_user
  password: mqtt_pass
```

### Home Assistant Config
```yaml
# configuration.yaml
mqtt:
  sensor:
    - name: "Frigate Front Door Person"
      state_topic: "frigate/front_door/person"

camera:
  - platform: mqtt
    name: "Front Door"
    topic: "frigate/front_door/person/snapshot"
```

### Frigate Integration (HACS)
```yaml
# Use the Frigate integration from HACS for:
# - Camera entities
# - Binary sensors for objects
# - Event notifications
# - Lovelace card
```

---

## 7. Notifications

### MQTT Events
```yaml
# Events published to:
frigate/events                    # All events
frigate/<camera>/person          # Person count
frigate/<camera>/person/snapshot # Snapshot image
```

### Event JSON Structure
```json
{
  "type": "new",
  "before": {},
  "after": {
    "id": "1234567890.123456-abc123",
    "camera": "front_door",
    "frame_time": 1234567890.123,
    "label": "person",
    "score": 0.87,
    "box": [100, 200, 300, 400],
    "area": 20000,
    "region": [0, 0, 640, 480],
    "current_zones": ["driveway"],
    "entered_zones": ["driveway"]
  }
}
```

---

## 8. API Reference

### REST API Endpoints
```bash
# Get config
curl http://frigate:5000/api/config

# Get camera snapshot
curl http://frigate:5000/api/front_door/latest.jpg -o snapshot.jpg

# Get events
curl "http://frigate:5000/api/events?camera=front_door&limit=10"

# Delete event
curl -X DELETE http://frigate:5000/api/events/EVENT_ID

# Restart Frigate
curl -X POST http://frigate:5000/api/restart

# Get recording summary
curl http://frigate:5000/api/front_door/recordings/summary
```

### MQTT Commands
```bash
# Enable/disable detection
mosquitto_pub -t "frigate/front_door/detect/set" -m "ON"
mosquitto_pub -t "frigate/front_door/detect/set" -m "OFF"

# Enable/disable recording
mosquitto_pub -t "frigate/front_door/recordings/set" -m "ON"

# Enable/disable snapshots
mosquitto_pub -t "frigate/front_door/snapshots/set" -m "ON"
```

---

## 9. Performance Tuning

### Reduce CPU Usage
```yaml
cameras:
  front_door:
    detect:
      fps: 5          # Lower FPS for detection
      width: 1280     # Lower resolution
      height: 720
    ffmpeg:
      output_args:
        detect: -f rawvideo -pix_fmt yuv420p
        record: preset-record-generic-audio-aac
```

### Memory Optimization
```yaml
# Docker Compose
shm_size: "256mb"  # Increase if needed

# frigate.yml
cameras:
  front_door:
    ffmpeg:
      hwaccel_args: preset-vaapi  # Intel Quick Sync
      # hwaccel_args: preset-nvidia  # NVIDIA GPU
```

### Hardware Acceleration
```yaml
ffmpeg:
  hwaccel_args: preset-vaapi  # Intel
  # hwaccel_args: preset-nvidia-h264  # NVIDIA
  # hwaccel_args: preset-rpi-64-h264  # Raspberry Pi 4
```

---

## 10. Troubleshooting

### Common Issues

**Camera not connecting:**
```bash
# Test RTSP stream
ffprobe rtsp://user:pass@192.168.1.100:554/stream1

# Check Frigate logs
docker logs frigate 2>&1 | grep "front_door"
```

**High CPU usage:**
- Lower detect FPS to 5
- Use hardware acceleration
- Add motion masks for busy areas
- Use sub-stream for detection

**Coral not detected:**
```bash
# Check USB devices
lsusb | grep Google

# Check Frigate logs
docker logs frigate 2>&1 | grep -i coral
```

**No recordings:**
```bash
# Check storage permissions
ls -la /media/frigate/

# Check recording config
grep -A 10 "record:" /config/frigate.yml
```

### Debug Configuration
```yaml
logger:
  default: info
  logs:
    frigate.record: debug
    frigate.event: debug
    detector.coral: debug
```

---

## Best Practices

1. **Use sub-streams** for detection (lower resolution, less CPU)
2. **Use main stream** for recording (full quality)
3. **Set appropriate FPS** - 5 FPS is usually sufficient for detection
4. **Configure zones** to reduce false positives
5. **Use motion masks** for trees, roads, reflections
6. **Regular maintenance** - prune old recordings
7. **Monitor storage** - set appropriate retention policies
8. **Use Coral TPU** for best detection performance
