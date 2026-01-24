# OctoPrint API Reference

Complete API reference for OctoPrint REST API operations.

## Authentication

All API requests require an API key passed in the header:

```
X-Api-Key: YOUR_API_KEY
```

Get your API key from: OctoPrint Settings > API > Global API Key

## API Response Codes

| Code | Meaning |
|------|---------|
| 200 | Success with response body |
| 201 | Created (file upload) |
| 204 | Success, no content |
| 400 | Bad request (invalid parameters) |
| 403 | Forbidden (invalid API key) |
| 404 | Not found |
| 409 | Conflict (invalid printer state) |
| 500 | Server error |

---

## Connection API

### GET /api/connection

Get current connection state and options.

**Response:**
```json
{
  "current": {
    "state": "Operational",
    "port": "/dev/ttyUSB0",
    "baudrate": 115200,
    "printerProfile": "_default"
  },
  "options": {
    "ports": ["/dev/ttyUSB0", "/dev/ttyACM0"],
    "baudrates": [250000, 230400, 115200, 57600, 38400, 19200, 9600],
    "printerProfiles": [{"id": "_default", "name": "Default"}],
    "portPreference": "/dev/ttyUSB0",
    "baudratePreference": 115200,
    "autoconnect": true
  }
}
```

**States:**
- `Operational` - Connected and ready
- `Printing` - Currently printing
- `Pausing` - Transitioning to paused
- `Paused` - Print paused
- `Cancelling` - Transitioning to cancelled
- `Error` - Error state
- `Offline` - Not connected
- `Closed` - Connection closed

### POST /api/connection

Connect, disconnect, or fake ack.

**Connect:**
```json
{
  "command": "connect",
  "port": "/dev/ttyUSB0",
  "baudrate": 115200,
  "printerProfile": "_default",
  "save": true,
  "autoconnect": true
}
```

**Disconnect:**
```json
{
  "command": "disconnect"
}
```

---

## Printer API

### GET /api/printer

Get full printer state.

**Response:**
```json
{
  "temperature": {
    "tool0": {
      "actual": 195.5,
      "target": 200.0,
      "offset": 0
    },
    "bed": {
      "actual": 58.2,
      "target": 60.0,
      "offset": 0
    }
  },
  "sd": {
    "ready": true
  },
  "state": {
    "text": "Operational",
    "flags": {
      "operational": true,
      "printing": false,
      "pausing": false,
      "paused": false,
      "cancelling": false,
      "sdReady": true,
      "error": false,
      "ready": true,
      "closedOrError": false
    }
  }
}
```

### GET /api/printer/tool

Get tool (hotend) temperatures.

### POST /api/printer/tool

Control tool temperature or extrusion.

**Set Temperature:**
```json
{
  "command": "target",
  "targets": {
    "tool0": 200,
    "tool1": 195
  }
}
```

**Set Offset:**
```json
{
  "command": "offset",
  "offsets": {
    "tool0": 5
  }
}
```

**Extrude:**
```json
{
  "command": "extrude",
  "amount": 10,
  "speed": 300
}
```

**Select Tool:**
```json
{
  "command": "select",
  "tool": "tool0"
}
```

### GET /api/printer/bed

Get bed temperature.

### POST /api/printer/bed

Control bed temperature.

```json
{
  "command": "target",
  "target": 60
}
```

### POST /api/printer/printhead

Control print head movement.

**Home:**
```json
{
  "command": "home",
  "axes": ["x", "y", "z"]
}
```

**Jog:**
```json
{
  "command": "jog",
  "x": 10,
  "y": -5,
  "z": 2,
  "absolute": false,
  "speed": 3000
}
```

**Feedrate:**
```json
{
  "command": "feedrate",
  "factor": 100
}
```

### POST /api/printer/command

Send G-code commands.

**Single:**
```json
{
  "command": "G28"
}
```

**Multiple:**
```json
{
  "commands": ["G28", "G1 Z10 F300", "M104 S200"]
}
```

