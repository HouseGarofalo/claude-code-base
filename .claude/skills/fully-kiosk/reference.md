# Fully Kiosk Browser - Complete Technical Reference

## REST API Command Reference

Base URL: `http://<device-ip>:2323/?cmd=<command>&password=<password>`

Add `&type=json` for JSON responses instead of HTML.

### Device Information & Logs

| Command | Parameters | Description |
|---------|------------|-------------|
| `deviceInfo` | - | Get complete device status JSON |
| `showLog` | - | Get Fully Kiosk application log |
| `logcat` | - | Get Android system logcat |
| `getScreenshot` | - | Get PNG screenshot |
| `getCamshot` | - | Get camera image (requires motion detection) |
| `loadStatsCSV` | - | Get usage statistics CSV |

### Web Browsing Commands

| Command | Parameters | Description |
|---------|------------|-------------|
| `loadStartUrl` | - | Load configured Start URL |
| `loadUrl` | `url`, `tab`, `newtab`, `focus` | Load specific URL |
| `focusTab` | `tab` (index) | Switch to tab |
| `closeTab` | `tab` (index) | Close tab |
| `refreshTab` | - | Refresh current tab |
| `clearCache` | - | Clear browser cache |
| `clearWebstorage` | - | Clear localStorage/sessionStorage |
| `clearCookies` | - | Clear all cookies |
| `resetWebview` | - | Full WebView reset |

**loadUrl Parameters:**
- `url` - URL to load (required)
- `tab` - Tab index (0-n) to load in
- `newtab` - `true`/`false` - Open in new tab
- `focus` - `true`/`false` - Focus the tab after loading

### Screen Control Commands

| Command | Parameters | Description |
|---------|------------|-------------|
| `screenOn` | - | Turn screen on |
| `screenOff` | - | Turn screen off |
| `forceSleep` | - | Force device to sleep |
| `triggerMotion` | - | Simulate motion detection event |
| `startScreensaver` | - | Start screensaver |
| `stopScreensaver` | - | Stop screensaver |
| `startDaydream` | - | Start Android Daydream |
| `stopDaydream` | - | Stop Android Daydream |

### Audio Commands

| Command | Parameters | Description |
|---------|------------|-------------|
| `textToSpeech` | `text`, `locale`, `engine`, `queue` | Speak text |
| `stopTextToSpeech` | - | Stop TTS playback |
| `playSound` | `url`, `loop`, `stream` | Play audio file |
| `stopSound` | - | Stop audio playback |
| `setAudioVolume` | `level`, `stream` | Set volume |
| `playVideo` | `url`, `loop`, `showControls`, `exitOnTouch`, `exitOnCompletion` | Play video |
| `stopVideo` | - | Stop video playback |

**Audio Stream Codes for setAudioVolume:**

| Code | Stream Type |
|------|-------------|
| 0 | Voice Call |
| 1 | System |
| 2 | Ring |
| 3 | Music |
| 4 | Alarm |
| 5 | Notification |
| 6 | Bluetooth |
| 8 | DTMF |
| 9 | TTS |
| 10 | Accessibility |

### Kiosk Mode Commands

| Command | Parameters | Description |
|---------|------------|-------------|
| `lockKiosk` | - | Enable kiosk mode |
| `unlockKiosk` | - | Disable kiosk mode |
| `enableLockedMode` | - | Enable maintenance/locked mode |
| `disableLockedMode` | - | Disable maintenance mode |
| `setOverlayMessage` | `text` | Display overlay message |

### Application Commands

| Command | Parameters | Description |
|---------|------------|-------------|
| `toForeground` | - | Bring Fully to foreground |
| `toBackground` | - | Send Fully to background |
| `startApplication` | `package` | Start app by package name |
| `startIntent` | `url` | Start app via intent URL |
| `restartApp` | - | Restart Fully Kiosk |
| `exitApp` | - | Exit Fully Kiosk |
| `killMyProcess` | - | Force kill Fully process |
| `popFragment` | - | Close special views/fragments |

### APK Management Commands

| Command | Parameters | Description |
|---------|------------|-------------|
| `loadApkFile` | `url`, `forceInstall` | Download and install APK |
| `uninstallApp` | `package` | Uninstall app |
| `getInstallApkState` | - | Get installation status |
| `killBackgroundProcesses` | `package` | Kill app background processes |
| `clearAppData` | `package` | Clear app data (Android 9+, provisioned) |

### File Management Commands

| Command | Parameters | Description |
|---------|------------|-------------|
| `loadZipFile` | `url`, `dir` | Download and extract ZIP |
| `deleteFile` | `filename` | Delete file |
| `downloadFile` | `filename` | Download file from device |
| `deleteFolder` | `foldername` | Delete folder |

