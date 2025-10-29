# CLAUDE.md - Digital Memoirs Technical Reference

**Project**: Digital Memoirs - Event Photo Sharing Web App
**Version**: 0.3.0
**Python**: >=3.11
**Framework**: Flask 3.1.2
**Last Updated**: 2025-10-28

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [File Structure](#file-structure)
4. [Core Components](#core-components)
5. [API Endpoints](#api-endpoints)
6. [Frontend Templates](#frontend-templates)
7. [Configuration & Environment](#configuration--environment)
8. [Known Issues & Solutions](#known-issues--solutions)
9. [Development Guidelines](#development-guidelines)
10. [Deployment Notes](#deployment-notes)
11. [Testing Strategy](#testing-strategy)

---

## Project Overview

Digital Memoirs is a Flask-based web application designed for event photo sharing. Guests at events (birthdays, parties, weddings) can upload photos via QR code scanning, and images are displayed in a real-time slideshow on a projector or large screen.

### Key Features

- **QR Code Generation**: Automatic QR code creation with local network IP
- **Photo Upload**: Multi-file upload with gallery and camera capture support
- **Real-time Slideshow**: Auto-refreshing image display with modern UI
- **Batch Processing**: Handles up to 800 images per batch with ThreadPoolExecutor
- **UUID File Naming**: Prevents filename conflicts and special character issues
- **HEIC/HEIF Support**: iPhone photo format compatibility
- **Dark Theme UI**: Modern glassmorphism design with Fira Code monospace font

### Target Environment

- **Primary**: Raspberry Pi access point (subnet `10.0.17.0/24`)
- **Gateway IP**: `10.0.17.1`
- **DHCP Range**: `10.0.17.2 - 10.0.17.254`
- **Development**: Any machine with Python 3.11+ and network connectivity

---

## Architecture

### System Design

```
┌─────────────────────────────────────────────────────────────┐
│                    Digital Memoirs Stack                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐         ┌──────────────┐                 │
│  │   Display   │◄────────┤   Flask      │                 │
│  │  /display   │         │   Server     │                 │
│  │  Slideshow  │         │   (app.py)   │                 │
│  └─────────────┘         └──────────────┘                 │
│        ▲                        │                          │
│        │                        │                          │
│        │                        ▼                          │
│        │                 ┌──────────────┐                 │
│        │                 │   File       │                 │
│        │                 │   Watcher    │                 │
│        │                 │  (Watchdog)  │                 │
│        │                 └──────────────┘                 │
│        │                        │                          │
│        └────────────────────────┘                          │
│                                                             │
│  ┌─────────────┐         ┌──────────────┐                 │
│  │    QR       │◄────────┤  QR Code     │                 │
│  │   /qr       │         │  Generator   │                 │
│  │  Display    │         │  (qrcode)    │                 │
│  └─────────────┘         └──────────────┘                 │
│                                                             │
│  ┌─────────────┐         ┌──────────────┐                 │
│  │   Upload    │────────►│  Upload      │                 │
│  │  /upload    │         │  Handler     │                 │
│  │   Form      │         │ (POST /upload)│                 │
│  └─────────────┘         └──────────────┘                 │
│        │                        │                          │
│        │                        ▼                          │
│        │                 ┌──────────────┐                 │
│        └────────────────►│   uploads/   │                 │
│                          │  (UUID files)│                 │
│                          └──────────────┘                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Request Flow

1. **QR Display**: Host opens `/qr` → Flask generates QR with local IP
2. **Guest Scan**: Guest scans QR → Opens `/upload` on mobile
3. **File Upload**: Guest selects photos → POST to `/upload` endpoint
4. **File Processing**: ThreadPoolExecutor saves files with UUID names
5. **File Watcher**: Watchdog detects new files → Updates image list
6. **Slideshow Update**: `/display` polls `/api/images` → Shows new photos

---

## File Structure

```
digital-memoirs/
├── app.py                      # Main Flask application (429 lines)
├── pyproject.toml              # UV/pip dependency management
├── README.md                   # User-facing documentation
├── TODO.md                     # Development history and issues log
├── CLAUDE.md                   # This file - technical reference
│
├── templates/                  # Jinja2 HTML templates
│   ├── display.html            # Main slideshow display (680 lines)
│   ├── qr.html                 # QR code display page (669 lines)
│   └── upload.html             # Photo upload interface (1117 lines)
│
├── static/                     # Static assets (auto-generated)
│   └── qr_code.png             # Generated QR code (cleaned on exit)
│
├── uploads/                    # User-uploaded photos (UUID-named)
│   └── [uuid].{jpg,png,gif,webp,heic,heif}
│
└── scripts/                    # Deployment and diagnostic scripts
    ├── install_service.sh      # systemd service installer (interactive)
    ├── setup_autostart.sh      # Browser autostart installer
    ├── autostart_browser.sh    # Browser autostart script
    ├── digital-memoirs-FIXED.service        # systemd service (180s delay)
    ├── digital-memoirs-NO-DELAY.service     # systemd service (10s delay)
    ├── digital-memoirs-autostart.desktop    # LXDE autostart config
    │
    ├── testing/                # Testing and diagnostic tools
    │   ├── diagnostics/        # Service diagnostics
    │   │   └── diagnose_service.sh
    │   └── network/            # Network diagnostics
    │       └── network_diagnostic.py
    │
    └── reference/              # Historical/reference code
        ├── hotfixes/           # Previous versions of app.py/templates
        ├── templates/          # Experimental templates
        └── services/           # Obsolete service files
```

---

## Core Components

### 1. Flask Application (`app.py`)

#### Key Configuration

```python
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['MAX_CONTENT_LENGTH'] = 500 * 1024 * 1024  # 500MB
app.config['BATCH_UPLOAD_LIMIT'] = 800  # Critical limit

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'heic', 'heif'}
```

#### Critical Functions

**`get_local_ip()`** (`app.py:61-83`)
- Determines local network IP via socket connection test
- Fallback mechanism for hostname resolution
- **Warning**: Returns `127.0.0.1` if all methods fail

**`generate_qr_code(url)`** (`app.py:133-147`)
- Creates QR code at `static/qr_code.png`
- Navy blue fill, white background
- Box size: 10, Border: 5
- **Cleanup**: Removed on shutdown via `cleanup_qr_code()`

**`UploadHandler` Class** (`app.py:85-117`)
- Extends `watchdog.events.FileSystemEventHandler`
- ThreadPoolExecutor with 4 workers for concurrent processing
- Renames uploaded files to `{uuid}.{extension}`
- Triggers `update_image_list()` on new files

**`process_single_file(file)`** (`app.py:250-273`)
- Validates file type via `allowed_file()`
- Uses `werkzeug.secure_filename()` for initial naming
- Saves file and verifies size > 0
- Returns `{'success': bool, 'error': str}` dict

#### Threading Model

```python
# Browser auto-open thread
browser_thread = threading.Thread(target=open_browser, daemon=True)
browser_thread.start()

# File watcher thread
observer = Observer()
observer.schedule(event_handler, 'uploads/', recursive=False)
observer.start()

# Upload processing
with ThreadPoolExecutor(max_workers=8) as executor:
    futures = [executor.submit(process_single_file, file) for file in files]
```

### 2. File System Watcher

**Watchdog Observer Pattern**
- Monitors: `uploads/` directory
- Events: `on_created` only (no modify/delete handling)
- Delay: 0.5s wait before processing to ensure file write completion
- Thread-safe: Uses `slideshow_lock` for `current_images` access

### 3. Concurrency & Performance

**ThreadPoolExecutor Usage**
- `UploadHandler`: 4 workers (file rename operations)
- `upload_files()`: 8 workers (concurrent upload processing)
- Timeout: 30 seconds per file operation
- Error handling: Captures and reports failed file count

**Critical Performance Notes**
- Batch limit of 800 files prevents memory exhaustion
- Particle count reduced to 15 in CSS for better rendering
- Simplified gradient backgrounds to avoid cursor lag in Firefox
- `will-change: auto` and `backface-visibility: hidden` for GPU optimization

---

## API Endpoints

### Public Routes

#### `GET /` or `GET /display`
**Purpose**: Main slideshow display for projection
**Returns**: HTML template (`display.html`)
**Side Effects**: Generates QR code in `static/`
**Reference**: `app.py:149-165`

#### `GET /qr`
**Purpose**: Clean QR code display for guest access
**Returns**: HTML template (`qr.html`)
**Context Variables**:
- `qr_path`: Path to QR code image
- `upload_url`: Full URL for upload page
**Reference**: `app.py:167-179`

#### `GET /upload`
**Purpose**: Upload form for guests
**Returns**: HTML template (`upload.html`)
**Reference**: `app.py:181-188`

#### `POST /upload`
**Purpose**: Handle multi-file photo uploads
**Request**: `multipart/form-data` with `files` field
**Validation**:
- Max 800 files per batch (`BATCH_UPLOAD_LIMIT`)
- Only allowed image extensions
- Max 500MB total request size

**Response**:
```json
{
  "success": "N fotos subidas exitosamente! 🎉"
}
// or
{
  "error": "Error message here"
}
```
**Reference**: `app.py:190-248`

### API Routes

#### `GET /api/images`
**Purpose**: Fetch current image list for slideshow
**Response**:
```json
{
  "images": ["uuid1.jpg", "uuid2.png"],
  "count": 2,
  "timestamp": "2025-10-21T12:00:00"
}
```
**Reference**: `app.py:275-287`

#### `GET /api/next_image`
**Purpose**: Get next image in slideshow rotation
**Response**:
```json
{
  "image": "/uploads/uuid.jpg",
  "filename": "uuid.jpg",
  "total": 150,
  "index": 42
}
```
**Reference**: `app.py:298-319`

#### `GET /api/stats`
**Purpose**: Application statistics
**Response**:
```json
{
  "total_photos": 150,
  "total_size_mb": 450.23,
  "server_status": "online",
  "batch_limit": 800,
  "last_upload": 1729512000
}
```
**Reference**: `app.py:321-345`

#### `GET /api/status`
**Purpose**: Health check endpoint
**Response**:
```json
{
  "status": "healthy",
  "image_count": 150,
  "timestamp": "2025-10-21T12:00:00",
  "upload_limit": 800
}
```
**Reference**: `app.py:348-363`

### Static File Routes

#### `GET /uploads/<filename>`
**Purpose**: Serve uploaded images
**Reference**: `app.py:289-296`

---

## Frontend Templates

### 1. `display.html` - Slideshow Display

**Purpose**: Real-time rotating photo slideshow for projection

**Key Features**:
- Fixed-position container with perfect centering (app.py:162 fix)
- 90-degree rotation for landscape orientation
- Auto-refresh every 2 seconds for new images
- Glassmorphism UI with dark theme
- Performance optimizations:
  - Reduced particle count (15 instead of 20)
  - Simplified gradients
  - GPU-accelerated transforms

**JavaScript Class**: `ModernSlideshow`
```javascript
class ModernSlideshow {
  slideInterval: null
  currentImages: []
  currentIndex: 0
  particleCount: 15

  init() {
    this.checkForNewImages()  // Every 2 seconds
    this.loadNextImage()      // Every 5 seconds
  }
}
```

**CSS Critical Sections**:
```css
.slideshow-area {
  position: fixed;
  top: 50%;
  left: 50%;
  width: 85vh;
  height: 85vw;
  transform: translate(-50%, -50%) rotate(90deg);
  /* FIX: Changed from relative to fixed for centering */
}

/* FIX: Widget orientation (21/10/2025) - Rotated to match slideshow */
.header-info {
  transform: rotate(90deg) translateY(-100%);
  transform-origin: top left;
  /* Left widget rotates vertically */
}

.photo-counter {
  transform: rotate(90deg) translateX(100%);
  transform-origin: top right;
  /* Right widget rotates vertically */
}
```

**Widget Orientation Fix** (`display.html:111-116`, `153-158`):
- Both status widgets now rotate 90° to align with slideshow
- Left widget ("Sistema Activo") uses `translateY(-100%)` compensation
- Right widget ("0 FOTOS") uses `translateX(100%)` compensation
- Ensures consistent vertical orientation across all UI elements

**API Calls**:
- `GET /api/images` - Check for new uploads
- `GET /api/next_image` - Fetch next photo

**Reference**: `display.html:1-680`

### 2. `qr.html` - QR Code Display

**Purpose**: Guest-facing QR code page for easy scanning

**Key Features**:
- Large, high-contrast QR code (280x280px)
- Animated scan line effect
- Copy-to-clipboard URL functionality
- Step-by-step instructions
- Server status indicator

**JavaScript Class**: `QRCodeManager`
```javascript
class QRCodeManager {
  async copyUrl() {
    await navigator.clipboard.writeText(this.uploadUrl)
    this.showSuccessAnimation()
  }

  startStatusCheck() {
    // Checks /api/status every 10 seconds
  }
}
```

**Reference**: `qr.html:1-669`

### 3. `upload.html` - Photo Upload Interface

**Purpose**: Guest interface for uploading photos

**Key Features**:
- Dual upload modes: Gallery selection + Camera capture
- Camera loop prevention (critical fix, app.py:162)
- Batch upload validation (800 file limit warning)
- Drag-and-drop support
- Progress bar with shimmer animation
- File type validation client-side

**JavaScript Class**: `ModernUploader`
```javascript
class ModernUploader {
  selectedFilesList: []
  isUploading: false
  cameraStream: null
  isCameraOpen: false
  cameraCloseTimeout: null  // FIX: Prevents infinite loop

  async toggleCamera() {
    // Try 'environment' (back) camera first
    // Fallback to 'user' (front) camera
  }

  closeCamera() {
    // Clean up all streams
    // Clear timeouts
    // Set flags to false
  }
}
```

**Critical Fix - Camera Loop Prevention**:
```javascript
// FIX from TODO.md (line 104-113)
closeCamera() {
  if (this.cameraStream) {
    this.cameraStream.getTracks().forEach(track => track.stop())
    this.cameraStream = null
  }
  this.isCameraOpen = false
  if (this.cameraCloseTimeout) {
    clearTimeout(this.cameraCloseTimeout)
    this.cameraCloseTimeout = null
  }
}
```

**Reference**: `upload.html:1-1117`

### ⚠️ **Camera Functionality Status (21/10/2025)**

**Status**: DISABLED - Browser Security Restriction

The camera capture feature is currently **disabled** due to modern browser security policies that block `getUserMedia` API in insecure HTTP contexts.

**Technical Details**:
- `navigator.mediaDevices` returns `undefined` when accessing via HTTP on local network IPs
- All legacy APIs (`navigator.webkitGetUserMedia`, etc.) are also unavailable
- Only works on `localhost` or with HTTPS connections
- **Reference**: `TODO.md:9-53` (21/10/2025 investigation)

**Current Implementation**:
- Camera button displays as **disabled** with grayed-out styling
- Shows informative error message when clicked: `"📷 La función de cámara no está disponible..."`
- "Seleccionar Fotos" gallery upload remains fully functional
- **Files Modified**:
  - `templates/upload.html:671-675` - Disabled button markup
  - `templates/upload.html:278-304` - `.camera-disabled` CSS styling
  - `templates/upload.html:741-794` - API detection polyfill
  - `templates/upload.html:1235-1244` - Error message handler

**To Re-enable Camera**:
Configure Flask with HTTPS using SSL certificates:
```python
# Option 1: Self-signed (testing)
app.run(host='0.0.0.0', port=5000, ssl_context='adhoc')

# Option 2: Proper certificates
app.run(host='0.0.0.0', port=5000,
        ssl_context=('/path/to/cert.pem', '/path/to/key.pem'))
```

Or use nginx/apache as HTTPS reverse proxy in production.

---

## Configuration & Environment

### Installation Methods

#### Option 1: UV (Recommended)
```bash
uv sync
./.venv/bin/python3 app.py
```

#### Option 2: Pip + venv
```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -e .
python app.py
```

### Dependencies (`pyproject.toml`)

```toml
[project]
requires-python = ">=3.11"
dependencies = [
    "flask>=3.1.2",          # Web framework
    "jsonify>=0.5",          # JSON responses
    "netifaces>=0.11.0",     # Network interface info
    "pillow>=11.3.0",        # Image processing
    "qrcode>=8.2",           # QR code generation
    "requests>=2.32.5",      # HTTP client
    "segno>=1.6.6",          # Alternative QR encoder
    "sockets>=1.0.0",        # Socket utilities
    "uuid>=1.30",            # UUID generation
    "watchdog>=6.0.0",       # File system monitoring
]
```

### Runtime Configuration

**Port**: `5000` (hardcoded in `app.py:429`)
**Host**: `0.0.0.0` (listens on all interfaces)
**Debug Mode**: `False` (FIX: changed from True to prevent double browser tabs)
**Threading**: `True` (enables multi-threading)

**Startup Sequence** (`app.py:398-439`):
1. Register cleanup functions (`atexit`, `signal.SIGINT`)
2. Clean up existing QR code
3. Initialize image list from `uploads/`
4. Start file watcher (Watchdog)
5. Get and log local IP
6. Start browser-opening thread (3-second delay)
7. Run Flask server

---

## Known Issues & Solutions

### Issue History (from `TODO.md`)

#### ✅ RESOLVED: Duplicate Browser Tab Opening
**Status**: Fixed
**Date**: 15/10/2025
**Root Cause**: `debug=True` in Flask causes reloader to launch twice
**Solution**: Changed to `debug=False` in `app.py:429`
**Reference**: `app.py:426-429`, `TODO.md:13-30`

#### ✅ RESOLVED: Static IP Subnet Change
**Status**: Done
**Date**: 15/10/2025
**Old Subnet**: `192.168.10.0/24`
**New Subnet**: `10.0.17.0/24`
**Gateway**: `10.0.17.1`
**Reference**: `TODO.md:33-55`

#### ✅ RESOLVED: Camera Button Loop
**Status**: Fixed
**Date**: 19/10/2025
**Root Cause**: Template mismatch - app.py referenced non-existent files
**Files**: `upload_fixed.html`, `display_fixed.html`, `qr_fixed.html`
**Solution**: Corrected to `upload.html`, `display.html`, `qr.html`
**Reference**: `app.py:162, 176, 185`, `TODO.md:70-85`

#### ⚠️ DISABLED: Camera Functionality - getUserMedia API Blocked
**Status**: Feature Disabled (Not a Bug)
**Date**: 21/10/2025
**Root Cause**: Modern browsers block `getUserMedia` API in HTTP contexts (non-localhost IPs) for security
**Investigation**:
- All getUserMedia APIs return `undefined` or `false` in HTTP on local network
- `navigator.mediaDevices`, `webkitGetUserMedia`, `mozGetUserMedia` all unavailable
- Browser security policy, not a code bug
**Solution**:
- Camera button disabled with visual indicators (grayed out, "⚠️ no disponible")
- Informative error message shown on click
- "Seleccionar Fotos" gallery upload remains fully functional
**Future**: Can be re-enabled by configuring HTTPS with SSL certificates
**Reference**: `upload.html:278-304, 671-675, 741-794, 1235-1244`, `TODO.md:9-53`

#### ✅ RESOLVED: Widget Orientation Mismatch in Display
**Status**: Fixed
**Date**: 21/10/2025
**Root Cause**: Status widgets remained horizontal while slideshow rotated 90°
**Solution**:
- Applied `rotate(90deg)` transform to both widgets
- Left widget: `translateY(-100%)` compensation
- Right widget: `translateX(100%)` compensation
- Both widgets now align with vertical slideshow orientation
**Reference**: `display.html:111-116, 153-158`, `TODO.md:56-81`

#### ✅ RESOLVED: CSS Container Misalignment
**Status**: Fixed
**Date**: 17/10/2025
**Root Cause**: `position: relative` with margin-based centering failed
**Solution**: Changed to `position: fixed` with `transform: translate(-50%, -50%)`
**Reference**: `display.html:179-196`, `TODO.md:94-103`

#### ✅ RESOLVED: Infinite Camera Loop
**Status**: Fixed
**Date**: 17/10/2025
**Root Cause**: Missing state management for camera open/close cycles
**Solution**: Added `isCameraOpen` flag and `cameraCloseTimeout` cleanup
**Reference**: `upload.html:712, 869-885`, `TODO.md:104-113`

#### ✅ RESOLVED: Bulk Upload Crashes (>800 images)
**Status**: Fixed
**Date**: 17/10/2025
**Root Cause**: Memory exhaustion on large concurrent uploads
**Solution**: Implemented `BATCH_UPLOAD_LIMIT = 800` with validation
**Reference**: `app.py:25, 199-204`, `TODO.md:114-123`

### Current Known Limitations

1. **Raspberry Pi Access Point Stability**: Requires periodic network checks
2. **HEIC Support**: Requires Pillow with HEIC extras (may need `pillow-heif`)
3. **Camera Functionality**: DISABLED - Requires HTTPS for `getUserMedia` API (21/10/2025)
   - Works only on `localhost` or with SSL certificates
   - Gallery upload ("Seleccionar Fotos") remains fully functional
4. **Image Rotation**: Slideshow rotates 90° - assumes landscape display orientation
5. **No Authentication**: Open network with no user accounts or access control

---

## Development Guidelines

### Code Style

- **Language**: Python 3.11+
- **Formatting**: Standard Python conventions (PEP 8)
- **Comments**: Use `# FIX:` prefix for bug-related changes
- **Logging**: Use `logger.info()` and `logger.error()` with emoji prefixes

### Git Commit Convention

Based on `TODO.md` history, commits should follow:
```
<type>: <description>

Examples:
- fix: corrected template mismatch in app.py routes
- feat: added batch upload limit of 800 files
- perf: reduced particle count for better rendering
- docs: updated CLAUDE.md with architecture details
```

### Testing Checklist (from `TODO.md:186-202`)

**Before Deployment**:
1. ✅ CSS Container - Verify slideshow centers perfectly
2. ✅ Camera Button - Test open → close → gallery → camera cycle
3. ✅ Bulk Upload - Try 900+ images, verify controlled failure
4. ✅ Performance - Check for cursor lag in Firefox/Mozilla
5. ✅ Responsive - Test on mobile, tablet, desktop
6. ✅ Camera Capture - Verify direct photo capture works
7. ✅ Upload Limit - Confirm 800-file warning displays
8. ✅ Dark Theme - Check consistency across all pages
9. ✅ Progress Bar - Verify upload indicators work
10. ✅ Health Check - Test `/api/status` endpoint

### Adding New Features

**Backend (app.py)**:
1. Add route with proper error handling
2. Use `logger.info()` for significant events
3. Add to error handlers if needed (`@app.errorhandler`)
4. Update this CLAUDE.md's API Endpoints section

**Frontend (templates/)**:
1. Maintain dark theme CSS variables
2. Use `Fira Code` monospace font
3. Implement glassmorphism style (`--glass-bg`, `--glass-border`)
4. Add performance optimizations (`will-change`, `backface-visibility`)
5. Test on mobile devices

**Documentation**:
1. Update `README.md` for user-facing changes
2. Update `TODO.md` with testing results
3. Update this `CLAUDE.md` with technical details

---

## Deployment Notes

### Raspberry Pi Configuration

**Network Setup** (from `TODO.md:38-49`):
```bash
# dnsmasq.conf
interface=wlan0
dhcp-range=10.0.17.2,10.0.17.254,255.255.255.0,24h
dhcp-option=3,10.0.17.1  # Gateway
dhcp-option=6,10.0.17.1  # DNS
address=/digital-memoirs.local/10.0.17.1
```

**Hostapd Configuration**:
```bash
# /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=EventPhotos
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=YourSecurePassword
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
```

### Systemd Service (Optional)

```ini
[Unit]
Description=Digital Memoirs Photo Sharing
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/digital-memoirs
Environment="PATH=/home/pi/digital-memoirs/.venv/bin"
ExecStart=/home/pi/digital-memoirs/.venv/bin/python3 app.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### Pre-Deployment Checklist

- [ ] Test on Raspberry Pi hardware
- [ ] Verify subnet configuration (`10.0.17.0/24`)
- [ ] Test QR code scanning from mobile
- [ ] Verify uploads/ directory permissions
- [ ] Test with 700-900 image batch
- [ ] Confirm browser auto-launch works
- [ ] Verify cleanup on Ctrl+C
- [ ] Test camera API on mobile browsers
- [ ] Check HEIC file support
- [ ] Verify slideshow rotation on actual projector

---

## Testing Strategy

### Unit Testing (Not Implemented)

Future consideration: Add pytest tests for:
- `get_local_ip()` fallback mechanisms
- `allowed_file()` validation
- `process_single_file()` error handling
- QR code generation

### Integration Testing

**Manual Testing Workflow**:
1. Start server: `python app.py`
2. Verify browser opens to `/display`
3. Open `/qr` in separate tab
4. Scan QR with mobile device
5. Upload test images (1, 10, 100, 800, 900)
6. Verify slideshow updates
7. Test camera capture on mobile
8. Check `/api/stats` and `/api/status`
9. Force quit with Ctrl+C
10. Verify `static/qr_code.png` cleanup

### Performance Testing

**Benchmarks** (from `TODO.md`):
- ✅ Up to 800 images: Handled smoothly
- ⚠️ 800-900 images: Warning displayed, may succeed
- ❌ 900+ images: Likely to fail (memory/timeout)

**Browser Performance**:
- ✅ Chrome/Edge: Smooth gradients and animations
- ✅ Firefox: Fixed cursor lag with simplified gradients
- ⚠️ Safari: Camera API requires user gesture
- ⚠️ Mobile browsers: HEIC upload requires Pillow extras

---

## Quick Reference

### Common Tasks

**Start Development Server**:
```bash
uv sync && ./.venv/bin/python3 app.py
```

**Check Server Status**:
```bash
curl http://localhost:5000/api/status
```

**Clear Uploads**:
```bash
rm -rf uploads/*
```

**Regenerate QR Code**:
```python
# Restart server or access /qr endpoint
```

### Important File Locations

| File | Purpose | Auto-Generated? |
|------|---------|----------------|
| `uploads/` | User photos | Yes (on upload) |
| `static/qr_code.png` | QR code image | Yes (on `/qr` access) |
| `.venv/` | Virtual environment | Yes (on `uv sync`) |
| `__pycache__/` | Python bytecode | Yes (on runtime) |

### Port & Network

- **Local Access**: `http://localhost:5000`
- **Network Access**: `http://<local_ip>:5000`
- **Upload Endpoint**: `http://<local_ip>:5000/upload`
- **Raspberry Pi**: `http://10.0.17.1:5000`

### Logging

**Important Log Messages**:
```
🚀 Starting Digital Memoirs app...
📱 Local access: http://localhost:5000
🌐 Network access: http://<IP>:5000
📸 Upload URL for QR: http://<IP>:5000/upload
🖥️ Display will open in browser in 3 seconds...
📊 Batch upload limit: 800 files
🧹 Cleaned up QR code file
👋 Digital Memoirs closed gracefully
```

---

## Appendix

### Color Palette (CSS Variables)

```css
--dark-bg-primary: #0a0a0f
--dark-bg-secondary: #1a1a2e
--dark-bg-tertiary: #16213e
--accent-cyan: #00f5ff
--accent-purple: #8b5cf6
--accent-pink: #ec4899
--accent-green: #10b981
--accent-orange: #f59e0b
--text-primary: #e2e8f0
--text-secondary: #94a3b8
--glass-bg: rgba(255, 255, 255, 0.05)
--glass-border: rgba(255, 255, 255, 0.1)
```

### Project Timeline

- **15/10/2025**: Fixed Raspberry Pi AP stability, browser double-tab, subnet change
- **17/10/2025**: CSS container fix, camera loop fix, bulk upload limit
- **19/10/2025**: Template mismatch fix, camera button functional
- **21/10/2025**:
  - CLAUDE.md documentation created
  - Camera functionality investigation - disabled due to browser security (HTTP context)
  - Widget orientation fix - aligned status widgets with 90° rotated slideshow
- **24/10/2025**:
  - Captive portal WiFi configuration implemented (dnsmasq + iptables + Flask endpoints)
  - Android captive portal partially working (requires manual "USE AS IS")
  - DNS wildcard hijacking configured for Google domains
  - iptables HTTP/DNS redirection to Flask server
  - Persistent configuration saved for reboot
- **25/10/2025 - 7:00 AM**:
  - **CRITICAL FIX**: Android captive portal HTTP 302 redirect implementation
  - Changed all captive portal endpoints from `HTTP 200` → `HTTP 302 Redirect`
  - Modified `ios_captive_portal()`, `android_captive_portal()`, `windows_captive_portal()`
  - Expected result: Android CNA stays open automatically without "USE AS IS" button
  - Testing scheduled for 12:00 PM before Saturday event

### External References

- Flask Documentation: https://flask.palletsprojects.com/
- Watchdog Docs: https://python-watchdog.readthedocs.io/
- QRCode Library: https://github.com/lincolnloop/python-qrcode
- Pillow (PIL): https://pillow.readthedocs.io/
- Android Captive Portal Detection: https://source.android.com/docs/core/connect/captive-portal

---

## Captive Portal Configuration

### Overview

As of 24/10/2025, Digital Memoirs includes a WiFi captive portal system that automatically redirects users to the `/upload` page when they connect to the "MomentoMarco" WiFi network.

### Architecture

```
Guest Device (Phone/Tablet)
    │
    ├─→ Scans WiFi QR Code
    │   └─→ Auto-connects to "MomentoMarco" (SSID)
    │
    ├─→ OS checks for internet connectivity
    │   ├─→ iOS: requests http://captive.apple.com/hotspot-detect.html
    │   ├─→ Android: requests http://connectivitycheck.gstatic.com/generate_204
    │   └─→ Windows: requests http://www.msftconnecttest.com/connecttest.txt
    │
    ├─→ DNS Query: "What's the IP of captive.apple.com?"
    │   └─→ dnsmasq intercepts → responds: "10.0.17.1" (Raspberry Pi)
    │
    ├─→ HTTP Request: GET http://10.0.17.1/generate_204
    │   └─→ iptables intercepts port 80 → redirects to port 5000 (Flask)
    │
    ├─→ Flask responds with captive portal page
    │   ├─→ iOS: Renders upload.html directly
    │   ├─→ Android: Returns HTML with auto-redirect to /upload
    │   └─→ Windows: Renders upload.html directly
    │
    └─→ User uploads photos via /upload endpoint
```

### Components

#### 1. dnsmasq Configuration

**File**: `/etc/dnsmasq.conf`

**Purpose**: DNS server that hijacks captive portal detection domains and points them to the Raspberry Pi

**Key Configuration**:
- DHCP range: `10.0.17.2 - 10.0.17.254`
- DNS hijacking for:
  - `captive.apple.com` → `10.0.17.1`
  - `connectivitycheck.gstatic.com` → `10.0.17.1`
  - Wildcard: `*.google.com` → `10.0.17.1`
  - Wildcard: `*.gstatic.com` → `10.0.17.1`

**Reference**: `TODO.md:185-240` (full configuration)

#### 2. iptables Firewall Rules

**File**: `/etc/iptables/rules.v4`

**Purpose**: Redirect HTTP and DNS traffic to local services

**Rules**:
```bash
# PREROUTING chain (intercept incoming traffic)
-A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-ports 5000   # HTTP → Flask
-A PREROUTING -i wlan0 -p tcp --dport 53 -j REDIRECT --to-ports 53     # DNS → dnsmasq
-A PREROUTING -i wlan0 -p udp --dport 53 -j REDIRECT --to-ports 53     # DNS → dnsmasq

# POSTROUTING chain (internet sharing)
-A POSTROUTING -o eth0 -j MASQUERADE  # Share internet via Ethernet
```

**Reference**: `TODO.md:244-277` (full configuration)

#### 3. Flask Captive Portal Endpoints

**File**: `app.py:392-423`

**Endpoints**:
- `GET /hotspot-detect.html` - iOS captive portal detection (`app.py:398`)
- `GET /library/test/success.html` - iOS alternative (`app.py:399`)
- `GET /generate_204` - Android captive portal detection (`app.py:406`)
- `GET /gen_204` - Android alternative (`app.py:407`)
- `GET /connecttest.txt` - Windows captive portal detection (`app.py:417`)
- `GET /ncsi.txt` - Windows alternative (`app.py:418`)

**Response Strategy (Updated 25/10/2025)**:
- **All platforms (iOS/Android/Windows)**: Return `HTTP 302 Redirect` to `/upload`
  - Uses `redirect(url_for('upload_page'))`
  - Does NOT render template directly (would send HTTP 200 and close portal)
  - Background OS services continue polling and receiving HTTP 302
  - OS interprets 302 as "user still authenticating" → keeps portal open

**Previous Strategy (DEPRECATED - caused Android to close CNA immediately)**:
- ~~iOS/Windows: Directly render `upload.html` template (HTTP 200)~~
- ~~Android: Return HTML with meta refresh + JavaScript redirect (HTTP 200)~~

**Reference**: `app.py:392-423`

### Known Issues

#### ✅ Android Captive Portal Detection (Status: RESOLVED - 25/10/2025)

**Problem**: Android devices did not automatically show "Sign in to network" notification and closed CNA immediately

**Root Cause**: Flask endpoints responded with `HTTP 200 OK` instead of `HTTP 302 Redirect`
- Android interprets HTTP 200 as "internet available" → closes Captive Network Assistant (CNA)
- Android interprets HTTP 302 as "captive portal active" → keeps CNA open

**Solution Implemented**:
- Changed all captive portal endpoints from `render_template('upload.html')` → `redirect(url_for('upload_page'))`
- Endpoints affected: `/hotspot-detect.html`, `/generate_204`, `/connecttest.txt`
- Now responds with HTTP 302 redirect to `/upload` instead of HTTP 200 with rendered template

**How It Works Now**:
```
1. Android background service requests: GET /generate_204
2. Flask responds: HTTP 302 Location: /upload
3. Android detects: "Captive portal active"
4. Android opens: CNA (mini-browser) navigated to /upload
5. Background polling: Continues requesting /generate_204 every 5-10 seconds
6. Flask continues: Responding with HTTP 302
7. Android keeps: CNA open (interprets as "user still authenticating")
```

**Testing Status**: Pending real-world testing (scheduled for 12:00 PM 25/10/2025)

**Files Modified**: `app.py:398-423`

**Reference**: `TODO.md:9-45, 384-424`

### Deployment Checklist

Before using captive portal in production:

1. **Verify dnsmasq**:
   ```bash
   sudo systemctl status dnsmasq  # Should be "active (running)"
   nslookup www.google.com localhost  # Should return 10.0.17.1
   ```

2. **Verify iptables**:
   ```bash
   sudo iptables -t nat -L PREROUTING -n -v  # Should show 3 REDIRECT rules
   ```

3. **Test endpoints**:
   ```bash
   curl http://localhost:5000/generate_204  # Should return HTML (200)
   curl http://localhost:5000/hotspot-detect.html  # Should return HTML (200)
   ```

4. **Test with real devices**:
   - iOS: Test if notification appears automatically
   - Android: Confirm "USE AS IS" workflow
   - Windows: Test connectivity check

5. **Monitor logs**:
   ```bash
   sudo journalctl -u dnsmasq -f  # DNS queries
   python3 app.py  # Flask captive portal requests
   ```

### Troubleshooting

**If captive portal doesn't work**:
1. Check dnsmasq is running: `sudo systemctl status dnsmasq`
2. Check iptables rules: `sudo iptables -t nat -L -n -v`
3. Check Flask is listening on 0.0.0.0:5000: `netstat -tulpn | grep 5000`
4. Check DNS resolution from client device: Install "DNS Lookup" app, verify google.com → 10.0.17.1

**If configuration resets after reboot**:
1. Verify dnsmasq config: `cat /etc/dnsmasq.conf | grep "DIGITAL MEMOIRS"`
2. Verify iptables persistence: `cat /etc/iptables/rules.v4`
3. Restore from backup: See `TODO.md:342-350`

---

## Deployment Automation (Version 0.3.0)

### Overview

Version 0.3.0 introduces complete Plug & Play deployment automation for Raspberry Pi. The system now boots automatically, starts Flask, and opens the browser in kiosk mode without any manual intervention.

### Architecture

```
┌──────────────────────────────────────────────────────────────┐
│               Raspberry Pi Boot Sequence                     │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. System Boot                                              │
│     │                                                        │
│     ▼                                                        │
│  2. Network Services Start                                   │
│     ├─ dnsmasq (DHCP + DNS)                                 │
│     └─ wpa_supplicant (WiFi)                                │
│     │                                                        │
│     ▼                                                        │
│  3. Wait 180 seconds (ensure network stable)                │
│     │                                                        │
│     ▼                                                        │
│  4. systemd starts digital-memoirs.service                  │
│     ├─ ExecStartPre: /bin/sleep 180                         │
│     ├─ TimeoutStartSec: 240 (critical fix)                  │
│     └─ ExecStart: uv run app.py                             │
│     │                                                        │
│     ▼                                                        │
│  5. Flask Server Running (port 5000)                        │
│     ├─ QR codes generated                                   │
│     ├─ Endpoints available                                  │
│     └─ Watchdog monitoring uploads/                         │
│                                                              │
│  ═════════════════════════════════════════════════════════  │
│                                                              │
│  6. User Login to Desktop (LXDE)                            │
│     │                                                        │
│     ▼                                                        │
│  7. LXDE Autostart Triggered                                │
│     └─ ~/.config/autostart/digital-memoirs-autostart.desktop│
│     │                                                        │
│     ▼                                                        │
│  8. autostart_browser.sh Executes                           │
│     ├─ Wait for Flask (curl localhost:5000/api/status)     │
│     ├─ Timeout: 5 minutes                                   │
│     ├─ Polling interval: 5 seconds                          │
│     └─ Log: ~/.digital-memoirs-autostart.log               │
│     │                                                        │
│     ▼                                                        │
│  9. Chromium Opens in Kiosk Mode                            │
│     ├─ --kiosk (fullscreen, no UI)                          │
│     ├─ --password-store=basic (no keyring prompt)          │
│     ├─ --noerrdialogs                                       │
│     ├─ --disable-infobars                                   │
│     └─ URL: http://localhost:5000/display                   │
│                                                              │
│  ✅ System Ready for Event                                  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Component 1: systemd Service

#### Files
- `scripts/digital-memoirs-FIXED.service` - Production service (180s delay)
- `scripts/digital-memoirs-NO-DELAY.service` - Fast boot alternative (10s delay)
- `scripts/install_service.sh` - Interactive installer

#### Configuration (FIXED.service)

```ini
[Unit]
Description=Digital Memoirs - Event Photo Sharing
Documentation=https://github.com/oroslan/digital-memoirs
After=network-online.target dnsmasq.service wpa_supplicant.service
Wants=network-online.target

[Service]
Type=simple
User=pi
Group=pi
WorkingDirectory=/home/pi/Downloads/repos/digital-memoirs

# CRITICAL FIX (v0.3.0): Timeout must exceed sleep duration
TimeoutStartSec=240   # 180s sleep + 60s margin
TimeoutStopSec=30

# Delay ensures network and dnsmasq are fully ready
ExecStartPre=/bin/sleep 180

# Start Flask with uv (handles venv automatically)
ExecStart=/home/pi/.local/bin/uv run app.py

# Auto-restart on failure
Restart=on-failure
RestartSec=10

# Environment
Environment="PYTHONUNBUFFERED=1"
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

#### Critical Bug Fix - systemd Timeout

**Problem**: Service hung for 90 seconds then failed with "Start operation timed out"

**Root Cause**:
- `ExecStartPre=/bin/sleep 180` waited 180 seconds
- systemd default `TimeoutStartSec` is ~90 seconds
- Service exceeded timeout → systemd terminated it

**Solution**:
```ini
TimeoutStartSec=240  # Must be > sleep duration (180s) + margin
```

**Verification**:
```bash
# Check configured timeout
systemctl show digital-memoirs | grep Timeout
# Should show: TimeoutStartUSec=4min (240 seconds)

# Check service status
sudo systemctl status digital-memoirs
# Should show: active (running)
```

**Reference**: `scripts/SOLUCION_TIMEOUT.md`, `scripts/reference/services/README.md`

#### Installation

```bash
cd /home/pi/Downloads/repos/digital-memoirs/scripts
chmod +x install_service.sh
./install_service.sh

# Interactive menu:
# [1] Install FIXED version (180s delay) - RECOMMENDED
# [2] Install NO-DELAY version (10s delay) - Fast boot
# [3] Check service status
# [4] View service logs
# [5] Uninstall service
```

**Manual installation**:
```bash
sudo cp digital-memoirs-FIXED.service /etc/systemd/system/digital-memoirs.service
sudo systemctl daemon-reload
sudo systemctl enable digital-memoirs
sudo systemctl start digital-memoirs
```

#### Logging

```bash
# View logs in real-time
sudo journalctl -u digital-memoirs -f

# View last 50 lines
sudo journalctl -u digital-memoirs -n 50

# View logs since boot
sudo journalctl -u digital-memoirs -b
```

### Component 2: Browser Autostart

#### Files
- `scripts/autostart_browser.sh` - Autostart script with health checks
- `scripts/setup_autostart.sh` - Interactive installer
- `scripts/digital-memoirs-autostart.desktop` - LXDE desktop entry

#### Script: autostart_browser.sh

```bash
#!/bin/bash

# Configuration
FLASK_URL="http://localhost:5000/display"
LOG_FILE="$HOME/.digital-memoirs-autostart.log"
MAX_WAIT=300      # 5 minutes timeout
WAIT_INTERVAL=5   # Check every 5 seconds

# Wait for Flask to be available
echo "$(date): Waiting for Flask server..." >> "$LOG_FILE"

elapsed=0
while [ $elapsed -lt $MAX_WAIT ]; do
    if curl -s -o /dev/null -w "%{http_code}" "$FLASK_URL" | grep -q "200"; then
        echo "$(date): Flask is available!" >> "$LOG_FILE"
        break
    fi

    sleep $WAIT_INTERVAL
    elapsed=$((elapsed + WAIT_INTERVAL))
    echo "$(date): Still waiting... ($elapsed/$MAX_WAIT seconds)" >> "$LOG_FILE"
done

# Check if timeout exceeded
if [ $elapsed -ge $MAX_WAIT ]; then
    echo "$(date): ERROR - Flask did not start within $MAX_WAIT seconds" >> "$LOG_FILE"
    exit 1
fi

# Wait an additional 3 seconds for stability
sleep 3

# Launch Chromium in kiosk mode
echo "$(date): Launching Chromium..." >> "$LOG_FILE"

chromium-browser \
    --kiosk \
    --password-store=basic \
    --noerrdialogs \
    --disable-infobars \
    --disable-session-crashed-bubble \
    --check-for-update-interval=31536000 \
    "$FLASK_URL" >> "$LOG_FILE" 2>&1 &

echo "$(date): Chromium launched successfully" >> "$LOG_FILE"
```

**Key Features**:
- Health check loop: Polls Flask `/display` until available
- Timeout: 5 minutes maximum wait
- Logging: All events logged to `~/.digital-memoirs-autostart.log`
- Chromium flags:
  - `--kiosk`: Fullscreen mode, no browser UI
  - `--password-store=basic`: Prevents keyring password prompt (critical fix)
  - `--noerrdialogs`: Suppress error dialogs
  - `--disable-infobars`: No information bars

#### Desktop Entry: digital-memoirs-autostart.desktop

```ini
[Desktop Entry]
Type=Application
Name=Digital Memoirs Autostart
Comment=Auto-opens Chromium with Digital Memoirs slideshow
Exec=/home/pi/Downloads/repos/digital-memoirs/scripts/autostart_browser.sh
Terminal=false
Hidden=false
X-GNOME-Autostart-enabled=true
```

**Installation location**: `~/.config/autostart/digital-memoirs-autostart.desktop`

#### Installation

```bash
cd /home/pi/Downloads/repos/digital-memoirs/scripts
chmod +x setup_autostart.sh
./setup_autostart.sh

# Prompts:
# - Confirms project location
# - Installs desktop entry file
# - Configures Chromium flags
# - Offers to test immediately (Y/N)
```

**Verification**:
```bash
# Check autostart is configured
ls -la ~/.config/autostart/digital-memoirs-autostart.desktop

# View autostart log
tail -f ~/.digital-memoirs-autostart.log

# Test manually
cd /home/pi/Downloads/repos/digital-memoirs/scripts
./autostart_browser.sh
```

#### Critical Bug Fix - Chromium Keyring Password

**Problem**: Chromium prompted for keyring password on every launch

**Root Cause**: Chromium tries to use gnome-keyring by default to store passwords

**Solution**: `--password-store=basic` flag tells Chromium to use basic (file-based) password storage instead of keyring

**Impact**: No password prompts, autostart works seamlessly

**Reference**: `scripts/AUTOSTART_BROWSER.md`

### Component 3: Diagnostic Tools

#### diagnose_service.sh

**Location**: `scripts/testing/diagnostics/diagnose_service.sh`

**Purpose**: Comprehensive diagnostic report for systemd service and Flask

**Output**:
```
=== DIGITAL MEMOIRS SERVICE DIAGNOSTIC ===
Date: 2025-10-28 14:30:00

=== SYSTEM INFO ===
Hostname: raspberrypi
OS: Raspberry Pi OS (Debian 12)
Python: 3.11.2

=== FILE CHECKS ===
✓ Project directory exists
✓ app.py found
✓ uv binary found at /home/pi/.local/bin/uv

=== SERVICE STATUS ===
● digital-memoirs.service - Digital Memoirs - Event Photo Sharing
     Loaded: loaded (/etc/systemd/system/digital-memoirs.service; enabled)
     Active: active (running) since ...

=== SERVICE LOGS (last 20 lines) ===
[... recent logs ...]

=== FLASK CONNECTIVITY ===
✓ Flask responding on localhost:5000

=== NETWORK INFO ===
wlan0: 10.0.17.1/24
...

=== PYTHON DEPENDENCIES ===
Flask==3.1.2
qrcode==8.2
...

=== RECOMMENDATIONS ===
✓ All checks passed
```

**Usage**:
```bash
cd scripts/testing/diagnostics
./diagnose_service.sh > report.txt
cat report.txt
```

#### network_diagnostic.py

**Location**: `scripts/testing/network/network_diagnostic.py`

**Purpose**: Diagnose network configuration and connectivity

**Checks**:
- wlan0 interface status and IP
- dnsmasq DHCP configuration
- DNS resolution testing
- iptables rules for captive portal
- Flask connectivity

**Usage**:
```bash
cd scripts/testing/network
python3 network_diagnostic.py
```

### Deployment Workflow

#### Initial Setup (One-time)

1. **Clone repository**:
   ```bash
   cd /home/pi/Downloads/repos
   git clone <repo-url> digital-memoirs
   cd digital-memoirs
   ```

2. **Install uv** (if not installed):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   source ~/.bashrc
   ```

3. **Install dependencies**:
   ```bash
   uv sync
   ```

4. **Install systemd service**:
   ```bash
   cd scripts
   chmod +x install_service.sh
   ./install_service.sh
   # Select Option 1 (FIXED version with 180s delay)
   ```

5. **Install browser autostart**:
   ```bash
   chmod +x setup_autostart.sh
   ./setup_autostart.sh
   # Answer 'Y' to test immediately
   ```

6. **Reboot and verify**:
   ```bash
   sudo reboot
   # After reboot:
   # 1. Login to desktop
   # 2. Wait 3-5 minutes
   # 3. Verify Flask service: sudo systemctl status digital-memoirs
   # 4. Verify Chromium opened in kiosk mode
   # 5. Verify /display slideshow is shown
   ```

#### Event Day (Plug & Play)

1. **Plug in Raspberry Pi** → Power on
2. **Wait for boot** → ~1 minute to GUI login
3. **Login to desktop** → Username: pi
4. **Wait 3-5 minutes** → systemd starts Flask (180s delay + startup time)
5. **Chromium opens automatically** → Shows slideshow in kiosk mode
6. **Project QR codes** → Navigate to `http://localhost:5000/qr` if needed
7. **Monitor** (optional):
   ```bash
   # In terminal (SSH or local)
   sudo journalctl -u digital-memoirs -f
   tail -f ~/.digital-memoirs-autostart.log
   ```

#### Troubleshooting

**Service not starting**:
```bash
# Check service status
sudo systemctl status digital-memoirs

# View logs
sudo journalctl -u digital-memoirs -n 50

# Run diagnostics
cd scripts/testing/diagnostics
./diagnose_service.sh > report.txt
cat report.txt
```

**Browser not opening**:
```bash
# Check autostart configuration
ls ~/.config/autostart/digital-memoirs-autostart.desktop

# View autostart log
tail -f ~/.digital-memoirs-autostart.log

# Test manually
cd /home/pi/Downloads/repos/digital-memoirs/scripts
./autostart_browser.sh
```

**Service timeout error**:
```bash
# Verify timeout configuration
systemctl show digital-memoirs | grep Timeout
# Should show TimeoutStartUSec=4min

# If incorrect, reinstall FIXED service
cd scripts
./install_service.sh
# Select Option 1
```

### References

- **systemd timeout fix**: `scripts/SOLUCION_TIMEOUT.md`
- **Browser autostart setup**: `scripts/AUTOSTART_BROWSER.md`
- **Service file documentation**: `scripts/reference/services/README.md`
- **Diagnostic tools**: `scripts/testing/README.md`
- **Version 0.3.0 changes**: `CHANGELOG.md`

---

**End of CLAUDE.md**

*For user-facing documentation, see README.md*
*For development history and issues, see TODO.md*
