# Changelog - Digital Memoirs

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [Unreleased]

### En Testing
- Captive Portal HTTP 302 Redirect Fix - Testing programado para 25/10/2025 12:00 PM

---

## [0.2.0] - 2025-10-25

### 🔧 Fixed - CRÍTICO

#### Android Captive Portal HTTP 302 Redirect
- **Problema**: Android CNA (Captive Network Assistant) se cerraba inmediatamente al conectar al WiFi
- **Solución**: Cambio de `HTTP 200 OK` → `HTTP 302 Redirect` en endpoints de captive portal
- **Endpoints modificados**:
  - `/hotspot-detect.html` - iOS
  - `/generate_204` - Android
  - `/connecttest.txt` - Windows
- **Cambio de código**: `render_template('upload.html')` → `redirect(url_for('upload_page'))`
- **Resultado esperado**: Android mantiene CNA abierto automáticamente sin requerir "USE AS IS"
- **Archivos modificados**: `app.py:398-423`

### 📝 Changed
- Actualizada documentación en `TODO.md` con nueva sección "FIX IMPLEMENTADO"
- Actualizada documentación técnica en `CLAUDE.md` con estrategia HTTP 302
- Creado `CHANGELOG.md` para tracking de cambios del proyecto

---

## [0.1.5] - 2025-10-24

### ⚙️ Added - Configuración Captive Portal

#### Implementación Captive Portal WiFi
- **dnsmasq**: Configurado DNS hijacking para dominios de conectividad
  - `captive.apple.com` → `10.0.17.1`
  - `connectivitycheck.gstatic.com` → `10.0.17.1`
  - Wildcards: `*.google.com`, `*.gstatic.com`
- **iptables**: Redirección de tráfico HTTP y DNS
  - HTTP puerto 80 → Flask puerto 5000
  - DNS puerto 53 → dnsmasq
  - Reglas persistentes en `/etc/iptables/rules.v4`
- **Flask endpoints**: Agregados endpoints de detección captive portal
  - iOS: `/hotspot-detect.html`, `/library/test/success.html`
  - Android: `/generate_204`, `/gen_204`
  - Windows: `/connecttest.txt`, `/ncsi.txt`

### 📝 Changed
- Documentación completa en `TODO.md` con comandos de configuración
- Backup de configuraciones anteriores guardados

### ⚠️ Known Issues
- Android requiere presionar "USE AS IS" manualmente (resuelto en v0.2.0)

---

## [0.1.4] - 2025-10-21

### 🔧 Fixed

#### Camera Functionality - getUserMedia API
- **Status**: Feature deshabilitada (no es un bug)
- **Problema**: Camera API bloqueada por navegadores en contexto HTTP insecure
- **Solución**: Botón de cámara deshabilitado con mensaje informativo
- **Archivos modificados**:
  - `templates/upload.html:278-304` - CSS disabled state
  - `templates/upload.html:671-675` - Disabled button markup
  - `templates/upload.html:741-794` - getUserMedia polyfill
  - `templates/upload.html:1235-1244` - Error message handler

#### Widget Orientation Fix
- **Problema**: Status widgets horizontales mientras slideshow rotado 90°
- **Solución**: Aplicado `transform: rotate(90deg)` a ambos widgets
  - Left widget: `translateY(-100%)`
  - Right widget: `translateX(100%)`
- **Archivos modificados**:
  - `templates/display.html:111-116` - Header widget
  - `templates/display.html:153-158` - Photo counter

### 📝 Added
- `CLAUDE.md` - Documentación técnica completa del proyecto
- Polyfill completo para detección de getUserMedia APIs

---

## [0.1.3] - 2025-10-19

### 🔧 Fixed

#### Template Mismatch Bug
- **Problema**: Botón de cámara no ejecutaba ninguna acción
- **Causa raíz**: `app.py` referenciaba archivos inexistentes
  - `upload_fixed.html`, `display_fixed.html`, `qr_fixed.html`
- **Solución**: Corregidos nombres a archivos reales
  - `upload.html`, `display.html`, `qr.html`
- **Archivos modificados**: `app.py:162, 176, 185`

---

## [0.1.2] - 2025-10-17

### 🔧 Fixed - Bugs Críticos de Performance y UX

#### CSS Container Misalignment
- **Problema**: Slideshow no se centraba correctamente en display
- **Solución**:
  - Cambio de `position: relative` → `position: fixed`
  - Reemplazo de margins por `transform: translate(-50%, -50%)`
- **Performance**: Simplificado gradiente de fondo para evitar lag en Firefox
- **Archivos modificados**: `templates/display.html:179-196`

#### Infinite Camera Loop
- **Problema**: Bucle infinito al abrir/cerrar cámara y luego abrir galería
- **Solución**:
  - Agregado flag `isCameraOpen` para state management
  - Implementado `cameraCloseTimeout` con cleanup
  - Función `closeCamera()` con limpieza completa de streams