### Settings Commands

| Command | Parameters | Description |
|---------|------------|-------------|
| `listSettings` | - | Get all current settings (JSON) |
| `setStringSetting` | `key`, `value` | Set string setting |
| `setBooleanSetting` | `key`, `value` | Set boolean setting |
| `importSettingsFile` | `url` | Import settings from JSON URL |

### Root Commands (Rooted Devices Only)

| Command | Parameters | Description |
|---------|------------|-------------|
| `rebootDevice` | - | Reboot device |
| `shutdownDevice` | - | Shutdown device |
| `runRootCommand` | `command` | Execute as root |
| `runSuCommand` | `command` | Execute with su |

### Fully Video Kiosk Commands

| Command | Parameters | Description |
|---------|------------|-------------|
| `playerStart` | - | Start video player |
| `playerStop` | - | Stop video player |
| `playerPause` | - | Pause playback |
| `playerResume` | - | Resume playback |
| `playerNext` | - | Skip to next video |

---

## Complete Settings Key Reference

### Web Content Settings

| Key | Type | Description |
|-----|------|-------------|
| `startURL` | string | Start URL (supports variables) |
| `httpAuthUsername` | string | HTTP auth username |
| `httpAuthPassword` | string | HTTP auth password |
| `enableFullscreenVideos` | boolean | Allow fullscreen videos |
| `autoplayVideos` | boolean | Autoplay video content |
| `enableFileUpload` | boolean | Allow file uploads |
| `uploadFromCamera` | boolean | Allow camera for uploads |
| `handleJsAlerts` | boolean | Handle JavaScript alerts |
| `showPdfInline` | boolean | Show PDFs in browser |

### Web Browsing Settings

| Key | Type | Description |
|-----|------|-------------|
| `enablePullToRefresh` | boolean | Pull to refresh page |
| `enableBackButtonNavigation` | boolean | Back button navigates history |
| `tapSound` | boolean | Play tap sound |
| `enableSwipeNavigation` | boolean | Swipe to navigate |
| `swipeAnimations` | boolean | Animate page transitions |
| `nfcScan` | boolean | Enable NFC reading |
| `searchProviderUrl` | string | Custom search URL |

### Web Zoom & Scaling Settings

| Key | Type | Description |
|-----|------|-------------|
| `enableZoom` | boolean | Enable pinch zoom |
| `loadWithOverviewMode` | boolean | Zoom out to overview |
| `fontScaling` | integer | Font scaling percentage |
| `desktopMode` | boolean | Request desktop site |
| `viewportWidth` | integer | Custom viewport width |

### Web Auto Reload Settings

| Key | Type | Description |
|-----|------|-------------|
| `autoReloadOnIdle` | boolean | Reload on idle |
| `idleTimeout` | integer | Idle minutes before reload |
| `errorReload` | boolean | Reload on error |
| `errorTimeout` | integer | Error wait before reload |
| `reloadOnScreenOn` | boolean | Reload when screen turns on |
| `reloadOnScreensaverStop` | boolean | Reload after screensaver |
| `reloadOnNetworkReconnect` | boolean | Reload on network restore |
| `deleteCacheOnReload` | boolean | Clear cache on reload |
| `deleteHistoryOnReload` | boolean | Clear history on reload |
| `clearCacheOnReload` | boolean | Clear all data on reload |

### Advanced Web Settings

| Key | Type | Description |
|-----|------|-------------|
| `enableAutomation` | boolean | Enable web automation |
| `automationClickSelector` | string | CSS selector to auto-click |
| `automationFillSelector` | string | CSS selector to auto-fill |
| `automationFillValue` | string | Value for auto-fill |
| `enableJavascriptInterface` | boolean | Enable JS interface |
| `jsInjectionOnLoad` | string | JS to inject on page load |
| `jsInjectionOnFinish` | string | JS to inject on page finish |
| `formAutocomplete` | boolean | Enable autocomplete |
| `formAutofill` | boolean | Enable autofill |
| `thirdPartyCookies` | boolean | Allow 3rd party cookies |
| `ignoreSslErrors` | boolean | Ignore SSL certificate errors |
| `userAgent` | string | Custom user agent string |
| `defaultUserAgent` | string | Default UA (read-only) |

### Toolbar & Appearance Settings