---

## Job API

### GET /api/job

Get current job information.

**Response:**
```json
{
  "job": {
    "file": {
      "name": "myprint.gcode",
      "origin": "local",
      "size": 1234567,
      "date": 1234567890
    },
    "estimatedPrintTime": 3600,
    "averagePrintTime": 3500,
    "lastPrintTime": 3450,
    "filament": {
      "tool0": {
        "length": 15000,
        "volume": 36.5
      }
    }
  },
  "progress": {
    "completion": 45.5,
    "filepos": 560000,
    "printTime": 1620,
    "printTimeLeft": 1980,
    "printTimeLeftOrigin": "analysis"
  },
  "state": "Printing"
}
```

### POST /api/job

Control print job.

**Start:**
```json
{
  "command": "start"
}
```

**Cancel:**
```json
{
  "command": "cancel"
}
```

**Restart (from beginning):**
```json
{
  "command": "restart"
}
```

**Pause/Resume:**
```json
{
  "command": "pause",
  "action": "pause"
}
```

Actions: `pause`, `resume`, `toggle`

---

## Files API

### GET /api/files

List all files.

**Query Parameters:**
- `recursive=true` - Include subdirectories
- `force=true` - Bypass cache

### GET /api/files/{location}

List files from location (`local` or `sdcard`).

### GET /api/files/{location}/{path}

Get specific file info.

**Response:**
```json
{
  "name": "myprint.gcode",
  "display": "myprint.gcode",
  "path": "myprint.gcode",
  "type": "machinecode",
  "typePath": ["machinecode", "gcode"],
  "origin": "local",
  "date": 1234567890,
  "size": 1234567,
  "hash": "abc123...",
  "gcodeAnalysis": {
    "estimatedPrintTime": 3600,
    "filament": {
      "tool0": {
        "length": 15000,
        "volume": 36.5
      }
    }
  },
  "refs": {
    "resource": "http://octoprint/api/files/local/myprint.gcode",
    "download": "http://octoprint/downloads/files/local/myprint.gcode"
  }
}
```

### POST /api/files/{location}

Upload file or create folder.

**Upload (multipart/form-data):**
- `file` - The file to upload
- `select` - Select file after upload (true/false)
- `print` - Start printing after upload (true/false)
- `path` - Subfolder path

### POST /api/files/{location}/{path}

File commands.

**Select:**
```json
{
  "command": "select",
  "print": true
}
```

**Unselect:**
```json
{
  "command": "unselect"
}
```

**Copy:**
```json
{
  "command": "copy",
  "destination": "folder/newname.gcode"
}
```

**Move:**
```json
{
  "command": "move",
  "destination": "folder/newname.gcode"
}
```

### DELETE /api/files/{location}/{path}

Delete file or folder.

---

## Settings API

### GET /api/settings

Get all settings.

### POST /api/settings

Update settings.

```json
{
  "appearance": {
    "name": "My Printer"
  },
  "webcam": {
    "streamUrl": "/webcam/?action=stream",
    "snapshotUrl": "/webcam/?action=snapshot"
  }
}
```

---

## Timelapse API

### GET /api/timelapse

List timelapses and current configuration.

**Response:**
```json
{
  "config": {
    "type": "zchange",
    "postRoll": 0,
    "fps": 25,
    "interval": 10
  },
  "files": [
    {
      "name": "timelapse_20250120_1234.mp4",
      "size": 12345678,
      "date": "2025-01-20 12:34:56",
      "bytes": 12345678,
      "url": "/downloads/timelapse/timelapse_20250120_1234.mp4"
    }
  ]
}
```

### DELETE /api/timelapse/{filename}

Delete a timelapse.

### POST /api/timelapse

Update timelapse configuration.

```json
{
  "type": "zchange",
  "postRoll": 5,
  "fps": 25
}
```

---

## System API

### GET /api/system/commands

List system commands.

### POST /api/system/commands/{source}/{action}

Execute system command.