- **Archivos modificados**: `templates/upload.html:712, 869-885`

#### Bulk Upload Crashes (>800 images)
- **Problema**: Falla al cargar más de 800 imágenes simultáneas
- **Solución**:
  - Implementado `BATCH_UPLOAD_LIMIT = 800`
  - `ThreadPoolExecutor` para procesamiento concurrente (8 workers)
  - Timeout de 30 segundos por archivo
  - Validación previa con advertencia al usuario
- **Archivos modificados**: `app.py:25, 199-204, 237-258`

### ⚡ Performance

#### Optimizaciones de Renderizado
- Reducido particle count de 20 → 15
- Agregado `will-change: auto` y `backface-visibility: hidden`
- GPU acceleration con `transform-style: preserve-3d`
- `@media (prefers-reduced-motion: reduce)` para accesibilidad

### 🎨 UI/UX

#### Dark Theme Implementation
- Fuentes monoespaciadas: `'Fira Code', 'Consolas', 'Monaco', monospace`
- Paleta de colores oscuros con variables CSS
- Efectos glassmorphism y gradientes modernos
- Mejor contraste y jerarquía visual

### 📝 Added
- Endpoint `/api/status` para health checks
- Soporte HEIC/HEIF para fotos de iPhone
- Error handlers HTTP (413, 500)
- Logging mejorado con niveles INFO/ERROR

---

## [0.1.1] - 2025-10-15

### 🔧 Fixed

#### Duplicate Browser Tab Opening
- **Problema**: Flask abría 2 tabs del navegador al iniciar
- **Causa raíz**: `debug=True` causaba que reloader lanzara proceso doble
- **Solución**: Cambio a `debug=False`
- **Archivos modificados**: `app.py:508`

#### Raspberry Pi Access Point Stability
- **Problema**: Conexión inestable en subnet `192.168.10.0/24`
- **Solución**: Migración a subnet `10.0.17.0/24`
- **Nueva configuración**:
  - Gateway: `10.0.17.1`
  - DHCP range: `10.0.17.2 - 10.0.17.254`
  - Subnet mask: `255.255.255.0` (/24)

### 📝 Changed
- Actualizada configuración hostapd y dnsmasq
- Documentación de red en README.md

---

## [0.1.0] - 2025-10-01

### 🎉 Initial Release

#### Core Features
- **QR Code Generation**: Auto-genera QR con IP local para WiFi connection
- **Photo Upload**: Multi-file upload con soporte de galería y cámara
- **Real-time Slideshow**: Auto-refresh cada 2 segundos con rotación 90°
- **Batch Processing**: ThreadPoolExecutor para hasta 800 imágenes por batch
- **UUID File Naming**: Prevención de conflictos de nombres
- **Dark Theme UI**: Glassmorphism design con Fira Code font

#### Technical Stack
- **Framework**: Flask 3.1.2
- **Python**: >=3.11
- **Dependencies**:
  - qrcode 8.2 - QR generation
  - Pillow 11.3.0 - Image processing
  - watchdog 6.0.0 - File system monitoring
  - netifaces 0.11.0 - Network info

#### File Structure
```
digital-memoirs/
├── app.py                 # Flask application (500+ lines)
├── templates/
│   ├── display.html       # Slideshow (680 lines)
│   ├── qr.html            # QR display (669 lines)
│   └── upload.html        # Upload interface (1117 lines)
├── static/
│   └── qr_code.png        # Auto-generated QR
└── uploads/               # User photos (UUID-named)
```

#### API Endpoints
- `GET /` - Main display
- `GET /qr` - QR code page
- `GET /upload` - Upload form
- `POST /upload` - File upload handler
- `GET /api/images` - Current image list
- `GET /api/next_image` - Slideshow next image
- `GET /api/stats` - Application statistics
- `GET /uploads/<filename>` - Serve uploaded files

#### Configuration
- Max upload size: 500MB
- Allowed extensions: png, jpg, jpeg, gif, webp, heic, heif
- Port: 5000
- Host: 0.0.0.0 (all interfaces)

---

## Notas de Versiones

### Sistema de Versionado

Este proyecto usa [Semantic Versioning](https://semver.org/lang/es/):
- **MAJOR version** (X.0.0): Cambios incompatibles de API
- **MINOR version** (0.X.0): Funcionalidad nueva compatible hacia atrás
- **PATCH version** (0.0.X): Bug fixes compatibles hacia atrás

### Categorías de Cambios

- **Added**: Nuevas funcionalidades
- **Changed**: Cambios en funcionalidad existente
- **Deprecated**: Funcionalidad que será removida
- **Removed**: Funcionalidad removida
- **Fixed**: Bug fixes
- **Security**: Parches de seguridad

---

**Última actualización**: 2025-10-25 07:00 AM
**Versión actual**: 0.2.0 (en testing)
**Próximo evento piloto**: Sábado 25/10/2025 (tarde)