| Key | Type | Description |
|-----|------|-------------|
| `showStatusBar` | boolean | Show Android status bar |
| `showNavigationBar` | boolean | Show Android nav bar |
| `showActionBar` | boolean | Show Fully action bar |
| `actionBarSize` | integer | Action bar size percent |
| `showAddressBar` | boolean | Show URL bar |
| `showProgressBar` | boolean | Show loading progress |
| `showTabFlaps` | boolean | Show tab indicators |
| `showRefreshButton` | boolean | Show refresh in action bar |
| `showHomeButton` | boolean | Show home button |
| `showForwardButton` | boolean | Show forward button |
| `showBackButton` | boolean | Show back button |
| `showPrintButton` | boolean | Show print button |
| `showShareButton` | boolean | Show share button |
| `showQrButton` | boolean | Show QR scan button |
| `actionBarBgColor` | string | Action bar background color |
| `progressBarColor` | string | Progress bar color |
| `statusBarColor` | string | Status bar color |
| `navigationBarColor` | string | Nav bar color |

### Screensaver Settings (PLUS)

| Key | Type | Description |
|-----|------|-------------|
| `screensaverTimer` | integer | Minutes until screensaver |
| `screensaverPlaylist` | string | Media playlist URL/path |
| `screensaverWallpaperUrl` | string | Wallpaper URL |
| `screensaverBrightness` | integer | Brightness during screensaver |
| `screensaverEnableAndroid` | boolean | Use Android screensaver |
| `screensaverShowClock` | boolean | Show clock on screensaver |
| `screensaverClockFormat` | string | Clock format string |

### Device Management Settings

| Key | Type | Description |
|-----|------|-------------|
| `screenBrightness` | integer | Brightness level (0-255) |
| `screenOrientation` | integer | 0=auto, 1=portrait, 2=landscape, 3=rev-landscape |
| `screenOffTimer` | integer | Minutes until screen off |
| `keepScreenOn` | boolean | Prevent screen timeout |
| `keepScreenOnWhilePlugged` | boolean | Keep on while charging |
| `forceWifi` | boolean | Force WiFi on |
| `forceBluetooth` | boolean | Force Bluetooth on |
| `sleepScheduleEnabled` | boolean | Enable sleep schedule |
| `sleepTime` | string | Sleep time (HH:MM) |
| `wakeupTime` | string | Wake time (HH:MM) |
| `deviceName` | string | Custom device name |

### Kiosk Mode Settings (PLUS)

| Key | Type | Description |
|-----|------|-------------|
| `kioskMode` | boolean | Enable kiosk mode |
| `kioskModePin` | string | PIN to exit kiosk |
| `kioskExitGesture` | integer | Exit gesture type |
| `kioskWifiPin` | string | PIN for WiFi settings |
| `kioskSettingsPin` | string | PIN for settings access |
| `lockStatusBar` | boolean | Lock status bar |
| `lockNavigationBar` | boolean | Lock navigation bar |
| `disableHomeButton` | boolean | Disable home button |
| `disablePowerButton` | boolean | Disable power button |
| `disableVolumeButtons` | boolean | Disable volume buttons |
| `disableNotifications` | boolean | Block notifications |
| `blockOtherApps` | boolean | Prevent other apps |
| `enableScreenshots` | boolean | Allow screenshots |
| `lockSafeMode` | boolean | Prevent safe mode boot |
| `whitelistUrls` | string | Allowed URL patterns |
| `blacklistUrls` | string | Blocked URL patterns |
| `appWhitelist` | string | Allowed app packages |
| `appBlacklist` | string | Blocked app packages |
| `singleAppMode` | boolean | Single app mode |
| `singleAppPackage` | string | Package for single app mode |

**Kiosk Exit Gestures:**
- 0: Swipe from left
- 1: Long press back button
- 2: Fast 5 taps (any corner)
- 3: Fast 7 taps (any corner)
- 4: Double tap top-left then bottom-right

### Motion Detection Settings (PLUS)

| Key | Type | Description |
|-----|------|-------------|
| `motionDetection` | boolean | Enable motion detection |
| `motionSensitivity` | integer | Sensitivity (0-100) |
| `motionFrameRate` | integer | Detection frame rate |
| `motionDetectDarkness` | boolean | Detect in darkness |
| `faceDetection` | boolean | Enable face detection |
| `acousticDetection` | boolean | Enable sound detection |
| `acousticSensitivity` | integer | Sound sensitivity |
| `screenOnOnMotion` | boolean | Screen on when motion |
| `stopScreensaverOnMotion` | boolean | Stop screensaver on motion |
| `exitScreensaverOnMotion` | boolean | Exit screensaver on motion |
| `cameraApi` | string | Camera API (legacy/cameraX) |

### Device Movement Detection (PLUS)