Common commands:
- `core/restart` - Restart OctoPrint
- `core/reboot` - Reboot system
- `core/shutdown` - Shutdown system

---

## Plugin APIs

### Bed Level Visualizer

**Trigger mesh update:**
```
POST /api/plugin/bedlevelvisualizer
{
  "command": "mesh"
}
```

### Octolapse

**Get status:**
```
GET /plugin/octolapse/status
```

**Get settings:**
```
GET /plugin/octolapse/settings
```

---

## Ender 3 G-code Reference

### Movement Commands

| Command | Description | Example |
|---------|-------------|---------|
| G0 | Rapid move | `G0 X100 Y100 F6000` |
| G1 | Linear move | `G1 X100 Y100 E10 F1500` |
| G28 | Home axes | `G28`, `G28 X Y`, `G28 Z` |
| G29 | Auto bed level | `G29` |
| G90 | Absolute positioning | `G90` |
| G91 | Relative positioning | `G91` |
| G92 | Set position | `G92 E0` |

### Temperature Commands

| Command | Description | Example |
|---------|-------------|---------|
| M104 | Set hotend (no wait) | `M104 S200` |
| M109 | Set hotend (wait) | `M109 S200` |
| M140 | Set bed (no wait) | `M140 S60` |
| M190 | Set bed (wait) | `M190 S60` |
| M105 | Report temperatures | `M105` |

### Fan Commands

| Command | Description | Example |
|---------|-------------|---------|
| M106 | Set fan speed | `M106 S255` (100%) |
| M107 | Fan off | `M107` |

### Motor Commands

| Command | Description | Example |
|---------|-------------|---------|
| M17 | Enable steppers | `M17` |
| M18/M84 | Disable steppers | `M84` |
| M92 | Set steps/mm | `M92 E93` |

### EEPROM Commands

| Command | Description |
|---------|-------------|
| M500 | Save settings |
| M501 | Load settings |
| M502 | Reset to defaults |
| M503 | Report settings |

### Bed Leveling

| Command | Description |
|---------|-------------|
| G29 | Run auto bed level |
| M420 S1 | Enable mesh |
| M420 S0 | Disable mesh |
| M420 V | View mesh values |
| M421 | Set mesh point |

### Emergency

| Command | Description |
|---------|-------------|
| M112 | Emergency stop |
| M410 | Quickstop |

---

## WebSocket API

OctoPrint provides real-time updates via SockJS at:

```
ws://OCTOPRINT_HOST/sockjs/websocket
```

**Message Types:**
- `connected` - Connection established
- `current` - Current state update
- `history` - Temperature history
- `event` - Various events
- `timelapse` - Timelapse updates
- `slicingProgress` - Slicing progress

---

## Common Workflows

### Start a Print

1. Upload file: `POST /api/files/local` (multipart)
2. Select and print: `POST /api/files/local/{filename}` with `{"command": "select", "print": true}`

### Monitor Print Progress

1. Get job: `GET /api/job`
2. Check `progress.completion` for percentage
3. Check `progress.printTimeLeft` for remaining time

### Change Filament Mid-Print

1. Pause: `POST /api/job` with `{"command": "pause", "action": "pause"}`
2. Heat: `POST /api/printer/tool` with `{"command": "target", "targets": {"tool0": 200}}`
3. Retract: `POST /api/printer/tool` with `{"command": "extrude", "amount": -50}`
4. Wait for filament change
5. Extrude: `POST /api/printer/tool` with `{"command": "extrude", "amount": 50}`
6. Resume: `POST /api/job` with `{"command": "pause", "action": "resume"}`

### Emergency Stop

1. Send M112: `POST /api/printer/command` with `{"command": "M112"}`
2. Or cancel print: `POST /api/job` with `{"command": "cancel"}`
3. Cool down: `POST /api/printer/tool` with `{"command": "target", "targets": {"tool0": 0}}`
4. Cool bed: `POST /api/printer/bed` with `{"command": "target", "target": 0}`