| Key | Type | Description |
|-----|------|-------------|
| `accelerometerDetection` | boolean | Enable accelerometer |
| `accelerometerSensitivity` | integer | Accelerometer sensitivity |
| `compassDetection` | boolean | Enable compass detection |
| `compassSensitivity` | integer | Compass sensitivity |
| `antiTheftAlarm` | boolean | Enable anti-theft |
| `antiTheftAlarmSound` | string | Alarm sound URL |
| `iBeaconDetection` | boolean | Enable iBeacon scanning |

### Remote Administration Settings (PLUS)

| Key | Type | Description |
|-----|------|-------------|
| `remoteAdmin` | boolean | Enable remote admin |
| `remoteAdminPassword` | string | Admin password |
| `remoteAdminFromLocalNetwork` | boolean | Local network only |
| `remoteAdminPort` | integer | Port number (default 2323) |
| `remoteAdminEnableHttps` | boolean | Enable HTTPS |
| `remoteAdminAllowFileManagement` | boolean | Allow file access |
| `remoteAdminAllowScreenshot` | boolean | Allow screenshots |
| `remoteAdminAllowCamshot` | boolean | Allow camera access |
| `fullyCloud` | boolean | Enable Fully Cloud |
| `fullyCloudToken` | string | Cloud auth token |

### MQTT Settings

| Key | Type | Description |
|-----|------|-------------|
| `mqttEnabled` | boolean | Enable MQTT |
| `mqttBrokerUrl` | string | Broker URL (tcp://host:port) |
| `mqttUsername` | string | MQTT username |
| `mqttPassword` | string | MQTT password |
| `mqttDeviceInfoTopic` | string | Device info topic |
| `mqttEventTopic` | string | Event topic |

### Other Settings

| Key | Type | Description |
|-----|------|-------------|
| `barcodeScanEnabled` | boolean | Enable barcode scanner |
| `barcodeScanCamera` | integer | Camera for scanning |
| `restartOnCrash` | boolean | Auto restart on crash |
| `restartOnUpdate` | boolean | Restart after update |
| `runAsPriorityApp` | boolean | Run as priority app |
| `customLocale` | string | Override system locale |
| `darkMode` | integer | Dark mode handling |
| `settingsPassword` | string | Settings access password |
| `licenseKey` | string | Plus license key |
| `volumeLicenseKey` | string | Volume license key |

---

## MQTT Topic Reference

### Published Topics

**Device Info Topic** (configurable, e.g., `fully/devicename/deviceInfo`)

Published periodically and on events. JSON payload:
```json
{
  "deviceID": "abc123",
  "deviceName": "Kitchen Tablet",
  "deviceModel": "Fire HD 10",
  "appVersion": "1.55.2",
  "androidVersion": "9",
  "batteryLevel": 87,
  "isPlugged": true,
  "isScreenOn": true,
  "screenBrightness": 128,
  "currentTabUrl": "http://homeassistant.local:8123",
  "wifiSSID": "HomeNetwork",
  "wifiSignalLevel": -45,
  "ip4": "192.168.1.100",
  "mac": "AA:BB:CC:DD:EE:FF",
  "hostname": "kitchen-tablet",
  "freeStorageMB": 4521,
  "totalStorageMB": 32000,
  "freeMemoryMB": 1234,
  "totalMemoryMB": 2048,
  "lastMotionDetected": "2024-01-15T10:30:00Z",
  "kioskMode": true,
  "screensaverOn": false,
  "maintenanceMode": false
}
```

**Event Topic** (configurable, e.g., `fully/devicename/event`)

Published on events. JSON payload:
```json
{
  "event": "screenOn",
  "deviceID": "abc123",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Event Types:**
- `screenOn` - Screen turned on
- `screenOff` - Screen turned off
- `onMotion` - Motion detected
- `pluggedAC` - Plugged into AC power
- `pluggedUSB` - Plugged into USB
- `unplugged` - Unplugged
- `networkConnect` - Network connected
- `networkDisconnect` - Network disconnected
- `batteryLow` - Battery below threshold
- `kioskLocked` - Kiosk mode enabled
- `kioskUnlocked` - Kiosk mode disabled
- `screensaverStart` - Screensaver started
- `screensaverStop` - Screensaver stopped
- `appStart` - Fully Kiosk started
- `facesDetected` - Face(s) detected
- `volumeChanged` - Volume changed
- `urlChanged` - URL navigated

---

## Device Info JSON Response Reference

`GET /?cmd=deviceInfo&type=json&password=<password>`

```json
{
  "deviceID": "abc123def456",
  "deviceName": "Kitchen Tablet",
  "deviceManufacturer": "Amazon",
  "deviceModel": "KFMAWI",
  "androidVersion": "9",
  "androidSdk": 28,
  "deviceSerial": "G0K0PC012345678",
  "appVersionCode": 902,
  "appVersionName": "1.55.2",
  "webViewVersion": "112.0.5615.136",
  "ip4": "192.168.1.100",
  "ip6": "fe80::1234:5678:abcd:ef01",
  "mac": "AA:BB:CC:DD:EE:FF",
  "hostname": "kitchen-tablet",
  "wifiSSID": "HomeNetwork",
  "wifiBSSID": "00:11:22:33:44:55",
  "wifiSignalLevel": -45,
  "screenOn": true,
  "screenBrightness": 128,
  "screenLockedByPolicy": false,
  "batteryLevel": 87,
  "isPlugged": true,
  "plugSource": "ac",
  "currentTabUrl": "http://homeassistant.local:8123",
  "currentTabIndex": 0,
  "tabsCount": 1,
  "kioskMode": true,
  "kioskLocked": true,
  "maintenanceMode": false,
  "screensaverOn": false,
  "motionDetectorState": 1,
  "lastMotionDetected": 1705315800000,
  "facesDetected": 0,
  "freeStorageMB": 4521,
  "totalStorageMB": 32000,
  "freeRamMB": 1234,
  "totalRamMB": 2048,
  "cpuUsage": 12.5,
  "displayWidthPixels": 1920,
  "displayHeightPixels": 1200,
  "displayDensity": 1.5,
  "timeZone": "America/New_York",
  "locale": "en_US",
  "startUrl": "http://homeassistant.local:8123",
  "isDeviceProvisioned": false,
  "isDeviceAdmin": true,
  "isFullyLicensed": true,
  "licenseInfo": "Plus License",
  "mqtt": false,
  "mqttConnected": false,
  "fullyCloud": true,
  "fullyCloudConnected": true
}
```

---

## Configuration JSON Schema

For `importSettingsFile` and Fully Cloud configuration push:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "startURL": { "type": "string" },
    "kioskMode": { "type": "boolean" },
    "kioskModePin": { "type": "string" },
    "kioskExitGesture": { "type": "integer", "minimum": 0, "maximum": 4 },
    "showStatusBar": { "type": "boolean" },
    "showNavigationBar": { "type": "boolean" },
    "screenBrightness": { "type": "integer", "minimum": 0, "maximum": 255 },
    "screensaverTimer": { "type": "integer", "minimum": 0 },
    "screensaverBrightness": { "type": "integer", "minimum": 0, "maximum": 255 },
    "motionDetection": { "type": "boolean" },
    "motionSensitivity": { "type": "integer", "minimum": 0, "maximum": 100 },
    "screenOnOnMotion": { "type": "boolean" },
    "remoteAdmin": { "type": "boolean" },
    "remoteAdminPassword": { "type": "string" },
    "remoteAdminFromLocalNetwork": { "type": "boolean" },
    "keepScreenOn": { "type": "boolean" },
    "enableZoom": { "type": "boolean" },
    "desktopMode": { "type": "boolean" },
    "autoReloadOnIdle": { "type": "boolean" },
    "idleTimeout": { "type": "integer" },
    "clearCacheOnReload": { "type": "boolean" }
  }
}
```

---

## URL Variables

Supported variables in Start URL and other URL fields:

| Variable | Description |
|----------|-------------|
| `$mac` | Device MAC address |
| `$deviceID` | Fully device ID |
| `$deviceName` | Configured device name |
| `$serial` | Device serial number |
| `$ip` | Device IP address |
| `$hostname` | Device hostname |
| `$ssid` | Connected WiFi SSID |
| `$locale` | System locale |
| `$battery` | Battery percentage |

Example: `http://dashboard.local/display?device=$deviceID&room=$deviceName`

---

## Error Codes

REST API error responses (with `type=json`):

| Code | Message | Description |
|------|---------|-------------|
| 401 | Unauthorized | Invalid password |
| 400 | Bad Request | Missing required parameter |
| 404 | Not Found | Unknown command |
| 500 | Internal Error | Device error |
| 503 | Feature Not Available | Requires Plus license |

---

## HTTP Response Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 401 | Authentication failed |
| 400 | Bad request / missing parameters |
| 404 | Unknown command |
| 500 | Server error |

---

## Port Reference

| Port | Service |
|------|---------|
| 2323 | Remote Admin HTTP (default) |
| 2324 | Remote Admin HTTPS (if enabled) |
| 1883 | MQTT (standard, to broker) |
| 8883 | MQTT TLS (to broker) |
